-- =========================================================================
-- 04 - Migration: align an EXISTING SmartIrrigationDB with the backend code.
-- Safe to run more than once (every change is guarded).
-- New installs do not need this script: 01_SmartIrrigation_Schema_17Tables.sql
-- already contains these columns.
-- =========================================================================
USE SmartIrrigationDB;
GO

-- WateringSession.source: written by WateringSessionDAO / IrrigationHistoryDAO
IF COL_LENGTH('WateringSession', 'source') IS NULL
    ALTER TABLE WateringSession ADD source VARCHAR(20) NULL CONSTRAINT DF_WateringSession_source DEFAULT 'DEVICE';
GO

-- SensorReading.source: written by SensorDataDAO
IF COL_LENGTH('SensorReading', 'source') IS NULL
    ALTER TABLE SensorReading ADD source VARCHAR(20) NULL CONSTRAINT DF_SensorReading_source DEFAULT 'DEVICE';
GO

-- Plant.water_amount_ml: default volume (ml) per manual watering session
IF COL_LENGTH('Plant', 'water_amount_ml') IS NULL
    ALTER TABLE Plant ADD water_amount_ml INT NULL CONSTRAINT DF_Plant_water_amount_ml DEFAULT 250;
GO

-- Plant.default_pot_id: assigned irrigation zone / pot
IF COL_LENGTH('Plant', 'default_pot_id') IS NULL
    ALTER TABLE Plant ADD default_pot_id INT NULL;
GO

-- Back-fill rows created before the columns existed
UPDATE WateringSession SET source = CASE WHEN schedule_id IS NULL THEN 'MANUAL' ELSE 'SCHEDULED' END WHERE source IS NULL;
UPDATE SensorReading   SET source = 'DEVICE' WHERE source IS NULL;
UPDATE Plant           SET water_amount_ml = 250 WHERE water_amount_ml IS NULL OR water_amount_ml <= 0;
GO
