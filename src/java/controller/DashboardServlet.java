package controller;

import dao.DashboardDAO;
import dao.PlantDAO;
import dao.PotDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Khởi tạo các DAO
        DashboardDAO dashDAO = new DashboardDAO();
        PlantDAO plantDAO = new PlantDAO();
        PotDAO potDAO = new PotDAO();
        
        // 1. Lấy dữ liệu KPI Nước (Từ DashboardController cũ)
        double[] waterKPIs = dashDAO.getWaterKPIs();
        request.setAttribute("waterUsed", String.format("%.2f", waterKPIs[0]));
        request.setAttribute("waterRetained", String.format("%.2f", waterKPIs[1]));
        request.setAttribute("waterWaste", String.format("%.2f", waterKPIs[2]));
        
        // 2. Lấy dữ liệu thống kê số lượng & cảnh báo
        int totalPlants = plantDAO.count(""); // Đếm tất cả cây
        int totalPots = potDAO.getAll().size(); // Đếm tất cả chậu
        int alertCount = dashDAO.getActiveAlertCount(); // Đếm cảnh báo
        
        request.setAttribute("totalPlants", totalPlants);
        request.setAttribute("totalPots", totalPots);
        request.setAttribute("alertCount", alertCount);
        
        // 3. Chuyển hướng sang giao diện trang chủ
        request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
    }
}