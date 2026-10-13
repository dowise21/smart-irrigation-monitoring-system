-- =========================================================================
-- FILE 2/3: SAMPLE DATA & TEST USERS (17 TABLES)
-- TÊN DỰ ÁN: SMART IRRIGATION MONITORING SYSTEM (PRJ301 - FALL 2026)
-- DBMS: MICROSOFT SQL SERVER 2019/2022 (T-SQL)
-- =========================================================================

USE SmartIrrigationDB;
GO

-- 1. INSERT VAI TRÒ (5 ROLES CHUẨN CỦA HỆ THỐNG)
INSERT INTO AppRole (role_name) VALUES 
('ADMIN'), 
('MANAGER'), 
('TECHNICIAN'), 
('STAFF'), 
('VIEWER');

-- 2. INSERT QUYỀN HẠN (PERMISSIONS)
INSERT INTO Permission (perm_name) VALUES 
('USER_MANAGE'),
('GARDEN_MANAGE'),
('SCHEDULE_MANAGE'),
('IOT_DEVICE_MANAGE'),
('MANUAL_WATER_EXECUTE'),
('ALERT_HANDLE'),
('AI_PREDICT_VIEW'),
('REPORT_EXPORT');

-- Gán quyền cho các vai trò
INSERT INTO RolePermission (role_id, perm_id) VALUES 
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), -- ADMIN full quyền
(2, 2), (2, 3), (2, 7), (2, 8),                                   -- MANAGER
(3, 4), (3, 8),                                                   -- TECHNICIAN
(4, 5), (4, 6),                                                   -- STAFF
(5, 7);                                                           -- VIEWER

-- 3. INSERT TÀI KHOẢN MẪU (MẬT KHẨU CHUNG: 123456 ĐÃ BĂM PBKDF2)
DECLARE @Hash VARCHAR(255) = '20000:8423ce0bb2ce5e11e8698f395d48a8ef:2292ef7d76dbb575d136a46ca5a78a47de36f7c6459ade6cd6d85fd3c1b76bc6';

INSERT INTO AppUser (username, password_hash, full_name, email, role_id, status) VALUES 
('admin',  @Hash, N'Lê Văn Ngoan (Admin)',       'admin1@demo.com',  1, 1),
('manager', @Hash, N'Nguyễn Ngọc Linh (Manager)', 'manager@demo.com', 2, 1),
('tech',    @Hash, N'Phan Duy Bảo (Technician)',  'tech@demo.com',    3, 1),
('staff',   @Hash, N'Trần Văn Hoàng (Staff)',     'staff@demo.com',   4, 1),
('viewer',  @Hash, N'Khách Tham Quan (Viewer)',   'viewer@demo.com',  5, 1);

-- 4. INSERT DANH MỤC CÂY TRỒNG (PLANTS)
INSERT INTO Plant (plant_name, species, ideal_moisture_min, ideal_moisture_max, description) VALUES 
(N'Cây Nha Đam', N'Aloe vera', 30.0, 60.0, N'Cây mọng nước chịu hạn tốt, cần đất thoát nước nhanh.'),
(N'Cúc Họa Mi', N'Chrysanthemum', 45.0, 75.0, N'Cây ưa ẩm vừa phải, cần ánh sáng tự nhiên đầy đủ.'),
(N'Lan Hồ Điệp', N'Phalaenopsis', 50.0, 70.0, N'Cần giữ ẩm rễ đều đặn, tránh ngập úng gốc.'),
(N'Trầu Bà Vàng', N'Epipremnum aureum', 55.0, 80.0, N'Thích nghi bóng râm, hấp thụ nước nhanh.'),
(N'Xương Rồng Bát Tiên', N'Euphorbia milii', 25.0, 50.0, N'Cần rất ít nước, dễ bị úng rễ nếu tưới nhiều.');

-- 5. INSERT CHẬU VƯỜN (POTS)
INSERT INTO Pot (pot_name, location, plant_id, status) VALUES 
(N'Chậu Ban Công 1', N'Ban công Đông Tầng 2', 1, 1),
(N'Chậu Sân Thượng', N'Sân thượng Tầng 3', 2, 1),
(N'Giàn Lan Hiên Nhà', N'Hiên trước phòng khách', 3, 1),
(N'Chậu Trầu Bà Cửa Sổ', N'Bệ cửa sổ văn phòng', 4, 1);

-- 6. INSERT CẢM BIẾN (SENSORS) & MÁY BƠM (PUMPS)
INSERT INTO Sensor (pot_id, sensor_type, status) VALUES 
(1, 'Moisture', 1),
(2, 'Moisture', 1),
(3, 'Moisture', 1),
(4, 'Moisture', 1);

INSERT INTO Pump (pot_id, pump_name, status) VALUES 
(1, N'Bơm Submersible 12V - Trạm 1', 1),
(2, N'Bơm Mini Drip - Trạm 2', 1),
(3, N'Bơm Phun Sương - Trạm 3', 1),
(4, N'Bơm Nhỏ 5V - Trạm 4', 1);

INSERT INTO PumpCalibration (pump_id, flow_rate_ml_per_sec, calibrated_by) VALUES 
(1, 28.5, 3),
(2, 15.0, 3);

