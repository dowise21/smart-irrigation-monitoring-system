package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import service.AlertService;
import util.DBContext;

public class WateringSessionDAO {

    private static final Logger LOGGER = Logger.getLogger(WateringSessionDAO.class.getName());

    /** Default fallback pump throughput (ml/sec) if PumpCalibration is not yet recorded. */
    public static final int PUMP_RATE_ML_PER_SECOND = 50;

    /**
     * Resolves calibrated pump rate (ml/sec) from PumpCalibration table, falling back to 50 ml/sec.
     */
    public double getEffectivePumpRate(int potId) {
        return new PumpCalibrationDAO().getLatestFlowRate(potId, PUMP_RATE_ML_PER_SECOND);
    }

    /**
     * Records a manual watering command: one WateringSession row plus the
     * delivered volume and calculated retain_ratio in WaterAnalysis.
     *
     * @return the new session id, or 0 when the insert failed
     */
    public int insertManualWatering(int potId, int durationSeconds, double volumeMl) {
        return insertSession(potId, durationSeconds, volumeMl, "MANUAL");
    }

    /** Backwards compatible overload: volume is derived from the calibrated pump rate. */
    public boolean insertManualWatering(int potId, int durationSeconds) {
        double rate = getEffectivePumpRate(potId);
        return insertManualWatering(potId, durationSeconds, (double) durationSeconds * rate) > 0;
    }

    /**
     * @param source MANUAL, SCHEDULED, AUTO or DEVICE
     */
    public int insertSession(int potId, int durationSeconds, double volumeMl, String source) {
        return insertSession(potId, durationSeconds, volumeMl, source, "COMPLETED", null);
    }

    /**
     * @param status      COMPLETED, STOPPED or FAILED
     * @param retainRatio fraction of the water the soil retained (0..1), or null to compute from weight_before/weight_after
     */
    public int insertSession(int potId, int durationSeconds, double volumeMl, String source,
            String status, Double retainRatio) {
        return insertSessionWithWeights(potId, durationSeconds, volumeMl, source, status, null, null, retainRatio);
    }

    public int insertSessionWithWeights(int potId, int durationSeconds, double volumeMl, String source,
            String status, Double weightBeforeKg, Double weightAfterKg, Double retainRatio) {
        String sqlSession = "INSERT INTO WateringSession (pot_id, duration_seconds, status, source, start_time) "
                + "VALUES (?, ?, ?, ?, GETDATE())";
        String sqlAnalysis = "INSERT INTO WaterAnalysis (session_id, weight_before, weight_after, water_ml, retain_ratio) "
                + "VALUES (?, ?, ?, ?, ?)";

        Connection cn = null;
        int sessionId = 0;
        double effectiveRetain = 0.75;
        double moistureBefore = 50.0;
        double moistureAfter = 60.0;

        try {
            cn = DBContext.getConnection();
            cn.setAutoCommit(false);

            // Query latest sensor reading for pot to get realistic weight_before and moisture_before
            double latestWeight = 5.5;
            String sqlLatest = "SELECT TOP 1 r.moisture_level, r.weight_kg FROM SensorReading r "
                             + "JOIN Sensor s ON r.sensor_id = s.sensor_id "
                             + "WHERE s.pot_id = ? ORDER BY r.recorded_at DESC, r.reading_id DESC";
            try (PreparedStatement psLat = cn.prepareStatement(sqlLatest)) {
                psLat.setInt(1, potId);
                try (ResultSet rsLat = psLat.executeQuery()) {
                    if (rsLat.next()) {
                        moistureBefore = rsLat.getDouble("moisture_level");
                        double w = rsLat.getDouble("weight_kg");
                        if (!rsLat.wasNull() && w > 0) {
                            latestWeight = w;
                        }
                    }
                }
            }

            double wBefore = weightBeforeKg != null ? weightBeforeKg : latestWeight;
            double wAfter;
            if (weightAfterKg != null) {
                wAfter = weightAfterKg;
            } else if (retainRatio != null) {
                wAfter = Math.round((wBefore + (volumeMl / 1000.0) * Math.max(0.0, Math.min(1.0, retainRatio))) * 100.0) / 100.0;
            } else {
                // Estimate soil retention based on moisture saturation (drier soil retains more, saturated soil drains excess)
                double estimatedRetention = moistureBefore >= 75.0 ? 0.42 : (moistureBefore >= 60.0 ? 0.65 : 0.80);
                wAfter = Math.round((wBefore + (volumeMl / 1000.0) * estimatedRetention) * 100.0) / 100.0;
            }

            // Exact Formula: Retain Ratio = (weight_after - weight_before) / water_ml
            effectiveRetain = retainRatio != null
                    ? Math.max(0.0, Math.min(1.0, retainRatio))
                    : AlertService.calculateRetainRatio(wBefore, wAfter, volumeMl);
            moistureAfter = Math.min(95.0, Math.round((moistureBefore + Math.max(1.5, volumeMl / 500.0)) * 10.0) / 10.0);

            try (PreparedStatement ps = cn.prepareStatement(sqlSession, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, potId);
                ps.setInt(2, durationSeconds);
                ps.setString(3, status);
                ps.setString(4, source);
                if (ps.executeUpdate() > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) {
                            sessionId = rs.getInt(1);
                        }
                    }
                }
            }
            if (sessionId > 0) {
                try (PreparedStatement ps = cn.prepareStatement(sqlAnalysis)) {
                    ps.setInt(1, sessionId);
                    ps.setDouble(2, wBefore);
                    ps.setDouble(3, wAfter);
                    ps.setDouble(4, volumeMl);
                    ps.setDouble(5, effectiveRetain);
                    ps.executeUpdate();
                }
            }
            cn.commit();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "insertSession failed: {0}", e.getMessage());
            try {
                if (cn != null) {
                    cn.rollback();
                }
            } catch (SQLException ignored) {
            }
            sessionId = 0;
        } finally {
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (SQLException ignored) {
            }
        }

        if (sessionId > 0) {
            new AlertService().analyzeWateringSession(potId, sessionId, volumeMl, effectiveRetain, moistureBefore, moistureAfter);
        }
        return sessionId;
    }
}