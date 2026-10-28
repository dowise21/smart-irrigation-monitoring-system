package model;

import java.sql.Timestamp;

/**
 * Entity đại diện cho Khu vực đặt chậu cây (Table Area).
 * Quan hệ: 1 Area (Khu vực) chứa nhiều Pot (Chậu cây).
 */
public class Area {
    private int areaId;
    private String areaName;
    private String description;
    private Timestamp createdAt;

    public Area() {
    }

    public Area(int areaId, String areaName, String description) {
        this.areaId = areaId;
        this.areaName = areaName;
        this.description = description;
    }

    public Area(int areaId, String areaName, String description, Timestamp createdAt) {
        this.areaId = areaId;
        this.areaName = areaName;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getId() { return areaId; }
    public void setId(int id) { this.areaId = id; }

    public int getAreaId() { return areaId; }
    public void setAreaId(int areaId) { this.areaId = areaId; }

    public String getName() { return areaName; }
    public void setName(String name) { this.areaName = name; }

    public String getAreaName() { return areaName; }
    public void setAreaName(String areaName) { this.areaName = areaName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}

