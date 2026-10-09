package model;

import java.sql.Timestamp;

public class SensorData {
    private int dataId;
    private int potId;
    private double moistureLevel; // Độ ẩm đo được (%)
    private Timestamp recordedAt; // Thời gian đo

    // Các thuộc tính mở rộng (Lấy từ bảng Pot và Plant thông qua JOIN)
    private String potName;
    private String plantName;

    public SensorData() {
    }

    public SensorData(int dataId, int potId, double moistureLevel, Timestamp recordedAt, String potName, String plantName) {
        this.dataId = dataId;
        this.potId = potId;
        this.moistureLevel = moistureLevel;
        this.recordedAt = recordedAt;
        this.potName = potName;
        this.plantName = plantName;
    }

    // --- GETTER & SETTER ---
    public int getDataId() { return dataId; }
    public void setDataId(int dataId) { this.dataId = dataId; }

    public int getPotId() { return potId; }
    public void setPotId(int potId) { this.potId = potId; }

    public double getMoistureLevel() { return moistureLevel; }
    public void setMoistureLevel(double moistureLevel) { this.moistureLevel = moistureLevel; }

    public Timestamp getRecordedAt() { return recordedAt; }
    public void setRecordedAt(Timestamp recordedAt) { this.recordedAt = recordedAt; }

    public String getPotName() { return potName; }
    public void setPotName(String potName) { this.potName = potName; }

    public String getPlantName() { return plantName; }
    public void setPlantName(String plantName) { this.plantName = plantName; }
}