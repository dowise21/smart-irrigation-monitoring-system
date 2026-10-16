package model;

import java.sql.Timestamp;

public class IrrigationHistory {
    private int historyId;
    private int potId;
    private Timestamp irrigationTime;
    private Integer durationSeconds;
    private Double waterAmount;

    // Dữ liệu mở rộng từ lệnh JOIN
    private String potName;
    private String plantName;
    private String status;
    private String source;
    private Double retainRatio;

    public IrrigationHistory() {
    }

    public IrrigationHistory(int historyId, int potId, Timestamp irrigationTime, Integer durationSeconds, Double waterAmount, String potName, String plantName) {
        this.historyId = historyId;
        this.potId = potId;
        this.irrigationTime = irrigationTime;
        this.durationSeconds = durationSeconds;
        this.waterAmount = waterAmount;
        this.potName = potName;
        this.plantName = plantName;
    }

    // --- GETTER & SETTER ---
    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }

    public int getPotId() { return potId; }
    public void setPotId(int potId) { this.potId = potId; }

    public Timestamp getIrrigationTime() { return irrigationTime; }
    public void setIrrigationTime(Timestamp irrigationTime) { this.irrigationTime = irrigationTime; }

    public Integer getDurationSeconds() { return durationSeconds; }
    public void setDurationSeconds(Integer durationSeconds) { this.durationSeconds = durationSeconds; }

    public Double getWaterAmount() { return waterAmount; }
    public void setWaterAmount(Double waterAmount) { this.waterAmount = waterAmount; }

    public String getPotName() { return potName; }
    public void setPotName(String potName) { this.potName = potName; }

    public String getPlantName() { return plantName; }
    public void setPlantName(String plantName) { this.plantName = plantName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    /** Fraction of the delivered water the soil kept (0.0 - 1.0); null when not analysed. */
    public Double getRetainRatio() { return retainRatio; }
    public void setRetainRatio(Double retainRatio) { this.retainRatio = retainRatio; }

}
