package org.example.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class Attendance {
    private int id;
    private String studentId;
    private String studentName;
    private java.sql.Date attendanceDate;
    private Timestamp checkInTime;
    private Timestamp checkOutTime;
    private String status;
    private String markedBy;
    private String remarks;
    private Timestamp createdAt;

    public Attendance() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public java.sql.Date getAttendanceDate() { return attendanceDate; }
    public void setAttendanceDate(java.sql.Date attendanceDate) { this.attendanceDate = attendanceDate; }

    public Timestamp getCheckInTime() { return checkInTime; }
    public void setCheckInTime(Timestamp checkInTime) { this.checkInTime = checkInTime; }

    public Timestamp getCheckOutTime() { return checkOutTime; }
    public void setCheckOutTime(Timestamp checkOutTime) { this.checkOutTime = checkOutTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getMarkedBy() { return markedBy; }
    public void setMarkedBy(String markedBy) { this.markedBy = markedBy; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // Helper methods
    public String getFormattedCheckInTime() {
        if (checkInTime == null) return "--:--";
        return new SimpleDateFormat("hh:mm a").format(checkInTime);
    }

    public String getFormattedCheckOutTime() {
        if (checkOutTime == null) return "--:--";
        return new SimpleDateFormat("hh:mm a").format(checkOutTime);
    }

    public String getFormattedDate() {
        if (attendanceDate == null) return "";
        return new SimpleDateFormat("dd MMM yyyy").format(attendanceDate);
    }

    @Override
    public String toString() {
        return "Attendance{" +
                "id=" + id +
                ", studentId='" + studentId + '\'' +
                ", checkIn=" + checkInTime +
                ", checkOut=" + checkOutTime +
                ", status='" + status + '\'' +
                '}';
    }
}