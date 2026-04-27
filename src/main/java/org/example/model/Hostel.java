package org.example.model;

import java.util.Date;

public class Hostel {
    private int id;
    private String ownerId;      // OWN001
    private String hostelName;
    private String address;
    private String city;
    private int totalRooms;
    private int availableRooms;
    private String contactNumber;
    private String email;
    private String wardenName;
    private String wardenPhone;
    private String status;
    private Date createdAt;

    public Hostel() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getOwnerId() { return ownerId; }
    public void setOwnerId(String ownerId) { this.ownerId = ownerId; }

    public String getHostelName() { return hostelName; }
    public void setHostelName(String hostelName) { this.hostelName = hostelName; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public int getTotalRooms() { return totalRooms; }
    public void setTotalRooms(int totalRooms) { this.totalRooms = totalRooms; }

    public int getAvailableRooms() { return availableRooms; }
    public void setAvailableRooms(int availableRooms) { this.availableRooms = availableRooms; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getWardenName() { return wardenName; }
    public void setWardenName(String wardenName) { this.wardenName = wardenName; }

    public String getWardenPhone() { return wardenPhone; }
    public void setWardenPhone(String wardenPhone) { this.wardenPhone = wardenPhone; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    // Business methods
    public int getOccupiedRooms() {
        return totalRooms - availableRooms;
    }

    public double getOccupancyRate() {
        if (totalRooms == 0) return 0;
        return (double) getOccupiedRooms() / totalRooms * 100;
    }
}