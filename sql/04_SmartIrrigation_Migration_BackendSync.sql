-- =========================================================================
-- 04 - Migration: align an EXISTING SmartIrrigationDB with the backend code
-- and the refactored Area - Plant - Pot entity model.
-- Safe to run more than once (every change is guarded).
-- =========================================================================
USE SmartIrrigationDB;
GO

-- 1. Create Area table if it does not exist
IF OBJECT_ID('Area', 'U') IS NULL
BEGIN
    CREATE TABLE Area (
        area_id INT IDENTITY(1,1) PRIMARY KEY,
        area_name NVARCHAR(100) NOT NULL,
        description NVARCHAR(500),
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- Seed default Areas if empty
IF NOT EXISTS (SELECT 1 FROM Area)
BEGIN
    INSERT INTO Area (area_name, description) VALUES
        (N'Ban công Tầng 2 (Balcony Zone A)', N'Khu vực đón nắng sáng trực tiếp, thoáng gió'),
        (N'Sân thượng (Rooftop Garden B)', N'Khu vực trồng rau ăn lá và cây ăn quả'),
        (N'Phòng khách / Trong nhà (Indoor Zone C)', N'Khu vực cây cảnh nội thất ít nắng');
END
GO

-- 2. Plant columns: water_requirement, min_moisture_threshold, max_moisture_threshold
IF COL_LENGTH('Plant', 'water_requirement') IS NULL
    ALTER TABLE Plant ADD water_requirement NVARCHAR(100) NULL CONSTRAINT DF_Plant_water_req DEFAULT N'Trung bình (250ml/lần)';
GO

IF COL_LENGTH('Plant', 'min_moisture_threshold') IS NULL
    ALTER TABLE Plant ADD min_moisture_threshold FLOAT NULL CONSTRAINT DF_Plant_min_threshold DEFAULT 35.0;
GO

IF COL_LENGTH('Plant', 'max_moisture_threshold') IS NULL
    ALTER TABLE Plant ADD max_moisture_threshold FLOAT NULL CONSTRAINT DF_Plant_max_threshold DEFAULT 75.0;
GO

IF COL_LENGTH('Plant', 'water_amount_ml') IS NULL
    ALTER TABLE Plant ADD water_amount_ml INT NULL CONSTRAINT DF_Plant_water_amount_ml DEFAULT 250;
GO

IF COL_LENGTH('Plant', 'default_pot_id') IS NULL
    ALTER TABLE Plant ADD default_pot_id INT NULL;
GO

-- 3. Pot columns: area_id (FK -> Area), auto_watering_enabled
IF COL_LENGTH('Pot', 'area_id') IS NULL
BEGIN
    ALTER TABLE Pot ADD area_id INT NULL;
    ALTER TABLE Pot ADD CONSTRAINT FK_Pot_Area FOREIGN KEY (area_id) REFERENCES Area(area_id);
END
GO

IF COL_LENGTH('Pot', 'auto_watering_enabled') IS NULL
    ALTER TABLE Pot ADD auto_watering_enabled BIT NULL CONSTRAINT DF_Pot_auto_water DEFAULT 1;
GO

-- 4. WateringSession & SensorReading source columns
IF COL_LENGTH('WateringSession', 'source') IS NULL
    ALTER TABLE WateringSession ADD source VARCHAR(20) NULL CONSTRAINT DF_WateringSession_source DEFAULT 'DEVICE';
GO

IF COL_LENGTH('SensorReading', 'source') IS NULL
    ALTER TABLE SensorReading ADD source VARCHAR(20) NULL CONSTRAINT DF_SensorReading_source DEFAULT 'DEVICE';
GO

-- 5. Synchronize existing rows
UPDATE Plant SET min_moisture_threshold = COALESCE(ideal_moisture_min, 35.0) WHERE min_moisture_threshold IS NULL;
UPDATE Plant SET max_moisture_threshold = COALESCE(ideal_moisture_max, 75.0) WHERE max_moisture_threshold IS NULL;
UPDATE Plant SET ideal_moisture_min = COALESCE(min_moisture_threshold, 35.0) WHERE ideal_moisture_min IS NULL;
UPDATE Plant SET ideal_moisture_max = COALESCE(max_moisture_threshold, 75.0) WHERE ideal_moisture_max IS NULL;
UPDATE Plant SET water_amount_ml = 250 WHERE water_amount_ml IS NULL OR water_amount_ml <= 0;
UPDATE Plant SET water_requirement = CAST(water_amount_ml AS NVARCHAR(20)) + N' ml/lần' WHERE water_requirement IS NULL;
UPDATE Pot   SET area_id = (SELECT TOP 1 area_id FROM Area ORDER BY area_id ASC) WHERE area_id IS NULL;
UPDATE Pot   SET auto_watering_enabled = 1 WHERE auto_watering_enabled IS NULL;
UPDATE WateringSession SET source = CASE WHEN schedule_id IS NULL THEN 'MANUAL' ELSE 'SCHEDULED' END WHERE source IS NULL;
UPDATE SensorReading   SET source = 'DEVICE' WHERE source IS NULL;
GO
