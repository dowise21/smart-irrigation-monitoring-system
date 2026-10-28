package controller;

import dao.PotDAO;
import dao.SensorDataDAO;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Pot;
import model.SensorData;

@WebServlet(name = "SensorController", urlPatterns = {"/sensor-data"})
public class SensorController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SensorController.class.getName());
    private static final int PAGE_SIZE = 10;
    private final SensorDataDAO sensorDAO = new SensorDataDAO();
    private final PotDAO potDAO = new PotDAO();

    /** Web view: server-side paginated + date-filtered SensorReading list (OFFSET/FETCH in the DAO). */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int potId = parseInt(request.getParameter("potId"), 0);
        int page = Math.max(1, parseInt(request.getParameter("page"), 1));
        String fromDate = cleanDate(request.getParameter("fromDate"));
        String toDate = cleanDate(request.getParameter("toDate"));

        int totalItems = sensorDAO.countData(potId, fromDate, toDate);
        int totalPages = Math.max(1, (int) Math.ceil(totalItems / (double) PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<SensorData> listData = sensorDAO.getPaginatedData(potId, fromDate, toDate, page, PAGE_SIZE);
        List<Pot> listPot = potDAO.getAll();

        request.setAttribute("listData", listData);
        request.setAttribute("listPot", listPot);
        request.setAttribute("selectedPotId", potId);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);

        request.getRequestDispatcher("/sensors.jsp").forward(request, response);
    }

    /** IoT device (ESP32/ESP8266) or simulator pushes a reading. Supports both JSON and form parameters. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        SensorApiServlet.handleTelemetryPost(request, response, sensorDAO, false);
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

    private static Double optionalDouble(String raw) {
        return raw == null || raw.trim().isEmpty() ? null : Double.valueOf(raw.trim());
    }

    private static Integer optionalInt(String raw) {
        return raw == null || raw.trim().isEmpty() ? null : Integer.valueOf(raw.trim());
    }

    /** Accepts only yyyy-MM-dd; anything else is ignored. */
    private static String cleanDate(String raw) {
        if (raw == null) {
            return null;
        }
        String t = raw.trim();
        return t.matches("\\d{4}-\\d{2}-\\d{2}") ? t : null;
    }
}