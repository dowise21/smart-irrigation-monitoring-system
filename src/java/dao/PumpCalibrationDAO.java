package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import util.DBContext;

/**
 * Data Access Object for Pump and PumpCalibration tables.
 */
public class PumpCalibrationDAO {

    private static final Logger LOGGER = Logger.getLogger(PumpCalibrationDAO.class.getName());

    /**
     * Returns the latest calibrated flow rate (ml/sec) for the pump attached to a pot,
     * or fallbackRate if no calibration exists.
     */
    public double getLatestFlowRate(int potId, double fallbackRate) {
        String sql = "SELECT TOP 1 pc.flow_rate_ml_per_sec "
                   + "FROM PumpCalibration pc "
                   + "JOIN Pump pu ON pu.pump_id = pc.pump_id "
                   + "WHERE pu.pot_id = ? AND pu.status = 1 "
                   + "ORDER BY pc.calibrated_at DESC, pc.calibration_id DESC";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, potId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double rate = rs.getDouble("flow_rate_ml_per_sec");
                    if (rate > 0) {
                        return rate;
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Could not load pump calibration for potId={0}: {1}",
                    new Object[]{potId, e.getMessage()});
        }
        return fallbackRate;
    }

    /**
     * Retrieves all pumps with their latest calibration info.
     */
    public List<Map<String, Object>> getAllPumpsWithCalibration() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT pu.pump_id, pu.pot_id, pu.pump_name, pu.status, p.pot_name, "
                   + "       pc.calibration_id, pc.flow_rate_ml_per_sec, pc.calibrated_at, u.full_name AS calibrated_by_name "
                   + "FROM Pump pu "
                   + "JOIN Pot p ON p.pot_id = pu.pot_id "
                   + "OUTER APPLY ( "
                   + "    SELECT TOP 1 calibration_id, flow_rate_ml_per_sec, calibrated_at, calibrated_by "
                   + "    FROM PumpCalibration WHERE pump_id = pu.pump_id ORDER BY calibrated_at DESC, calibration_id DESC "
                   + ") pc "
                   + "LEFT JOIN AppUser u ON u.user_id = pc.calibrated_by "
                   + "ORDER BY pu.pump_id ASC";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("pumpId", rs.getInt("pump_id"));
                row.put("potId", rs.getInt("pot_id"));
                row.put("pumpName", rs.getString("pump_name"));
                row.put("potName", rs.getString("pot_name"));
                row.put("status", rs.getBoolean("status"));
                int calId = rs.getInt("calibration_id");
                row.put("calibrationId", rs.wasNull() ? null : calId);
                double flow = rs.getDouble("flow_rate_ml_per_sec");
                row.put("flowRateMlPerSec", rs.wasNull() ? null : flow);
                Timestamp calAt = rs.getTimestamp("calibrated_at");
                row.put("calibratedAt", calAt);
                row.put("calibratedByName", rs.getString("calibrated_by_name"));
                list.add(row);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getAllPumpsWithCalibration: {0}", e.getMessage());
        }
        return list;
    }

    /**
     * Retrieves calibration history records using PreparedStatement.
     */
    public List<Map<String, Object>> getCalibrationHistory(int page, int size) {
        List<Map<String, Object>> list = new ArrayList<>();
        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(100, size));
        String sql = "SELECT pc.calibration_id, pc.pump_id, pc.flow_rate_ml_per_sec, pc.calibrated_at, "
                   + "       pu.pump_name, pu.pot_id, p.pot_name, u.full_name AS calibrated_by_name "
                   + "FROM PumpCalibration pc "
                   + "JOIN Pump pu ON pu.pump_id = pc.pump_id "
                   + "JOIN Pot p ON p.pot_id = pu.pot_id "
                   + "LEFT JOIN AppUser u ON u.user_id = pc.calibrated_by "
                   + "ORDER BY pc.calibrated_at DESC, pc.calibration_id DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, (safePage - 1) * safeSize);
            ps.setInt(2, safeSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("calibrationId", rs.getInt("calibration_id"));
                    row.put("pumpId", rs.getInt("pump_id"));
                    row.put("potId", rs.getInt("pot_id"));
                    row.put("pumpName", rs.getString("pump_name"));
                    row.put("potName", rs.getString("pot_name"));
                    row.put("flowRateMlPerSec", rs.getDouble("flow_rate_ml_per_sec"));
                    row.put("calibratedAt", rs.getTimestamp("calibrated_at"));
                    row.put("calibratedByName", rs.getString("calibrated_by_name"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in getCalibrationHistory: {0}", e.getMessage());
        }
        return list;
    }

    /**
     * Inserts a new PumpCalibration record for a given pump_id (or pot_id's pump).
     */
    public boolean insertCalibration(int pumpId, double flowRateMlPerSec, Integer calibratedByUserId) {
        String sql = "INSERT INTO PumpCalibration (pump_id, flow_rate_ml_per_sec, calibrated_by, calibrated_at) "
                   + "VALUES (?, ?, ?, GETDATE())";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, pumpId);
            ps.setDouble(2, flowRateMlPerSec);
            if (calibratedByUserId != null && calibratedByUserId > 0) {
                ps.setInt(3, calibratedByUserId);
            } else {
                ps.setNull(3, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in insertCalibration: {0}", e.getMessage());
        }
        return false;
    }
}

