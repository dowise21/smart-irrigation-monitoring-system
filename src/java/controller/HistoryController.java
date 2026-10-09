package controller;

import dao.IrrigationHistoryDAO;
import dao.PotDAO;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.IrrigationHistory;
import model.Pot;

@WebServlet(name = "HistoryController", urlPatterns = {"/history"})
public class HistoryController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(HistoryController.class.getName());
    private final IrrigationHistoryDAO historyDAO = new IrrigationHistoryDAO();
    private final PotDAO potDAO = new PotDAO();

    // Dành cho Web: Hiển thị danh sách lịch sử tưới
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String potIdParam = request.getParameter("potId");
        int potId = 0;
        if (potIdParam != null && !potIdParam.isEmpty()) {
            try {
                potId = Integer.parseInt(potIdParam);
            } catch (NumberFormatException e) {
                potId = 0;
            }
        }

        // Lấy 50 bản ghi lịch sử mới nhất
        List<IrrigationHistory> listHistory = historyDAO.getHistory(potId, 50);
        List<Pot> listPot = potDAO.getAll();

        request.setAttribute("listHistory", listHistory);
        request.setAttribute("listPot", listPot);
        request.setAttribute("selectedPotId", potId);

        request.getRequestDispatcher("/WEB-INF/views/history-list.jsp").forward(request, response);
    }

    // Dành cho Mạch IoT: Gửi thông báo khi vừa tưới xong
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int potId = Integer.parseInt(request.getParameter("potId"));
            Integer duration = Integer.valueOf(request.getParameter("duration"));
            Double waterAmount = Double.valueOf(request.getParameter("waterAmount"));
            
            boolean success = historyDAO.insert(potId, duration, waterAmount);
            
            if (success) {
                response.getWriter().write("OK");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi lưu DB");
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi nhận dữ liệu History: {0}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Dữ liệu không hợp lệ");
        }
    }
}