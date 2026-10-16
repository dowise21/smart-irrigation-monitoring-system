package model;

import java.sql.Timestamp;

public class Plant {
    private int plantId;
    private String plantName;
    private String species;
    private Double idealMoistureMin;
    private Double idealMoistureMax;
    private String description;
    private Timestamp createdAt;
    private int waterAmountMl = 250; // default volume of one manual watering (ml)
    private Integer defaultPotId;    // assigned irrigation zone / pot

    public Plant() {
    }

    public Plant(int plantId, String plantName, String species, Double idealMoistureMin, Double idealMoistureMax, String description, Timestamp createdAt) {
        this.plantId = plantId;
        this.plantName = plantName;
        this.species = species;
        this.idealMoistureMin = idealMoistureMin;
        this.idealMoistureMax = idealMoistureMax;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getPlantId() { return plantId; }
    public void setPlantId(int plantId) { this.plantId = plantId; }

    public String getPlantName() { return plantName; }
    public void setPlantName(String plantName) { this.plantName = plantName; }

    public String getSpecies() { return species; }
    public void setSpecies(String species) { this.species = species; }

    public Double getIdealMoistureMin() { return idealMoistureMin; }
    public void setIdealMoistureMin(Double idealMoistureMin) { this.idealMoistureMin = idealMoistureMin; }

    public Double getIdealMoistureMax() { return idealMoistureMax; }
    public void setIdealMoistureMax(Double idealMoistureMax) { this.idealMoistureMax = idealMoistureMax; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getWaterAmountMl() { return waterAmountMl; }
    public void setWaterAmountMl(int waterAmountMl) { this.waterAmountMl = waterAmountMl; }

    public Integer getDefaultPotId() { return defaultPotId; }
    public void setDefaultPotId(Integer defaultPotId) { this.defaultPotId = defaultPotId; }
}