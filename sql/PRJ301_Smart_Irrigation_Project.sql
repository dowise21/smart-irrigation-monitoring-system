-- =========================================================================
-- TÊN DỰ ÁN: SMART IRRIGATION MONITORING SYSTEM (17 TABLES)
-- DBMS: SQL SERVER (T-SQL)
-- =========================================================================

USE master;
GO
-- Tạo Database nếu chưa có (Bạn có thể đổi tên DB tùy ý)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SmartIrrigationDB')
BEGIN
    CREATE DATABASE SmartIrrigationDB;
END
GO
USE SmartIrrigationDB;
GO

-- ==========================================
-- 0. DỌN DẸP BẢNG CŨ (Hỗ trợ chạy lại script nhiều lần không lỗi)
-- ==========================================
DROP TABLE IF EXISTS SystemLog;
DROP TABLE IF EXISTS MLPrediction;
DROP TABLE IF EXISTS AlertConfirmation;
DROP TABLE IF EXISTS Alert;
DROP TABLE IF EXISTS WaterAnalysis;
DROP TABLE IF EXISTS WateringSession;
DROP TABLE IF EXISTS WateringSchedule;
DROP TABLE IF EXISTS PumpCalibration;
DROP TABLE IF EXISTS Pump;
DROP TABLE IF EXISTS SensorReading;
DROP TABLE IF EXISTS Sensor;
DROP TABLE IF EXISTS Pot;
DROP TABLE IF EXISTS Plant;
DROP TABLE IF EXISTS RolePermission;
DROP TABLE IF EXISTS Permission;
DROP TABLE IF EXISTS AppUser;
DROP TABLE IF EXISTS AppRole;
GO

-- ==========================================
-- I. NHÓM BẢNG PHÂN QUYỀN VÀ NGƯỜI DÙNG (USER & ROLES)
-- ==========================================
CREATE TABLE AppRole (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL
);

CREATE TABLE Permission (
    perm_id INT IDENTITY(1,1) PRIMARY KEY,
    perm_name VARCHAR(100) NOT NULL
);

CREATE TABLE RolePermission (
    role_id INT NOT NULL,
    perm_id INT NOT NULL,
    PRIMARY KEY (role_id, perm_id),
    CONSTRAINT FK_RolePerm_Role FOREIGN KEY (role_id) REFERENCES AppRole(role_id),
    CONSTRAINT FK_RolePerm_Perm FOREIGN KEY (perm_id) REFERENCES Permission(perm_id)
);

CREATE TABLE AppUser (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100), 
    role_id INT NOT NULL,
    status BIT DEFAULT 1, -- Đã đổi từ is_active thành status theo chuẩn update của bạn
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_AppUser_Role FOREIGN KEY (role_id) REFERENCES AppRole(role_id)
);

-- ==========================================
-- II. NHÓM BẢNG THỰC THỂ CỐT LÕI (CORE)
-- ==========================================
CREATE TABLE Plant (
    plant_id INT IDENTITY(1,1) PRIMARY KEY,
    plant_name NVARCHAR(100) NOT NULL,
    species NVARCHAR(100),
    ideal_moisture_min FLOAT,
    ideal_moisture_max FLOAT,
    description NVARCHAR(500)
);

CREATE TABLE Pot (
    pot_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_name NVARCHAR(100) NOT NULL,
    location NVARCHAR(200),
    plant_id INT NOT NULL,
    status BIT DEFAULT 1,
    CONSTRAINT FK_Pot_Plant FOREIGN KEY (plant_id) REFERENCES Plant(plant_id)
);

-- ==========================================
-- III. NHÓM BẢNG CẢM BIẾN & THIẾT BỊ (IOT)
-- ==========================================
CREATE TABLE Sensor (
    sensor_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_id INT NOT NULL,
    sensor_type VARCHAR(50), -- VD: Moisture, Weight, Light
    status BIT DEFAULT 1,
    CONSTRAINT FK_Sensor_Pot FOREIGN KEY (pot_id) REFERENCES Pot(pot_id)
);

CREATE TABLE SensorReading (
    reading_id INT IDENTITY(1,1) PRIMARY KEY,
    sensor_id INT NOT NULL,
    moisture_level FLOAT,
    weight_kg FLOAT,
    light_lux INT,
    recorded_at DATETIME DEFAULT GETDATE(),
    source VARCHAR(20) DEFAULT 'SAMPLE', -- 'SAMPLE' hoặc 'DEVICE'
    CONSTRAINT FK_Reading_Sensor FOREIGN KEY (sensor_id) REFERENCES Sensor(sensor_id)
);

CREATE TABLE Pump (
    pump_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_id INT NOT NULL,
    pump_name NVARCHAR(100),
    status BIT DEFAULT 1,
    CONSTRAINT FK_Pump_Pot FOREIGN KEY (pot_id) REFERENCES Pot(pot_id)
);

CREATE TABLE PumpCalibration (
    calibration_id INT IDENTITY(1,1) PRIMARY KEY,
    pump_id INT NOT NULL,
    flow_rate_ml_per_sec FLOAT NOT NULL,
    calibrated_at DATETIME DEFAULT GETDATE(),
    calibrated_by INT,
    CONSTRAINT FK_Calibration_Pump FOREIGN KEY (pump_id) REFERENCES Pump(pump_id),
    CONSTRAINT FK_Calibration_User FOREIGN KEY (calibrated_by) REFERENCES AppUser(user_id)
);

