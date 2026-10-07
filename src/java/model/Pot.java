package model;

public class Pot {
    private int potId;
    private String potName;
    private String location;     // Vị trí đặt chậu (VD: Ban công, Sân thượng)
    private int plantId;         // Khóa ngoại trỏ sang bảng Plant
    private String plantName;    // Tên cây (Lấy từ lệnh JOIN, không có trong bảng Pot gốc)
    private boolean status;      // Trạng thái (true: Đang hoạt động, false: Ngừng tưới)

    public Pot() {
    }

    public Pot(int potId, String potName, String location, int plantId, String plantName, boolean status) {
        this.potId = potId;
        this.potName = potName;
        this.location = location;
        this.plantId = plantId;
        this.plantName = plantName;
        this.status = status;
    }

    public int getPotId() { return potId; }
    public void setPotId(int potId) { this.potId = potId; }

    public String getPotName() { return potName; }
    public void setPotName(String potName) { this.potName = potName; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public int getPlantId() { return plantId; }
    public void setPlantId(int plantId) { this.plantId = plantId; }

    public String getPlantName() { return plantName; }
    public void setPlantName(String plantName) { this.plantName = plantName; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}