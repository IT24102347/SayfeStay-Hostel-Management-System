package org.example.model;

import java.sql.Timestamp;

public class Inquiry {
    private int id;
    private String inquiryId;
    private String studentId;
    private Integer roomId; // Can be null
    private String subject;
    private String message;
    private String inquiryType;
    private String status;
    private Timestamp createdAt;
    
    // Student Info (from join)
    private String studentName;
    private String studentEmail;
    
    // Room Info (from join, if applicable)
    private String roomNumber;
    
    // Reply Info
    private String replyMessage;
    private Timestamp repliedAt;
    private String repliedBy;

    // Constructors
    public Inquiry() {}

    // Helper Methods
    public boolean isPending() {
        return "Pending".equals(status);
    }
    
    public boolean isReplied() {
        return "Replied".equals(status);
    }
    
    public boolean isClosed() {
        return "Closed".equals(status);
    }
    
    public String getStatusBadgeClass() {
        switch (status) {
            case "Pending": return "warning";
            case "Replied": return "success";
            case "Closed": return "secondary";
            default: return "info";
        }
    }
    
    public String getInquiryTypeIcon() {
        switch (inquiryType) {
            case "Room Details": return "fa-door-open";
            case "Location": return "fa-map-marker-alt";
            case "Photos": return "fa-camera";
            case "Facilities": return "fa-couch";
            case "General": return "fa-question-circle";
            default: return "fa-envelope";
        }
    }
    
    public boolean hasRoomReference() {
        return roomId != null && roomId > 0;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getInquiryId() {
        return inquiryId;
    }

    public void setInquiryId(String inquiryId) {
        this.inquiryId = inquiryId;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public Integer getRoomId() {
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getInquiryType() {
        return inquiryType;
    }

    public void setInquiryType(String inquiryType) {
        this.inquiryType = inquiryType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getStudentEmail() {
        return studentEmail;
    }

    public void setStudentEmail(String studentEmail) {
        this.studentEmail = studentEmail;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getReplyMessage() {
        return replyMessage;
    }

    public void setReplyMessage(String replyMessage) {
        this.replyMessage = replyMessage;
    }

    public Timestamp getRepliedAt() {
        return repliedAt;
    }

    public void setRepliedAt(Timestamp repliedAt) {
        this.repliedAt = repliedAt;
    }

    public String getRepliedBy() {
        return repliedBy;
    }

    public void setRepliedBy(String repliedBy) {
        this.repliedBy = repliedBy;
    }
}
