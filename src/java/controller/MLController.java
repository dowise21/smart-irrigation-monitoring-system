package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.MLPrediction;
import service.MLService;

@WebServlet(name = "MLController", urlPatterns = {"/predict"})
public class MLController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/ml-prediction.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        int potId = Integer.parseInt(request.getParameter("potId"));
        
        // Trong thực tế, các giá trị này lấy trực tiếp từ SensorDataDAO. 
        // Ở đây lấy từ form nhập để bạn dễ test các trường hợp khác nhau.
        double moisture = Double.parseDouble(request.getParameter("moisture"));
        double water = Double.parseDouble(request.getParameter("water"));
        int light = Integer.parseInt(request.getParameter("light"));
        
        MLService mlService = new MLService();
        MLPrediction result = mlService.predictDryTime(potId, moisture, water, light);
        
        request.setAttribute("predictionResult", result);
        request.setAttribute("potId", potId);
        request.setAttribute("moisture", moisture);
        request.setAttribute("water", water);
        request.setAttribute("light", light);
        
        request.getRequestDispatcher("/WEB-INF/views/ml-prediction.jsp").forward(request, response);
    }
}