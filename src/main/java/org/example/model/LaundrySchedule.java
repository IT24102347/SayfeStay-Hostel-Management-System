package org.example.model;

public class LaundrySchedule {
    private int id;
    private int floorNo;
    private String dayOfWeek;
    private String collectionTime;
    private String deliveryTime;
    private boolean isActive;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getFloorNo() { return floorNo; }
    public void setFloorNo(int floorNo) { this.floorNo = floorNo; }

    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public String getCollectionTime() { return collectionTime; }
    public void setCollectionTime(String collectionTime) { this.collectionTime = collectionTime; }

    public String getDeliveryTime() { return deliveryTime; }
    public void setDeliveryTime(String deliveryTime) { this.deliveryTime = deliveryTime; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}