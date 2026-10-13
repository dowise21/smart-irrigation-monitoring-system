-- =========================================================================
-- FILE 3/3: VERIFICATION QUERIES (INTEGRITY & RUBRIC CHECK)
-- TÊN DỰ ÁN: SMART IRRIGATION MONITORING SYSTEM (PRJ301 - FALL 2026)
-- DBMS: MICROSOFT SQL SERVER 2019/2022 (T-SQL)
-- =========================================================================

USE SmartIrrigationDB;
GO

PRINT '=============================================================';
PRINT '>>> 1. KIỂM TRA ĐỦ 17 BẢNG TRONG CƠ SỞ DỮ LIỆU & SỐ DÒNG:';
PRINT '=============================================================';
SELECT 
    t.name AS [Table_Name],
    p.rows AS [Total_Rows]
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
ORDER BY t.name;
GO

PRINT '=============================================================';
PRINT '>>> 2. KIỂM TRA TÀI KHOẢN VÀ 5 VAI TRÒ HỆ THỐNG (RBAC):';
PRINT '=============================================================';
SELECT 
    u.user_id, 
    u.username, 
    u.full_name, 
    u.email, 
    r.role_name, 
    u.status AS [Is_Active],
    u.created_at
FROM AppUser u
JOIN AppRole r ON u.role_id = r.role_id
ORDER BY u.role_id;
GO

PRINT '=============================================================';
PRINT '>>> 3. KIỂM TRA DANH MỤC CÂY TRỒNG VÀ CHẬU KHU VỰC:';
PRINT '=============================================================';
SELECT 
    p.pot_id,
    p.pot_name,
    p.location,
    pl.plant_name,
    pl.species,
    pl.ideal_moisture_min AS [Min_Moisture],
    pl.ideal_moisture_max AS [Max_Moisture],
    p.status AS [Pot_Status]
FROM Pot p
LEFT JOIN Plant pl ON p.plant_id = pl.plant_id;
GO

PRINT '=============================================================';
PRINT '>>> 4. KIỂM TRA 10 BẢN GHI SỐ ĐO CẢM BIẾN TELEMETRY GẦN NHẤT:';
PRINT '=============================================================';
SELECT TOP 10
    sr.reading_id,
    s.sensor_id,
    p.pot_name,
    sr.moisture_level AS [Moisture_%],
    sr.weight_kg AS [Weight_kg],
    sr.light_lux AS [Light_lux],
    sr.recorded_at
FROM SensorReading sr
JOIN Sensor s ON sr.sensor_id = s.sensor_id
JOIN Pot p ON s.pot_id = p.pot_id
ORDER BY sr.recorded_at DESC;
GO

PRINT '=============================================================';
PRINT '>>> 5. TỔNG HỢP KPI SỬ DỤNG NƯỚC (DASHBOARD ANALYTICS):';
PRINT '=============================================================';
SELECT 
    ROUND(SUM(wa.water_ml) / 1000.0, 2) AS [Water_Delivered_L],
    ROUND(SUM(wa.water_ml * wa.retain_ratio) / 1000.0, 2) AS [Water_Retained_L],
    ROUND(SUM(wa.water_ml * (1.0 - wa.retain_ratio)) / 1000.0, 2) AS [Water_Waste_L],
    COUNT(ws.session_id) AS [Total_Sessions]
FROM WateringSession ws
JOIN WaterAnalysis wa ON ws.session_id = wa.session_id;
GO

PRINT '=============================================================';
PRINT '>>> 6. DANH SÁCH CẢNH BÁO SỰ CỐ ĐANG MỞ (ACTIVE ALERTS):';
PRINT '=============================================================';
SELECT 
    a.alert_id,
    p.pot_name,
    a.alert_type,
    a.message,
    a.is_resolved,
    a.created_at
FROM Alert a
JOIN Pot p ON a.pot_id = p.pot_id
WHERE a.is_resolved = 0
ORDER BY a.created_at DESC;
GO

PRINT '=============================================================';
PRINT '>>> 7. CẤU HÌNH LỊCH TƯỚI TỰ ĐỘNG (SCHEDULES):';
PRINT '=============================================================';
SELECT 
    ws.schedule_id,
    p.pot_name,
    ws.cron_expression,
    ws.duration_seconds,
    ws.is_active
FROM WateringSchedule ws
JOIN Pot p ON ws.pot_id = p.pot_id;
GO

PRINT '=============================================================';
PRINT '>>> 8. BẢN GHI DỰ ĐOÁN ĐẤT KHÔ (ML PREDICTIONS):';
PRINT '=============================================================';
SELECT TOP 5
    mlp.prediction_id,
    p.pot_name,
    mlp.predicted_dry_time,
    mlp.confidence_score AS [Confidence_%],
    mlp.features_used
FROM MLPrediction mlp
JOIN Pot p ON mlp.pot_id = p.pot_id
ORDER BY mlp.created_at DESC;
GO
