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

/**
 * DAO quản lý Chậu cây (Table Pot).
 * Thực hiện JOIN với bảng Area (Khu vực) và Plant (Loại cây trồng)
 * để đảm bảo quy tắc: 1 Chậu cây thuộc 1 Khu vực và chỉ trồng duy nhất 1 Loại cây.
 */
public class PotDAO {

    private static final Logger LOGGER = Logger.getLogger(PotDAO.class.getName());

    private static final String SELECT_BASE =
        "SELECT po.pot_id, po.pot_name, po.area_id, a.area_name, po.location, " +
        "       po.plant_id, pl.plant_name, " +
        "       COALESCE(pl.min_moisture_threshold, pl.ideal_moisture_min, 35.0) AS min_moisture_threshold, " +
        "       COALESCE(pl.max_moisture_threshold, pl.ideal_moisture_max, 75.0) AS max_moisture_threshold, " +
        "       COALESCE(po.auto_watering_enabled, 1) AS auto_watering_enabled, po.status " +
        "FROM Pot po " +
        "LEFT JOIN Area a ON po.area_id = a.area_id " +
        "JOIN Plant pl ON po.plant_id = pl.plant_id ";

    private Pot map(ResultSet rs) throws SQLException {
        Pot p = new Pot();
        p.setPotId(rs.getInt("pot_id"));
        p.setPotName(rs.getString("pot_name"));
        int areaId = rs.getInt("area_id");
        p.setAreaId(rs.wasNull() ? 1 : areaId);
        String areaName = rs.getString("area_name");
        String loc = rs.getString("location");
        String resolvedArea = (areaName != null && !areaName.trim().isEmpty())
                ? areaName
                : ((loc != null && !loc.trim().isEmpty()) ? loc : "Khu A - Ban công Tầng 2");
        p.setAreaName(resolvedArea);
        p.setLocation(resolvedArea);
        p.setPlantId(rs.getInt("plant_id"));
        p.setPlantName(rs.getString("plant_name"));
        p.setMinMoistureThreshold(rs.getDouble("min_moisture_threshold"));
        p.setMaxMoistureThreshold(rs.getDouble("max_moisture_threshold"));
        p.setAutoWateringEnabled(rs.getBoolean("auto_watering_enabled"));
        p.setStatus(rs.getBoolean("status"));
        return p;
    }