-- 7. INSERT BẢN GHI ĐO LƯỜNG TELEMETRY (SENSOR READINGS)
INSERT INTO SensorReading (sensor_id, moisture_level, weight_kg, light_lux, recorded_at) VALUES 
(1, 35.2, 5.8, 1200, DATEADD(MINUTE, -120, GETDATE())),
(1, 36.8, 5.8, 1350, DATEADD(MINUTE, -90, GETDATE())),
(1, 38.0, 5.9, 1400, DATEADD(MINUTE, -60, GETDATE())),
(1, 41.5, 6.1, 1600, DATEADD(MINUTE, -30, GETDATE())),
(1, 42.0, 6.1, 1500, GETDATE()),

(2, 48.0, 6.2, 2500, DATEADD(MINUTE, -120, GETDATE())),
(2, 50.5, 6.4, 2800, DATEADD(MINUTE, -60, GETDATE())),
(2, 52.0, 6.4, 2700, GETDATE()),

(3, 28.5, 4.5, 900, DATEADD(MINUTE, -60, GETDATE())),
(3, 27.0, 4.4, 950, GETDATE());

-- 8. INSERT LỊCH TƯỚI TỰ ĐỘNG (WATERING SCHEDULES)
INSERT INTO WateringSchedule (pot_id, cron_expression, duration_seconds, is_active) VALUES 
(1, '0 0 7 * * ?', 45, 1),
(2, '0 30 6,17 * * ?', 60, 1),
(3, '0 0 8 * * ?', 30, 0),
(4, '0 0 18 * * ?', 40, 1);

-- 9. INSERT PHIÊN TƯỚI (WATERING SESSIONS) & PHÂN TÍCH NƯỚC (WATER ANALYSIS)
INSERT INTO WateringSession (pot_id, schedule_id, start_time, duration_seconds, status) VALUES 
(1, 1, DATEADD(HOUR, -24, GETDATE()), 45, 'COMPLETED'),
(1, 1, DATEADD(HOUR, -12, GETDATE()), 45, 'COMPLETED'),
(2, 2, DATEADD(HOUR, -18, GETDATE()), 60, 'COMPLETED'),
(2, 2, DATEADD(HOUR, -6, GETDATE()),  60, 'COMPLETED'),
(3, NULL, DATEADD(HOUR, -4, GETDATE()), 30, 'COMPLETED');

INSERT INTO WaterAnalysis (session_id, weight_before, weight_after, water_ml, retain_ratio) VALUES 
(1, 5.2, 6.0, 1280.0, 0.62),
(2, 5.4, 6.1, 1280.0, 0.55),
(3, 5.6, 6.3, 900.0,  0.78),
(4, 5.7, 6.4, 900.0,  0.77),
(5, 4.3, 4.7, 650.0,  0.61);

-- 10. INSERT CẢNH BÁO SỰ CỐ (ALERTS) & XÁC NHẬN SỰ CỐ
INSERT INTO Alert (pot_id, session_id, alert_type, message, is_resolved, created_at) VALUES 
(1, 1, 'OVERWATER', N'Cảnh báo tưới thừa! Đã cấp 1280 ml nước nhưng tỷ lệ giữ nước chỉ đạt 55%.', 0, DATEADD(HOUR, -12, GETDATE())),
(3, 5, 'DRY_STRESS', N'Cây đang thiếu nước khẩn cấp! Độ ẩm hiện tại đạt 27%, thấp hơn ngưỡng 50%.', 0, DATEADD(HOUR, -2, GETDATE())),
(2, 3, 'SENSOR_FAULT', N'Mạch báo đã tưới 900 ml nhưng độ ẩm không đổi.', 1, DATEADD(HOUR, -18, GETDATE()));

INSERT INTO AlertConfirmation (alert_id, user_id, action_taken, confirmed_at) VALUES 
(3, 4, N'Đã cắm chặt lại giắc cắm cảm biến độ ẩm trên chậu 2.', DATEADD(HOUR, -17, GETDATE()));

-- 11. INSERT DỰ ĐOÁN ĐẤT KHÔ (ML PREDICTIONS)
INSERT INTO MLPrediction (pot_id, predicted_dry_time, confidence_score, features_used) VALUES 
(1, DATEADD(HOUR, 14, GETDATE()), 88.5, N'Moisture=42%, Light=1500lux, WaterMl=1280'),
(2, DATEADD(HOUR, 9,  GETDATE()), 91.2, N'Moisture=52%, Light=2700lux, WaterMl=900'),
(3, DATEADD(HOUR, 2,  GETDATE()), 85.0, N'Moisture=27%, Light=950lux, WaterMl=650');

-- 12. INSERT NHẬT KÝ HỆ THỐNG (SYSTEM LOGS)
INSERT INTO SystemLog (log_level, module, message) VALUES 
('INFO', 'AUTH', N'User admin1 logged in successfully from 127.0.0.1'),
('INFO', 'SCHEDULE', N'Triggered scheduled watering for Pot 1 (Duration: 45s)'),
('WARN', 'ALERT_SERVICE', N'Generated OVERWATER alert for Pot 1'),
('INFO', 'TELEMETRY', N'Ingested 10 telemetry packets from ESP32 Station');
GO
