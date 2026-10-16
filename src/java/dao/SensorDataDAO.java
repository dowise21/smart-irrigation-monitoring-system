package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.SensorData;
import service.AlertService;
import util.DBContext;

public class SensorDataDAO {

    private static final Logger LOGGER = Logger.getLogger(SensorDataDAO.class.getName());

    private static final String SELECT_BASE =
        "SELECT r.reading_id AS data_id, s.pot_id, r.moisture_level, r.weight_kg, r.light_lux, " +
        "       r.source, r.recorded_at, p.pot_name, pl.plant_name " +
        "FROM SensorReading r " +
        "JOIN Sensor s ON r.sensor_id = s.sensor_id " +
        "JOIN Pot p ON s.pot_id = p.pot_id " +
        "JOIN Plant pl ON p.plant_id = pl.plant_id ";

    private SensorData map(ResultSet rs) throws SQLException {
        SensorData s = new SensorData();
        s.setDataId(rs.getInt("data_id"));
        s.setPotId(rs.getInt("pot_id"));
        s.setMoistureLevel(rs.getDouble("moisture_level"));
        double w = rs.getDouble("weight_kg");
        s.setWeightKg(rs.wasNull() ? null : w);
        int lux = rs.getInt("light_lux");
        s.setLightLux(rs.wasNull() ? null : lux);
        s.setSource(rs.getString("source"));
        s.setRecordedAt(rs.getTimestamp("recorded_at"));
        s.setPotName(rs.getString("pot_name"));
        s.setPlantName(rs.getString("plant_name"));
        return s;
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (cn != null) cn.close(); } catch (SQLException ignored) {}
    }

    /**
     * Lấy danh sách độ ẩm mới nhất.
     */
    public List<SensorData> getRecentData(int potId, int limit) {
        return getPaginatedData(potId, null, null, 1, limit);
    }

    /**
     * Server-side pagination + filtering by potId and date range (OFFSET ? ROWS FETCH NEXT ? ROWS ONLY)
     */
    public List<SensorData> getPaginatedData(int potId, String fromDate, String toDate, int page, int size) {
        List<SensorData> out = new ArrayList<>();
        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(500, size));

        StringBuilder sql = new StringBuilder(SELECT_BASE).append(" WHERE 1 = 1 ");
        if (potId > 0) {
            sql.append(" AND s.pot_id = ? ");
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND r.recorded_at >= TRY_CAST(? AS DATETIME) ");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND r.recorded_at < DATEADD(DAY, 1, TRY_CAST(? AS DATETIME)) ");
        }
        sql.append(" ORDER BY r.recorded_at DESC, r.reading_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (potId > 0) {
                ps.setInt(idx++, potId);
            }
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(idx++, fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(idx++, toDate.trim());
            }
            ps.setInt(idx++, (safePage - 1) * safeSize);
            ps.setInt(idx, safeSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại getPaginatedData: {0}", e.getMessage());
        }
        return out;
    }

    public int countData(int potId, String fromDate, String toDate) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM SensorReading r JOIN Sensor s ON r.sensor_id = s.sensor_id WHERE 1 = 1 ");
        if (potId > 0) {
            sql.append(" AND s.pot_id = ? ");
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append(" AND r.recorded_at >= TRY_CAST(? AS DATETIME) ");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append(" AND r.recorded_at < DATEADD(DAY, 1, TRY_CAST(? AS DATETIME)) ");
        }
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (potId > 0) {
                ps.setInt(idx++, potId);
            }
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(idx++, fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(idx++, toDate.trim());
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại countData: {0}", e.getMessage());
        }
        return 0;
    }

    public boolean insert(int potId, double moisture) {
        return insert(potId, moisture, null, null);
    }

    /**
     * Lưu dữ liệu cảm biến (Moisture, Weight, Light) và tự động kích hoạt AlertService.
     */
    public boolean insert(int potId, double moisture, Double weightKg, Integer lightLux) {
        String sql = "INSERT INTO SensorReading(sensor_id, moisture_level, weight_kg, light_lux, source) "
                   + "VALUES ((SELECT TOP 1 sensor_id FROM Sensor WHERE pot_id = ?), ?, ?, ?, 'DEVICE')";

        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, potId);
            ps.setDouble(2, moisture);
            if (weightKg != null) {
                ps.setDouble(3, weightKg);
            } else {
                ps.setNull(3, java.sql.Types.FLOAT);
            }
            if (lightLux != null) {
                ps.setInt(4, lightLux);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                new AlertService().evaluateIncomingTelemetry(potId, moisture, weightKg);
            }
            return ok;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại insert SensorData: {0}", e.getMessage());
        }
        return false;
    }
}