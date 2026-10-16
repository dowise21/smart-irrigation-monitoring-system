package controller;

import dao.PumpCalibrationDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.AppUser;

/**
 * Pump calibration (tables Pump + PumpCalibration).
 *   GET  /pump-calibration  -> pumps with latest calibration + paginated history (everyone may read)
 *   POST /pump-calibration  -> inserts a new PumpCalibration row (ADMIN, TECHNICIAN) then redirects (PRG)
 *
 * Flow rate = measuredMl / durationSec (ml per second).
 */
@WebServlet(name = "PumpCalibrationServlet", urlPatterns = {"/pump-calibration"})
public class PumpCalibrationServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private static final double MAX_FLOW_ML_PER_SEC = 500;

    private final PumpCalibrationDAO calibrationDAO = new PumpCalibrationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int page = 1;
        try {
            page = Math.max(1, Integer.parseInt(request.getParameter("page")));
        } catch (NumberFormatException ignored) {
            // default page 1
        }
        List<Map<String, Object>> pumps = calibrationDAO.getAllPumpsWithCalibration();
        List<Map<String, Object>> history = calibrationDAO.getCalibrationHistory(page, PAGE_SIZE + 1);
        boolean hasNext = history.size() > PAGE_SIZE;
        if (hasNext) {
            history = history.subList(0, PAGE_SIZE);
        }
        request.setAttribute("pumps", pumps);
        request.setAttribute("history", history);
        request.setAttribute("currentPage", page);
        request.setAttribute("hasNext", hasNext);
        request.getRequestDispatcher("/pump-calibration.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        AppUser user = (AppUser) session.getAttribute("LOGIN_USER");
        String role = user == null || user.getRoleName() == null ? "" : user.getRoleName().toUpperCase();
        if (!"ADMIN".equals(role) && !"TECHNICIAN".equals(role)) {
            session.setAttribute("ERROR_MSG", "Only Admin and Technician accounts can calibrate pumps.");
            response.sendRedirect(request.getContextPath() + "/pump-calibration");
            return;
        }

        try {
            int pumpId = Integer.parseInt(request.getParameter("pumpId").trim());
            double measuredMl = Double.parseDouble(request.getParameter("measuredMl").trim());
            double durationSec = Double.parseDouble(request.getParameter("durationSec").trim());
            if (pumpId <= 0) {
                throw new IllegalArgumentException("Please select a pump.");
            }
            if (measuredMl <= 0 || durationSec <= 0 || Double.isNaN(measuredMl) || Double.isNaN(durationSec)) {
                throw new IllegalArgumentException("Measured volume and duration must be greater than 0.");
            }
            double flow = Math.round(measuredMl / durationSec * 1000.0) / 1000.0;
            if (flow <= 0 || flow > MAX_FLOW_ML_PER_SEC) {
                throw new IllegalArgumentException("Flow rate must be between 0 and " + (int) MAX_FLOW_ML_PER_SEC + " ml/s.");
            }
            if (calibrationDAO.insertCalibration(pumpId, flow, user.getUserId())) {
                session.setAttribute("SUCCESS_MSG", "Calibration saved: " + flow + " ml/s.");
            } else {
                session.setAttribute("ERROR_MSG", "Could not save calibration.");
            }
        } catch (NumberFormatException | NullPointerException e) {
            session.setAttribute("ERROR_MSG", "Invalid calibration input.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("ERROR_MSG", e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/pump-calibration");
    }
}
