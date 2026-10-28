package controller;

import filter.AuthFilter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.AppUser;
import service.AppDataService;
import util.AppConfig;
import util.Json;

/**
 * Serves /app-data.js: a tiny script every page loads BEFORE its own scripts.
 * It publishes the logged-in user, role permissions and the database snapshot
 * (areas, zones, plants, alerts, irrigation history, schedules) as window.SI_* globals.
 */
@WebServlet(name = "AppDataServlet", urlPatterns = {"/app-data.js"})
public class AppDataServlet extends HttpServlet {

    private final AppDataService data = new AppDataService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        AppUser user = session == null ? null : (AppUser) session.getAttribute("LOGIN_USER");
        if (user == null) { // the filter already blocks this; defensive
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        response.setContentType("application/javascript;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        String role = user.getRoleName() == null ? "" : user.getRoleName().toUpperCase();
        String permsJson = array(AuthFilter.effectivePermissions(user));
        String success = popFlash(session, "SUCCESS_MSG");
        String error = popFlash(session, "ERROR_MSG");

        try (PrintWriter out = response.getWriter()) {
            out.println("window.SI_CTX = " + Json.quote(request.getContextPath()) + ";");
            out.println("window.SI_USER = {\"id\":" + user.getUserId()
                    + ",\"username\":" + Json.quote(user.getUsername())
                    + ",\"name\":" + Json.quote(user.getFullName())
                    + ",\"role\":" + Json.quote(role)
                    + ",\"permissions\":" + permsJson + "};");
            out.println("window.SI_ACCESS = {\"role\":" + Json.quote(role)
                    + ",\"permissions\":" + permsJson
                    + ",\"nav\":" + array(AuthFilter.navRoutes(role))
                    + ",\"read\":" + array(AuthFilter.allowedRoutes(role))
                    + ",\"write\":" + array(AuthFilter.writableRoutes(role)) + "};");
            if (success != null || error != null) {
                out.println("window.SI_FLASH = {\"success\":" + (success == null ? "null" : Json.quote(success))
                        + ",\"error\":" + (error == null ? "null" : Json.quote(error)) + "};");
            } else {
                out.println("window.SI_FLASH = window.SI_FLASH || {\"success\":null,\"error\":null};");
            }
            out.println("window.SI_DATA = {");
            out.println("  \"config\": {\"flowLitersPerMinute\":" + Json.number(AppConfig.PUMP_FLOW_LITERS_PER_MINUTE)
                    + ",\"dailyQuotaLiters\":" + Json.number(AppConfig.DAILY_QUOTA_LITERS) + "},");
            out.println("  \"areas\": " + data.areasJson() + ",");
            out.println("  \"zones\": " + data.zonesJson() + ",");
            out.println("  \"plants\": " + data.plantsJson() + ",");
            out.println("  \"alerts\": " + data.alertsJson() + ",");
            out.println("  \"history\": " + data.historyJson() + ",");
            out.println("  \"schedules\": " + data.schedulesJson());
            out.println("};");
        }
    }

    /**
     * Renders window.SI_CTX, window.SI_USER, window.SI_ACCESS, and window.SI_FLASH inline
     * inside the JSP header so RBAC state is available at 0ms before any DOM element paints.
     */
    public static String renderAccessScript(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        AppUser user = session == null ? null : (AppUser) session.getAttribute("LOGIN_USER");
        if (user == null) {
            return "";
        }
        String role = user.getRoleName() == null ? "" : user.getRoleName().toUpperCase();
        String permsJson = array(AuthFilter.effectivePermissions(user));
        String success = popFlash(session, "SUCCESS_MSG");
        String error = popFlash(session, "ERROR_MSG");

        StringBuilder sb = new StringBuilder();
        sb.append("window.SI_CTX=").append(Json.quote(request.getContextPath())).append(';');
        sb.append("window.SI_USER={\"id\":").append(user.getUserId())
                .append(",\"username\":").append(Json.quote(user.getUsername()))
                .append(",\"name\":").append(Json.quote(user.getFullName()))
                .append(",\"role\":").append(Json.quote(role))
                .append(",\"permissions\":").append(permsJson).append("};");
        sb.append("window.SI_ACCESS={\"role\":").append(Json.quote(role))
                .append(",\"permissions\":").append(permsJson)
                .append(",\"nav\":").append(array(AuthFilter.navRoutes(role)))
                .append(",\"read\":").append(array(AuthFilter.allowedRoutes(role)))
                .append(",\"write\":").append(array(AuthFilter.writableRoutes(role))).append("};");
        sb.append("window.SI_FLASH={\"success\":").append(success == null ? "null" : Json.quote(success))
                .append(",\"error\":").append(error == null ? "null" : Json.quote(error)).append("};");
        return sb.toString();
    }

    private static String popFlash(HttpSession session, String key) {
        Object value = session.getAttribute(key);
        session.removeAttribute(key);
        return value == null ? null : value.toString();
    }

    private static String array(java.util.Set<String> routes) {
        List<String> sorted = new ArrayList<>(routes);
        Collections.sort(sorted);
        StringBuilder sb = new StringBuilder("[");
        for (String route : sorted) {
            if (sb.length() > 1) {
                sb.append(',');
            }
            sb.append(Json.quote(route));
        }
        return sb.append(']').toString();
    }
}
