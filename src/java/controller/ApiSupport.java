package controller;

import java.io.IOException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.AppUser;
import util.Json;

/** Small helpers shared by the JSON endpoints under /api and by AJAX-aware servlets. */
final class ApiSupport {

    private ApiSupport() {
    }

    /** True when the request comes from the front end's fetch() helper (see js/api.js). */
    static boolean isAjax(HttpServletRequest request) {
        return "fetch".equals(request.getHeader("X-Requested-With"))
                || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"));
    }

    static AppUser user(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (AppUser) session.getAttribute("LOGIN_USER");
    }

    static String role(HttpServletRequest request) {
        AppUser user = user(request);
        return user == null || user.getRoleName() == null ? "" : user.getRoleName().toUpperCase();
    }

    static void write(HttpServletResponse response, int status, String json) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.getWriter().write(json);
    }

    static void ok(HttpServletResponse response, String message) throws IOException {
        write(response, HttpServletResponse.SC_OK, Json.result(true, message));
    }

    static void error(HttpServletResponse response, int status, String message) throws IOException {
        write(response, status, Json.result(false, message));
    }

    static Integer intParam(HttpServletRequest request, String name) {
        try {
            return Integer.valueOf(request.getParameter(name).trim());
        } catch (Exception e) {
            return null;
        }
    }

    static Double doubleParam(HttpServletRequest request, String name) {
        try {
            double value = Double.parseDouble(request.getParameter(name).trim());
            return Double.isNaN(value) || Double.isInfinite(value) ? null : value;
        } catch (Exception e) {
            return null;
        }
    }
}

