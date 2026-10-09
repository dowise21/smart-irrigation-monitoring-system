package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Alert;
import util.DBContext;

public class AlertDAO {

    private static final Logger LOGGER = Logger.getLogger(AlertDAO.class.getName());

    /**
     * Lấy danh sách các cảnh báo (Có thể lọc theo trạng thái đã xử lý hay chưa)
     */
    public List<Alert> getAlerts(Boolean isResolvedStatus) {
        List<Alert> list = new ArrayList<>();
        String sql = "SELECT a.*, p.pot_name FROM Alert a " +
                     "JOIN Pot p ON a.pot_id = p.pot_id ";
        
        if (isResolvedStatus != null) {
            sql += "WHERE a.is_resolved = ? ";
        }
        sql += "ORDER BY a.created_at DESC";

        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
             
            if (isResolvedStatus != null) {
                ps.setBoolean(1, isResolvedStatus);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Alert a = new Alert();
                    a.setAlertId(rs.getInt("alert_id"));
                    a.setPotId(rs.getInt("pot_id"));
                    
                    int sessionId = rs.getInt("session_id");
                    a.setSessionId(rs.wasNull() ? null : sessionId);
                    
                    a.setAlertType(rs.getString("alert_type"));
                    a.setMessage(rs.getString("message"));
                    a.setCreatedAt(rs.getTimestamp("created_at"));
                    a.setIsResolved(rs.getBoolean("is_resolved"));
                    a.setPotName(rs.getString("pot_name"));
                    list.add(a);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách Alert: {0}", e.getMessage());
        }
        return list;
    }

    /**
     * Hệ thống tự động Insert cảnh báo khi phát hiện bất thường
     */
    public boolean insertAlert(int potId, Integer sessionId, String alertType, String message) {
        String sql = "INSERT INTO Alert(pot_id, session_id, alert_type, message, is_resolved) VALUES (?, ?, ?, ?, 0)";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
             
            ps.setInt(1, potId);
            if (sessionId != null) ps.setInt(2, sessionId);
            else ps.setNull(2, java.sql.Types.INTEGER);
            
            ps.setString(3, alertType);
            ps.setString(4, message);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi insert Alert: {0}", e.getMessage());
        }
        return false;
    }

    /**
     * Cập nhật trạng thái "Đã xử lý" (Dành cho STAFF / TECHNICIAN)
     */
    public boolean resolveAlert(int alertId) {
        String sql = "UPDATE Alert SET is_resolved = 1 WHERE alert_id = ?";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, alertId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi resolve Alert: {0}", e.getMessage());
        }
        return false;
    }
}