package controller;

import dao.IrrigationHistoryDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.IrrigationHistory;

@WebServlet(name = "ExportCSVController", urlPatterns = {"/export-history"})
public class ExportCSVController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        // 1. Cấu hình Response để ép trình duyệt tải file
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"Bao_Cao_Lich_Su_Tuoi.csv\"");
        
        try (PrintWriter out = response.getWriter()) {
            // 2. Ghi cờ BOM (Byte Order Mark) để Excel đọc tiếng Việt UTF-8 không bị lỗi font
            out.write('\ufeff'); 
            
            // 3. Ghi dòng Header của file CSV
            out.println("ID Lịch sử,Chậu cây,Thời gian tưới,Thời lượng bơm (giây),Lượng nước (Lít)");
            
            // 4. Lấy dữ liệu từ Database (Giả sử lấy 1000 bản ghi mới nhất)
            IrrigationHistoryDAO dao = new IrrigationHistoryDAO();
            List<IrrigationHistory> list = dao.getHistory(0, 1000); 
            
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
            
            // 5. Duyệt danh sách và ghi từng dòng dữ liệu cách nhau bằng dấu phẩy
            for (IrrigationHistory h : list) {
                String timeStr = h.getIrrigationTime() != null ? sdf.format(h.getIrrigationTime()) : "";
                String duration = h.getDurationSeconds() != null ? String.valueOf(h.getDurationSeconds()) : "N/A";
                String amount = h.getWaterAmount() != null ? String.format("%.2f", h.getWaterAmount()) : "0";
                
                // Bao bọc tên chậu trong dấu ngoặc kép để tránh lỗi nếu tên có chứa dấu phẩy
                out.println(String.format("%d,\"%s\",%s,%s,%s", 
                        h.getHistoryId(), 
                        h.getPotName(), 
                        timeStr, 
                        duration, 
                        amount));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}