package controller;

import dao.SensorDataDAO;
import dao.WateringSessionDAO;
import java.io.IOException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.SensorData;
import service.AppDataService;

@WebServlet(name = "ManualWateringServlet", urlPatterns = {"/manual-water"})
public class ManualWateringServlet extends HttpServlet {

    /** Upper safety bound for one manual watering session (ml). */
    private static final double MAX_VOLUME_ML = 10000;

    private final WateringSessionDAO sessionDAO = new WateringSessionDAO();
    private final SensorDataDAO sensorDAO = new SensorDataDAO();
    private final AppDataService appData = new AppDataService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/wateringManagement.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        try {
            String potIdStr = request.getParameter("potId");
            String volumeStr = request.getParameter("volume");

            if (potIdStr == null || volumeStr == null || potIdStr.isEmpty() || volumeStr.isEmpty()) {
                throw new IllegalArgumentException("Please select an irrigation zone and water volume.");
            }

            int potId = Integer.parseInt(potIdStr.trim());
            double volumeMl = Double.parseDouble(volumeStr.trim());

            if (potId <= 0) {
                throw new IllegalArgumentException("Invalid irrigation zone.");
            }
            if (Double.isNaN(volumeMl) || Double.isInfinite(volumeMl) || volumeMl <= 0) {
                throw new IllegalArgumentException("Water volume must be greater than 0 ml.");
            }
            if (volumeMl > MAX_VOLUME_ML) {
                throw new IllegalArgumentException("Water volume must not exceed " + (int) MAX_VOLUME_ML + " ml per session.");
            }

            double pumpRate = sessionDAO.getEffectivePumpRate(potId);
            int durationSeconds = Math.max(1, (int) Math.ceil(volumeMl / pumpRate));
            int sessionId = sessionDAO.insertManualWatering(potId, durationSeconds, volumeMl);

            if (sessionId > 0) {
                Map<Integer, SensorData> readings = appData.latestReadings();
                SensorData latest = readings.get(potId);
                double current = latest != null ? latest.getMoistureLevel() : 60.0;
                double updated = Math.min(95.0, Math.round((current + Math.max(1.5, volumeMl / 500.0)) * 10.0) / 10.0);
                sensorDAO.insert(potId, updated);

                String msg = "Command sent! Pump will run for " + durationSeconds + " seconds (" + Math.round(volumeMl) + " ml).";
                if (ApiSupport.isAjax(request)) {
                    ApiSupport.ok(response, msg);
                    return;
                }
                session.setAttribute("SUCCESS_MSG", msg);
            } else {
                String err = "System error: could not save watering session.";
                if (ApiSupport.isAjax(request)) {
                    ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, err);
                    return;
                }
                session.setAttribute("ERROR_MSG", err);
            }

        } catch (NumberFormatException e) {
            String err = "Invalid water volume or zone ID.";
            if (ApiSupport.isAjax(request)) {
                ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, err);
                return;
            }
            session.setAttribute("ERROR_MSG", err);
        } catch (IllegalArgumentException e) {
            String err = e.getMessage();
            if (ApiSupport.isAjax(request)) {
                ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, err);
                return;
            }
            session.setAttribute("ERROR_MSG", err);
        } catch (Exception e) {
            String err = "System error: could not process the watering request.";
            if (ApiSupport.isAjax(request)) {
                ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, err);
                return;
            }
            session.setAttribute("ERROR_MSG", err);
        }

        response.sendRedirect(request.getContextPath() + "/manual-water");
    }
}