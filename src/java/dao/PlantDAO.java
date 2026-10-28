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
import model.Plant;
import util.DBContext;

public class PlantDAO {

    private static final Logger LOGGER = Logger.getLogger(PlantDAO.class.getName());

    private static final String SELECT_BASE =
        "SELECT plant_id, plant_name, species, water_requirement, " +
        "       COALESCE(min_moisture_threshold, ideal_moisture_min, 35.0) AS min_moisture_threshold, " +
        "       COALESCE(max_moisture_threshold, ideal_moisture_max, 75.0) AS max_moisture_threshold, " +
        "       description, created_at, water_amount_ml, default_pot_id " +
        "FROM Plant ";

    private String whereClause(String keyword) {
        StringBuilder sb = new StringBuilder(" WHERE 1 = 1 ");
        if (keyword != null && keyword.trim().length() > 0) {
            sb.append("AND (plant_name LIKE ? OR species LIKE ?) ");
        }
        return sb.toString();
    }

    private int bindFilters(PreparedStatement ps, String keyword, int start) throws SQLException {
        int i = start;
        if (keyword != null && keyword.trim().length() > 0) {
            String like = "%" + keyword.trim() + "%";
            ps.setString(i++, like);
            ps.setString(i++, like);
        }
        return i;
    }

    /** READ: Lấy danh sách cây có tính năng Tìm kiếm và Phân trang */
    public List<Plant> search(String keyword, int page, int size) {
        List<Plant> out = new ArrayList<>();
        String sql = SELECT_BASE + whereClause(keyword)
                   + "ORDER BY plant_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            int i = bindFilters(ps, keyword, 1);
            ps.setInt(i++, (page - 1) * size);
            ps.setInt(i++, size);
            rs = ps.executeQuery();
            while (rs.next()) {
                out.add(map(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại search Plant: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return out;
    }

    /** Đếm tổng số lượng bản ghi để tính toán tổng số trang cho Pagination */
    public int count(String keyword) {
        String sql = "SELECT COUNT(*) FROM Plant " + whereClause(keyword);
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            bindFilters(ps, keyword, 1);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại count Plant: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return 0;
    }

    /** Lấy chi tiết 1 loại cây theo ID */
    public Plant findById(int id) {
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(SELECT_BASE + " WHERE plant_id = ?");
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại findById Plant: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return null;
    }

    /** CREATE: Thêm cây mới */
    public int insert(Plant p) {
        String sql = "INSERT INTO Plant(plant_name, species, water_requirement, min_moisture_threshold, max_moisture_threshold, "
                   + "ideal_moisture_min, ideal_moisture_max, description, water_amount_ml, default_pot_id) "
                   + "VALUES (?,?,?,?,?,?,?,?,?,?)";
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            bindWritable(ps, p);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại insert Plant: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return 0;
    }

    /** UPDATE: Cập nhật thông tin cây và ngưỡng tưới tự động */
    public boolean update(Plant p) {
        String sql = "UPDATE Plant SET plant_name = ?, species = ?, water_requirement = ?, "
                   + "min_moisture_threshold = ?, max_moisture_threshold = ?, "
                   + "ideal_moisture_min = ?, ideal_moisture_max = ?, "
                   + "description = ?, water_amount_ml = ?, default_pot_id = ? WHERE plant_id = ?";
        Connection cn = null; PreparedStatement ps = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            bindWritable(ps, p);
            ps.setInt(11, p.getPlantId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại update Plant: {0}", e.getMessage());
        } finally {
            close(null, ps, cn);
        }
        return false;
    }

    /** Cập nhật nhanh ngưỡng độ ẩm tối thiểu/tối đa cho cây của 1 chậu */
    public boolean updateThresholdsByPotOrPlant(Integer potId, Integer plantId, Double minThreshold, Double maxThreshold) {
        String sql = "UPDATE Plant SET "
                   + "min_moisture_threshold = COALESCE(?, min_moisture_threshold), "
                   + "ideal_moisture_min = COALESCE(?, ideal_moisture_min), "
                   + "max_moisture_threshold = COALESCE(?, max_moisture_threshold), "
                   + "ideal_moisture_max = COALESCE(?, ideal_moisture_max) "
                   + "WHERE plant_id = COALESCE(?, (SELECT plant_id FROM Pot WHERE pot_id = ?))";
        Connection cn = null; PreparedStatement ps = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            if (minThreshold != null) {
                ps.setDouble(1, minThreshold);
                ps.setDouble(2, minThreshold);
            } else {
                ps.setNull(1, java.sql.Types.DECIMAL);
                ps.setNull(2, java.sql.Types.DECIMAL);
            }
            if (maxThreshold != null) {
                ps.setDouble(3, maxThreshold);
                ps.setDouble(4, maxThreshold);
            } else {
                ps.setNull(3, java.sql.Types.DECIMAL);
                ps.setNull(4, java.sql.Types.DECIMAL);
            }
            if (plantId != null && plantId > 0) {
                ps.setInt(5, plantId);
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            if (potId != null && potId > 0) {
                ps.setInt(6, potId);
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại updateThresholdsByPotOrPlant: {0}", e.getMessage());
        } finally {
            close(null, ps, cn);
        }
        return false;
    }

    /** DELETE: Xóa cây và vô hiệu hóa chậu gắn với cây đó (nếu còn ít nhất 1 chậu khác đang hoạt động) */
    public boolean delete(int plantId) {
        Connection cn = null;
        PreparedStatement psDeactivatePot = null;
        PreparedStatement psReassign = null;
        PreparedStatement psDelete = null;
        try {
            cn = DBContext.getConnection();
            cn.setAutoCommit(false);

            String deactivateSql = "UPDATE Pot SET status = 0 WHERE plant_id = ? AND (SELECT COUNT(*) FROM Pot WHERE status = 1) > 1";
            psDeactivatePot = cn.prepareStatement(deactivateSql);
            psDeactivatePot.setInt(1, plantId);
            psDeactivatePot.executeUpdate();

            String reassignSql = "UPDATE Pot SET plant_id = (SELECT TOP 1 plant_id FROM Plant WHERE plant_id <> ? ORDER BY plant_id ASC) "
                               + "WHERE plant_id = ? AND EXISTS (SELECT 1 FROM Plant WHERE plant_id <> ?)";
            psReassign = cn.prepareStatement(reassignSql);
            psReassign.setInt(1, plantId);
            psReassign.setInt(2, plantId);
            psReassign.setInt(3, plantId);
            psReassign.executeUpdate();

            psDelete = cn.prepareStatement("DELETE FROM Plant WHERE plant_id = ?");
            psDelete.setInt(1, plantId);
            int affected = psDelete.executeUpdate();
            cn.commit();
            return affected > 0;
        } catch (Exception e) {
            try { if (cn != null) cn.rollback(); } catch (SQLException ignored) {}
            LOGGER.log(Level.SEVERE, "Lỗi tại delete Plant: {0}", e.getMessage());
        } finally {
            close(null, psDeactivatePot, null);
            close(null, psReassign, null);
            close(null, psDelete, cn);
        }
        return false;
    }

    /** Lấy TOÀN BỘ danh sách cây */
    public List<Plant> getAll() {
        List<Plant> out = new ArrayList<>();
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(SELECT_BASE + " ORDER BY plant_id ASC");
            rs = ps.executeQuery();
            while (rs.next()) out.add(map(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại getAll Plant: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return out;
    }

    private void bindWritable(PreparedStatement ps, Plant p) throws SQLException {
        int waterMl = p.getWaterAmountMl() > 0 ? p.getWaterAmountMl() : 250;
        String waterReq = p.getWaterRequirement();
        if (waterReq == null || waterReq.trim().isEmpty()) {
            waterReq = waterMl + " ml/lần";
        }
        ps.setString(1, p.getPlantName());
        ps.setString(2, p.getSpecies());
        ps.setString(3, waterReq);

        Double min = p.getMinMoistureThreshold();
        Double max = p.getMaxMoistureThreshold();

        if (min != null) {
            ps.setDouble(4, min);
            ps.setDouble(6, min);
        } else {
            ps.setNull(4, java.sql.Types.DECIMAL);
            ps.setNull(6, java.sql.Types.DECIMAL);
        }

        if (max != null) {
            ps.setDouble(5, max);
            ps.setDouble(7, max);
        } else {
            ps.setNull(5, java.sql.Types.DECIMAL);
            ps.setNull(7, java.sql.Types.DECIMAL);
        }

        ps.setString(8, p.getDescription());
        ps.setInt(9, waterMl);
        if (p.getDefaultPotId() != null && p.getDefaultPotId() > 0) {
            ps.setInt(10, p.getDefaultPotId());
        } else {
            ps.setNull(10, java.sql.Types.INTEGER);
        }
    }

    private Plant map(ResultSet rs) throws SQLException {
        Plant p = new Plant();
        p.setPlantId(rs.getInt("plant_id"));
        p.setPlantName(rs.getString("plant_name"));
        p.setSpecies(rs.getString("species"));
        p.setWaterRequirement(rs.getString("water_requirement"));

        double min = rs.getDouble("min_moisture_threshold");
        p.setMinMoistureThreshold(rs.wasNull() ? null : min);

        double max = rs.getDouble("max_moisture_threshold");
        p.setMaxMoistureThreshold(rs.wasNull() ? null : max);

        p.setDescription(rs.getString("description"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        int water = rs.getInt("water_amount_ml");
        p.setWaterAmountMl(rs.wasNull() || water <= 0 ? 250 : water);
        int potId = rs.getInt("default_pot_id");
        p.setDefaultPotId(rs.wasNull() || potId <= 0 ? null : potId);
        return p;
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (cn != null) cn.close(); } catch (SQLException ignored) {}
    }
}
