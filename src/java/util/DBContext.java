package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    
    private static final String SERVER_NAME = "localhost";
    private static final String DB_NAME = "SmartIrrigationDB";
    private static final String PORT_NUMBER = "1433";
    private static final String USER_ID = "sa"; 
    private static final String PASSWORD = "12345"; 

    public static Connection getConnection() throws Exception {
        String url = "jdbc:sqlserver://" + SERVER_NAME + ":" + PORT_NUMBER 
                   + ";databaseName=" + DB_NAME 
                   + ";encrypt=false;trustServerCertificate=true;";
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(url, USER_ID, PASSWORD);
    }
    
    public static void main(String[] args) {
        try {
            Connection conn = DBContext.getConnection();
            if (conn != null) {
                System.out.println("Kết nối đến Database SmartIrrigationDB thành công!");
                conn.close();
            }
        } catch (Exception e) {
            System.out.println("Lỗi kết nối CSDL: " + e.getMessage());
        }
    }
}