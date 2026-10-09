package controller;

import dao.PotDAO;
import dao.SensorDataDAO;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.Pot;
import model.SensorData;

@WebServlet(name = "SensorController", urlPatterns = {"/sensor-data"})
public class SensorController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SensorController.class.getName());
    private final SensorDataDAO sensorDAO = new SensorDataDAO();
    private final PotDAO potDAO = new PotDAO();

    // Dành cho Web: Hiển thị danh sách dữ liệu cảm biến
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Nhận ID chậu nếu người dùng muốn lọc (mặc định là 0 - Tức là xem tất cả)
        String potIdParam = request.getParameter("potId");
        int potId = 0;
        if (potIdParam != null && !potIdParam.isEmpty()) {
            try {
                potId = Integer.parseInt(potIdParam);
            } catch (NumberFormatException e) {
                potId = 0;
            }
        }

        // Lấy 50 bản ghi mới nhất
        List<SensorData> listData = sensorDAO.getRecentData(potId, 50);
        
        // Lấy danh sách chậu để làm Menu Dropdown lọc dữ liệu
        List<Pot> listPot = potDAO.getAll();

        request.setAttribute("listData", listData);
        request.setAttribute("listPot", listPot);
        request.setAttribute("selectedPotId", potId);

        request.getRequestDispatcher("/WEB-INF/views/sensor-list.jsp").forward(request, response);
    }

    // Dành cho Mạch IoT (ESP32/ESP8266) Gửi dữ liệu độ ẩm lên
    // Hoặc dùng để Giả lập (Simulate) tạo dữ liệu test
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int potId = Integer.parseInt(request.getParameter("potId"));
            double moisture = Double.parseDouble(request.getParameter("moisture"));
            
            boolean success = sensorDAO.insert(potId, moisture);
            
            if (success) {
                // Phản hồi về cho mạch ESP biết là đã lưu thành công
                response.getWriter().write("OK");
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi lưu DB");
            }
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Lỗi khi nhận dữ liệu Sensor: {0}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Dữ liệu không hợp lệ");
        }
    }
}