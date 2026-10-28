package model;

/**
 * Entity đại diện cho Chậu cây (Table Pot).
 * Quy tắc bắt buộc:
 *   - 1 Chậu cây (Pot) thuộc về 1 Khu vực (areaId -> Area).
 *   - 1 Chậu cây (Pot) chỉ được trồng duy nhất 1 Loại cây (plantId -> Plant).
 */
public class Pot {
    private int potId;
    private String potName;
    private Integer areaId;               // Khóa ngoại trỏ sang bảng Area
    private String areaName;              // Tên khu vực (Lấy từ lệnh JOIN bảng Area)
    private String location;              // Vị trí đặt chậu (Đồng bộ với areaName)
    private int plantId;                  // Khóa ngoại bắt buộc trỏ sang bảng Plant (1 Pot = 1 Plant)
    private String plantName;             // Tên loại cây đang trồng trong chậu
    private Double minMoistureThreshold;  // Ngưỡng kích hoạt tưới tự động của cây trong chậu
    private Double maxMoistureThreshold;  // Ngưỡng cảnh báo ngập úng của cây trong chậu
    private boolean autoWateringEnabled = true;
    private boolean status = true;        // Trạng thái hoạt động của chậu

    public Pot() {
    }

    public Pot(int potId, String potName, String location, int plantId, String plantName, boolean status) {
        this.potId = potId;
        this.potName = potName;
        this.location = location;
        this.areaName = location;
        this.plantId = plantId;
        this.plantName = plantName;
        this.status = status;
    }

    public Pot(int potId, String potName, Integer areaId, String areaName, int plantId, String plantName, boolean status) {
        this.potId = potId;
        this.potName = potName;
        this.areaId = areaId;
        this.areaName = areaName;
        this.location = areaName;
        this.plantId = plantId;
        this.plantName = plantName;
        this.status = status;
    }

    public int getId() { return potId; }
    public void setId(int id) { this.potId = id; }

    public int getPotId() { return potId; }
    public void setPotId(int potId) { this.potId = potId; }

    public String getName() { return potName; }
    public void setName(String name) { this.potName = name; }

    public String getPotName() { return potName; }
    public void setPotName(String potName) { this.potName = potName; }

    public Integer getAreaId() { return areaId; }
    public void setAreaId(Integer areaId) { this.areaId = areaId; }

    public String getAreaName() {
        return (areaName != null && !areaName.trim().isEmpty()) ? areaName : location;
    }
    public void setAreaName(String areaName) {
        this.areaName = areaName;
        if (this.location == null || this.location.trim().isEmpty()) {
            this.location = areaName;
        }
    }

    public String getLocation() {
        return (location != null && !location.trim().isEmpty()) ? location : areaName;
    }
    public void setLocation(String location) {
        this.location = location;
    }

    public int getPlantId() { return plantId; }
    public void setPlantId(int plantId) { this.plantId = plantId; }

    public String getPlantName() { return plantName; }
    public void setPlantName(String plantName) { this.plantName = plantName; }

    public Double getMinMoistureThreshold() { return minMoistureThreshold; }
    public void setMinMoistureThreshold(Double minMoistureThreshold) {
        this.minMoistureThreshold = minMoistureThreshold;
    }

    public Double getMaxMoistureThreshold() { return maxMoistureThreshold; }
    public void setMaxMoistureThreshold(Double maxMoistureThreshold) {
        this.maxMoistureThreshold = maxMoistureThreshold;
    }

    public boolean isAutoWateringEnabled() { return autoWateringEnabled; }
    public void setAutoWateringEnabled(boolean autoWateringEnabled) {
        this.autoWateringEnabled = autoWateringEnabled;
    }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
