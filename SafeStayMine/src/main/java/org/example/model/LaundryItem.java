package org.example.model;

import java.util.Date;

public class LaundryItem {
    private int id;
    private String itemName;
    private double basePrice;
    private boolean isActive;
    private Date createdAt;

    // Default constructor
    public LaundryItem() {}

    // Constructor with parameters (ADD THIS)
    public LaundryItem(int id, String itemName, double basePrice) {
        this.id = id;
        this.itemName = itemName;
        this.basePrice = basePrice;
        this.isActive = true;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public double getBasePrice() { return basePrice; }
    public void setBasePrice(double basePrice) { this.basePrice = basePrice; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}