    private void close(ResultSet rs, PreparedStatement ps, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (cn != null) cn.close(); } catch (SQLException ignored) {}
    }

    /** Lấy danh sách tất cả chậu cây kèm thông tin Khu vực (Area) và Loại cây (Plant) */
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

    /** Lấy 1 chậu theo ID */
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

    /**
     * Đồng bộ hóa quan hệ 1-1 giữa Chậu cây (Pot), Khu vực (Area) và Cây trồng (Plant):
     *   - Cập nhật Pot.plant_id = plantId (và Pot.area_id, Pot.pot_name nếu truyền vào)
     *   - Cập nhật Plant.default_pot_id = potId (đồng thời gỡ default_pot_id của cây cũ từng gắn với chậu này)
     */
    public boolean syncPotPlantAssignment(int potId, int plantId, Integer areaId, String potName) {
        if (potId <= 0 || plantId <= 0) {
            return false;
        }
        Connection cn = null;
        PreparedStatement psClearOld = null;
        PreparedStatement psSetPlant = null;
        PreparedStatement psUpdatePot = null;
        try {
            cn = DBContext.getConnection();
            cn.setAutoCommit(false);

            psClearOld = cn.prepareStatement("UPDATE Plant SET default_pot_id = NULL WHERE default_pot_id = ? AND plant_id <> ?");
            psClearOld.setInt(1, potId);
            psClearOld.setInt(2, plantId);
            psClearOld.executeUpdate();

            psSetPlant = cn.prepareStatement("UPDATE Plant SET default_pot_id = ? WHERE plant_id = ?");
            psSetPlant.setInt(1, potId);
            psSetPlant.setInt(2, plantId);
            psSetPlant.executeUpdate();

            StringBuilder sql = new StringBuilder("UPDATE Pot SET plant_id = ?, status = 1");
            if (areaId != null && areaId > 0) {
                sql.append(", area_id = ?, location = COALESCE((SELECT area_name FROM Area WHERE area_id = ?), location)");
            }
            if (potName != null && !potName.trim().isEmpty()) {
                sql.append(", pot_name = ?");
            }
            sql.append(" WHERE pot_id = ?");

            psUpdatePot = cn.prepareStatement(sql.toString());
            int idx = 1;
            psUpdatePot.setInt(idx++, plantId);
            if (areaId != null && areaId > 0) {
                psUpdatePot.setInt(idx++, areaId);
                psUpdatePot.setInt(idx++, areaId);
            }
            if (potName != null && !potName.trim().isEmpty()) {
                psUpdatePot.setString(idx++, potName.trim());
            }
            psUpdatePot.setInt(idx, potId);
            int affected = psUpdatePot.executeUpdate();

            cn.commit();
            return affected > 0;
        } catch (Exception e) {
            try { if (cn != null) cn.rollback(); } catch (SQLException ignored) {}
            LOGGER.log(Level.SEVERE, "Lỗi tại syncPotPlantAssignment: {0}", e.getMessage());
        } finally {
            close(null, psClearOld, null);
            close(null, psSetPlant, null);
            close(null, psUpdatePot, cn);
        }
        return false;
    }

    /**
     * Tạo mới 1 Chậu cây (Pot) trong Khu vực (Area) gắn với Cây trồng (Plant),
     * đồng thời khởi tạo Sensor, Pump và bản ghi độ ẩm ban đầu.
     */
    public int insertWithHardware(String potName, int areaId, int plantId) {
        String resolvedName = (potName != null && !potName.trim().isEmpty()) ? potName.trim() : "Chậu mới";
        int resolvedAreaId = areaId > 0 ? areaId : 1;
        String sqlPot = "INSERT INTO Pot (pot_name, area_id, location, plant_id, auto_watering_enabled, status) "
                      + "VALUES (?, ?, COALESCE((SELECT area_name FROM Area WHERE area_id = ?), N'Khu A - Ban công Tầng 2'), ?, 1, 1)";
        Connection cn = null;
        PreparedStatement psPot = null;
        PreparedStatement psSensor = null;
        PreparedStatement psReading = null;
        PreparedStatement psPump = null;
        PreparedStatement psPlant = null;
        ResultSet rsPot = null;
        ResultSet rsSensor = null;
        try {
            cn = DBContext.getConnection();
            cn.setAutoCommit(false);

            psPot = cn.prepareStatement(sqlPot, Statement.RETURN_GENERATED_KEYS);
            psPot.setString(1, resolvedName);
            psPot.setInt(2, resolvedAreaId);
            psPot.setInt(3, resolvedAreaId);
            psPot.setInt(4, plantId);
            psPot.executeUpdate();
            rsPot = psPot.getGeneratedKeys();
            int newPotId = rsPot.next() ? rsPot.getInt(1) : 0;
            if (newPotId <= 0) {
                cn.rollback();
                return 0;
            }

            psSensor = cn.prepareStatement("INSERT INTO Sensor (pot_id, sensor_type, status) VALUES (?, 'Moisture', 1)", Statement.RETURN_GENERATED_KEYS);
            psSensor.setInt(1, newPotId);
            psSensor.executeUpdate();
            rsSensor = psSensor.getGeneratedKeys();
            int newSensorId = rsSensor.next() ? rsSensor.getInt(1) : 0;

            if (newSensorId > 0) {
                psReading = cn.prepareStatement("INSERT INTO SensorReading (sensor_id, moisture_level, weight_kg, light_lux, source) VALUES (?, 55.0, 5.5, 1200, 'DEVICE')");
                psReading.setInt(1, newSensorId);
                psReading.executeUpdate();
            }

            psPump = cn.prepareStatement("INSERT INTO Pump (pot_id, pump_name, status) VALUES (?, ?, 1)");
            psPump.setInt(1, newPotId);
            psPump.setString(2, "Bơm Trạm #" + newPotId);
            psPump.executeUpdate();

            psPlant = cn.prepareStatement("UPDATE Plant SET default_pot_id = ? WHERE plant_id = ?");
            psPlant.setInt(1, newPotId);
            psPlant.setInt(2, plantId);
            psPlant.executeUpdate();

            cn.commit();
            return newPotId;
        } catch (Exception e) {
            try { if (cn != null) cn.rollback(); } catch (SQLException ignored) {}
            LOGGER.log(Level.SEVERE, "Lỗi tại insertWithHardware Pot: {0}", e.getMessage());
        } finally {
            close(rsSensor, psSensor, null);
            close(null, psReading, null);
            close(null, psPump, null);
            close(null, psPlant, null);
            close(rsPot, psPot, cn);
        }
        return 0;
    }

    /** Thêm mới Chậu cây (Create) */
    public int insert(Pot p) {
        String sql = "INSERT INTO Pot (pot_name, area_id, location, plant_id, auto_watering_enabled, status) VALUES (?, ?, ?, ?, ?, ?)";
        Connection cn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, p.getPotName());
            if (p.getAreaId() != null && p.getAreaId() > 0) {
                ps.setInt(2, p.getAreaId());
            } else {
                ps.setInt(2, 1);
            }
            ps.setString(3, p.getLocation());
            ps.setInt(4, p.getPlantId());
            ps.setBoolean(5, p.isAutoWateringEnabled());
            ps.setBoolean(6, p.isStatus());

            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                int newPotId = rs.getInt(1);
                syncPotPlantAssignment(newPotId, p.getPlantId(), p.getAreaId(), p.getPotName());
                return newPotId;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại insert Pot: {0}", e.getMessage());
        } finally {
            close(rs, ps, cn);
        }
        return 0;
    }

    /** Cập nhật Chậu cây (Update) */
    public boolean update(Pot p) {
        String sql = "UPDATE Pot SET pot_name = ?, area_id = ?, location = ?, plant_id = ?, auto_watering_enabled = ?, status = ? WHERE pot_id = ?";
        Connection cn = null; PreparedStatement ps = null;
        try {
            cn = DBContext.getConnection();
            ps = cn.prepareStatement(sql);
            ps.setString(1, p.getPotName());
            if (p.getAreaId() != null && p.getAreaId() > 0) {
                ps.setInt(2, p.getAreaId());
            } else {
                ps.setInt(2, 1);
            }
            ps.setString(3, p.getLocation());
            ps.setInt(4, p.getPlantId());
            ps.setBoolean(5, p.isAutoWateringEnabled());
            ps.setBoolean(6, p.isStatus());
            ps.setInt(7, p.getPotId());

            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                syncPotPlantAssignment(p.getPotId(), p.getPlantId(), p.getAreaId(), p.getPotName());
            }
            return ok;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi tại update Pot: {0}", e.getMessage());
        } finally {
            close(null, ps, cn);
        }
        return false;
    }

    /** Xóa Chậu cây (Delete) */
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
