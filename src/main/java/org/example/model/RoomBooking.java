package org.example.model;

import java.util.Date;

public class RoomBooking {
    private int id;
    private String bookingNo;
    private String studentId;
    private String studentName;
    private String roomType;
    private int floor;
    private String needAc;
    private String needFan;
    private String status;
    private int assignedRoomId;
    private String assignedRoomNumber;
    private Date createdAt;

    public RoomBooking() {
        this.needFan = "Yes";
        this.status = "Pending";
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getBookingNo() { return bookingNo; }
    public void setBookingNo(String bookingNo) { this.bookingNo = bookingNo; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public int getFloor() { return floor; }
    public void setFloor(int floor) { this.floor = floor; }

    public String getNeedAc() { return needAc; }
    public void setNeedAc(String needAc) { this.needAc = needAc; }

    public String getNeedFan() { return needFan; }
    public void setNeedFan(String needFan) { this.needFan = needFan; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getAssignedRoomId() { return assignedRoomId; }
    public void setAssignedRoomId(int assignedRoomId) { this.assignedRoomId = assignedRoomId; }

    public String getAssignedRoomNumber() { return assignedRoomNumber; }
    public void setAssignedRoomNumber(String assignedRoomNumber) { this.assignedRoomNumber = assignedRoomNumber; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}