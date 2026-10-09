package controller;

import dao.DashboardDAO;
import dao.PotDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "DashboardController", urlPatterns = {"/dashboard"})
public class DashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        DashboardDAO dashDAO = new DashboardDAO();
        PotDAO potDAO = new PotDAO();
        
        // 1. Lấy dữ liệu KPI Nước
        double[] waterKPIs = dashDAO.getWaterKPIs();
        request.setAttribute("waterUsed", String.format("%.2f", waterKPIs[0]));
        request.setAttribute("waterRetained", String.format("%.2f", waterKPIs[1]));
        request.setAttribute("waterWaste", String.format("%.2f", waterKPIs[2]));
        
        // 2. Lấy Cảnh báo & Số lượng chậu
        request.setAttribute("alertCount", dashDAO.getActiveAlertCount());
        request.setAttribute("totalPots", potDAO.getAll().size());
        
        request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
    }
}