-- ==========================================
-- IV. NHÓM BẢNG TƯỚI TIÊU & PHÂN TÍCH (IRRIGATION & ANALYSIS)
-- ==========================================
CREATE TABLE WateringSchedule (
    schedule_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_id INT NOT NULL,
    cron_expression VARCHAR(100),
    duration_seconds INT NOT NULL,
    is_active BIT DEFAULT 1,
    CONSTRAINT FK_Schedule_Pot FOREIGN KEY (pot_id) REFERENCES Pot(pot_id)
);

CREATE TABLE WateringSession (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_id INT NOT NULL,
    schedule_id INT NULL,
    start_time DATETIME DEFAULT GETDATE(),
    duration_seconds INT,
    source VARCHAR(20) DEFAULT 'SAMPLE',
    CONSTRAINT FK_Session_Pot FOREIGN KEY (pot_id) REFERENCES Pot(pot_id),
    CONSTRAINT FK_Session_Schedule FOREIGN KEY (schedule_id) REFERENCES WateringSchedule(schedule_id)
);

CREATE TABLE WaterAnalysis (
    analysis_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL,
    weight_before FLOAT,
    weight_after FLOAT,
    water_ml FLOAT,
    retain_ratio FLOAT, -- (Weight After - Weight Before) / Water Used
    moisture_before FLOAT,
    moisture_after FLOAT,
    dry_rate FLOAT,
    light_lux INT,
    CONSTRAINT FK_Analysis_Session FOREIGN KEY (session_id) REFERENCES WateringSession(session_id)
);

-- ==========================================
-- V. NHÓM BẢNG CẢNH BÁO & MACHINE LEARNING (ALERTS & ML)
-- ==========================================
CREATE TABLE Alert (
    alert_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_id INT NOT NULL,
    session_id INT NULL,
    alert_type VARCHAR(50) NOT NULL, -- NORMAL, OVERWATER, DRY_STRESS, SENSOR_FAULT, LEAK
    message NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    is_resolved BIT DEFAULT 0,
    CONSTRAINT FK_Alert_Pot FOREIGN KEY (pot_id) REFERENCES Pot(pot_id),
    CONSTRAINT FK_Alert_Session FOREIGN KEY (session_id) REFERENCES WateringSession(session_id)
);

CREATE TABLE AlertConfirmation (
    confirmation_id INT IDENTITY(1,1) PRIMARY KEY,
    alert_id INT NOT NULL,
    user_id INT NOT NULL,
    action_taken NVARCHAR(500),
    confirmed_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Confirm_Alert FOREIGN KEY (alert_id) REFERENCES Alert(alert_id),
    CONSTRAINT FK_Confirm_User FOREIGN KEY (user_id) REFERENCES AppUser(user_id)
);

CREATE TABLE MLPrediction (
    prediction_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_id INT NOT NULL,
    predicted_dry_time DATETIME,
    confidence_score FLOAT,
    features_used NVARCHAR(MAX),
    predicted_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ML_Pot FOREIGN KEY (pot_id) REFERENCES Pot(pot_id)
);

CREATE TABLE SystemLog (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    log_level VARCHAR(20), -- INFO, WARN, ERROR
    module VARCHAR(100),
    message NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- ==========================================
-- VI. CHÈN DỮ LIỆU MẪU (DUMMY DATA)
-- ==========================================

-- 1. Insert Roles
INSERT INTO AppRole (role_name) VALUES 
('ADMIN'), 
('MANAGER'), 
('TECHNICIAN'), 
('STAFF'), 
('VIEWER');

-- 2. Insert Users (Đã chuẩn hóa hash và email trực tiếp)
DECLARE @Hash VARCHAR(255) = '20000:8423ce0bb2ce5e11e8698f395d48a8ef:2292ef7d76dbb575d136a46ca5a78a47de36f7c6459ade6cd6d85fd3c1b76bc6';

INSERT INTO AppUser (username, password_hash, full_name, email, role_id, status) VALUES 
('admin1',  @Hash, N'Quản Trị Viên',   'admin1@demo.com',  1, 1),
('manager', @Hash, N'Quản Lý Vườn',    'manager@demo.com', 2, 1),
('tech',    @Hash, N'Kỹ Thuật Viên',   'tech@demo.com',    3, 1),
('staff',   @Hash, N'Nhân Viên Tưới',  'staff@demo.com',   4, 1),
('viewer',  @Hash, N'Khách Tham Quan', 'viewer@demo.com',  5, 1);

-- 3. Insert Core Data
INSERT INTO Plant (plant_name, species, ideal_moisture_min, ideal_moisture_max, description) 
VALUES (N'Cây Nha Đam', N'Aloe vera', 30.0, 60.0, N'Chịu hạn tốt, tưới ít nước.');

INSERT INTO Pot (pot_name, location, plant_id, status) 
VALUES (N'Chậu Ban Công 1', N'Khu vực ngoài trời', 1, 1);

INSERT INTO Sensor (pot_id, sensor_type, status) 
VALUES (1, 'Moisture', 1);

-- 4. Insert Alerts
INSERT INTO Alert (pot_id, alert_type, message, is_resolved) VALUES 
(1, 'OVERWATER', N'Cảnh báo tưới thừa! Đã dùng 1500 ml nước nhưng tỷ lệ giữ nước chỉ đạt 35%.', 0),
(1, 'DRY_STRESS', N'Cây đang thiếu nước! Độ ẩm hiện tại là 25%, thấp hơn ngưỡng an toàn.', 0),
(1, 'SENSOR_FAULT', N'Mạch báo đã tưới 800 ml nhưng độ ẩm không tăng.', 1);
GO