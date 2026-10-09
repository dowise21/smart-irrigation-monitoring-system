package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.WateringSchedule;
import util.DBContext;

public class WateringScheduleDAO {

    private static final Logger LOGGER = Logger.getLogger(WateringScheduleDAO.class.getName());

    // Lấy danh sách lịch tưới của một chậu cụ thể
    public List<WateringSchedule> getSchedulesByPot(int potId) {
        List<WateringSchedule> list = new ArrayList<>();
        String sql = "SELECT * FROM WateringSchedule WHERE pot_id = ? ORDER BY schedule_id DESC";
        
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
             
            ps.setInt(1, potId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new WateringSchedule(
                        rs.getInt("schedule_id"),
                        rs.getInt("pot_id"),
                        rs.getString("cron_expression"),
                        rs.getInt("duration_seconds"),
                        rs.getBoolean("is_active")
                    ));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy lịch tưới: {0}", e.getMessage());
        }
        return list;
    }

    // Thêm mới một lịch tưới
    public boolean insertSchedule(WateringSchedule schedule) {
        String sql = "INSERT INTO WateringSchedule (pot_id, cron_expression, duration_seconds, is_active) VALUES (?, ?, ?, ?)";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
             
            ps.setInt(1, schedule.getPotId());
            ps.setString(2, schedule.getCronExpression());
            ps.setInt(3, schedule.getDurationSeconds());
            ps.setBoolean(4, schedule.isIsActive());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi thêm lịch tưới: {0}", e.getMessage());
        }
        return false;
    }

    // Bật/Tắt nhanh một lịch tưới
    public boolean toggleStatus(int scheduleId, boolean isActive) {
        String sql = "UPDATE WateringSchedule SET is_active = ? WHERE schedule_id = ?";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
             
            ps.setBoolean(1, isActive);
            ps.setInt(2, scheduleId);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi cập nhật trạng thái lịch tưới: {0}", e.getMessage());
        }
        return false;
    }
    
    // Xóa lịch tưới
    public boolean deleteSchedule(int scheduleId) {
        String sql = "DELETE FROM WateringSchedule WHERE schedule_id = ?";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
             
            ps.setInt(1, scheduleId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi xóa lịch tưới: {0}", e.getMessage());
        }
        return false;
    }
}