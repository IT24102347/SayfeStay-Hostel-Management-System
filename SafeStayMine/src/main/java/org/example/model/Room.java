package org.example.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

public class Room {
    private int id;
    private int hostelId;
    private String roomNumber;
    private int floorNumber;
    private String roomType; // AC or Non-AC
    private int capacity;
    private int occupied;
    private int availableSlots;
    private BigDecimal priceMonthly;
    private String status; // Available, Partially Occupied, Full, Under Maintenance
    
    // Bed and Bathroom
    private String bedType;
    private String bathroomType;
    
    // Facilities
    private boolean hasWifi;
    private boolean hasStudyTable;
    private boolean hasCupboard;
    private boolean hasFan;
    private boolean hasAc;
    private boolean hasLaundryAccess;
    
    // Services
    private boolean hasRoomCleaning;
    
    // Images and Description
    private String imagePaths;
    private String description;
    
    // Hostel Info (from join)
    private String hostelName;
    private String hostelAddress;
    private String city;
    
    // Timestamps
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Constructors
    public Room() {}

    public Room(int id, String roomNumber, int floorNumber, String roomType, 
                int capacity, int occupied, BigDecimal priceMonthly, String status) {
        this.id = id;
        this.roomNumber = roomNumber;
        this.floorNumber = floorNumber;
        this.roomType = roomType;
        this.capacity = capacity;
        this.occupied = occupied;
        this.priceMonthly = priceMonthly;
        this.status = status;
        this.availableSlots = capacity - occupied;
    }

    // Helper Methods
    public List<String> getImageList() {
        if (imagePaths == null || imagePaths.trim().isEmpty()) {
            return Arrays.asList("images/rooms/default.jpg");
        }
        return Arrays.asList(imagePaths.split(";"));
    }
    
    public String getFirstImage() {
        List<String> images = getImageList();
        return images.isEmpty() ? "images/rooms/default.jpg" : images.get(0);
    }
    
    public boolean isAvailable() {
        return availableSlots > 0 && 
               ("Available".equals(status) || "Partially Occupied".equals(status));
    }
    
    public String getFormattedPrice() {
        return String.format("Rs. %.2f", priceMonthly);
    }
    
    public String getCapacityDisplay() {
        if (capacity == 1) return "Single";
        return capacity + " Students";
    }
    
    public String getAvailabilityDisplay() {
        if (availableSlots == 0) return "Full";
        if (availableSlots == capacity) return "All Slots Available";
        return availableSlots + " Slot" + (availableSlots > 1 ? "s" : "") + " Available";
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getHostelId() {
        return hostelId;
    }

    public void setHostelId(int hostelId) {
        this.hostelId = hostelId;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public int getFloorNumber() {
        return floorNumber;
    }

    public void setFloorNumber(int floorNumber) {
        this.floorNumber = floorNumber;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public int getOccupied() {
        return occupied;
    }

    public void setOccupied(int occupied) {
        this.occupied = occupied;
        this.availableSlots = this.capacity - occupied;
    }

    public int getAvailableSlots() {
        return availableSlots;
    }

    public void setAvailableSlots(int availableSlots) {
        this.availableSlots = availableSlots;
    }

    public BigDecimal getPriceMonthly() {
        return priceMonthly;
    }

    public void setPriceMonthly(BigDecimal priceMonthly) {
        this.priceMonthly = priceMonthly;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getBedType() {
        return bedType;
    }

    public void setBedType(String bedType) {
        this.bedType = bedType;
    }

    public String getBathroomType() {
        return bathroomType;
    }

    public void setBathroomType(String bathroomType) {
        this.bathroomType = bathroomType;
    }

    public boolean isHasWifi() {
        return hasWifi;
    }

    public void setHasWifi(boolean hasWifi) {
        this.hasWifi = hasWifi;
    }

    public boolean isHasStudyTable() {
        return hasStudyTable;
    }

    public void setHasStudyTable(boolean hasStudyTable) {
        this.hasStudyTable = hasStudyTable;
    }

    public boolean isHasCupboard() {
        return hasCupboard;
    }

    public void setHasCupboard(boolean hasCupboard) {
        this.hasCupboard = hasCupboard;
    }

    public boolean isHasFan() {
        return hasFan;
    }

    public void setHasFan(boolean hasFan) {
        this.hasFan = hasFan;
    }

    public boolean isHasAc() {
        return hasAc;
    }

    public void setHasAc(boolean hasAc) {
        this.hasAc = hasAc;
    }

    public boolean isHasLaundryAccess() {
        return hasLaundryAccess;
    }

    public void setHasLaundryAccess(boolean hasLaundryAccess) {
        this.hasLaundryAccess = hasLaundryAccess;
    }

    public boolean isHasRoomCleaning() {
        return hasRoomCleaning;
    }

    public void setHasRoomCleaning(boolean hasRoomCleaning) {
        this.hasRoomCleaning = hasRoomCleaning;
    }

    public String getImagePaths() {
        return imagePaths;
    }

    public void setImagePaths(String imagePaths) {
        this.imagePaths = imagePaths;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getHostelName() {
        return hostelName;
    }

    public void setHostelName(String hostelName) {
        this.hostelName = hostelName;
    }

    public String getHostelAddress() {
        return hostelAddress;
    }

    public void setHostelAddress(String hostelAddress) {
        this.hostelAddress = hostelAddress;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
