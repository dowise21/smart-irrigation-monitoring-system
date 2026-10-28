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
     * Hệ thống tự động Insert cảnh báo khi phát hiện bất thường.
     * Nếu trong vòng 60 giây gần nhất đã có cảnh báo cùng loại (chưa xử lý) của cùng chậu cây,
     * cập nhật lại nội dung và thời gian mới nhất để tránh làm ngập bảng Alert khi cảm biến gửi mỗi 5 giây.
     */
    public boolean insertAlert(int potId, Integer sessionId, String alertType, String message) {
        String checkRecentSql = "SELECT TOP 1 alert_id FROM Alert "
                + "WHERE pot_id = ? AND alert_type = ? AND is_resolved = 0 "
                + "AND created_at >= DATEADD(SECOND, -60, GETDATE()) ORDER BY alert_id DESC";
        String updateRecentSql = "UPDATE Alert SET message = ?, created_at = GETDATE() WHERE alert_id = ?";
        String insertSql = "INSERT INTO Alert(pot_id, session_id, alert_type, message, is_resolved) VALUES (?, ?, ?, ?, 0)";

        try (Connection cn = DBContext.getConnection()) {
            try (PreparedStatement psCheck = cn.prepareStatement(checkRecentSql)) {
                psCheck.setInt(1, potId);
                psCheck.setString(2, alertType);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        int existingId = rs.getInt("alert_id");
                        try (PreparedStatement psUp = cn.prepareStatement(updateRecentSql)) {
                            psUp.setString(1, message);
                            psUp.setInt(2, existingId);
                            return psUp.executeUpdate() > 0;
                        }
                    }
                }
            }
            try (PreparedStatement ps = cn.prepareStatement(insertSql)) {
                ps.setInt(1, potId);
                if (sessionId != null) {
                    ps.setInt(2, sessionId);
                } else {
                    ps.setNull(2, java.sql.Types.INTEGER);
                }
                ps.setString(3, alertType);
                ps.setString(4, message);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi insert Alert: {0}", e.getMessage());
        }
        return false;
    }

    public boolean resolveAlert(int alertId) {
        return resolveAlert(alertId, null, "Resolved via web console");
    }

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
