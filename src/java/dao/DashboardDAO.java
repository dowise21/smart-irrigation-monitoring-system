package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import util.DBContext;

public class DashboardDAO {

    /**
     * Lấy các chỉ số nước.
     * Mảng trả về: [0] = Nước đã tưới (Lít), [1] = Nước giữ lại (Lít), [2] = Nước hao phí (Lít)
     */
    public double[] getWaterKPIs() {
        double[] kpis = new double[3];
        // Công thức: Water Waste = Water Used - Retained Water (theo tài liệu PRJ301)
        String sql = "SELECT SUM(water_ml) / 1000.0 AS total_used, " +
                     "SUM(water_ml * retain_ratio) / 1000.0 AS total_retained " +
                     "FROM WaterAnalysis";
                     
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            if (rs.next()) {
                kpis[0] = rs.getDouble("total_used");
                kpis[1] = rs.getDouble("total_retained");
                kpis[2] = kpis[0] - kpis[1]; // Waste = Used - Retained
            }
        } catch (Exception e) {
            System.err.println("Lỗi DashboardDAO.getWaterKPIs: " + e.getMessage());
        }
        return kpis;
    }

    /**
     * Lấy số lượng cảnh báo chưa được xử lý (is_resolved = 0)
     */
    public int getActiveAlertCount() {
        String sql = "SELECT COUNT(*) FROM Alert WHERE is_resolved = 0";
        try (Connection cn = DBContext.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            System.err.println("Lỗi DashboardDAO.getActiveAlertCount: " + e.getMessage());
        }
        return 0;
    }
}