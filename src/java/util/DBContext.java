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
     * Ensures columns required by DAO queries exist on existing databases
     * created from earlier schema versions. Runs once per JVM startup.
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
                "IF COL_LENGTH('WateringSession', 'source') IS NULL "
                    + "ALTER TABLE WateringSession ADD source VARCHAR(20) NULL CONSTRAINT DF_WateringSession_source DEFAULT 'DEVICE'",
                "IF COL_LENGTH('SensorReading', 'source') IS NULL "
                    + "ALTER TABLE SensorReading ADD source VARCHAR(20) NULL CONSTRAINT DF_SensorReading_source DEFAULT 'DEVICE'",
                "IF COL_LENGTH('Plant', 'water_amount_ml') IS NULL "
                    + "ALTER TABLE Plant ADD water_amount_ml INT NULL CONSTRAINT DF_Plant_water_amount_ml DEFAULT 250",
                "IF COL_LENGTH('Plant', 'default_pot_id') IS NULL "
                    + "ALTER TABLE Plant ADD default_pot_id INT NULL",
                "UPDATE WateringSession SET source = CASE WHEN schedule_id IS NULL THEN 'MANUAL' ELSE 'SCHEDULED' END WHERE source IS NULL",
                "UPDATE SensorReading SET source = 'DEVICE' WHERE source IS NULL",
                "UPDATE Plant SET water_amount_ml = 250 WHERE water_amount_ml IS NULL OR water_amount_ml <= 0"
            };
            try (Statement st = conn.createStatement()) {
                for (String sql : ddl) {
                    st.execute(sql);
                }
                schemaSynced = true;
            } catch (Exception ignored) {
                // Ignore if user lacks DDL permissions; standard queries will still proceed if schema is already updated.
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