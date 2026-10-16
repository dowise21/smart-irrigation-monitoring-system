package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Alert;
import util.DBContext;

public class AlertDAO {

    private static final Logger LOGGER = Logger.getLogger(AlertDAO.class.getName());

    private Alert map(ResultSet rs) throws SQLException {
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
        return a;
    }

    /**
     * Lấy danh sách các cảnh báo (Có thể lọc theo trạng thái đã xử lý hay chưa)
     */
    public List<Alert> getAlerts(Boolean isResolvedStatus) {
        return getAlerts(isResolvedStatus, 1, 200);
    }

    /**
     * Lấy danh sách cảnh báo có phân trang Server-Side (OFFSET / FETCH NEXT)
     */
    public List<Alert> getAlerts(Boolean isResolvedStatus, int page, int size) {
        List<Alert> list = new ArrayList<>();
        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(500, size));

        String sql = "SELECT a.*, p.pot_name FROM Alert a "
                   + "JOIN Pot p ON a.pot_id = p.pot_id ";
        if (isResolvedStatus != null) {
            sql += "WHERE a.is_resolved = ? ";
        }
        sql += "ORDER BY a.created_at DESC, a.alert_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            int idx = 1;
            if (isResolvedStatus != null) {
                ps.setBoolean(idx++, isResolvedStatus);
            }
            ps.setInt(idx++, (safePage - 1) * safeSize);
            ps.setInt(idx, safeSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi lấy danh sách Alert: {0}", e.getMessage());
        }
        return list;
    }

    public int countAlerts(Boolean isResolvedStatus) {
        String sql = "SELECT COUNT(*) FROM Alert a ";
        if (isResolvedStatus != null) {
            sql += "WHERE a.is_resolved = ? ";
        }
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            if (isResolvedStatus != null) {
                ps.setBoolean(1, isResolvedStatus);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi đếm Alert: {0}", e.getMessage());
        }
        return 0;
    }

    /**
     * Hệ thống tự động Insert cảnh báo khi phát hiện bất thường
     */
    public boolean insertAlert(int potId, Integer sessionId, String alertType, String message) {
        String sql = "INSERT INTO Alert(pot_id, session_id, alert_type, message, is_resolved) VALUES (?, ?, ?, ?, 0)";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, potId);
            if (sessionId != null) {
                ps.setInt(2, sessionId);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, alertType);
            ps.setString(4, message);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi insert Alert: {0}", e.getMessage());
        }
        return false;
    }

    /**
     * Cập nhật trạng thái "Đã xử lý" (Backwards-compatible overload)
     */
    public boolean resolveAlert(int alertId) {
        return resolveAlert(alertId, null, "Resolved via web console");
    }

    /**
     * Cập nhật trạng thái "Đã xử lý" và ghi vết vào bảng AlertConfirmation trong cùng 1 Transaction.
     */
    public boolean resolveAlert(int alertId, Integer userId, String actionTaken) {
        String sqlUpdate = "UPDATE Alert SET is_resolved = 1 WHERE alert_id = ?";
        String sqlConfirm = "INSERT INTO AlertConfirmation (alert_id, user_id, action_taken, confirmed_at) "
                          + "VALUES (?, ?, ?, GETDATE())";
        try (Connection cn = DBContext.getConnection()) {
            cn.setAutoCommit(false);
            try (PreparedStatement psUpdate = cn.prepareStatement(sqlUpdate)) {
                psUpdate.setInt(1, alertId);
                int updated = psUpdate.executeUpdate();
                if (updated > 0 && userId != null && userId > 0) {
                    try (PreparedStatement psConfirm = cn.prepareStatement(sqlConfirm)) {
                        psConfirm.setInt(1, alertId);
                        psConfirm.setInt(2, userId);
                        psConfirm.setString(3, (actionTaken == null || actionTaken.trim().isEmpty())
                                ? "Confirmed and resolved alert" : actionTaken.trim());
                        psConfirm.executeUpdate();
                    }
                }
                cn.commit();
                return updated > 0;
            } catch (Exception ex) {
                cn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi resolve Alert: {0}", e.getMessage());
        }
        return false;
    }

    public boolean resolveAllAlerts() {
        return resolveAllAlerts(null);
    }

    public boolean resolveAllAlerts(Integer userId) {
        String sqlInsertConfirms = "INSERT INTO AlertConfirmation (alert_id, user_id, action_taken, confirmed_at) "
                                 + "SELECT alert_id, ?, 'Bulk resolved via web console', GETDATE() "
                                 + "FROM Alert WHERE is_resolved = 0";
        String sqlUpdate = "UPDATE Alert SET is_resolved = 1 WHERE is_resolved = 0";
        try (Connection cn = DBContext.getConnection()) {
            cn.setAutoCommit(false);
            try {
                if (userId != null && userId > 0) {
                    try (PreparedStatement psConfirm = cn.prepareStatement(sqlInsertConfirms)) {
                        psConfirm.setInt(1, userId);
                        psConfirm.executeUpdate();
                    }
                }
                try (PreparedStatement psUpdate = cn.prepareStatement(sqlUpdate)) {
                    psUpdate.executeUpdate();
                }
                cn.commit();
                return true;
            } catch (Exception ex) {
                cn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error resolving all alerts: {0}", e.getMessage());
        }
        return false;
    }
}