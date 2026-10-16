package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.MLPrediction;
import service.MLService;

@WebServlet(name = "MLController", urlPatterns = {"/predict"})
public class MLController extends HttpServlet {

    private static final String[] FLASH_KEYS = {"predictionResult", "potId", "moisture", "water", "light"};
    private static final String FLASH_PREFIX = "ML_FLASH_";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Restore the result of the previous POST (Post-Redirect-Get) and consume it once
        HttpSession session = request.getSession(false);
        if (session != null) {
            for (String key : FLASH_KEYS) {
                Object value = session.getAttribute(FLASH_PREFIX + key);
                if (value != null) {
                    request.setAttribute(key, value);
                    session.removeAttribute(FLASH_PREFIX + key);
                }
            }
        }
        request.getRequestDispatcher("/WEB-INF/views/ml-prediction.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        try {
            int potId = Integer.parseInt(request.getParameter("potId").trim());
            double moisture = Double.parseDouble(request.getParameter("moisture").trim());
            double water = Double.parseDouble(request.getParameter("water").trim());
            int light = Integer.parseInt(request.getParameter("light").trim());

            if (potId <= 0) {
                throw new IllegalArgumentException("Invalid pot.");
            }
            if (Double.isNaN(moisture) || moisture < 0 || moisture > 100) {
                throw new IllegalArgumentException("Moisture must be between 0 and 100.");
            }
            if (Double.isNaN(water) || water < 0 || water > 10000) {
                throw new IllegalArgumentException("Water volume must be between 0 and 10000 ml.");
            }
            if (light < 0 || light > 200000) {
                throw new IllegalArgumentException("Light must be between 0 and 200000 lux.");
            }

            MLPrediction result = new MLService().predictDryTime(potId, moisture, water, light);

            session.setAttribute(FLASH_PREFIX + "predictionResult", result);
            session.setAttribute(FLASH_PREFIX + "potId", potId);
            session.setAttribute(FLASH_PREFIX + "moisture", moisture);
            session.setAttribute(FLASH_PREFIX + "water", water);
            session.setAttribute(FLASH_PREFIX + "light", light);
        } catch (NumberFormatException | NullPointerException e) {
            session.setAttribute("ERROR_MSG", "Invalid prediction input: please enter valid numbers.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("ERROR_MSG", e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/predict");
    }
}