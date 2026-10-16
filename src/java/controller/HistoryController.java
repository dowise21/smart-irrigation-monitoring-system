package controller;

import dao.IrrigationHistoryDAO;
import dao.PotDAO;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.IrrigationHistory;
import model.Pot;

@WebServlet(name = "HistoryController", urlPatterns = {"/history"})
public class HistoryController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(HistoryController.class.getName());
    private static final int PAGE_SIZE = 10;
    private final IrrigationHistoryDAO historyDAO = new IrrigationHistoryDAO();
    private final PotDAO potDAO = new PotDAO();

    /** Web view: server-side paginated WateringSession list filtered by pot, status and date range. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int potId = parseInt(request.getParameter("potId"), 0);
        int page = Math.max(1, parseInt(request.getParameter("page"), 1));
        String status = cleanStatus(request.getParameter("status"));
        String fromDate = cleanDate(request.getParameter("fromDate"));
        String toDate = cleanDate(request.getParameter("toDate"));

        int totalItems = historyDAO.countHistory(potId, status, fromDate, toDate);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<IrrigationHistory> listHistory = historyDAO.getPaginatedHistory(potId, status, fromDate, toDate, page, PAGE_SIZE);
        List<Pot> listPot = potDAO.getAll();

        request.setAttribute("listHistory", listHistory);
        request.setAttribute("listPot", listPot);
        request.setAttribute("selectedPotId", potId);
        request.setAttribute("status", status);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        request.getRequestDispatcher("/wateringHistory.jsp").forward(request, response);
    }

    /** IoT device reports a finished watering session (ADMIN/TECHNICIAN/STAFF session required). */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int potId = Integer.parseInt(request.getParameter("potId").trim());
            Integer duration = Integer.valueOf(request.getParameter("duration").trim());
            Double waterAmount = Double.valueOf(request.getParameter("waterAmount").trim());

            if (potId <= 0) {
                throw new IllegalArgumentException("potId must be positive.");
            }
            if (duration <= 0 || duration > 86400) {
                throw new IllegalArgumentException("duration must be between 1 and 86400 seconds.");
            }
            if (waterAmount.isNaN() || waterAmount <= 0 || waterAmount > 1000) {
                throw new IllegalArgumentException("waterAmount (liters) must be greater than 0 and at most 1000.");
            }

            boolean success = historyDAO.insert(potId, duration, waterAmount);
            if (success) {
                response.getWriter().write("OK");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error while saving watering history.");
            }
        } catch (NullPointerException | IllegalArgumentException ex) {
            LOGGER.log(Level.WARNING, "Rejected watering history: {0}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid history data.");
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error receiving watering history: {0}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not save watering history.");
        }
    }

    private static int parseInt(String raw, int fallback) {
        if (raw == null || raw.trim().isEmpty()) {
            return fallback;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private static String cleanDate(String raw) {
        if (raw == null) {
            return null;
        }
        String t = raw.trim();
        return t.matches("\\d{4}-\\d{2}-\\d{2}") ? t : null;
    }

    private static String cleanStatus(String raw) {
        if (raw == null) {
            return null;
        }
        String t = raw.trim().toUpperCase();
        return t.matches("[A-Z_]{1,20}") ? t : null;
    }
}