package util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SampleDataGenerator {

    private static final Logger LOGGER = Logger.getLogger(SampleDataGenerator.class.getName());
    private static final Random RANDOM = new Random();

    public static void main(String[] args) {
        System.out.println("Bắt đầu tiến trình sinh dữ liệu mẫu (SAMPLE DATA GENERATOR)...");
        Connection cn = null;
        try {
            cn = DBContext.getConnection();
            if (cn == null) {
                System.out.println("Lỗi kết nối CSDL!");
                return;
            }

            // 1. Sinh 1000+ Dữ liệu cảm biến (SensorReading)
            generateSensorReadings(cn, 1, 1000);
            
            // 2. Sinh 300+ Phiên tưới và Phân tích nước (WateringSession & WaterAnalysis)
            generateWateringSessionsAndAnalysis(cn, 1, 300);

            System.out.println("Đã tạo dữ liệu thành công! Hãy kiểm tra SQL Server.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi sinh dữ liệu: {0}", e.getMessage());
        } finally {
            try { if (cn != null) cn.close(); } catch (Exception ignored) {}
        }
    }

    /**
     * Sinh 1000 dòng dữ liệu cảm biến cho một chậu cụ thể
     */
    private static void generateSensorReadings(Connection cn, int sensorId, int count) throws Exception {
        String sql = "INSERT INTO SensorReading (sensor_id, moisture_level, weight_kg, light_lux, recorded_at, source) "
                   + "VALUES (?, ?, ?, ?, ?, 'SAMPLE')";
        PreparedStatement ps = cn.prepareStatement(sql);
        
        long currentTime = System.currentTimeMillis();
        // Lùi lại quá khứ (ví dụ 30 ngày trước) để tạo dữ liệu lịch sử
        long startTime = currentTime - (30L * 24 * 60 * 60 * 1000); 
        long timeStep = (30L * 24 * 60 * 60 * 1000) / count; // Khoảng cách giữa các lần đo

        int batchSize = 0;
        for (int i = 0; i < count; i++) {
            ps.setInt(1, sensorId);
            
            // Giả lập độ ẩm dao động từ 30% đến 85%
            double moisture = 30.0 + (55.0 * RANDOM.nextDouble());
            ps.setDouble(2, Math.round(moisture * 100.0) / 100.0);
            
            // Giả lập khối lượng chậu dao động 5.0kg - 6.5kg
            double weight = 5.0 + (1.5 * RANDOM.nextDouble());
            ps.setDouble(3, Math.round(weight * 100.0) / 100.0);
            
            // Giả lập ánh sáng (Sáng ngày, tối đêm)
            int light = RANDOM.nextInt(10000); // 0 - 10000 lux
            ps.setInt(4, light);
            
            ps.setTimestamp(5, new Timestamp(startTime + (i * timeStep)));
            
            ps.addBatch();
            batchSize++;
            
            // Execute batch mỗi 100 dòng để tối ưu hiệu suất
            if (batchSize % 100 == 0) {
                ps.executeBatch();
            }
        }
        ps.executeBatch(); // Chạy nốt những dòng còn lại
        ps.close();
        System.out.println(" Đã tạo " + count + " bản ghi SensorReading.");
    }

    /**
     * Sinh 300 phiên tưới và tính toán dữ liệu phân tích (WaterAnalysis)
     */
    private static void generateWateringSessionsAndAnalysis(Connection cn, int potId, int count) throws Exception {
        String insertSessionSql = "INSERT INTO WateringSession (pot_id, start_time, duration_seconds, source) VALUES (?, ?, ?, 'SAMPLE')";
        String insertAnalysisSql = "INSERT INTO WaterAnalysis (session_id, weight_before, weight_after, water_ml, retain_ratio, moisture_before, moisture_after) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        long currentTime = System.currentTimeMillis();
        long startTime = currentTime - (30L * 24 * 60 * 60 * 1000); 
        long timeStep = (30L * 24 * 60 * 60 * 1000) / count;

        for (int i = 0; i < count; i++) {
            // 1. Tạo Session
            PreparedStatement psSession = cn.prepareStatement(insertSessionSql, PreparedStatement.RETURN_GENERATED_KEYS);
            psSession.setInt(1, potId);
            psSession.setTimestamp(2, new Timestamp(startTime + (i * timeStep)));
            psSession.setInt(3, 30 + RANDOM.nextInt(60)); // Bơm từ 30-90 giây
            psSession.executeUpdate();
            
            // Lấy session_id vừa tạo
            java.sql.ResultSet rs = psSession.getGeneratedKeys();
            if (rs.next()) {
                int sessionId = rs.getInt(1);
                
                // 2. Tạo dữ liệu phân tích hợp lý theo logic nghiệp vụ (NORMAL, OVERWATER, DRY_STRESS)
                PreparedStatement psAnalysis = cn.prepareStatement(insertAnalysisSql);
                psAnalysis.setInt(1, sessionId);
                
                double weightBefore = 5.0 + RANDOM.nextDouble();
                double waterMl = 500 + RANDOM.nextInt(1500); // Tưới 500ml - 2000ml
                
                // Trọng lượng sau khi tưới = Trọng lượng cũ + (Lượng nước * Tỷ lệ giữ nước)
                double retainRatio = 0.4 + (0.5 * RANDOM.nextDouble()); // Tỷ lệ giữ 40% - 90% (Để giả lập NORMAL và OVERWATER)
                double weightAfter = weightBefore + ((waterMl / 1000.0) * retainRatio); 
                
                double moistureBefore = 20.0 + RANDOM.nextInt(30); // 20% - 50%
                double moistureAfter = moistureBefore + (20.0 + RANDOM.nextInt(30)); // Tăng độ ẩm
                
                psAnalysis.setDouble(2, Math.round(weightBefore * 100.0) / 100.0);
                psAnalysis.setDouble(3, Math.round(weightAfter * 100.0) / 100.0);
                psAnalysis.setDouble(4, waterMl);
                psAnalysis.setDouble(5, Math.round(retainRatio * 100.0) / 100.0);
                psAnalysis.setDouble(6, Math.round(moistureBefore * 100.0) / 100.0);
                psAnalysis.setDouble(7, Math.round(moistureAfter * 100.0) / 100.0);
                
                psAnalysis.executeUpdate();
                psAnalysis.close();
            }
            rs.close();
            psSession.close();
        }
        System.out.println(" Đã tạo " + count + " phiên tưới (WateringSession) và phân tích (WaterAnalysis).");
    }
}