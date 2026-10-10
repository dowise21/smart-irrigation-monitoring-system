package model;

import java.sql.Timestamp;

public class WateringSession {
    private int sessionId;
    private int potId;
    private double volume;
    private String source; // 'MANUAL' hoặc 'AUTO'
    private int triggerBy; // ID của User đã nhấn nút
    private Timestamp createdAt;

    public WateringSession() {
    }

    public WateringSession(int potId, double volume, String source, int triggerBy) {
        this.potId = potId;
        this.volume = volume;
        this.source = source;
        this.triggerBy = triggerBy;
    }

    // --- GETTERS & SETTERS ---
    public int getSessionId() { return sessionId; }
    public void setSessionId(int sessionId) { this.sessionId = sessionId; }
    
    public int getPotId() { return potId; }
    public void setPotId(int potId) { this.potId = potId; }
    
    public double getVolume() { return volume; }
    public void setVolume(double volume) { this.volume = volume; }
    
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    
    public int getTriggerBy() { return triggerBy; }
    public void setTriggerBy(int triggerBy) { this.triggerBy = triggerBy; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}