package service;

import controller.WateringCommandServlet;
import dao.AlertDAO;
import dao.SystemLogDAO;
import dao.WateringSessionDAO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import util.AppConfig;
import util.DBContext;

/**
 * Core Mathematical, Auto-Watering & 4-Alert Generation Engine:
 *   1. DRY_STRESS (Khô hạn):      moisture < min_moisture_threshold (+ Tự động kích hoạt Bơm AUTO)
 *   2. SENSOR_FAULT (Lỗi mạch):   Mất tín hiệu DHT11/HX711 (NaN / < -500) hoặc sai lệch vật lý sau tưới
 *   3. OVERWATER (Ngập úng):      moisture > max_moisture_threshold (+ Tự động ngắt Bơm khẩn cấp)
 *   4. LEAK (Rò rỉ nước):         Độ ẩm đất tụt giảm đột ngột (>= 15% trong <= 10 phút) dựa trên lịch sử SensorReading
 *                                 hoặc tốc độ sụt khối lượng cân Loadcell > 0.5 kg/h
 */
public class AlertService {

    private static final Logger LOGGER = Logger.getLogger(AlertService.class.getName());
    /** Cooldown 30 giây giữa các lần tự động kích hoạt bơm cho cùng 1 chậu để chờ nước ngấm vào đất */
    private static final long AUTO_WATER_COOLDOWN_MS = 30_000L;
    /** Ngưỡng tụt giảm độ ẩm đột ngột (%) để phát hiện Rò rỉ nước (Leak Detection) */
    private static final double LEAK_MOISTURE_DROP_THRESHOLD = 15.0;
    /** Cửa sổ thời gian tối đa (phút) để đánh giá độ ẩm tụt nhanh bất thường */
    private static final double LEAK_TIME_WINDOW_MINUTES = 10.0;

    private static final Map<Integer, Long> LAST_AUTO_WATER_TIME = new ConcurrentHashMap<>();
    private static final Map<Integer, TelemetryEvaluationResult> LAST_EVALUATION = new ConcurrentHashMap<>();

    private final AlertDAO alertDAO = new AlertDAO();
    private final SystemLogDAO logDAO = new SystemLogDAO();

    /**
     * Chứa thông tin ngưỡng tưới tự động và tên loại cây đang trồng trong chậu.
     */
    public static final class PotPlantThreshold {
        public final int potId;
        public final String potName;
        public final String areaName;
        public final String plantName;
        public final double minMoisture;
        public final double maxMoisture;
        public final int waterAmountMl;
        public final boolean autoWateringEnabled;

        public PotPlantThreshold(int potId, String potName, String areaName, String plantName,
                                 double minMoisture, double maxMoisture, int waterAmountMl, boolean autoWateringEnabled) {
            this.potId = potId;
            this.potName = potName != null && !potName.trim().isEmpty() ? potName.trim() : ("Pot #" + potId);
            this.areaName = areaName != null && !areaName.trim().isEmpty() ? areaName.trim() : "Default Area";
            this.plantName = plantName != null && !plantName.trim().isEmpty() ? plantName.trim() : "Plant";
            this.minMoisture = minMoisture;
            this.maxMoisture = maxMoisture;
            this.waterAmountMl = waterAmountMl > 0 ? waterAmountMl : 250;
            this.autoWateringEnabled = autoWateringEnabled;
        }
    }

    /**
     * Kết quả đánh giá Telemetry trả về cho SensorApiServlet để phản hồi trực tiếp cho ESP8266.
     */
    public static final class TelemetryEvaluationResult {
        public final String alertType;
        public final String alertMessage;
        public final boolean autoWaterTriggered;
        public final int autoWaterDurationSeconds;

        public TelemetryEvaluationResult(String alertType, String alertMessage,
                                         boolean autoWaterTriggered, int autoWaterDurationSeconds) {
            this.alertType = alertType;
            this.alertMessage = alertMessage;
            this.autoWaterTriggered = autoWaterTriggered;
            this.autoWaterDurationSeconds = autoWaterDurationSeconds;
        }
    }

