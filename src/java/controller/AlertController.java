package controller;

import dao.AlertDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Alert;
import model.AppUser;
import service.AppDataService;

@WebServlet(name = "AlertController", urlPatterns = {"/alerts"})
public class AlertController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int MAX_PAGE_SIZE = 100;

    private final AlertDAO alertDAO = new AlertDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String statusParam = request.getParameter("status");
        Boolean isResolved = Boolean.FALSE; // default view: open alerts
        if (statusParam != null && !statusParam.isEmpty()) {
            if (statusParam.equals("1")) {
                isResolved = Boolean.TRUE;
            } else if (statusParam.equals("all")) {
                isResolved = null;
            }
        }

        int size = parsePositive(request.getParameter("size"), DEFAULT_PAGE_SIZE);
        size = Math.min(size, MAX_PAGE_SIZE);
        int page = parsePositive(request.getParameter("page"), 1);

        int totalItems = alertDAO.countAlerts(isResolved);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) size));
        if (page > totalPages) {
            page = totalPages;
        }

        List<Alert> listAlerts = alertDAO.getAlerts(isResolved, page, size);
        request.setAttribute("listAlerts", listAlerts);
        request.setAttribute("pagedAlertsJson", new AppDataService().alertsJson(listAlerts));
        request.setAttribute("currentStatus", statusParam == null || statusParam.isEmpty() ? "0" : statusParam);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", size);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/alert.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        AppUser loginUser = (AppUser) session.getAttribute("LOGIN_USER");

        if (loginUser == null) {
            if (ApiSupport.isAjax(request)) {
                ApiSupport.error(response, HttpServletResponse.SC_UNAUTHORIZED, "Please sign in.");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return;
        }

        // Defense in depth (AuthFilter already enforces this): VIEWER is strictly read-only.
        String role = loginUser.getRoleName();
        boolean canHandle = "ADMIN".equalsIgnoreCase(role) || "MANAGER".equalsIgnoreCase(role)
                || "TECHNICIAN".equalsIgnoreCase(role) || "STAFF".equalsIgnoreCase(role);
        if (!canHandle) {
            String msg = "Your account is read-only and cannot resolve alerts.";
            if (ApiSupport.isAjax(request)) {
                ApiSupport.error(response, HttpServletResponse.SC_FORBIDDEN, msg);
            } else {
                session.setAttribute("ERROR_MSG", msg);
                response.sendRedirect(request.getContextPath() + "/alerts");
            }
            return;
        }

        Integer userId = loginUser.getUserId();
        String action = request.getParameter("action");
        String actionTaken = trimToNull(request.getParameter("actionTaken"));
        if (actionTaken != null && actionTaken.length() > 255) {
            actionTaken = actionTaken.substring(0, 255);
        }

        if ("resolveAll".equals(action)) {
            alertDAO.resolveAllAlerts(userId);
            if (ApiSupport.isAjax(request)) {
                ApiSupport.ok(response, "All alerts resolved.");
            } else {
                session.setAttribute("SUCCESS_MSG", "All alerts resolved.");
                response.sendRedirect(request.getContextPath() + "/alerts");
            }
            return;
        }

        if ("resolve".equals(action) || "dismiss".equals(action)) {
            try {
                String rawId = request.getParameter("alertId");
                if (rawId == null || rawId.trim().isEmpty()) {
                    throw new IllegalArgumentException("Missing alert ID.");
                }
                rawId = rawId.trim();
                if (rawId.startsWith("AL-")) {
                    rawId = rawId.substring(3);
                }
                int alertId = Integer.parseInt(rawId);
                if (alertId <= 0) {
                    throw new IllegalArgumentException("Invalid alert ID.");
                }
                boolean ok = alertDAO.resolveAlert(alertId, userId,
                        actionTaken != null ? actionTaken : ("dismiss".equals(action) ? "Dismissed" : "Resolved"));

                if (ApiSupport.isAjax(request)) {
                    if (ok) {
                        ApiSupport.ok(response, "Alert resolved.");
                    } else {
                        ApiSupport.error(response, HttpServletResponse.SC_NOT_FOUND, "Alert not found or already resolved.");
                    }
                } else {
                    session.setAttribute(ok ? "SUCCESS_MSG" : "ERROR_MSG",
                            ok ? "Alert resolved." : "Alert not found or already resolved.");
                    response.sendRedirect(request.getContextPath() + "/alerts?status=0");
                }
            } catch (IllegalArgumentException e) {
                if (ApiSupport.isAjax(request)) {
                    ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid alert ID.");
                } else {
                    session.setAttribute("ERROR_MSG", "Invalid alert ID.");
                    response.sendRedirect(request.getContextPath() + "/alerts");
                }
            }
            return;
        }

        // Unknown action: PRG back to the list
        response.sendRedirect(request.getContextPath() + "/alerts");
    }

    private static int parsePositive(String raw, int fallback) {
        if (raw == null) {
            return fallback;
        }
        try {
            int v = Integer.parseInt(raw.trim());
            return v > 0 ? v : fallback;
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private static String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}