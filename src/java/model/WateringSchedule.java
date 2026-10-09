package model;

public class WateringSchedule {
    private int scheduleId;
    private int potId;
    private String cronExpression; // Dùng lưu chuỗi định dạng thời gian, VD: "08:00 Hàng ngày"
    private int durationSeconds;   // Thời gian bơm chạy (giây)
    private boolean isActive;      // Trạng thái Bật/Tắt lịch tưới

    public WateringSchedule() {
    }

    public WateringSchedule(int scheduleId, int potId, String cronExpression, int durationSeconds, boolean isActive) {
        this.scheduleId = scheduleId;
        this.potId = potId;
        this.cronExpression = cronExpression;
        this.durationSeconds = durationSeconds;
        this.isActive = isActive;
    }

    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }

    public int getPotId() { return potId; }
    public void setPotId(int potId) { this.potId = potId; }

    public String getCronExpression() { return cronExpression; }
    public void setCronExpression(String cronExpression) { this.cronExpression = cronExpression; }

    public int getDurationSeconds() { return durationSeconds; }
    public void setDurationSeconds(int durationSeconds) { this.durationSeconds = durationSeconds; }

    public boolean isIsActive() { return isActive; }
    public void setIsActive(boolean isActive) { this.isActive = isActive; }
}