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
import model.Area;
import util.DBContext;

/**
 * DAO quản lý Khu vực trồng cây (Table Area).
 */
public class AreaDAO {

    private static final Logger LOGGER = Logger.getLogger(AreaDAO.class.getName());

    private Area map(ResultSet rs) throws SQLException {
        Area a = new Area();
        a.setAreaId(rs.getInt("area_id"));
        a.setAreaName(rs.getString("area_name"));
        a.setDescription(rs.getString("description"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        return a;
    }

    public List<Area> getAll() {
        List<Area> out = new ArrayList<>();
        String sql = "SELECT area_id, area_name, description, created_at FROM Area ORDER BY area_id ASC";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                out.add(map(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại getAll Area: {0}", e.getMessage());
        }
        return out;
    }

    public Area findById(int areaId) {
        String sql = "SELECT area_id, area_name, description, created_at FROM Area WHERE area_id = ?";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, areaId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại findById Area: {0}", e.getMessage());
        }
        return null;
    }

    public int insert(Area area) {
        String sql = "INSERT INTO Area (area_name, description) VALUES (?, ?)";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, area.getAreaName());
            ps.setString(2, area.getDescription());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại insert Area: {0}", e.getMessage());
        }
        return 0;
    }

    public boolean update(Area area) {
        String sql = "UPDATE Area SET area_name = ?, description = ? WHERE area_id = ?";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, area.getAreaName());
            ps.setString(2, area.getDescription());
            ps.setInt(3, area.getAreaId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại update Area: {0}", e.getMessage());
        }
        return false;
    }

    public boolean delete(int areaId) {
        try (Connection cn = DBContext.getConnection()) {
            try (PreparedStatement psClear = cn.prepareStatement("UPDATE Pot SET area_id = NULL WHERE area_id = ?")) {
                psClear.setInt(1, areaId);
                psClear.executeUpdate();
            }
            try (PreparedStatement psDel = cn.prepareStatement("DELETE FROM Area WHERE area_id = ?")) {
                psDel.setInt(1, areaId);
                return psDel.executeUpdate() > 0;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại delete Area: {0}", e.getMessage());
        }
        return false;
    }
}

