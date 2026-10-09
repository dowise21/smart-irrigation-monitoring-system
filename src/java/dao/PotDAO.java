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
import model.Pot;
import util.DBContext;

public class PotDAO {

    private static final Logger LOGGER = Logger.getLogger(PotDAO.class.getName());

    // Cần JOIN với bảng Plant để lấy tên cây
    private static final String SELECT_BASE =
        "SELECT po.pot_id, po.pot_name, po.location, po.plant_id, po.status, pl.plant_name " +
        "FROM Pot po " +
        "LEFT JOIN Plant pl ON po.plant_id = pl.plant_id ";

    // Helper: Đóng gói ResultSet
    private Pot map(ResultSet rs) throws SQLException {
        Pot p = new Pot();
        p.setPotId(rs.getInt("pot_id"));
        p.setPotName(rs.getString("pot_name"));
        p.setLocation(rs.getString("location"));
        p.setPlantId(rs.getInt("plant_id"));
        p.setPlantName(rs.getString("plant_name"));
        p.setStatus(rs.getBoolean("status"));
        return p;
    }

    // Helper: Đóng kết nối
    private void close(ResultSet rs, PreparedStatement ps, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (cn != null) cn.close(); } catch (SQLException ignored) {}
    }

    /** Lấy danh sách (Có thể thêm phân trang sau nếu cần) */
    public List<Pot> getAll() {
        List<Pot> out = new ArrayList<>();
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(SELECT_BASE + " ORDER BY po.pot_id DESC");
            rs = ps.executeQuery();
            while (rs.next()) {
                out.add(map(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại getAll Pot: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return out;
    }

    /** Lấy 1 chậu theo ID (Dùng cho Update) */
    public Pot findById(int id) {
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(SELECT_BASE + " WHERE po.pot_id = ?");
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại findById Pot: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return null;
    }

    /** Thêm mới (Create) */
    public int insert(Pot p) {
        String sql = "INSERT INTO Pot (pot_name, location, plant_id, status) VALUES (?, ?, ?, ?)";
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, p.getPotName());
            ps.setString(2, p.getLocation());
            ps.setInt(3, p.getPlantId());
            ps.setBoolean(4, p.isStatus());
            
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại insert Pot: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return 0;
    }

    /** Cập nhật (Update) */
    public boolean update(Pot p) {
        String sql = "UPDATE Pot SET pot_name = ?, location = ?, plant_id = ?, status = ? WHERE pot_id = ?";
        Connection cn = null; PreparedStatement ps = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            ps.setString(1, p.getPotName());
            ps.setString(2, p.getLocation());
            ps.setInt(3, p.getPlantId());
            ps.setBoolean(4, p.isStatus());
            ps.setInt(5, p.getPotId());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại update Pot: {0}", e.getMessage());
        } finally {
            close(null, ps, cn);
        }
        return false;
    }

    /** Xóa (Delete) */
    public boolean delete(int id) {
        Connection cn = null; PreparedStatement ps = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement("DELETE FROM Pot WHERE pot_id = ?");
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại delete Pot: {0}", e.getMessage());
        } finally {
            close(null, ps, cn);
        }
        return false;
    }
}