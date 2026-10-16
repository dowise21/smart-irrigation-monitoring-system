package service;

import dao.AlertDAO;
import dao.SystemLogDAO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.logging.Level;
import java.util.logging.Logger;
import util.DBContext;

/**
 * Core Mathematical & Alert Generation Engine (5 Rules):
 *   1. OVERWATER:           water_ml >= 1000 && retain_ratio < 0.5
 *   2. DRY_STRESS:          moisture < plant's ideal_moisture_min
 *   3. SENSOR_FAULT:        (water_ml > 0 && moisture_after <= moisture_before)
 *                           OR (|delta_weight| >= 0.4 kg && |delta_moisture| < 0.3%)
 *   4. LEAK:                dry_rate (delta_weight / delta_time) > 0.5 kg/h while NO active WateringSession
 *   5. CALIBRATION_MISSING: pump attached to pot has no PumpCalibration record
 */
public class AlertService {

    private static final Logger LOGGER = Logger.getLogger(AlertService.class.getName());
    private final AlertDAO alertDAO = new AlertDAO();
    private final SystemLogDAO logDAO = new SystemLogDAO();

    /**
     * Exact Formula 1: Retain Ratio = (weight_after - weight_before) / water_ml
     * Note: When weight is measured in kg and water in ml (1000 ml = 1 kg of water),
     * we convert (weight_after - weight_before) to grams/ml if magnitude <= 20, or use direct ratio.
     */
    public static double calculateRetainRatio(double weightBefore, double weightAfter, double waterMl) {
        if (waterMl <= 0) {
            return 0.0;
        }
        double deltaWeight = weightAfter - weightBefore;
        // If weights are in kg (e.g. 5.2 kg -> 6.0 kg, delta = 0.8 kg = 800 ml), convert kg to ml (* 1000)
        double retainedMl = (Math.abs(weightBefore) < 100.0 && Math.abs(weightAfter) < 100.0)
                ? (deltaWeight * 1000.0)
                : deltaWeight;
        double ratio = retainedMl / waterMl;
        return Math.max(0.0, Math.min(1.0, Math.round(ratio * 100.0) / 100.0));
    }

    /**
     * Exact Formula 2: Water Waste = water_ml - (Retain Ratio * water_ml)
     */
    public static double calculateWaterWaste(double waterMl, double retainRatio) {
        if (waterMl <= 0) {
            return 0.0;
        }
        double clamped = Math.max(0.0, Math.min(1.0, retainRatio));
        return waterMl - (clamped * waterMl);
    }

    /**
     * Exact Formula 3: Dry Rate = delta_weight / delta_time (kg per hour)
     */
    public static double calculateDryRate(double previousWeightKg, double currentWeightKg,
                                          Timestamp previousTime, Timestamp currentTime) {
        if (previousTime == null || currentTime == null) {
            return 0.0;
        }
        double deltaHours = (currentTime.getTime() - previousTime.getTime()) / 3600000.0;
        if (deltaHours <= 0.0001) {
            return 0.0;
        }
        double deltaWeight = previousWeightKg - currentWeightKg;
        return Math.round((deltaWeight / deltaHours) * 100.0) / 100.0;
    }

    /**
     * Evaluates post-watering rules: OVERWATER, SENSOR_FAULT, and CALIBRATION_MISSING.
     */
    public void analyzeWateringSession(int potId, int sessionId, double waterMl, double retainRatio,
                                       double moistureBefore, double moistureAfter) {

        // RULE 1: OVERWATER (water_ml high >= 1000ml AND retain_ratio low < 0.5)
        if (waterMl >= 1000.0 && retainRatio < 0.5) {
            double wasteMl = calculateWaterWaste(waterMl, retainRatio);
            String msg = String.format(
                    "Over-watering detected: %.0f ml delivered, but retention ratio was only %.0f%% (estimated waste: %.0f ml).",
                    waterMl, retainRatio * 100.0, wasteMl);
            alertDAO.insertAlert(potId, sessionId, "OVERWATER", msg);
            logDAO.log("WARN", "ALERT_ENGINE", "OVERWATER on Pot #" + potId + ": " + msg);
            LOGGER.info("Recorded OVERWATER alert for pot " + potId);
        }

        // RULE 3A: SENSOR_FAULT (Water delivered > 0 but soil moisture did not increase)
        if (waterMl > 0 && moistureAfter <= moistureBefore) {
            String msg = String.format(
                    "Possible sensor fault: %.0f ml delivered, but soil moisture did not increase (Before: %.1f%%, After: %.1f%%).",
                    waterMl, moistureBefore, moistureAfter);
            alertDAO.insertAlert(potId, sessionId, "SENSOR_FAULT", msg);
            logDAO.log("WARN", "ALERT_ENGINE", "SENSOR_FAULT on Pot #" + potId + ": " + msg);
            LOGGER.info("Recorded SENSOR_FAULT alert for pot " + potId);
        }

        // RULE 5: CALIBRATION_MISSING (Pump attached to pot has no PumpCalibration record)
        checkPumpCalibration(potId, sessionId);
    }

