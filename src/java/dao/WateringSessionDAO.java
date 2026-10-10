package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import util.DBContext; 

public class WateringSessionDAO {

    // Nhận vào potId và durationSeconds (không cần userId nữa vì DB không có cột trigger_by)
    public boolean insertManualWatering(int potId, int durationSeconds) {
        // Cập nhật câu lệnh SQL khớp chính xác với ảnh bạn gửi
        String sql = "INSERT INTO WateringSession (pot_id, duration_seconds, source, start_time) "
                   + "VALUES (?, ?, 'MANUAL', GETDATE())";
                   
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, potId);
            ps.setInt(2, durationSeconds);
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
            
        } catch (Exception e) {
            System.out.println("Lỗi insertManualWatering: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}