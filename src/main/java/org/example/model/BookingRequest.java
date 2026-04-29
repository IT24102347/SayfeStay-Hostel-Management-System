package org.example.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class BookingRequest {
    private int id;
    private String bookingId;
    private String studentId;
    private int roomId;
    
    // Student Details
    private String studentName;
    private int studentAge;
    private String studentPhone;
    private String studentEmail;
    
    // Guardian Details
    private String guardianName;
    private String guardianPhone;
    private String guardianRelationship;
    
    // Booking Details
    private Date bookingStartDate;
    private Date bookingEndDate;
    private int durationMonths;
    
    // Special Requests
    private String specialRequests;
    
    // Payment Information
    private BigDecimal keyMoney;
    private BigDecimal monthlyRent;
    private BigDecimal totalAmount;
    private String paymentMethod;
    private String paymentStatus;
    
    // Booking Status
    private String status;
    private String adminRemarks;
    
    // Timestamps
    private Timestamp requestedAt;
    private Timestamp approvedAt;
    private String approvedBy;
    
    // Room Info (from join)
    private String roomNumber;
    private int floorNumber;
    private String roomType;
    private BigDecimal priceMonthly;
    private String hostelName;
    private String studentUsername;

    // Constructors
    public BookingRequest() {}

    // Helper Methods
    public boolean isPending() {
        return "Pending".equals(status);
    }
    
    public boolean isApproved() {
        return "Approved".equals(status);
    }
    
    public boolean isRejected() {
        return "Rejected".equals(status);
    }
    
    public String getStatusBadgeClass() {
        switch (status) {
            case "Pending": return "warning";
            case "Approved": return "success";
            case "Rejected": return "danger";
            case "Cancelled": return "secondary";
            default: return "info";
        }
    }
    
    public String getFormattedTotalAmount() {
        return String.format("Rs. %.2f", totalAmount);
    }
    
    public String getFormattedKeyMoney() {
        return String.format("Rs. %.2f", keyMoney);
    }
    
    public String getFormattedMonthlyRent() {
        return String.format("Rs. %.2f", monthlyRent);
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public int getStudentAge() {
        return studentAge;
    }

    public void setStudentAge(int studentAge) {
        this.studentAge = studentAge;
    }

    public String getStudentPhone() {
        return studentPhone;
    }

    public void setStudentPhone(String studentPhone) {
        this.studentPhone = studentPhone;
    }

    public String getStudentEmail() {
        return studentEmail;
    }

    public void setStudentEmail(String studentEmail) {
        this.studentEmail = studentEmail;
    }

    public String getGuardianName() {
        return guardianName;
    }

    public void setGuardianName(String guardianName) {
        this.guardianName = guardianName;
    }

    public String getGuardianPhone() {
        return guardianPhone;
    }

    public void setGuardianPhone(String guardianPhone) {
        this.guardianPhone = guardianPhone;
    }

    public String getGuardianRelationship() {
        return guardianRelationship;
    }

    public void setGuardianRelationship(String guardianRelationship) {
        this.guardianRelationship = guardianRelationship;
    }

    public Date getBookingStartDate() {
        return bookingStartDate;
    }

    public void setBookingStartDate(Date bookingStartDate) {
        this.bookingStartDate = bookingStartDate;
    }

    public Date getBookingEndDate() {
        return bookingEndDate;
    }

    public void setBookingEndDate(Date bookingEndDate) {
        this.bookingEndDate = bookingEndDate;
    }

    public int getDurationMonths() {
        return durationMonths;
    }

    public void setDurationMonths(int durationMonths) {
        this.durationMonths = durationMonths;
    }

    public String getSpecialRequests() {
        return specialRequests;
    }

    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }

    public BigDecimal getKeyMoney() {
        return keyMoney;
    }

    public void setKeyMoney(BigDecimal keyMoney) {
        this.keyMoney = keyMoney;
    }

    public BigDecimal getMonthlyRent() {
        return monthlyRent;
    }

    public void setMonthlyRent(BigDecimal monthlyRent) {
        this.monthlyRent = monthlyRent;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAdminRemarks() {
        return adminRemarks;
    }

    public void setAdminRemarks(String adminRemarks) {
        this.adminRemarks = adminRemarks;
    }

    public Timestamp getRequestedAt() {
        return requestedAt;
    }

    public void setRequestedAt(Timestamp requestedAt) {
        this.requestedAt = requestedAt;
    }

    public Timestamp getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(Timestamp approvedAt) {
        this.approvedAt = approvedAt;
    }

    public String getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(String approvedBy) {
        this.approvedBy = approvedBy;
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

    public BigDecimal getPriceMonthly() {
        return priceMonthly;
    }

    public void setPriceMonthly(BigDecimal priceMonthly) {
        this.priceMonthly = priceMonthly;
    }

    public String getHostelName() {
        return hostelName;
    }

    public void setHostelName(String hostelName) {
        this.hostelName = hostelName;
    }

    public String getStudentUsername() {
        return studentUsername;
    }

    public void setStudentUsername(String studentUsername) {
        this.studentUsername = studentUsername;
    }
}