    public static TelemetryEvaluationResult getLastEvaluation(int potId) {
        return LAST_EVALUATION.get(potId);
    }

    /**
     * Truy vấn thông tin Khu vực (Area), Chậu cây (Pot) và Ngưỡng độ ẩm của Cây trồng (Plant).
     */
    public static PotPlantThreshold getPotPlantThreshold(int potId) {
        String sql = "SELECT p.pot_name, COALESCE(a.area_name, p.location) AS area_name, pl.plant_name, "
                   + "       COALESCE(pl.min_moisture_threshold, pl.ideal_moisture_min, 35.0) AS min_m, "
                   + "       COALESCE(pl.max_moisture_threshold, pl.ideal_moisture_max, 75.0) AS max_m, "
                   + "       COALESCE(pl.water_amount_ml, 250) AS water_ml, "
                   + "       COALESCE(p.auto_watering_enabled, 1) AS auto_en "
                   + "FROM Pot p "
                   + "LEFT JOIN Area a ON p.area_id = a.area_id "
                   + "JOIN Plant pl ON p.plant_id = pl.plant_id "
                   + "WHERE p.pot_id = ?";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, potId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String potName = rs.getString("pot_name");
                    String areaName = rs.getString("area_name");
                    String plantName = rs.getString("plant_name");
                    double min = rs.getDouble("min_m");
                    if (rs.wasNull() || min <= 0) {
                        min = AppConfig.DEFAULT_MOISTURE_MIN;
                    }
                    double max = rs.getDouble("max_m");
                    if (rs.wasNull() || max <= 0) {
                        max = AppConfig.DEFAULT_MOISTURE_MAX;
                    }
                    int waterMl = rs.getInt("water_ml");
                    boolean autoEn = rs.getBoolean("auto_en");
                    return new PotPlantThreshold(potId, potName, areaName, plantName, min, max, waterMl, autoEn);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "getPotPlantThreshold error: {0}", e.getMessage());
        }
        return new PotPlantThreshold(potId, "Pot #" + potId, "Default Area", "Plant",
                AppConfig.DEFAULT_MOISTURE_MIN, AppConfig.DEFAULT_MOISTURE_MAX, 250, true);
    }

    public static double calculateRetainRatio(double weightBefore, double weightAfter, double waterMl) {
        if (waterMl <= 0) {
            return 0.0;
        }
        double deltaWeight = weightAfter - weightBefore;
        double retainedMl = (Math.abs(weightBefore) < 100.0 && Math.abs(weightAfter) < 100.0)
                ? (deltaWeight * 1000.0)
                : deltaWeight;
        double ratio = retainedMl / waterMl;
        return Math.max(0.0, Math.min(1.0, Math.round(ratio * 100.0) / 100.0));
    }

    public static double calculateWaterWaste(double waterMl, double retainRatio) {
        if (waterMl <= 0) {
            return 0.0;
        }
        double clamped = Math.max(0.0, Math.min(1.0, retainRatio));
        return waterMl - (clamped * waterMl);
    }

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
     * Ghi nhận trực tiếp cảnh báo Lỗi cảm biến (SENSOR_FAULT) khi phần cứng ESP8266
     * phát hiện mất tín hiệu DHT11 (NaN) hoặc Loadcell HX711 (< -500).
     */
    public void recordHardwareSensorFault(int potId, String faultDetail) {
        PotPlantThreshold threshold = getPotPlantThreshold(potId);
        String msg = (faultDetail != null && !faultDetail.trim().isEmpty())
                ? faultDetail.trim()
                : String.format("Mất tín hiệu từ cảm biến DHT11 hoặc Loadcell HX711 tại %s (%s). Vui lòng kiểm tra dây cắm phần cứng.",
                        threshold.potName, threshold.plantName);
        alertDAO.insertAlert(potId, null, "SENSOR_FAULT", msg);
        logDAO.log("WARN", "ALERT_ENGINE", "SENSOR_FAULT on Pot #" + potId + ": " + msg);
        LAST_EVALUATION.put(potId, new TelemetryEvaluationResult("SENSOR_FAULT", msg, false, 0));
    }

    /**
     * Evaluates post-watering rules: OVERWATER, SENSOR_FAULT, and CALIBRATION_MISSING.
     */
    public void analyzeWateringSession(int potId, int sessionId, double waterMl, double retainRatio,
                                       double moistureBefore, double moistureAfter) {

        if (waterMl >= 1000.0 && retainRatio < 0.5) {
            double wasteMl = calculateWaterWaste(waterMl, retainRatio);
            String msg = String.format(
                    "Over-watering detected: %.0f ml delivered, but retention ratio was only %.0f%% (estimated waste: %.0f ml).",
                    waterMl, retainRatio * 100.0, wasteMl);
            alertDAO.insertAlert(potId, sessionId, "OVERWATER", msg);
            logDAO.log("WARN", "ALERT_ENGINE", "OVERWATER on Pot #" + potId + ": " + msg);
        }

        if (waterMl > 0 && moistureAfter <= moistureBefore) {
            String msg = String.format(
                    "Possible sensor fault: %.0f ml delivered, but soil moisture did not increase (Before: %.1f%%, After: %.1f%%).",
                    waterMl, moistureBefore, moistureAfter);
            alertDAO.insertAlert(potId, sessionId, "SENSOR_FAULT", msg);
            logDAO.log("WARN", "ALERT_ENGINE", "SENSOR_FAULT on Pot #" + potId + ": " + msg);
        }

        checkPumpCalibration(potId, sessionId);
    }

    /**
     * Đánh giá toàn diện dữ liệu cảm biến gửi về (4 Loại Cảnh báo + Tự động Bật/Tắt Bơm theo ngưỡng):
     *   1. LEAK (Rò rỉ nước): Độ ẩm đất sụt giảm đột ngột >= 15% trong <= 10 phút so với bản ghi trước.
     *   2. OVERWATER (Ngập úng): Độ ẩm đất > max_moisture_threshold -> Cảnh báo & Ngắt bơm ngay lập tức.
     *   3. DRY_STRESS (Khô hạn): Độ ẩm đất < min_moisture_threshold -> Cảnh báo & Tự động bật bơm (AUTO).
     *   4. SENSOR_FAULT (Lỗi cảm biến): Cân nặng thay đổi >= 0.4kg nhưng độ ẩm đứng yên < 0.3%.
     */
    public void evaluateIncomingTelemetry(int potId, double currentMoisture, Double currentWeightKg) {
        PotPlantThreshold threshold = getPotPlantThreshold(potId);
        double dryRate = 0.0;
        double moistureDrop = 0.0;
        double prevMoistureVal = currentMoisture;
        double deltaSeconds = 0.0;
        boolean sensorFaultDetected = false;
        String triggeredType = null;
        String triggeredMsg = null;
        boolean autoWaterStarted = false;
        int autoDuration = 0;

        try (Connection cn = DBContext.getConnection()) {
            String sqlPrev = "SELECT TOP 2 r.moisture_level, r.weight_kg, r.recorded_at "
                           + "FROM SensorReading r JOIN Sensor s ON r.sensor_id = s.sensor_id "
                           + "WHERE s.pot_id = ? ORDER BY r.recorded_at DESC, r.reading_id DESC";
            try (PreparedStatement ps = cn.prepareStatement(sqlPrev)) {
                ps.setInt(1, potId);
                try (ResultSet rs = ps.executeQuery()) {
                    // Dòng 1 là bản ghi vừa insert, dòng 2 là bản ghi lịch sử liền trước đó
                    if (rs.next() && rs.next()) {
                        prevMoistureVal = rs.getDouble("moisture_level");
                        Double prevWeight = rs.getObject("weight_kg") != null ? rs.getDouble("weight_kg") : null;
                        Timestamp prevTime = rs.getTimestamp("recorded_at");
                        Timestamp now = new Timestamp(System.currentTimeMillis());

                        if (prevTime != null) {
                            deltaSeconds = Math.max(1.0, (now.getTime() - prevTime.getTime()) / 1000.0);
                            double deltaMinutes = deltaSeconds / 60.0;
                            if (deltaMinutes <= LEAK_TIME_WINDOW_MINUTES) {
                                moistureDrop = prevMoistureVal - currentMoisture;
                            }
                        }

                        if (currentWeightKg != null && prevWeight != null) {
                            double weightChange = Math.abs(currentWeightKg - prevWeight);
                            double moistureChange = Math.abs(currentMoisture - prevMoistureVal);

                            // RULE 2B: SENSOR_FAULT (Khối lượng thay đổi >= 0.4kg nhưng độ ẩm đứng yên)
                            if (weightChange >= 0.4 && moistureChange < 0.3) {
                                String msg = String.format(
                                        "Phát hiện bất thường cảm biến (%s): Khối lượng chậu thay đổi %.2f kg nhưng độ ẩm đất giữ nguyên ở mức %.1f%%.",
                                        threshold.plantName, weightChange, currentMoisture);
                                alertDAO.insertAlert(potId, null, "SENSOR_FAULT", msg);
                                logDAO.log("WARN", "ALERT_ENGINE", "SENSOR_FAULT on Pot #" + potId + ": " + msg);
                                sensorFaultDetected = true;
                                triggeredType = "SENSOR_FAULT";
                                triggeredMsg = msg;
                            }

                            dryRate = calculateDryRate(prevWeight, currentWeightKg, prevTime, now);
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "evaluateIncomingTelemetry error: {0}", e.getMessage());
        }

        // 1. KIỂM TRA CẢNH BÁO RÒ RỈ NƯỚC (LEAK DETECTION - Xử lý trên Backend dựa vào lịch sử SensorReading)
        if (moistureDrop >= LEAK_MOISTURE_DROP_THRESHOLD
                || (dryRate > 0.5 && !isWateringSessionActive(potId))) {
            String msg;
            if (moistureDrop >= LEAK_MOISTURE_DROP_THRESHOLD) {
                msg = String.format(
                        "Cảnh báo rò rỉ nước (%s - %s): Độ ẩm đất tụt giảm đột ngột %.1f%% (từ %.1f%% xuống %.1f%%) chỉ trong %.0f giây!",
                        threshold.potName, threshold.plantName, moistureDrop, prevMoistureVal, currentMoisture, deltaSeconds);
            } else {
                msg = String.format(
                        "Cảnh báo rò rỉ nước (%s - %s): Khối lượng chậu giảm bất thường với tốc độ %.2f kg/giờ khi không tưới.",
                        threshold.potName, threshold.plantName, dryRate);
            }
            alertDAO.insertAlert(potId, null, "LEAK", msg);
            logDAO.log("WARN", "ALERT_ENGINE", "LEAK on Pot #" + potId + ": " + msg);
            triggeredType = "LEAK";
            triggeredMsg = msg;
        }

        // 2. KIỂM TRA CẢNH BÁO NGẬP ÚNG (OVERWATER: moisture > max_moisture_threshold)
        if (currentMoisture > threshold.maxMoisture) {
            // Nếu máy bơm đang chạy thì tự động ra lệnh STOP ngay lập tức để bảo vệ cây
            WateringCommandServlet.ActivePumpState pumpState = WateringCommandServlet.getPumpState(potId);
            if (pumpState != null && pumpState.isRunning()) {
                WateringCommandServlet.enqueueStop(potId);
            }
            String msg = String.format(
                    "Cảnh báo ngập úng (%s - %s): Độ ẩm đất hiện tại đạt %.1f%%, vượt ngưỡng tối đa cho phép (%.1f%%). Đã tự động khóa máy bơm!",
                    threshold.potName, threshold.plantName, currentMoisture, threshold.maxMoisture);
            alertDAO.insertAlert(potId, null, "OVERWATER", msg);
            logDAO.log("WARN", "ALERT_ENGINE", "OVERWATER on Pot #" + potId + ": " + msg);
            if (triggeredType == null) {
                triggeredType = "OVERWATER";
                triggeredMsg = msg;
            }
        }

        // 3. KIỂM TRA CẢNH BÁO KHÔ HẠN & KÍCH HOẠT TƯỚI TỰ ĐỘNG (DRY_STRESS: moisture < min_moisture_threshold)
        else if (currentMoisture < threshold.minMoisture) {
            long nowMs = System.currentTimeMillis();
            Long lastAutoMs = LAST_AUTO_WATER_TIME.get(potId);
            WateringCommandServlet.ActivePumpState pumpState = WateringCommandServlet.getPumpState(potId);
            boolean pumpAlreadyRunning = pumpState != null && pumpState.isRunning();

            if (threshold.autoWateringEnabled && !pumpAlreadyRunning
                    && (lastAutoMs == null || (nowMs - lastAutoMs) >= AUTO_WATER_COOLDOWN_MS)) {
                LAST_AUTO_WATER_TIME.put(potId, nowMs);
                // Tính thời gian bơm tự động (mặc định 5 - 10 giây an toàn cho mô hình chậu cây)
                autoDuration = 6;
                try {
                    double rate = new WateringSessionDAO().getEffectivePumpRate(potId);
                    if (rate > 0) {
                        int calcSec = (int) Math.ceil(threshold.waterAmountMl / rate);
                        autoDuration = Math.max(5, Math.min(15, calcSec));
                    }
                } catch (Exception ignored) {
                }
                WateringCommandServlet.enqueueStart(potId, autoDuration);
                recordAutoWateringSession(potId, autoDuration, threshold.waterAmountMl);
                autoWaterStarted = true;
            }

            String msg = String.format(
                    "Cảnh báo khô hạn (%s - %s): Độ ẩm đất hiện tại %.1f%% thấp hơn ngưỡng kích hoạt tưới (%.1f%%). %s",
                    threshold.potName, threshold.plantName, currentMoisture, threshold.minMoisture,
                    (autoWaterStarted ? ("Hệ thống đã tự động bật máy bơm " + autoDuration + " giây!") : "Cần bổ sung nước cho cây."));
            alertDAO.insertAlert(potId, null, "DRY_STRESS", msg);
            logDAO.log("WARN", "ALERT_ENGINE", "DRY_STRESS on Pot #" + potId + ": " + msg);
            if (triggeredType == null) {
                triggeredType = "DRY_STRESS";
                triggeredMsg = msg;
            }
        }

        if (!sensorFaultDetected && triggeredType == null) {
            LAST_EVALUATION.remove(potId);
        } else {
            LAST_EVALUATION.put(potId, new TelemetryEvaluationResult(triggeredType, triggeredMsg, autoWaterStarted, autoDuration));
        }
    }

    private void recordAutoWateringSession(int potId, int durationSeconds, int waterMl) {
        String sql = "INSERT INTO WateringSession (pot_id, start_time, duration_seconds, status, source) "
                   + "VALUES (?, GETDATE(), ?, 'COMPLETED', 'AUTO')";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, potId);
            ps.setInt(2, durationSeconds);
            ps.executeUpdate();
            logDAO.log("INFO", "AUTO_IRRIGATION",
                    "Auto-watering triggered for Pot #" + potId + " (" + durationSeconds + "s, ~" + waterMl + "ml)");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "recordAutoWateringSession error: {0}", e.getMessage());
        }
    }

    public void checkSensorReading(int potId, double currentMoisture, double dryRate) {
        evaluateIncomingTelemetry(potId, currentMoisture, null);
    }

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
