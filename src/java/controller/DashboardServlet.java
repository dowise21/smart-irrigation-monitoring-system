package controller;

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
        
        // 1. Lấy dữ liệu thống kê nhanh
        PlantDAO plantDAO = new PlantDAO();
        PotDAO potDAO = new PotDAO();
        
        // Đếm số lượng
        int totalPlants = plantDAO.count(""); // truyền chuỗi rỗng để đếm tất cả
        int totalPots = potDAO.getAll().size();
        
        // Gửi dữ liệu sang JSP
        request.setAttribute("totalPlants", totalPlants);
        request.setAttribute("totalPots", totalPots);
        
        // 2. Chuyển hướng sang giao diện trang chủ
        request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
    }
}