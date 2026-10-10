package controller;

import dao.WateringSessionDAO;
import model.AppUser; 

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ManualWateringServlet", urlPatterns = {"/manual-water"})
public class ManualWateringServlet extends HttpServlet {

    // Xử lý khi người dùng VÀO TRANG (Load giao diện)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // TODO: Mở rộng sau này -> Gọi PotDAO để lấy danh sách chậu thật nạp vào JSP
        // PotDAO potDAO = new PotDAO();
        // List<Pot> potList = potDAO.getAllPots();
        // request.setAttribute("pots", potList);
        
        // Chuyển tiếp tới file giao diện
        request.getRequestDispatcher("/WEB-INF/views/manual-water.jsp").forward(request, response);
    }

    // Xử lý khi người dùng BẤM NÚT (Submit Form)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        HttpSession session = request.getSession();
        
        try {
            // 1. Lấy dữ liệu lượng nước (ml) từ Form
            String potIdStr = request.getParameter("potId");
            String volumeStr = request.getParameter("volume");
            
            if (potIdStr == null || volumeStr == null || potIdStr.isEmpty() || volumeStr.isEmpty()) {
                throw new IllegalArgumentException("Vui lòng chọn chậu và nhập lượng nước.");
            }
            
            int potId = Integer.parseInt(potIdStr);
            double volumeMl = Double.parseDouble(volumeStr);
            
            // 2. Chuyển đổi lượng nước (ml) sang thời gian bơm (giây)
            // Giả sử tốc độ máy bơm là 50ml / 1 giây
            int pumpRateMlPerSecond = 50; 
            int durationSeconds = (int) Math.ceil(volumeMl / pumpRateMlPerSecond);
            
            // 3. Gọi DAO để lưu xuống Database (chỉ truyền potId và durationSeconds)
            WateringSessionDAO dao = new WateringSessionDAO();
            boolean isSuccess = dao.insertManualWatering(potId, durationSeconds);
            
            // 4. Phản hồi lại giao diện
            if (isSuccess) {
                session.setAttribute("SUCCESS_MSG", "Đã gửi lệnh! Máy bơm sẽ chạy trong " + durationSeconds + " giây để tưới " + volumeMl + "ml nước.");
            } else {
                session.setAttribute("ERROR_MSG", "Lỗi hệ thống: Không thể lưu dữ liệu tưới nước.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("ERROR_MSG", "Dữ liệu lượng nước không hợp lệ. Vui lòng nhập số.");
        } catch (Exception e) {
            session.setAttribute("ERROR_MSG", "Đã xảy ra lỗi: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/manual-water");
    }
}