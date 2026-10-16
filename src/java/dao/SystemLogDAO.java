package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import util.DBContext;

/**
 * Data Access Object for the SystemLog table (Table #17 in the 17-table schema).
 */
public class SystemLogDAO {

    private static final Logger LOGGER = Logger.getLogger(SystemLogDAO.class.getName());

    public boolean log(String level, String module, String message) {
        String sql = "INSERT INTO SystemLog (log_level, module, message, created_at) VALUES (?, ?, ?, GETDATE())";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, level == null ? "INFO" : level.trim().toUpperCase());
            ps.setString(2, module == null ? "SYSTEM" : module.trim().toUpperCase());
            ps.setString(3, message == null ? "" : message);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Could not write SystemLog: {0}", e.getMessage());
        }
        return false;
    }

    public List<Map<String, Object>> getLogs(int page, int size) {
        List<Map<String, Object>> list = new ArrayList<>();
        int safePage = Math.max(1, page);
        int safeSize = Math.max(1, Math.min(200, size));
        String sql = "SELECT log_id, log_level, module, message, created_at "
                   + "FROM SystemLog ORDER BY created_at DESC, log_id DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, (safePage - 1) * safeSize);
            ps.setInt(2, safeSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("logId", rs.getInt("log_id"));
                    row.put("logLevel", rs.getString("log_level"));
                    row.put("module", rs.getString("module"));
                    row.put("message", rs.getString("message"));
                    row.put("createdAt", rs.getTimestamp("created_at"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Could not query SystemLog: {0}", e.getMessage());
        }
        return list;
    }
}

