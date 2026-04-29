package org.example.model;

import java.util.Date;

public class RoomAssignment {
    private int id;
    private String studentId;
    private String studentName;
    private int roomId;
    private String roomNumber;
    private Date assignmentDate;
    private Date startDate;
    private Date endDate;
    private double rentAmount;
    private String paymentStatus;
    private String status;
    private String remarks;
    private Date createdAt;
    private Date updatedAt;

    public RoomAssignment() {
        this.paymentStatus = "Pending";
        this.status = "Active";
        this.remarks = "";
    }

    // Getters
    public int getId() { return id; }
    public String getStudentId() { return studentId != null ? studentId : ""; }
    public String getStudentName() { return studentName != null ? studentName : ""; }
    public int getRoomId() { return roomId; }
    public String getRoomNumber() { return roomNumber != null ? roomNumber : ""; }
    public Date getAssignmentDate() { return assignmentDate; }
    public Date getStartDate() { return startDate; }
    public Date getEndDate() { return endDate; }
    public double getRentAmount() { return rentAmount; }
    public String getPaymentStatus() { return paymentStatus != null ? paymentStatus : "Pending"; }
    public String getStatus() { return status != null ? status : "Active"; }
    public String getRemarks() { return remarks != null ? remarks : ""; }
    public Date getCreatedAt() { return createdAt; }
    public Date getUpdatedAt() { return updatedAt; }

    // Setters
    public void setId(int id) { this.id = id; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public void setAssignmentDate(Date assignmentDate) { this.assignmentDate = assignmentDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }
    public void setRentAmount(double rentAmount) { this.rentAmount = rentAmount; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public void setStatus(String status) { this.status = status; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}