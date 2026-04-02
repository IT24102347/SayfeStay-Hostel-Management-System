package org.example.model;

import java.util.Date;

public class Room {
    private int id;
    private int hostelId;
    private String roomNumber;
    private String roomType;
    private int capacity;
    private int occupied;
    private double priceMonthly;
    private String hasAc;
    private String hasFan;
    private String hasAttachedBathroom;
    private String status;
    private int floor;
    private Date createdAt;

    public Room() {
        this.hasFan = "Yes";
        this.status = "Available";
    }

    // Getters
    public int getId() { return id; }
    public int getHostelId() { return hostelId; }
    public String getRoomNumber() { return roomNumber; }
    public String getRoomType() { return roomType; }
    public int getCapacity() { return capacity; }
    public int getOccupied() { return occupied; }
    public double getPriceMonthly() { return priceMonthly; }
    public String getHasAc() { return hasAc != null ? hasAc : "No"; }
    public String getHasFan() { return hasFan != null ? hasFan : "Yes"; }
    public String getHasAttachedBathroom() { return hasAttachedBathroom != null ? hasAttachedBathroom : "No"; }
    public String getStatus() { return status; }
    public int getFloor() { return floor; }
    public Date getCreatedAt() { return createdAt; }

    // Setters
    public void setId(int id) { this.id = id; }
    public void setHostelId(int hostelId) { this.hostelId = hostelId; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public void setRoomType(String roomType) { this.roomType = roomType; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    public void setOccupied(int occupied) { this.occupied = occupied; }
    public void setPriceMonthly(double priceMonthly) { this.priceMonthly = priceMonthly; }
    public void setHasAc(String hasAc) { this.hasAc = hasAc; }
    public void setHasFan(String hasFan) { this.hasFan = hasFan; }
    public void setHasAttachedBathroom(String hasAttachedBathroom) { this.hasAttachedBathroom = hasAttachedBathroom; }
    public void setStatus(String status) { this.status = status; }
    public void setFloor(int floor) { this.floor = floor; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    // Helper methods
    public int getAvailableBeds() {
        return capacity - occupied;
    }

    public boolean isAvailable() {
        return "Available".equals(status) && getAvailableBeds() > 0;
    }

    public boolean isHasAc() {
        return "Yes".equals(hasAc);
    }

    public boolean isHasFan() {
        return "Yes".equals(hasFan);
    }

    public boolean isHasAttachedBathroom() {
        return "Yes".equals(hasAttachedBathroom);
    }

    public String getStatusBadgeClass() {
        switch(status) {
            case "Available": return "status-available";
            case "Occupied": return "status-occupied";
            case "Maintenance": return "status-maintenance";
            default: return "status-available";
        }
    }
}