    /**
     * Evaluates periodic sensor telemetry rules: DRY_STRESS, SENSOR_FAULT, LEAK, and CALIBRATION_MISSING.
     */
    public void checkSensorReading(int potId, double currentMoisture, double dryRate) {
        double optimalMin = getPlantOptimalMinMoisture(potId, 30.0);

        // RULE 2: DRY_STRESS (Moisture drops below plant's optimal_moisture threshold)
        if (currentMoisture < optimalMin) {
            String msg = String.format(
                    "Low soil moisture: current reading is %.1f%%, below the plant's optimal threshold (%.1f%%).",
                    currentMoisture, optimalMin);
            alertDAO.insertAlert(potId, null, "DRY_STRESS", msg);
            logDAO.log("WARN", "ALERT_ENGINE", "DRY_STRESS on Pot #" + potId + ": " + msg);
            LOGGER.info("Recorded DRY_STRESS alert for pot " + potId);
        }

        // RULE 4: LEAK (Abnormal mass decrease dryRate while NO active WateringSession is occurring)
        if (dryRate > 0.5 && !isWateringSessionActive(potId)) {
            String msg = String.format(
                    "Possible water leak: abnormal drying/mass-loss rate of %.2f kg/h while no watering session is active.",
                    dryRate);
            alertDAO.insertAlert(potId, null, "LEAK", msg);
            logDAO.log("WARN", "ALERT_ENGINE", "LEAK on Pot #" + potId + ": " + msg);
            LOGGER.info("Recorded LEAK alert for pot " + potId);
        }
    }

    /**
     * Full telemetry evaluation comparing the latest reading with the previous reading from DB.
     */
    public void evaluateIncomingTelemetry(int potId, double currentMoisture, Double currentWeightKg) {
        double dryRate = 0.0;
        try (Connection cn = DBContext.getConnection()) {
            String sqlPrev = "SELECT TOP 2 r.moisture_level, r.weight_kg, r.recorded_at "
                           + "FROM SensorReading r JOIN Sensor s ON r.sensor_id = s.sensor_id "
                           + "WHERE s.pot_id = ? ORDER BY r.recorded_at DESC, r.reading_id DESC";
            try (PreparedStatement ps = cn.prepareStatement(sqlPrev)) {
                ps.setInt(1, potId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.next()) {
                        double prevMoisture = rs.getDouble("moisture_level");
                        Double prevWeight = rs.getObject("weight_kg") != null ? rs.getDouble("weight_kg") : null;
                        Timestamp prevTime = rs.getTimestamp("recorded_at");
                        Timestamp now = new Timestamp(System.currentTimeMillis());

                        if (currentWeightKg != null && prevWeight != null) {
                            double weightChange = Math.abs(currentWeightKg - prevWeight);
                            double moistureChange = Math.abs(currentMoisture - prevMoisture);

                            // RULE 3B: SENSOR_FAULT (Weight changes significantly >= 0.4kg but moisture stays static < 0.3%)
                            if (weightChange >= 0.4 && moistureChange < 0.3) {
                                String msg = String.format(
                                        "Sensor fault suspected: pot weight changed by %.2f kg, but soil moisture remained static at %.1f%%.",
                                        weightChange, currentMoisture);
                                alertDAO.insertAlert(potId, null, "SENSOR_FAULT", msg);
                                logDAO.log("WARN", "ALERT_ENGINE", "SENSOR_FAULT on Pot #" + potId + ": " + msg);
                            }

                            dryRate = calculateDryRate(prevWeight, currentWeightKg, prevTime, now);
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "evaluateIncomingTelemetry error: {0}", e.getMessage());
        }

        checkSensorReading(potId, currentMoisture, dryRate);
    }

    /**
     * RULE 5: CALIBRATION_MISSING — Triggered if a pump on the pot has no valid PumpCalibration record.
     */
    public void checkPumpCalibration(int potId, Integer sessionId) {
        String sql = "SELECT pu.pump_id, pu.pump_name FROM Pump pu "
                   + "LEFT JOIN PumpCalibration pc ON pu.pump_id = pc.pump_id "
                   + "WHERE pu.pot_id = ? AND pc.calibration_id IS NULL "
                   + "AND NOT EXISTS (SELECT 1 FROM Alert a WHERE a.pot_id = ? AND a.alert_type = 'CALIBRATION_MISSING' AND a.is_resolved = 0)";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, potId);
            ps.setInt(2, potId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String pumpName = rs.getString("pump_name");
                    String msg = "Pump calibration missing: '" + pumpName + "' (Pot #" + potId
                               + ") has no valid PumpCalibration record. Please calibrate flow rate.";
                    alertDAO.insertAlert(potId, sessionId, "CALIBRATION_MISSING", msg);
                    logDAO.log("WARN", "ALERT_ENGINE", "CALIBRATION_MISSING on Pot #" + potId);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "checkPumpCalibration error: {0}", e.getMessage());
        }
    }

    private double getPlantOptimalMinMoisture(int potId, double fallback) {
        String sql = "SELECT pl.ideal_moisture_min FROM Pot p "
                   + "JOIN Plant pl ON p.plant_id = pl.plant_id WHERE p.pot_id = ?";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, potId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double val = rs.getDouble("ideal_moisture_min");
                    if (!rs.wasNull() && val > 0) {
                        return val;
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "getPlantOptimalMinMoisture error: {0}", e.getMessage());
        }
        return fallback;
    }

    private boolean isWateringSessionActive(int potId) {
        String sql = "SELECT 1 FROM WateringSession WHERE pot_id = ? AND status IN ('PENDING', 'RUNNING')";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, potId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            return false;
        }
    }
}