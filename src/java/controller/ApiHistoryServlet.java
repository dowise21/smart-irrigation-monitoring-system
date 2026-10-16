package controller;

import dao.PotDAO;
import dao.WateringSessionDAO;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Pot;
import service.AppDataService;
import util.Json;

/**
 * GET  /api/history  -> irrigation runs (same shape as window.SI_DATA.history)
 * POST /api/history  -> records a finished irrigation run reported by the irrigation page
 *                       params: potId, minutes, liters, source, status[, excessLiters]
 */
@WebServlet(name = "ApiHistoryServlet", urlPatterns = {"/api/history"})
public class ApiHistoryServlet extends HttpServlet {

    private static final Set<String> SOURCES = new HashSet<>(Arrays.asList("MANUAL", "SCHEDULED", "AUTO"));
    private static final Set<String> STATUSES = new HashSet<>(Arrays.asList("COMPLETED", "STOPPED", "FAILED"));

    private final AppDataService data = new AppDataService();
    private final PotDAO potDAO = new PotDAO();
    private final WateringSessionDAO sessionDAO = new WateringSessionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ApiSupport.write(response, HttpServletResponse.SC_OK, data.historyJson());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer potId = ApiSupport.intParam(request, "potId");
        Double minutes = ApiSupport.doubleParam(request, "minutes");
        Double liters = ApiSupport.doubleParam(request, "liters");
        if (potId == null || minutes == null || liters == null || minutes < 0 || liters < 0) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "potId, minutes and liters are required numbers.");
            return;
        }
        Pot pot = potDAO.findById(potId);
        if (pot == null || !pot.isStatus()) {
            ApiSupport.error(response, HttpServletResponse.SC_NOT_FOUND, "Irrigation zone not found or inactive.");
            return;
        }

        String source = upper(request.getParameter("source"), "MANUAL");
        String status = upper(request.getParameter("status"), "COMPLETED");
        if (!SOURCES.contains(source) || !STATUSES.contains(status)) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Unknown source or status.");
            return;
        }

        Double retain = null;
        Double excess = ApiSupport.doubleParam(request, "excessLiters");
        if (excess != null && liters > 0) {
            retain = 1 - Math.min(excess, liters) / liters;
        }

        int seconds = (int) Math.round(minutes * 60);
        int sessionId = sessionDAO.insertSession(potId, seconds, liters * 1000, source, status, retain);
        if (sessionId == 0) {
            ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not save the irrigation run.");
            return;
        }
        ApiSupport.write(response, HttpServletResponse.SC_OK,
                "{\"ok\":true,\"message\":" + Json.quote("Irrigation run saved.")
                + ",\"id\":" + Json.quote("S-" + sessionId) + ",\"dbId\":" + sessionId + "}");
    }

    private static String upper(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim().toUpperCase(Locale.ROOT);
    }
}

