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
        
        // Mặc định lấy lịch của chậu số 1 nếu không truyền tham số
        int potId = 1; 
        String potIdStr = request.getParameter("potId");
        if (potIdStr != null && !potIdStr.isEmpty()) {
            potId = Integer.parseInt(potIdStr);
        }

        List<WateringSchedule> listSchedules = scheduleDAO.getSchedulesByPot(potId);
        request.setAttribute("listSchedules", listSchedules);
        request.setAttribute("potId", potId);
        
        request.getRequestDispatcher("/WEB-INF/views/schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        // Kiểm tra quyền (Authorization)
        HttpSession session = request.getSession();
        AppUser loginUser = (AppUser) session.getAttribute("LOGIN_USER");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if ("VIEWER".equals(loginUser.getRoleName())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "VIEWER không có quyền cấu hình lịch tưới.");
            return;
        }

        String action = request.getParameter("action");
        int potId = Integer.parseInt(request.getParameter("potId"));

        try {
            if ("add".equals(action)) {
                String cron = request.getParameter("cronExpression"); // VD: "07:30 Hàng ngày"
                int duration = Integer.parseInt(request.getParameter("durationSeconds"));
                
                WateringSchedule ws = new WateringSchedule(0, potId, cron, duration, true);
                scheduleDAO.insertSchedule(ws);
                
            } else if ("toggle".equals(action)) {
                int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
                boolean currentStatus = Boolean.parseBoolean(request.getParameter("isActive"));
                scheduleDAO.toggleStatus(scheduleId, !currentStatus); // Đảo trạng thái
                
            } else if ("delete".equals(action)) {
                int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
                scheduleDAO.deleteSchedule(scheduleId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Xử lý xong thì load lại trang danh sách của chậu đó
        response.sendRedirect(request.getContextPath() + "/schedules?potId=" + potId);
    }
}