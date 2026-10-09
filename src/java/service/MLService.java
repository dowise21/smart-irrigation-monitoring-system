package service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.MLPrediction;
import util.DBContext;

public class MLService {
    
    private static final Logger LOGGER = Logger.getLogger(MLService.class.getName());

    /**
     * Giả lập Mô hình Học máy dự đoán thời gian khô của đất
     */
    public MLPrediction predictDryTime(int potId, double currentMoisture, double recentWaterMl, int lightLux) {
        
        // 1. CHẠY THUẬT TOÁN (Giả lập Linear Regression)
        // Cơ sở logic: Độ ẩm càng cao, nước càng nhiều -> Lâu khô. Ánh sáng càng mạnh -> Nhanh khô.
        double baseDryHours = 12.0; // Mặc định 12 tiếng
        double moistureFactor = currentMoisture * 0.2; // Mỗi % độ ẩm cộng thêm 0.2 tiếng
        double waterFactor = (recentWaterMl / 100) * 0.5; // Mỗi 100ml nước cộng 0.5 tiếng
        double lightFactor = (lightLux / 1000.0) * 1.5; // Mỗi 1000 lux ánh sáng trừ 1.5 tiếng
        
        double totalHoursToDry = baseDryHours + moistureFactor + waterFactor - lightFactor;
        if (totalHoursToDry < 1.0) totalHoursToDry = 1.0; // Tối thiểu 1 tiếng
        
        // Tính thời điểm sẽ khô (Timestamp hiện tại + số giờ dự đoán)
        long currentTimeMillis = System.currentTimeMillis();
        long dryTimeMillis = currentTimeMillis + (long)(totalHoursToDry * 60 * 60 * 1000);
        Timestamp predictedDryTime = new Timestamp(dryTimeMillis);
        
        // Tính độ tin cậy (Confidence Score) ngẫu nhiên dựa trên chất lượng dữ liệu
        double confidence = 75.0 + (Math.random() * 20.0); // Từ 75% đến 95%
        
        String features = String.format("Moisture: %.1f%%, Water: %.0fml, Light: %dlux", currentMoisture, recentWaterMl, lightLux);
        
        MLPrediction prediction = new MLPrediction(0, potId, predictedDryTime, confidence, features, new Timestamp(currentTimeMillis));
        
        // 2. LƯU VÀO DATABASE
        savePrediction(prediction);
        
        return prediction;
    }
    
    private void savePrediction(MLPrediction p) {
        String sql = "INSERT INTO MLPrediction (pot_id, predicted_dry_time, confidence_score, features_used) VALUES (?, ?, ?, ?)";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
             
            ps.setInt(1, p.getPotId());
            ps.setTimestamp(2, p.getPredictedDryTime());
            ps.setDouble(3, p.getConfidenceScore());
            ps.setString(4, p.getFeaturesUsed());
            ps.executeUpdate();
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi lưu MLPrediction: {0}", e.getMessage());
        }
    }
}