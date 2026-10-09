package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.IrrigationHistory;
import util.DBContext;

public class IrrigationHistoryDAO {

    private static final Logger LOGGER = Logger.getLogger(IrrigationHistoryDAO.class.getName());

    // JOIN WateringSession và WaterAnalysis để lấy đủ thông tin Lịch sử tưới
    private static final String SELECT_BASE =
        "SELECT s.session_id AS history_id, s.pot_id, s.start_time AS irrigation_time, " +
        "       s.duration_seconds, (a.water_ml / 1000.0) AS water_amount, " +
        "       p.pot_name, pl.plant_name " +
        "FROM WateringSession s " +
        "LEFT JOIN WaterAnalysis a ON s.session_id = a.session_id " +
        "JOIN Pot p ON s.pot_id = p.pot_id " +
        "JOIN Plant pl ON p.plant_id = pl.plant_id ";

    private IrrigationHistory map(ResultSet rs) throws SQLException {
        IrrigationHistory h = new IrrigationHistory();
        h.setHistoryId(rs.getInt("history_id"));
        h.setPotId(rs.getInt("pot_id"));
        h.setIrrigationTime(rs.getTimestamp("irrigation_time"));
        
        int duration = rs.getInt("duration_seconds");
        h.setDurationSeconds(rs.wasNull() ? null : duration);
        
        double amount = rs.getDouble("water_amount");
        h.setWaterAmount(rs.wasNull() ? null : amount);
        
        h.setPotName(rs.getString("pot_name"));
        h.setPlantName(rs.getString("plant_name"));
        return h;
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (cn != null) cn.close(); } catch (SQLException ignored) {}
    }

    /** 
     * Lấy danh sách lịch sử tưới mới nhất
     */
    public List<IrrigationHistory> getHistory(int potId, int limit) {
        List<IrrigationHistory> out = new ArrayList<>();
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            String sql = SELECT_BASE;
            if (potId > 0) sql += " WHERE s.pot_id = ? ";
            sql += " ORDER BY s.start_time DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
            
            ps = cn.prepareStatement(sql);
            int i = 1;
            if (potId > 0) ps.setInt(i++, potId);
            ps.setInt(i, limit);
            
            rs = ps.executeQuery();
            while (rs.next()) out.add(map(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại getHistory: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return out;
    }

    /** 
     * Ghi nhận phiên tưới (Ghi vào WateringSession, sau đó ghi lượng nước vào WaterAnalysis)
     */
    public boolean insert(int potId, Integer durationSeconds, Double waterAmount) {
        String sqlSession = "INSERT INTO WateringSession(pot_id, duration_seconds, source) VALUES (?, ?, 'DEVICE')";
        String sqlAnalysis = "INSERT INTO WaterAnalysis(session_id, water_ml) VALUES (?, ?)";
        
        Connection cn = null; PreparedStatement ps1 = null; PreparedStatement ps2 = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            // Bật Transaction để đảm bảo tính toàn vẹn dữ liệu giữa 2 bảng
            cn.setAutoCommit(false); 
            
            // Bước 1: Lưu WateringSession
            ps1 = cn.prepareStatement(sqlSession, Statement.RETURN_GENERATED_KEYS);
            ps1.setInt(1, potId);
            if (durationSeconds != null) ps1.setInt(2, durationSeconds);
            else ps1.setNull(2, java.sql.Types.INTEGER);
            
            int affectedRows = ps1.executeUpdate();
            
            if (affectedRows > 0) {
                rs = ps1.getGeneratedKeys();
                if (rs.next()) {
                    int sessionId = rs.getInt(1);
                    
                    // Bước 2: Lưu lượng nước (water_ml) vào WaterAnalysis
                    ps2 = cn.prepareStatement(sqlAnalysis);
                    ps2.setInt(1, sessionId);
                    if (waterAmount != null) {
                        // Trên web hiển thị Lít (vd 1.5L), trong DB lưu Milliliters (1500ml)
                        ps2.setDouble(2, waterAmount * 1000); 
                    } else {
                        ps2.setNull(2, java.sql.Types.FLOAT);
                    }
                    ps2.executeUpdate();
                }
            }
            cn.commit(); // Hoàn tất Transaction
            return true;
        } catch (Exception e) {
            try { if (cn != null) cn.rollback(); } catch (SQLException ex) {}
            LOGGER.log(Level.SEVERE, "Lỗi tại insert IrrigationHistory: {0}", e.getMessage());
        } finally {
            close(rs, ps1, null);
            close(null, ps2, cn);
        }
        return false;
    }
}