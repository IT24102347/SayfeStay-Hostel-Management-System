package org.example.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class AdvancedMealColumn {
    private int id;
    private int sectionId;
    private int columnNo;
    private String columnType; // SPLIT or NORMAL
    private String itemName;
    private String imagePath;
    private double price;
    private boolean available;
    private Date createdAt;
    private Date updatedAt;
    private List<AdvancedMealColumnPart> parts = new ArrayList<>();

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSectionId() {
        return sectionId;
    }

    public void setSectionId(int sectionId) {
        this.sectionId = sectionId;
    }

    public int getColumnNo() {
        return columnNo;
    }

    public void setColumnNo(int columnNo) {
        this.columnNo = columnNo;
    }

    public String getColumnType() {
        return columnType;
    }

    public void setColumnType(String columnType) {
        this.columnType = columnType;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public boolean isAvailable() {
        return available;
    }

    public void setAvailable(boolean available) {
        this.available = available;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<AdvancedMealColumnPart> getParts() {
        return parts;
    }

    public void setParts(List<AdvancedMealColumnPart> parts) {
        this.parts = parts;
    }

    public boolean isSplitColumn() {
        return "SPLIT".equalsIgnoreCase(columnType);
    }

    public boolean isNormalColumn() {
        return "NORMAL".equalsIgnoreCase(columnType);
    }
}