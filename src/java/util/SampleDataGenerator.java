package util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;
import service.AlertService;

/**
 * Generates demo data (SensorReading, WateringSession, WaterAnalysis) for reports and ML.
 * All statements are PreparedStatements managed by try-with-resources (no leaked connections).
 */
public class SampleDataGenerator {

    private static final Logger LOGGER = Logger.getLogger(SampleDataGenerator.class.getName());
    private static final Random RANDOM = new Random();

    public static void main(String[] args) {
        System.out.println("Starting SAMPLE DATA GENERATOR...");
        try (Connection cn = DBContext.getConnection()) {
            if (cn == null) {
                System.out.println("Database connection failed!");
                return;
            }

            // 1. 1000+ sensor readings (SensorReading)
            generateSensorReadings(cn, 1, 1000);

            // 2. 300+ watering sessions + water analysis (WateringSession & WaterAnalysis)
            generateWateringSessionsAndAnalysis(cn, 1, 300);

            System.out.println("Sample data created successfully. Check SQL Server.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error while generating sample data: {0}", e.getMessage());
        }
    }

    /** Generates {@code count} readings for one sensor over the last 30 days. */
    private static void generateSensorReadings(Connection cn, int sensorId, int count) throws Exception {
        String sql = "INSERT INTO SensorReading (sensor_id, moisture_level, weight_kg, light_lux, recorded_at, source) "
                   + "VALUES (?, ?, ?, ?, ?, 'SAMPLE')";

        long currentTime = System.currentTimeMillis();
        long startTime = currentTime - (30L * 24 * 60 * 60 * 1000);
        long timeStep = (30L * 24 * 60 * 60 * 1000) / count;

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            int batchSize = 0;
            for (int i = 0; i < count; i++) {
                ps.setInt(1, sensorId);

                double moisture = 30.0 + (55.0 * RANDOM.nextDouble());          // 30% - 85%
                ps.setDouble(2, Math.round(moisture * 100.0) / 100.0);

                double weight = 5.0 + (1.5 * RANDOM.nextDouble());              // 5.0 - 6.5 kg
                ps.setDouble(3, Math.round(weight * 100.0) / 100.0);

                ps.setInt(4, RANDOM.nextInt(10000));                            // 0 - 10000 lux
                ps.setTimestamp(5, new Timestamp(startTime + (i * timeStep)));

                ps.addBatch();
                batchSize++;
                if (batchSize % 100 == 0) {
                    ps.executeBatch();
                }
            }
            ps.executeBatch();
        }
        System.out.println(" Created " + count + " SensorReading rows.");
    }

    /** Generates {@code count} sessions and their analysis using the official retain-ratio formula. */
    private static void generateWateringSessionsAndAnalysis(Connection cn, int potId, int count) throws Exception {
        String insertSessionSql = "INSERT INTO WateringSession (pot_id, start_time, duration_seconds, source) VALUES (?, ?, ?, 'SAMPLE')";
        String insertAnalysisSql = "INSERT INTO WaterAnalysis (session_id, weight_before, weight_after, water_ml, retain_ratio, moisture_before, moisture_after) VALUES (?, ?, ?, ?, ?, ?, ?)";

        long currentTime = System.currentTimeMillis();
        long startTime = currentTime - (30L * 24 * 60 * 60 * 1000);
        long timeStep = (30L * 24 * 60 * 60 * 1000) / count;

        try (PreparedStatement psSession = cn.prepareStatement(insertSessionSql, Statement.RETURN_GENERATED_KEYS);
             PreparedStatement psAnalysis = cn.prepareStatement(insertAnalysisSql)) {

            for (int i = 0; i < count; i++) {
                psSession.setInt(1, potId);
                psSession.setTimestamp(2, new Timestamp(startTime + (i * timeStep)));
                psSession.setInt(3, 30 + RANDOM.nextInt(60));                   // pump 30-90 s
                psSession.executeUpdate();

                try (ResultSet rs = psSession.getGeneratedKeys()) {
                    if (!rs.next()) {
                        continue;
                    }
                    int sessionId = rs.getInt(1);

                    double weightBefore = Math.round((5.0 + RANDOM.nextDouble()) * 100.0) / 100.0;
                    double waterMl = 500 + RANDOM.nextInt(1500);                // 500 - 2000 ml

                    // Simulated physical retention (40% - 90%) drives the "after" weight...
                    double simulatedRetain = 0.4 + (0.5 * RANDOM.nextDouble());
                    double weightAfter = Math.round((weightBefore + ((waterMl / 1000.0) * simulatedRetain)) * 100.0) / 100.0;

                    // ...but the stored ratio always comes from the official formula:
                    // (weight_after - weight_before) / water_ml
                    double retainRatio = AlertService.calculateRetainRatio(weightBefore, weightAfter, waterMl);

                    double moistureBefore = 20.0 + RANDOM.nextInt(30);          // 20% - 50%
                    double moistureAfter = Math.min(100.0, moistureBefore + (20.0 + RANDOM.nextInt(30)));

                    psAnalysis.setInt(1, sessionId);
                    psAnalysis.setDouble(2, weightBefore);
                    psAnalysis.setDouble(3, weightAfter);
                    psAnalysis.setDouble(4, waterMl);
                    psAnalysis.setDouble(5, retainRatio);
                    psAnalysis.setDouble(6, Math.round(moistureBefore * 100.0) / 100.0);
                    psAnalysis.setDouble(7, Math.round(moistureAfter * 100.0) / 100.0);
                    psAnalysis.executeUpdate();
                }
            }
        }
        System.out.println(" Created " + count + " WateringSession + WaterAnalysis rows.");
    }
}