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
        "SELECT plant_id, plant_name, species, ideal_moisture_min, " +
        "       ideal_moisture_max, description, created_at " +
        "FROM Plant ";

    // Xây dựng câu điều kiện WHERE dùng chung cho cả search và count
    private String whereClause(String keyword) {
        StringBuilder sb = new StringBuilder(" WHERE 1 = 1 ");
        if (keyword != null && keyword.trim().length() > 0) {
            sb.append("AND (plant_name LIKE ? OR species LIKE ?) ");
        }
        return sb.toString();
    }

    // Đổ dữ liệu vào các dấu ? của tham số tìm kiếm
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

    /** Lấy chi tiết 1 loại cây theo ID (Dùng khi Edit) */
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
        String sql = "INSERT INTO Plant(plant_name, species, ideal_moisture_min, ideal_moisture_max, description) "
                   + "VALUES (?,?,?,?,?)";
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

    /** UPDATE: Cập nhật thông tin cây */
    public boolean update(Plant p) {
        String sql = "UPDATE Plant SET plant_name = ?, species = ?, ideal_moisture_min = ?, "
                   + "ideal_moisture_max = ?, description = ? WHERE plant_id = ?";
        Connection cn = null; PreparedStatement ps = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            bindWritable(ps, p);
            ps.setInt(6, p.getPlantId()); // ID nằm ở vị trí thứ 6 trong câu UPDATE
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại update Plant: {0}", e.getMessage());
        } finally {
            close(null, ps, cn);
        }
        return false;
    }

    /** DELETE: Xóa cây (Lưu ý về khóa ngoại với bảng Pot) */
    public boolean delete(int plantId) {
        Connection cn = null; PreparedStatement ps = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement("DELETE FROM Plant WHERE plant_id = ?");
            ps.setInt(1, plantId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại delete Plant: {0}", e.getMessage());
        } finally {
            close(null, ps, cn);
        }
        return false;
    }
    
    /** Lấy TOÀN BỘ danh sách cây (Dùng để đổ vào thẻ <select> ở form tạo Chậu) */
    public List<Plant> getAll() {
        List<Plant> out = new ArrayList<>();
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(SELECT_BASE + " ORDER BY plant_name ASC");
            rs = ps.executeQuery();
            while (rs.next()) out.add(map(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại getAll Plant: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return out;
    }

    // Gắn giá trị cho các lệnh Insert/Update
    private void bindWritable(PreparedStatement ps, Plant p) throws SQLException {
        ps.setString(1, p.getPlantName());
        ps.setString(2, p.getSpecies());
        
        // Xử lý cẩn thận kiểu số thực (Double) có thể null
        if (p.getIdealMoistureMin() != null) ps.setDouble(3, p.getIdealMoistureMin());
        else ps.setNull(3, java.sql.Types.DECIMAL);
        
        if (p.getIdealMoistureMax() != null) ps.setDouble(4, p.getIdealMoistureMax());
        else ps.setNull(4, java.sql.Types.DECIMAL);
        
        ps.setString(5, p.getDescription());
    }

    // Đóng gói ResultSet thành Object Plant
    private Plant map(ResultSet rs) throws SQLException {
        Plant p = new Plant();
        p.setPlantId(rs.getInt("plant_id"));
        p.setPlantName(rs.getString("plant_name"));
        p.setSpecies(rs.getString("species"));
        
        // Tránh lỗi khi đọc số thực bị null trong CSDL
        double min = rs.getDouble("ideal_moisture_min");
        p.setIdealMoistureMin(rs.wasNull() ? null : min);
        
        double max = rs.getDouble("ideal_moisture_max");
        p.setIdealMoistureMax(rs.wasNull() ? null : max);
        
        p.setDescription(rs.getString("description"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }

    // Đóng kết nối
    private void close(ResultSet rs, PreparedStatement ps, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (cn != null) cn.close(); } catch (SQLException ignored) {}
    }
}