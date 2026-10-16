package controller;

import dao.WateringScheduleDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.AppUser;
import model.WateringSchedule;

@WebServlet(name = "ScheduleController", urlPatterns = {"/schedules"})
public class ScheduleController extends HttpServlet {

    private final WateringScheduleDAO scheduleDAO = new WateringScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Default to pot #1 when no (or an invalid) parameter is supplied
        int potId = 1;
        String potIdStr = request.getParameter("potId");
        if (potIdStr != null && !potIdStr.trim().isEmpty()) {
            try {
                potId = Math.max(1, Integer.parseInt(potIdStr.trim()));
            } catch (NumberFormatException e) {
                potId = 1;
            }
        }

        List<WateringSchedule> listSchedules = scheduleDAO.getSchedulesByPot(potId);
        request.setAttribute("listSchedules", listSchedules);
        request.setAttribute("potId", potId);

        request.getRequestDispatcher("/wateringManagement.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        AppUser loginUser = (AppUser) session.getAttribute("LOGIN_USER");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!"ADMIN".equalsIgnoreCase(loginUser.getRoleName()) && !"MANAGER".equalsIgnoreCase(loginUser.getRoleName())) {
            session.setAttribute("ERROR_MSG", "Only Admin and Manager accounts can modify irrigation schedules.");
            response.sendRedirect(request.getContextPath() + "/schedules");
            return;
        }

        String action = request.getParameter("action");
        int potId = 1;

        try {
            potId = Integer.parseInt(request.getParameter("potId").trim());
            if (potId <= 0) {
                throw new IllegalArgumentException("Invalid irrigation zone.");
            }

            if ("add".equals(action)) {
                String cron = request.getParameter("cronExpression") == null ? "" : request.getParameter("cronExpression").trim();
                int duration = Integer.parseInt(request.getParameter("durationSeconds").trim());
                if (cron.isEmpty() || cron.length() > 100) {
                    throw new IllegalArgumentException("Schedule time is required (max 100 characters).");
                }
                if (duration <= 0 || duration > 3600) {
                    throw new IllegalArgumentException("Duration must be between 1 and 3600 seconds.");
                }
                scheduleDAO.insertSchedule(new WateringSchedule(0, potId, cron, duration, true));
                session.setAttribute("SUCCESS_MSG", "Schedule added.");

            } else if ("toggle".equals(action)) {
                int scheduleId = Integer.parseInt(request.getParameter("scheduleId").trim());
                boolean currentStatus = Boolean.parseBoolean(request.getParameter("isActive"));
                scheduleDAO.toggleStatus(scheduleId, !currentStatus);
                session.setAttribute("SUCCESS_MSG", "Schedule updated.");

            } else if ("delete".equals(action)) {
                int scheduleId = Integer.parseInt(request.getParameter("scheduleId").trim());
                scheduleDAO.deleteSchedule(scheduleId);
                session.setAttribute("SUCCESS_MSG", "Schedule deleted.");
            }
        } catch (NumberFormatException | NullPointerException e) {
            session.setAttribute("ERROR_MSG", "Invalid number in the submitted schedule form.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("ERROR_MSG", e.getMessage());
        }

        // Post-Redirect-Get
        response.sendRedirect(request.getContextPath() + "/schedules?potId=" + potId);
    }
}