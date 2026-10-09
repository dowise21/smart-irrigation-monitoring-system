package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.SensorData;
import util.DBContext;

public class SensorDataDAO {

    private static final Logger LOGGER = Logger.getLogger(SensorDataDAO.class.getName());

    // Cập nhật câu SQL: Dùng bảng SensorReading, JOIN qua bảng Sensor để đến Pot và Plant
    private static final String SELECT_BASE =
        "SELECT r.reading_id AS data_id, s.pot_id, r.moisture_level, r.recorded_at, " +
        "       p.pot_name, pl.plant_name " +
        "FROM SensorReading r " +
        "JOIN Sensor s ON r.sensor_id = s.sensor_id " +
        "JOIN Pot p ON s.pot_id = p.pot_id " +
        "JOIN Plant pl ON p.plant_id = pl.plant_id ";

    private SensorData map(ResultSet rs) throws SQLException {
        SensorData s = new SensorData();
        s.setDataId(rs.getInt("data_id"));
        s.setPotId(rs.getInt("pot_id"));
        s.setMoistureLevel(rs.getDouble("moisture_level"));
        s.setRecordedAt(rs.getTimestamp("recorded_at"));
        
        s.setPotName(rs.getString("pot_name"));
        s.setPlantName(rs.getString("plant_name"));
        return s;
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (cn != null) cn.close(); } catch (SQLException ignored) {}
    }

    /** 
     * Lấy danh sách độ ẩm mới nhất.
     */
    public List<SensorData> getRecentData(int potId, int limit) {
        List<SensorData> out = new ArrayList<>();
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            String sql = SELECT_BASE;
            if (potId > 0) {
                sql += " WHERE s.pot_id = ? ";
            }
            sql += " ORDER BY r.recorded_at DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
            
            ps = cn.prepareStatement(sql);
            int paramIndex = 1;
            if (potId > 0) {
                ps.setInt(paramIndex++, potId);
            }
            ps.setInt(paramIndex, limit);
            
            rs = ps.executeQuery();
            while (rs.next()) {
                out.add(map(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại getRecentData: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return out;
    }
    
    /** 
     * Nút Giả lập: Tự động tìm Sensor thuộc Chậu này để Insert vào SensorReading
     */
    public boolean insert(int potId, double moisture) {
        // Dùng Sub-Query để tự động tìm sensor_id tương ứng với pot_id
        String sql = "INSERT INTO SensorReading(sensor_id, moisture_level, source) " +
                     "VALUES ((SELECT TOP 1 sensor_id FROM Sensor WHERE pot_id = ?), ?, 'DEVICE')";
                     
        Connection cn = null; PreparedStatement ps = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            ps.setInt(1, potId);
            ps.setDouble(2, moisture);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại insert SensorData: {0}", e.getMessage());
        } finally {
            close(null, ps, cn);
        }
        return false;
    }
}