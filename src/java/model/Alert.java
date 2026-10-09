package model;

import java.sql.Timestamp;

public class Alert {
    private int alertId;
    private int potId;
    private Integer sessionId; // Có thể null nếu lỗi không thuộc về phiên tưới nào (ví dụ: LEAK)
    private String alertType;
    private String message;
    private Timestamp createdAt;
    private boolean isResolved;
    
    // Thuộc tính bổ sung để hiển thị lên Web
    private String potName;

    public Alert() {
    }

    public Alert(int alertId, int potId, Integer sessionId, String alertType, String message, Timestamp createdAt, boolean isResolved, String potName) {
        this.alertId = alertId;
        this.potId = potId;
        this.sessionId = sessionId;
        this.alertType = alertType;
        this.message = message;
        this.createdAt = createdAt;
        this.isResolved = isResolved;
        this.potName = potName;
    }

    // --- GETTER & SETTER ---
    public int getAlertId() { return alertId; }
    public void setAlertId(int alertId) { this.alertId = alertId; }

    public int getPotId() { return potId; }
    public void setPotId(int potId) { this.potId = potId; }

    public Integer getSessionId() { return sessionId; }
    public void setSessionId(Integer sessionId) { this.sessionId = sessionId; }

    public String getAlertType() { return alertType; }
    public void setAlertType(String alertType) { this.alertType = alertType; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isIsResolved() { return isResolved; }
    public void setIsResolved(boolean isResolved) { this.isResolved = isResolved; }

    public String getPotName() { return potName; }
    public void setPotName(String potName) { this.potName = potName; }
}