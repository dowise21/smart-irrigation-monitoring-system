package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DBContext {

    private static final String SERVER_NAME = "localhost";
    private static final String DB_NAME = "SmartIrrigationDB";
    private static final String PORT_NUMBER = "1433";
    private static final String USER_ID = "sa";
    private static final String PASSWORD = "12345";

    private static volatile boolean schemaSynced = false;

    public static Connection getConnection() throws Exception {
        String url = "jdbc:sqlserver://" + SERVER_NAME + ":" + PORT_NUMBER
                   + ";databaseName=" + DB_NAME
                   + ";encrypt=false;trustServerCertificate=true;";
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection conn = DriverManager.getConnection(url, USER_ID, PASSWORD);
        ensureSchemaSynced(conn);
        return conn;
    }

    /**
     * Ensures Area table and columns required by DAO queries exist on existing databases
     * created from earlier schema versions, and keeps Area -> Pot -> Plant synchronized.
     */
    private static void ensureSchemaSynced(Connection conn) {
        if (schemaSynced) {
            return;
        }
        synchronized (DBContext.class) {
            if (schemaSynced) {
                return;
            }
            String[] ddl = {
                "IF OBJECT_ID('Area', 'U') IS NULL "
                    + "CREATE TABLE Area (area_id INT IDENTITY(1,1) PRIMARY KEY, area_name NVARCHAR(100) NOT NULL, description NVARCHAR(500), created_at DATETIME DEFAULT GETDATE())",
                "IF NOT EXISTS (SELECT 1 FROM Area) "
                    + "INSERT INTO Area (area_name, description) VALUES "
                    + "(N'Khu A - Ban công Tầng 2', N'Khu vực đón nắng sáng trực tiếp, thoáng gió'), "
                    + "(N'Khu B - Sân thượng Tầng 3', N'Khu vực nắng toàn phần, trồng hoa và cây cảnh'), "
                    + "(N'Khu C - Hiên nhà & Nội thất', N'Khu vực bán râm, hiên nhà và cửa sổ văn phòng')",
                "IF COL_LENGTH('Plant', 'water_requirement') IS NULL "
                    + "ALTER TABLE Plant ADD water_requirement NVARCHAR(100) NULL",
                "IF COL_LENGTH('Plant', 'min_moisture_threshold') IS NULL "
                    + "ALTER TABLE Plant ADD min_moisture_threshold FLOAT NULL",
                "IF COL_LENGTH('Plant', 'max_moisture_threshold') IS NULL "
                    + "ALTER TABLE Plant ADD max_moisture_threshold FLOAT NULL",
                "IF COL_LENGTH('Plant', 'water_amount_ml') IS NULL "
                    + "ALTER TABLE Plant ADD water_amount_ml INT NULL",
                "IF COL_LENGTH('Plant', 'default_pot_id') IS NULL "
                    + "ALTER TABLE Plant ADD default_pot_id INT NULL",
                "IF COL_LENGTH('Pot', 'area_id') IS NULL "
                    + "ALTER TABLE Pot ADD area_id INT NULL",
                "IF COL_LENGTH('Pot', 'auto_watering_enabled') IS NULL "
                    + "ALTER TABLE Pot ADD auto_watering_enabled BIT NULL CONSTRAINT DF_Pot_auto_water DEFAULT 1",
                "IF COL_LENGTH('WateringSession', 'source') IS NULL "
                    + "ALTER TABLE WateringSession ADD source VARCHAR(20) NULL CONSTRAINT DF_WateringSession_source DEFAULT 'DEVICE'",
                "IF COL_LENGTH('SensorReading', 'source') IS NULL "
                    + "ALTER TABLE SensorReading ADD source VARCHAR(20) NULL CONSTRAINT DF_SensorReading_source DEFAULT 'DEVICE'",
                "UPDATE Plant SET min_moisture_threshold = COALESCE(ideal_moisture_min, 35.0) WHERE min_moisture_threshold IS NULL",
                "UPDATE Plant SET max_moisture_threshold = COALESCE(ideal_moisture_max, 75.0) WHERE max_moisture_threshold IS NULL",
                "UPDATE Plant SET ideal_moisture_min = COALESCE(min_moisture_threshold, 35.0) WHERE ideal_moisture_min IS NULL",
                "UPDATE Plant SET ideal_moisture_max = COALESCE(max_moisture_threshold, 75.0) WHERE ideal_moisture_max IS NULL",
                "UPDATE Plant SET water_amount_ml = 250 WHERE water_amount_ml IS NULL OR water_amount_ml <= 0",
                "UPDATE Plant SET water_requirement = CAST(water_amount_ml AS NVARCHAR(20)) + N' ml/lần' WHERE water_requirement IS NULL",
                "UPDATE Pot SET area_id = CASE WHEN pot_id = 1 THEN 1 WHEN pot_id = 2 THEN 2 ELSE 3 END WHERE area_id IS NULL",
                "UPDATE Pot SET location = a.area_name FROM Pot po JOIN Area a ON po.area_id = a.area_id WHERE po.location IS NULL OR po.location = ''",
                "UPDATE Plant SET default_pot_id = po.pot_id FROM Plant pl JOIN Pot po ON po.plant_id = pl.plant_id WHERE pl.default_pot_id IS NULL OR pl.default_pot_id <> po.pot_id",
                "UPDATE Pot SET auto_watering_enabled = 1 WHERE auto_watering_enabled IS NULL",
                "UPDATE WateringSession SET source = CASE WHEN schedule_id IS NULL THEN 'MANUAL' ELSE 'SCHEDULED' END WHERE source IS NULL",
                "UPDATE SensorReading SET source = 'DEVICE' WHERE source IS NULL"
            };
            try (Statement st = conn.createStatement()) {
                for (String sql : ddl) {
                    try {
                        st.execute(sql);
                    } catch (Exception ignoredStep) {
                    }
                }
                schemaSynced = true;
            } catch (Exception ignored) {
                schemaSynced = true;
            }
        }
    }

    public static void main(String[] args) {
        try {
            Connection conn = DBContext.getConnection();
            if (conn != null) {
                System.out.println("Connected to SmartIrrigationDB successfully!");
                conn.close();
            }
        } catch (Exception e) {
            System.out.println("Database connection error: " + e.getMessage());
        }
    }
}
