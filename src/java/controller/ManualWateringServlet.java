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
    private static final double MAX_VOLUME_ML = 50000;

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
            String commandStr = request.getParameter("command");
            if (commandStr != null && ("STOP".equalsIgnoreCase(commandStr.trim()) || "OFF".equalsIgnoreCase(commandStr.trim()))) {
                int stopPotId = (potIdStr != null && !potIdStr.trim().isEmpty()) ? Integer.parseInt(potIdStr.trim()) : 1;
                WateringCommandServlet.enqueueStop(stopPotId);
                if (ApiSupport.isAjax(request)) {
                    ApiSupport.ok(response, "Pump stopped for Pot #" + stopPotId);
                    return;
                }
                session.setAttribute("SUCCESS_MSG", "Pump stopped for Pot #" + stopPotId);
                response.sendRedirect(request.getContextPath() + "/manual-water");
                return;
            }

            String volumeStr = request.getParameter("volume");
            String durationStr = request.getParameter("duration");
            String minutesStr = request.getParameter("minutes");

            if (potIdStr == null || potIdStr.isEmpty()) {
                throw new IllegalArgumentException("Please select an irrigation zone.");
            }
            int potId = Integer.parseInt(potIdStr.trim());
            if (potId <= 0) {
                throw new IllegalArgumentException("Invalid irrigation zone.");
            }

            double pumpRate = sessionDAO.getEffectivePumpRate(potId);
            Integer explicitDuration = null;
            if (durationStr != null && !durationStr.trim().isEmpty()) {
                explicitDuration = Integer.parseInt(durationStr.trim());
            } else if (minutesStr != null && !minutesStr.trim().isEmpty()) {
                double mins = Double.parseDouble(minutesStr.trim());
                if (mins > 0) {
                    explicitDuration = (int) Math.round(mins <= 2 ? mins * 60 : Math.min(60, mins));
                }
            }

            double volumeMl;
            if (volumeStr != null && !volumeStr.trim().isEmpty()) {
                volumeMl = Double.parseDouble(volumeStr.trim());
            } else if (explicitDuration != null && explicitDuration > 0) {
                volumeMl = explicitDuration * pumpRate;
            } else {
                throw new IllegalArgumentException("Please select a water volume or duration.");
            }

            if (Double.isNaN(volumeMl) || Double.isInfinite(volumeMl) || volumeMl <= 0) {
                throw new IllegalArgumentException("Water volume must be greater than 0 ml.");
            }
            if (volumeMl > MAX_VOLUME_ML) {
                throw new IllegalArgumentException("Water volume must not exceed " + (int) MAX_VOLUME_ML + " ml per session.");
            }

            int durationSeconds = (explicitDuration != null && explicitDuration > 0)
                    ? explicitDuration
                    : Math.max(1, (int) Math.ceil(volumeMl / pumpRate));
            int sessionId = sessionDAO.insertManualWatering(potId, durationSeconds, volumeMl);

            if (sessionId > 0) {
                WateringCommandServlet.enqueueStart(potId, durationSeconds);
                Map<Integer, SensorData> readings = appData.latestReadings();
                SensorData latest = readings.get(potId);
                double current = latest != null ? latest.getMoistureLevel() : 60.0;
                double updated = Math.min(95.0, Math.round((current + Math.max(1.5, Math.min(10.0, volumeMl / 500.0))) * 10.0) / 10.0);
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