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

@WebServlet(name = "AlertController", urlPatterns = {"/alerts"})
public class AlertController extends HttpServlet {

    private final AlertDAO alertDAO = new AlertDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy tham số lọc trạng thái (VD: ?status=0 để lấy các lỗi chưa xử lý)
        String statusParam = request.getParameter("status");
        Boolean isResolved = null;
        if (statusParam != null && !statusParam.isEmpty()) {
            if (statusParam.equals("0")) isResolved = false;
            else if (statusParam.equals("1")) isResolved = true;
        }

        List<Alert> listAlerts = alertDAO.getAlerts(isResolved);
        request.setAttribute("listAlerts", listAlerts);
        request.setAttribute("currentStatus", statusParam);
        
        request.getRequestDispatcher("/WEB-INF/views/alert-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy thông tin user đang đăng nhập để kiểm tra quyền
        HttpSession session = request.getSession();
        AppUser loginUser = (AppUser) session.getAttribute("LOGIN_USER");
        
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        // Xử lý xác nhận lỗi (Resolve Alert)
        if ("resolve".equals(action)) {
            // Yêu cầu: VIEWER không được quyền xác nhận lỗi
            if ("VIEWER".equals(loginUser.getRoleName())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "VIEWER không có quyền xử lý cảnh báo.");
                return;
            }
            
            try {
                int alertId = Integer.parseInt(request.getParameter("alertId"));
                alertDAO.resolveAlert(alertId);
                
                // Quay lại trang danh sách lỗi chưa xử lý
                response.sendRedirect(request.getContextPath() + "/alerts?status=0");
            } catch (Exception e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Dữ liệu không hợp lệ.");
            }
        }
    }
}