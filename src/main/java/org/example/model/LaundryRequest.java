package org.example.model;

import java.util.Date;

public class LaundryRequest {
    private int id;
    private String requestNo;
    private String studentId;
    private String studentName;
    private int floorNo;
    private String roomNo;
    private String serviceType;
    private String urgency;
    private int totalItems;
    private double totalCost;
    private String status;
    private Date collectionDate;
    private String assignedTime;
    private String notes;
    private Date createdAt;
    private String paymentStatus;
    private Date paymentDate;

    public LaundryRequest() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getRequestNo() { return requestNo; }
    public void setRequestNo(String requestNo) { this.requestNo = requestNo; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public int getFloorNo() { return floorNo; }
    public void setFloorNo(int floorNo) { this.floorNo = floorNo; }

    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }

    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }

    public String getUrgency() { return urgency; }
    public void setUrgency(String urgency) { this.urgency = urgency; }

    public int getTotalItems() { return totalItems; }
    public void setTotalItems(int totalItems) { this.totalItems = totalItems; }

    public double getTotalCost() { return totalCost; }
    public void setTotalCost(double totalCost) { this.totalCost = totalCost; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getCollectionDate() { return collectionDate; }
    public void setCollectionDate(Date collectionDate) { this.collectionDate = collectionDate; }

    public String getAssignedTime() { return assignedTime; }
    public void setAssignedTime(String assignedTime) { this.assignedTime = assignedTime; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public Date getPaymentDate() { return paymentDate; }
    public void setPaymentDate(Date paymentDate) { this.paymentDate = paymentDate; }
}