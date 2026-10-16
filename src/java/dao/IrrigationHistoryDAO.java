package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.IrrigationHistory;
import util.DBContext;

public class IrrigationHistoryDAO {

    private static final Logger LOGGER = Logger.getLogger(IrrigationHistoryDAO.class.getName());

    // JOIN WateringSession và WaterAnalysis để lấy đủ thông tin Lịch sử tưới
    private static final String SELECT_BASE =
        "SELECT s.session_id AS history_id, s.pot_id, s.start_time AS irrigation_time, " +
        "       s.duration_seconds, (a.water_ml / 1000.0) AS water_amount, " +
        "       s.status, s.source, a.retain_ratio, " +
        "       p.pot_name, pl.plant_name " +
        "FROM WateringSession s " +
        "LEFT JOIN WaterAnalysis a ON s.session_id = a.session_id " +
        "JOIN Pot p ON s.pot_id = p.pot_id " +
        "JOIN Plant pl ON p.plant_id = pl.plant_id ";

    private IrrigationHistory map(ResultSet rs) throws SQLException {
        IrrigationHistory h = new IrrigationHistory();
        h.setHistoryId(rs.getInt("history_id"));
        h.setPotId(rs.getInt("pot_id"));
        h.setIrrigationTime(rs.getTimestamp("irrigation_time"));
        
        int duration = rs.getInt("duration_seconds");
        h.setDurationSeconds(rs.wasNull() ? null : duration);
        
        double amount = rs.getDouble("water_amount");
        h.setWaterAmount(rs.wasNull() ? null : amount);
        
        h.setStatus(rs.getString("status"));
        h.setSource(rs.getString("source"));
        double retain = rs.getDouble("retain_ratio");
        h.setRetainRatio(rs.wasNull() ? null : retain);
        h.setPotName(rs.getString("pot_name"));
        h.setPlantName(rs.getString("plant_name"));
        return h;
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (cn != null) cn.close(); } catch (SQLException ignored) {}
    }

    /**
     * Lấy danh sách lịch sử tưới mới nhất
     */
    public List<IrrigationHistory> getHistory(int potId, int limit) {
        return getPaginatedHistory(potId, null, null, null, 1, limit);
    }

    /**
     * Server-side pagination + filtering by potId, status, and date range (OFFSET ? ROWS FETCH NEXT ? ROWS ONLY)
     */
    public List<IrrigationHistory> getPaginatedHistory(int potId, String status, String fromDate, String toDate, int page, int size) {
        List<IrrigationHistory> out = new ArrayList<>();
        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(1000, size));

        StringBuilder sql = new StringBuilder(SELECT_BASE).append(" WHERE 1 = 1 ");
        if (potId > 0) {
            sql.append(" AND s.pot_id = ? ");
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
            sql.append(" AND UPPER(s.status) = UPPER(?) ");
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND s.start_time >= TRY_CAST(? AS DATETIME) ");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND s.start_time < DATEADD(DAY, 1, TRY_CAST(? AS DATETIME)) ");
        }
        sql.append(" ORDER BY s.start_time DESC, s.session_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            int i = 1;
            if (potId > 0) {
                ps.setInt(i++, potId);
            }
            if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
                ps.setString(i++, status.trim());
            }
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(i++, fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(i++, toDate.trim());
            }
            ps.setInt(i++, (safePage - 1) * safeSize);
            ps.setInt(i, safeSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại getPaginatedHistory: {0}", e.getMessage());
        }
        return out;
    }

    public int countHistory(int potId, String status, String fromDate, String toDate) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM WateringSession s WHERE 1 = 1 ");
        if (potId > 0) {
            sql.append(" AND s.pot_id = ? ");
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
            sql.append(" AND UPPER(s.status) = UPPER(?) ");
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND s.start_time >= TRY_CAST(? AS DATETIME) ");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND s.start_time < DATEADD(DAY, 1, TRY_CAST(? AS DATETIME)) ");
        }
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            int i = 1;
            if (potId > 0) {
                ps.setInt(i++, potId);
            }
            if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
                ps.setString(i++, status.trim());
            }
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(i++, fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(i++, toDate.trim());
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại countHistory: {0}", e.getMessage());
        }
        return 0;
    }

    /**
     * Ghi nhận phiên tưới từ thiết bị IoT (tự động tính Retain Ratio và chạy AlertService)
     */
    public boolean insert(int potId, Integer durationSeconds, Double waterAmountLiters) {
        int dur = durationSeconds != null && durationSeconds > 0 ? durationSeconds : 30;
        double volumeMl = waterAmountLiters != null && waterAmountLiters > 0 ? (waterAmountLiters * 1000.0) : (dur * 50.0);
        return new WateringSessionDAO().insertSession(potId, dur, volumeMl, "DEVICE", "COMPLETED", null) > 0;
    }
}