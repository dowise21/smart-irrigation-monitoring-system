package model;

import java.sql.Timestamp;

/**
 * Entity đại diện cho Loại cây trồng (Table Plant).
 * Chứa ngưỡng kích hoạt tưới tự động (minMoistureThreshold) và ngưỡng ngập úng (maxMoistureThreshold).
 */
public class Plant {
    private int plantId;
    private String plantName;
    private String species;
    private String waterRequirement;     // Mô tả nhu cầu nước (VD: "250 ml/lần", "Ưa ẩm")
    private Double minMoistureThreshold; // Ngưỡng kích hoạt tưới tự động & cảnh báo Khô hạn (DRY_STRESS)
    private Double maxMoistureThreshold; // Ngưỡng cảnh báo Ngập úng (OVERWATER)
    private String description;
    private Timestamp createdAt;
    private int waterAmountMl = 250;     // Lượng nước mặc định mỗi lần tưới (ml)
    private Integer defaultPotId;        // Chậu mặc định gắn với cây

    public Plant() {
    }

    public Plant(int plantId, String plantName, String species, Double minMoistureThreshold, Double maxMoistureThreshold, String description, Timestamp createdAt) {
        this.plantId = plantId;
        this.plantName = plantName;
        this.species = species;
        this.minMoistureThreshold = minMoistureThreshold;
        this.maxMoistureThreshold = maxMoistureThreshold;
        this.description = description;
        this.createdAt = createdAt;
        this.waterRequirement = waterAmountMl + " ml/lần";
    }

    public int getId() { return plantId; }
    public void setId(int id) { this.plantId = id; }

    public int getPlantId() { return plantId; }
    public void setPlantId(int plantId) { this.plantId = plantId; }

    public String getName() { return plantName; }
    public void setName(String name) { this.plantName = name; }

    public String getPlantName() { return plantName; }
    public void setPlantName(String plantName) { this.plantName = plantName; }

    public String getSpecies() { return species; }
    public void setSpecies(String species) { this.species = species; }

    public String getWaterRequirement() {
        if (waterRequirement == null || waterRequirement.trim().isEmpty()) {
            return waterAmountMl + " ml/lần";
        }
        return waterRequirement;
    }
    public void setWaterRequirement(String waterRequirement) {
        this.waterRequirement = waterRequirement;
    }

    public Double getMinMoistureThreshold() { return minMoistureThreshold; }
    public void setMinMoistureThreshold(Double minMoistureThreshold) {
        this.minMoistureThreshold = minMoistureThreshold;
    }

    public Double getMaxMoistureThreshold() { return maxMoistureThreshold; }
    public void setMaxMoistureThreshold(Double maxMoistureThreshold) {
        this.maxMoistureThreshold = maxMoistureThreshold;
    }

    // Các getter/setter tương thích ngược với giao diện và DAO hiện có
    public Double getIdealMoistureMin() { return minMoistureThreshold; }
    public void setIdealMoistureMin(Double idealMoistureMin) {
        this.minMoistureThreshold = idealMoistureMin;
    }

    public Double getIdealMoistureMax() { return maxMoistureThreshold; }
    public void setIdealMoistureMax(Double idealMoistureMax) {
        this.maxMoistureThreshold = idealMoistureMax;
    }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getWaterAmountMl() { return waterAmountMl; }
    public void setWaterAmountMl(int waterAmountMl) {
        this.waterAmountMl = waterAmountMl;
        if (this.waterRequirement == null || this.waterRequirement.trim().isEmpty()) {
            this.waterRequirement = waterAmountMl + " ml/lần";
        }
    }

    public Integer getDefaultPotId() { return defaultPotId; }
    public void setDefaultPotId(Integer defaultPotId) { this.defaultPotId = defaultPotId; }
}
