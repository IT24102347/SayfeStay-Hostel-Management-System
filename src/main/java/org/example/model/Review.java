
package org.example.model;

import java.sql.Timestamp;

public class Review {
    private int id;
    private String studentId;
    private String studentName;
    private String roomNo;

    // Overall rating
    private int rating;

    // Category ratings
    private int foodRating;
    private int wifiRating;
    private int cleanlinessRating;
    private int staffRating;

    private String comment;
    private String status;       // Pending / Approved
    private String ownerReply;
    private Timestamp repliedAt;
    private Timestamp createdAt;

    public Review() {}

    // =================== Getters & Setters ===================

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getRoomNo() { return roomNo; }
    public void setRoomNo(String roomNo) { this.roomNo = roomNo; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public int getFoodRating() { return foodRating; }
    public void setFoodRating(int foodRating) { this.foodRating = foodRating; }

    public int getWifiRating() { return wifiRating; }
    public void setWifiRating(int wifiRating) { this.wifiRating = wifiRating; }

    public int getCleanlinessRating() { return cleanlinessRating; }
    public void setCleanlinessRating(int cleanlinessRating) { this.cleanlinessRating = cleanlinessRating; }

    public int getStaffRating() { return staffRating; }
    public void setStaffRating(int staffRating) { this.staffRating = staffRating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getOwnerReply() { return ownerReply; }
    public void setOwnerReply(String ownerReply) { this.ownerReply = ownerReply; }

    public Timestamp getRepliedAt() { return repliedAt; }
    public void setRepliedAt(Timestamp repliedAt) { this.repliedAt = repliedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // Helper: format date as readable string
    public String getFormattedDate() {
        if (createdAt == null) return "";
        return createdAt.toString().substring(0, 19); // yyyy-MM-dd HH:mm:ss
    }
}


