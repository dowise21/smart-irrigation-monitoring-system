package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.AppUser;
import util.DBContext;

public class UserDAO {

    // Khởi tạo Logger chuẩn của Java để ghi lỗi thay cho printStackTrace()
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    // 1. Câu lệnh SQL cơ bản dùng chung để lấy thông tin User + Role Name
    private static final String SELECT_BASE =
        "SELECT u.user_id, u.username, u.password_hash, u.full_name, u.email, " +
        "       u.role_id, u.status, u.created_at, r.role_name " +
        "FROM AppUser u " +
        "JOIN AppRole r ON r.role_id = u.role_id ";

    // 2. Helper: Đóng kết nối Database gọn gàng
    private void close(ResultSet rs, PreparedStatement ps, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (cn != null) cn.close(); } catch (SQLException ignored) {}
    }

    // 3. Helper: Đóng gói (Map) 1 dòng trong CSDL thành Object AppUser
    private AppUser map(ResultSet rs) throws SQLException {
        AppUser u = new AppUser();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setRoleId(rs.getInt("role_id"));
        u.setStatus(rs.getBoolean("status"));
        u.setRoleName(rs.getString("role_name"));
        return u;
    }

    /**
     * HÀM 1: Tìm người dùng bằng Username (Phục vụ chức năng Login)
     */
    public AppUser findByUsername(String username) {
        Connection cn = null; 
        PreparedStatement ps = null; 
        ResultSet rs = null;
        
        try {
            cn = DBContext.getConnection();
            String sql = SELECT_BASE + " WHERE u.username = ?";
            ps = cn.prepareStatement(sql);
            ps.setString(1, username);
            
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return map(rs);
            }
        } catch (Exception e) {
            // Thay thế printStackTrace bằng Logger
            LOGGER.log(Level.SEVERE, "Loi tai findByUsername: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn); 
        }
        return null; 
    }
    
    /**
     * HÀM 2: Kiểm tra Username đã tồn tại chưa (Dùng khi tạo mới/Cập nhật User)
     * @param exceptUserId Truyền vào 0 nếu là tạo mới, hoặc truyền ID của user nếu đang cập nhật
     */
    public boolean checkUsernameExists(String username, int exceptUserId) {
        String sql = "SELECT 1 FROM AppUser WHERE username = ? AND user_id <> ?";
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setInt(2, exceptUserId); 
            rs = ps.executeQuery();
            return rs.next(); 
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Loi tai checkUsernameExists: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return false;
    }

    /**
     * HÀM 3: Kiểm tra Email đã tồn tại chưa
     */
    public boolean checkEmailExists(String email, int exceptUserId) {
        String sql = "SELECT 1 FROM AppUser WHERE email = ? AND user_id <> ?";
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setInt(2, exceptUserId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Loi tai checkEmailExists: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return false;
    }
    
    /**
     * HÀM 4: Thêm mới một tài khoản vào CSDL (Create)
     * @return Trả về ID của user vừa được tạo, hoặc 0 nếu thất bại
     */
    public int insert(AppUser u) {
        String sql = "INSERT INTO AppUser(username, password_hash, full_name, email, role_id, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            ps.setString(1, u.getUsername());
            ps.setString(2, u.getPasswordHash());
            ps.setString(3, u.getFullName());
            ps.setString(4, u.getEmail());
            ps.setInt(5, u.getRoleId());
            ps.setBoolean(6, u.isStatus());
            
            ps.executeUpdate(); 
            
            rs = ps.getGeneratedKeys(); 
            if (rs.next()) {
                return rs.getInt(1); 
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Loi tai insert: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return 0;
    }
}