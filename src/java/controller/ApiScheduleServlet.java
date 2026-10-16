package controller;

import dao.PotDAO;
import dao.WateringScheduleDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Pot;
import model.WateringSchedule;
import service.AppDataService;
import util.Json;
import util.ScheduleFormat;

/**
 * GET  /api/schedules                         -> all schedules (same shape as window.SI_DATA.schedules)
 * POST /api/schedules action=add              -> potId, time (HH:mm), frequency (daily|weekdays|once), minutes
 * POST /api/schedules action=toggle           -> scheduleId, enabled (true|false)
 * POST /api/schedules action=delete           -> scheduleId
 */
@WebServlet(name = "ApiScheduleServlet", urlPatterns = {"/api/schedules"})
public class ApiScheduleServlet extends HttpServlet {

    private final AppDataService data = new AppDataService();
    private final PotDAO potDAO = new PotDAO();
    private final WateringScheduleDAO scheduleDAO = new WateringScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ApiSupport.write(response, HttpServletResponse.SC_OK, data.schedulesJson());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            add(request, response);
        } else if ("toggle".equals(action)) {
            toggle(request, response);
        } else if ("delete".equals(action)) {
            delete(request, response);
        } else {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "Unknown action.");
        }
    }

    private void add(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer potId = ApiSupport.intParam(request, "potId");
        Double minutes = ApiSupport.doubleParam(request, "minutes");
        String time = request.getParameter("time");
        String frequency = request.getParameter("frequency");
        if (frequency == null) {
            frequency = "daily";
        }

        if (potId == null || minutes == null || minutes <= 0 || minutes > 240
                || !ScheduleFormat.isValidTime(time) || !ScheduleFormat.isValidFrequency(frequency)) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Choose a garden, a valid time (HH:mm) and a duration between 1 and 240 minutes.");
            return;
        }
        Pot pot = potDAO.findById(potId);
        if (pot == null || !pot.isStatus()) {
            ApiSupport.error(response, HttpServletResponse.SC_NOT_FOUND, "Irrigation zone not found or inactive.");
            return;
        }

        WateringSchedule schedule = new WateringSchedule(0, potId, ScheduleFormat.toCron(time, frequency),
                (int) Math.round(minutes * 60), true);
        int id = scheduleDAO.insertAndGetId(schedule);
        if (id == 0) {
            ApiSupport.error(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not save the schedule.");
            return;
        }
        schedule.setScheduleId(id);
        ApiSupport.write(response, HttpServletResponse.SC_OK,
                "{\"ok\":true,\"message\":" + Json.quote("Schedule saved.") + ",\"schedule\":" + data.scheduleJson(schedule) + "}");
    }

    private void toggle(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = ApiSupport.intParam(request, "scheduleId");
        String enabled = request.getParameter("enabled");
        if (id == null || enabled == null) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "scheduleId and enabled are required.");
            return;
        }
        if (scheduleDAO.toggleStatus(id, Boolean.parseBoolean(enabled))) {
            ApiSupport.ok(response, "Schedule updated.");
        } else {
            ApiSupport.error(response, HttpServletResponse.SC_NOT_FOUND, "Schedule not found.");
        }
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer id = ApiSupport.intParam(request, "scheduleId");
        if (id == null) {
            ApiSupport.error(response, HttpServletResponse.SC_BAD_REQUEST, "scheduleId is required.");
            return;
        }
        if (scheduleDAO.deleteSchedule(id)) {
            ApiSupport.ok(response, "Schedule deleted.");
        } else {
            ApiSupport.error(response, HttpServletResponse.SC_NOT_FOUND, "Schedule not found.");
        }
    }
}

