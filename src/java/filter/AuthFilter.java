package filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.AppUser;
import util.Json;

/**
 * Single entry point for authentication and strict role/permission-based access control (RBAC).
 *
 * Enforces both the 5 system roles (ADMIN, MANAGER, TECHNICIAN, STAFF, VIEWER) and the
 * 8 granular permissions stored in RolePermission / Permission tables:
 *   USER_MANAGE, GARDEN_MANAGE, SCHEDULE_MANAGE, IOT_DEVICE_MANAGE,
 *   MANUAL_WATER_EXECUTE, ALERT_HANDLE, AI_PREDICT_VIEW, REPORT_EXPORT.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    public static final String ADMIN = "ADMIN";
    public static final String MANAGER = "MANAGER";
    public static final String TECHNICIAN = "TECHNICIAN";
    public static final String STAFF = "STAFF";
    public static final String VIEWER = "VIEWER";

    // Granular permissions from Permission table
    public static final String PERM_USER_MANAGE = "USER_MANAGE";
    public static final String PERM_GARDEN_MANAGE = "GARDEN_MANAGE";
    public static final String PERM_SCHEDULE_MANAGE = "SCHEDULE_MANAGE";
    public static final String PERM_IOT_DEVICE_MANAGE = "IOT_DEVICE_MANAGE";
    public static final String PERM_MANUAL_WATER_EXECUTE = "MANUAL_WATER_EXECUTE";
    public static final String PERM_ALERT_HANDLE = "ALERT_HANDLE";
    public static final String PERM_AI_PREDICT_VIEW = "AI_PREDICT_VIEW";
    public static final String PERM_REPORT_EXPORT = "REPORT_EXPORT";

    /** Routes that need no login. */
    private static final Set<String> PUBLIC_EXACT = new HashSet<>(Arrays.asList(
            "", "/", "/index.html", "/index.jsp", "/login", "/logout", "/register", "/error.jsp"));
    private static final String[] PUBLIC_PREFIX = {"/css/", "/js/", "/images/"};

    /** Action parameter values that mutate state and must be treated as WRITE even on GET. */
    private static final Set<String> MUTATING_ACTIONS = new HashSet<>(Arrays.asList(
            "add", "insert", "new", "edit", "update", "delete", "toggle",
            "water", "resolve", "resolveall", "dismiss", "calibrate",
            "create", "remove", "save", "start", "stop", "confirm", "acknowledge"));

    /** Old static page URLs and the servlet route that must be used instead. */
    private static final Map<String, String> PAGE_TO_ROUTE = new HashMap<>();

    /** route -> roles allowed to READ (GET). */
    private static final Map<String, Set<String>> READ = new LinkedHashMap<>();
    /** route -> roles allowed to WRITE (POST/mutating action). */
    private static final Map<String, Set<String>> WRITE = new HashMap<>();
    /** Default permissions per role (matches 02_SmartIrrigation_SampleData.sql). */
    private static final Map<String, Set<String>> DEFAULT_ROLE_PERMS = new HashMap<>();

    static {
        PAGE_TO_ROUTE.put("/dashboard.jsp", "/dashboard");
        PAGE_TO_ROUTE.put("/sensors.jsp", "/sensor-data");
        PAGE_TO_ROUTE.put("/sensor-data.jsp", "/sensor-data");
        PAGE_TO_ROUTE.put("/wateringManagement.jsp", "/manual-water");
        PAGE_TO_ROUTE.put("/manual-water.jsp", "/manual-water");
        PAGE_TO_ROUTE.put("/plantManagement.jsp", "/plants");
        PAGE_TO_ROUTE.put("/plants.jsp", "/plants");
        PAGE_TO_ROUTE.put("/alert.jsp", "/alerts");
        PAGE_TO_ROUTE.put("/alerts.jsp", "/alerts");
        PAGE_TO_ROUTE.put("/wateringHistory.jsp", "/history");
        PAGE_TO_ROUTE.put("/history.jsp", "/history");
        PAGE_TO_ROUTE.put("/reports.jsp", "/reports");
        PAGE_TO_ROUTE.put("/pump-calibration.jsp", "/pump-calibration");
        PAGE_TO_ROUTE.put("/schedules.jsp", "/schedules");
        PAGE_TO_ROUTE.put("/pots.jsp", "/pots");

        // Default permissions per role - mirror of the checklist matrix (authoritative on the server)
        DEFAULT_ROLE_PERMS.put(ADMIN, new HashSet<>(Arrays.asList(
                PERM_USER_MANAGE, PERM_GARDEN_MANAGE, PERM_SCHEDULE_MANAGE, PERM_IOT_DEVICE_MANAGE,
                PERM_MANUAL_WATER_EXECUTE, PERM_ALERT_HANDLE, PERM_AI_PREDICT_VIEW, PERM_REPORT_EXPORT)));
        DEFAULT_ROLE_PERMS.put(MANAGER, new HashSet<>(Arrays.asList(
                PERM_GARDEN_MANAGE, PERM_SCHEDULE_MANAGE, PERM_ALERT_HANDLE,
                PERM_AI_PREDICT_VIEW, PERM_REPORT_EXPORT)));
        DEFAULT_ROLE_PERMS.put(TECHNICIAN, new HashSet<>(Arrays.asList(
                PERM_IOT_DEVICE_MANAGE, PERM_MANUAL_WATER_EXECUTE, PERM_ALERT_HANDLE,
                PERM_AI_PREDICT_VIEW, PERM_REPORT_EXPORT)));
        DEFAULT_ROLE_PERMS.put(STAFF, new HashSet<>(Arrays.asList(
                PERM_MANUAL_WATER_EXECUTE, PERM_ALERT_HANDLE)));
        DEFAULT_ROLE_PERMS.put(VIEWER, new HashSet<>(Arrays.asList(
                PERM_AI_PREDICT_VIEW, PERM_REPORT_EXPORT)));

        // READ access by route (Strict server-side URL protection matrix)
        // 1. Dashboard & Core API: All authenticated users
        read("/dashboard", ADMIN, MANAGER, TECHNICIAN, STAFF, VIEWER);
        read("/app-data.js", ADMIN, MANAGER, TECHNICIAN, STAFF, VIEWER);

        // 2. Garden domain: Plants & Pots -> strictly ADMIN and MANAGER
        read("/plants", ADMIN, MANAGER);
        read("/pots", ADMIN, MANAGER);
        read("/api/plants", ADMIN, MANAGER, TECHNICIAN, STAFF); // Action checked in isActionAllowed

        // 3. Schedules domain -> strictly ADMIN and MANAGER
        read("/schedules", ADMIN, MANAGER);
        read("/api/schedules", ADMIN, MANAGER);

        // 4. IoT / Sensors domain -> /sensor-data strictly ADMIN and TECHNICIAN; /api/sensors feeds live dashboard
        read("/sensor-data", ADMIN, TECHNICIAN);
        read("/api/sensors", ADMIN, MANAGER, TECHNICIAN, STAFF, VIEWER);
        read("/api/sensor/readings", ADMIN, TECHNICIAN);

        // 5. Pump Calibration domain -> strictly ADMIN and TECHNICIAN
        read("/pump-calibration", ADMIN, TECHNICIAN);

        // 6. Irrigation / Watering domain -> strictly ADMIN, TECHNICIAN, STAFF
        read("/manual-water", ADMIN, TECHNICIAN, STAFF);
        read("/api/watering/command", ADMIN, TECHNICIAN, STAFF);

        // 7. Alerts domain -> ADMIN, MANAGER, TECHNICIAN, STAFF (VIEWER has NO access)
        read("/alerts", ADMIN, MANAGER, TECHNICIAN, STAFF);

        // 8. History / Logs domain -> ADMIN, MANAGER, TECHNICIAN, STAFF (VIEWER has NO access)
        read("/history", ADMIN, MANAGER, TECHNICIAN, STAFF);
        read("/api/history", ADMIN, MANAGER, TECHNICIAN, STAFF);

        // 9. Reports & Export domain -> strictly ADMIN and MANAGER
        read("/reports", ADMIN, MANAGER);
        read("/export-history", ADMIN, MANAGER);

        // 10. AI Prediction -> strictly ADMIN and MANAGER
        read("/predict", ADMIN, MANAGER);

        // WRITE access by route (POST / mutating action) - exact checklist matrix
        // WateringSession: ADMIN, TECHNICIAN (CRU), STAFF (CRU)
        write("/manual-water", ADMIN, TECHNICIAN, STAFF);
        write("/api/watering/command", ADMIN, TECHNICIAN, STAFF);
        write("/api/history", ADMIN, TECHNICIAN, STAFF);
        write("/history", ADMIN, TECHNICIAN, STAFF);
        // Plant / Pot / WateringSchedule: ADMIN, MANAGER (CRUD)
        write("/plants", ADMIN, MANAGER);
        write("/pots", ADMIN, MANAGER);
        write("/schedules", ADMIN, MANAGER);
        write("/api/schedules", ADMIN, MANAGER);
        // /api/plants: action-checked in isActionAllowed (water = session writers, others = ADMIN/MANAGER)
        write("/api/plants", ADMIN, MANAGER, TECHNICIAN, STAFF);
        // Alert: MANAGER (RU), TECHNICIAN (CRU), STAFF (RU), ADMIN (full)
        write("/alerts", ADMIN, MANAGER, TECHNICIAN, STAFF);
        // Sensor / SensorReading / PumpCalibration: ADMIN, TECHNICIAN (CRUD)
        write("/sensor-data", ADMIN, TECHNICIAN);
        write("/api/sensors", ADMIN, TECHNICIAN);
        write("/api/sensor/readings", ADMIN, TECHNICIAN);
        write("/pump-calibration", ADMIN, TECHNICIAN);
        // Everything else: ADMIN only (and Manager for export)
        write("/dashboard", ADMIN);
        write("/app-data.js", ADMIN);
        write("/predict", ADMIN, MANAGER);
        write("/reports", ADMIN, MANAGER);
        write("/export-history", ADMIN, MANAGER);
    }

    private static void read(String route, String... roles) {
        READ.put(route, new HashSet<>(Arrays.asList(roles)));
    }

    private static void write(String route, String... roles) {
        WRITE.put(route, new HashSet<>(Arrays.asList(roles)));
    }

    /** Effective permissions for a user: the server-side role matrix is authoritative. */
    public static Set<String> effectivePermissions(AppUser user) {
        if (user == null) {
            return Collections.emptySet();
        }
        String role = user.getRoleName() == null ? "" : user.getRoleName().trim().toUpperCase(Locale.ROOT);
        Set<String> defaults = DEFAULT_ROLE_PERMS.get(role);
        return defaults != null ? defaults : Collections.<String>emptySet();
    }

    /** Routes displayed in the top navbar for the given role. */
    public static Set<String> navRoutes(String role) {
        String norm = role == null ? "" : role.trim().toUpperCase(Locale.ROOT);
        switch (norm) {
            case ADMIN:
                // Full navigation: all 8 management modules
                return new HashSet<>(Arrays.asList(
                        "/dashboard", "/sensor-data", "/manual-water", "/plants",
                        "/alerts", "/history", "/reports", "/pump-calibration"));
            case MANAGER:
                // Focus: Garden & Schedule Operations + Analytics
                return new HashSet<>(Arrays.asList(
                        "/dashboard", "/plants", "/alerts", "/history", "/reports"));
            case TECHNICIAN:
                // Focus: IoT Hardware, Calibration, Pump Logs & Manual Testing
                return new HashSet<>(Arrays.asList(
                        "/dashboard", "/sensor-data", "/manual-water", "/alerts", "/history", "/pump-calibration"));
            case STAFF:
                // Focus: Daily Field Watering & Alert Confirmations
                return new HashSet<>(Arrays.asList(
                        "/dashboard", "/manual-water", "/alerts", "/history"));
            case VIEWER:
                // Overview only: Read-only Dashboard
                return new HashSet<>(Collections.singletonList("/dashboard"));
            default:
                return new HashSet<>(Collections.singletonList("/dashboard"));
        }
    }

    /** Routes the given role may open (used by the navigation on the front end). */
    public static Set<String> allowedRoutes(String role) {
        String norm = role == null ? "" : role.trim().toUpperCase(Locale.ROOT);
        Set<String> out = new HashSet<>();
        for (Map.Entry<String, Set<String>> entry : READ.entrySet()) {
            if (ADMIN.equals(norm) || entry.getValue().contains(norm)) {
                out.add(entry.getKey());
            }
        }
        return out;
    }

    /** Routes the given role may mutate (POST / action). */
    public static Set<String> writableRoutes(String role) {
        String norm = role == null ? "" : role.trim().toUpperCase(Locale.ROOT);
        if (VIEWER.equals(norm) || norm.isEmpty()) {
            return Collections.emptySet();
        }
        Set<String> out = new HashSet<>();
        for (Map.Entry<String, Set<String>> entry : WRITE.entrySet()) {
            if (ADMIN.equals(norm) || entry.getValue().contains(norm)) {
                out.add(entry.getKey());
            }
        }
        return out;
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        if (req.getCharacterEncoding() == null) {
            req.setCharacterEncoding("UTF-8");
        }

        String contextPath = req.getContextPath();
        String command = req.getRequestURI().substring(contextPath.length());

        // 1. Public routes & stateless IoT hardware device endpoints (ESP8266/ESP32)
        if (isPublic(command) || isIotDeviceEndpoint(req, command)) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Authentication & Active Status Check
        HttpSession session = req.getSession(false);
        AppUser user = session == null ? null : (AppUser) session.getAttribute("LOGIN_USER");
        if (user == null || !user.isStatus()) {
            if (session != null && user != null && !user.isStatus()) {
                session.invalidate();
            }
            deny(req, res, HttpServletResponse.SC_UNAUTHORIZED, contextPath + "/login", "Please sign in to continue.");
            return;
        }

        // 3. Direct .jsp URLs: validate role permission for known pages before redirecting
        String targetRoute = PAGE_TO_ROUTE.get(command);
        if (targetRoute != null) {
            String role = user.getRoleName() == null ? "" : user.getRoleName().trim().toUpperCase(Locale.ROOT);
            if (!ADMIN.equals(role)) {
                Set<String> targetRoles = READ.get(targetRoute);
                if (targetRoles == null || !targetRoles.contains(role)) {
                    deny(req, res, HttpServletResponse.SC_FORBIDDEN, contextPath + "/dashboard",
                            "Access denied (" + role + "): you do not have permission for this resource.");
                    return;
                }
            }
            res.sendRedirect(contextPath + targetRoute);
            return;
        }
        if (command.toLowerCase(Locale.ROOT).endsWith(".jsp")) {
            deny(req, res, HttpServletResponse.SC_FORBIDDEN, contextPath + "/dashboard",
                    "Access denied: direct JSP access is not permitted.");
            return;
        }

        // 4. Determine whether this request is READ or WRITE (including mutating GET actions)
        String method = req.getMethod() == null ? "GET" : req.getMethod().toUpperCase(Locale.ROOT);
        String action = req.getParameter("action");
        boolean hasMutatingAction = action != null && MUTATING_ACTIONS.contains(action.trim().toLowerCase(Locale.ROOT));
        boolean isRead = ("GET".equals(method) || "HEAD".equals(method)) && !hasMutatingAction;

        // 5. Authorization (server-side role matrix; UI hiding is NOT relied upon)
        String role = user.getRoleName() == null ? "" : user.getRoleName().trim().toUpperCase(Locale.ROOT);
        Set<String> allowedRoles = matchRoles(command, isRead);

        if (!ADMIN.equals(role)) {
            // VIEWER is strictly read-only: block every mutating request outright
            if (VIEWER.equals(role) && !isRead) {
                deny(req, res, HttpServletResponse.SC_FORBIDDEN, contextPath + "/dashboard",
                        "Access denied (VIEWER): read-only accounts cannot modify data.");
                return;
            }
            if (allowedRoles == null || !allowedRoles.contains(role)) {
                deny(req, res, HttpServletResponse.SC_FORBIDDEN, contextPath + "/dashboard",
                        "Access denied (" + role + "): you do not have permission for this resource.");
                return;
            }
            if (!isActionAllowed(command, isRead, action, role)) {
                deny(req, res, HttpServletResponse.SC_FORBIDDEN, contextPath + "/dashboard",
                        "Access denied (" + role + "): this action is not permitted for your role.");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    /**
     * Action-level rules for endpoints that serve several operations on one route.
     * /api/plants: "water" creates a WateringSession (ADMIN/TECHNICIAN/STAFF) while
     * add/edit/delete mutate Plant (ADMIN/MANAGER only).
     */
    private boolean isActionAllowed(String command, boolean isRead, String action, String role) {
        if (isRead) {
            return true;
        }
        String act = action == null ? "" : action.trim().toLowerCase(Locale.ROOT);
        if (command.equals("/api/plants")) {
            if ("water".equals(act)) {
                return TECHNICIAN.equals(role) || STAFF.equals(role);
            }
            return MANAGER.equals(role);
        }
        return true;
    }


    private boolean isPublic(String command) {
        if (PUBLIC_EXACT.contains(command)) {
            return true;
        }
        for (String prefix : PUBLIC_PREFIX) {
            if (command.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Stateless IoT microcontroller endpoints (ESP8266/ESP32):
     *   - POST /api/sensor/readings : pushes telemetry JSON to SensorReading
     *   - GET  /api/watering/command: polls for pending relay/pump commands or reports status=OFF
     *   - POST /api/watering/command: device acks (source=DEVICE)
     */
    private boolean isIotDeviceEndpoint(HttpServletRequest req, String command) {
        String method = req.getMethod() == null ? "GET" : req.getMethod().toUpperCase(Locale.ROOT);
        if (("/api/sensor/readings".equals(command) || "/api/sensors".equals(command)) && "POST".equals(method)) {
            return true;
        }
        if ("/api/watering/command".equals(command)) {
            if ("GET".equals(method)) {
                return true;
            }
            if ("POST".equals(method)) {
                String source = req.getParameter("source");
                String ua = req.getHeader("User-Agent");
                if ("DEVICE".equalsIgnoreCase(source)
                        || (ua != null && (ua.contains("ESP8266") || ua.contains("ESP32") || ua.contains("Arduino")))) {
                    return true;
                }
            }
        }
        return false;
    }

    private Set<String> matchRoles(String command, boolean isRead) {
        for (String route : READ.keySet()) {
            if (command.equals(route) || command.startsWith(route + "/")) {
                if (!isRead && WRITE.containsKey(route)) {
                    return WRITE.get(route);
                }
                return READ.get(route);
            }
        }
        return null; // unknown route: default deny (ADMIN is let through by the caller)
    }

    /** API/AJAX callers get a status code and JSON; browsers get a redirect. */
    private void deny(HttpServletRequest req, HttpServletResponse res, int status, String redirect, String message)
            throws IOException {
        String uri = req.getRequestURI();
        boolean ajax = "fetch".equals(req.getHeader("X-Requested-With"))
                || "XMLHttpRequest".equals(req.getHeader("X-Requested-With"))
                || uri.contains("/api/") || uri.endsWith("/app-data.js");
        if (ajax) {
            res.setStatus(status);
            res.setContentType("application/json;charset=UTF-8");
            res.getWriter().write(Json.result(false, message));
        } else {
            if (status == HttpServletResponse.SC_FORBIDDEN && req.getSession(false) != null) {
                req.getSession(false).setAttribute("ERROR_MSG", message);
            }
            res.sendRedirect(redirect);
        }
    }

    @Override
    public void destroy() {
    }
}