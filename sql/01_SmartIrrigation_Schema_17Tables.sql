-- =========================================================================
-- FILE 1/3: DATABASE SCHEMA DEFINITION (17 TABLES)
-- TÊN DỰ ÁN: SMART IRRIGATION MONITORING SYSTEM (PRJ301 - FALL 2026)
-- DBMS: MICROSOFT SQL SERVER 2019/2022 (T-SQL)
-- =========================================================================

USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SmartIrrigationDB')
BEGIN
    CREATE DATABASE SmartIrrigationDB;
END
GO

USE SmartIrrigationDB;
GO

-- =========================================================================
-- 0. DỌN DẸP BẢNG CŨ (REVERSE DEPENDENCY ORDER)
-- =========================================================================
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

-- =========================================================================
-- I. NHÓM BẢNG PHÂN QUYỀN VÀ NGƯỜI DÙNG (USER & ROLES)
-- =========================================================================
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
    status BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_User_Role FOREIGN KEY (role_id) REFERENCES AppRole(role_id)
);
GO

-- =========================================================================
-- II. NHÓM BẢNG THỰC THỂ CỐT LÕI (CORE)
-- =========================================================================
CREATE TABLE Plant (
    plant_id INT IDENTITY(1,1) PRIMARY KEY,
    plant_name NVARCHAR(100) NOT NULL,
    species NVARCHAR(100),
    ideal_moisture_min FLOAT,
    ideal_moisture_max FLOAT,
    description NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE Pot (
    pot_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_name NVARCHAR(100) NOT NULL,
    location NVARCHAR(200),
    plant_id INT NOT NULL,
    status BIT DEFAULT 1,
    CONSTRAINT FK_Pot_Plant FOREIGN KEY (plant_id) REFERENCES Plant(plant_id)
);
GO

-- =========================================================================
-- III. NHÓM BẢNG CẢM BIẾN & THIẾT BỊ (IOT)
-- =========================================================================
CREATE TABLE Sensor (
    sensor_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_id INT NOT NULL,
    sensor_type VARCHAR(50), -- Moisture, Light, Weight...
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
GO

-- =========================================================================
-- IV. NHÓM BẢNG TƯỚI TIÊU & PHÂN TÍCH (IRRIGATION & ANALYSIS)
-- =========================================================================
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
    status VARCHAR(50), -- PENDING, RUNNING, COMPLETED, FAILED
    CONSTRAINT FK_Session_Pot FOREIGN KEY (pot_id) REFERENCES Pot(pot_id),
    CONSTRAINT FK_Session_Schedule FOREIGN KEY (schedule_id) REFERENCES WateringSchedule(schedule_id)
);

CREATE TABLE WaterAnalysis (
    analysis_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL,
    weight_before FLOAT,
    weight_after FLOAT,
    water_ml FLOAT,
    retain_ratio FLOAT, -- Ty le giu nuoc (0.0 -> 1.0)
    CONSTRAINT FK_Analysis_Session FOREIGN KEY (session_id) REFERENCES WateringSession(session_id)
);
GO

-- =========================================================================
-- V. NHÓM BẢNG CẢNH BÁO & MACHINE LEARNING (ALERTS & ML)
-- =========================================================================
CREATE TABLE Alert (
    alert_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_id INT NOT NULL,
    session_id INT NULL,
    alert_type VARCHAR(50) NOT NULL, -- OVERWATER, DRY_STRESS, SENSOR_FAULT, LEAK
    message NVARCHAR(MAX),
    is_resolved BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Alert_Pot FOREIGN KEY (pot_id) REFERENCES Pot(pot_id),
    CONSTRAINT FK_Alert_Session FOREIGN KEY (session_id) REFERENCES WateringSession(session_id)
);

CREATE TABLE AlertConfirmation (
    confirmation_id INT IDENTITY(1,1) PRIMARY KEY,
    alert_id INT NOT NULL,
    user_id INT NOT NULL,
    action_taken NVARCHAR(500),
    confirmed_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Confirmation_Alert FOREIGN KEY (alert_id) REFERENCES Alert(alert_id),
    CONSTRAINT FK_Confirmation_User FOREIGN KEY (user_id) REFERENCES AppUser(user_id)
);

CREATE TABLE MLPrediction (
    prediction_id INT IDENTITY(1,1) PRIMARY KEY,
    pot_id INT NOT NULL,
    predicted_dry_time DATETIME,
    confidence_score FLOAT,
    features_used NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
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
