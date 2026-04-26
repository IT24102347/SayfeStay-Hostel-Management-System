package org.example.model;

import java.util.Date;

public class DamageReport {
    private int id;
    private String studentId;
    private String studentName;
    private String requestNo;
    private String description;
    private String photo1;
    private String photo2;
    private String photo3;
    private String photo4;
    private String status;
    private String staffResponse;
    private Date reportedAt;
    private Date resolvedAt;

    public DamageReport() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getRequestNo() { return requestNo; }
    public void setRequestNo(String requestNo) { this.requestNo = requestNo; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getPhoto1() { return photo1; }
    public void setPhoto1(String photo1) { this.photo1 = photo1; }

    public String getPhoto2() { return photo2; }
    public void setPhoto2(String photo2) { this.photo2 = photo2; }

    public String getPhoto3() { return photo3; }
    public void setPhoto3(String photo3) { this.photo3 = photo3; }

    public String getPhoto4() { return photo4; }
    public void setPhoto4(String photo4) { this.photo4 = photo4; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getStaffResponse() { return staffResponse; }
    public void setStaffResponse(String staffResponse) { this.staffResponse = staffResponse; }

    public Date getReportedAt() { return reportedAt; }
    public void setReportedAt(Date reportedAt) { this.reportedAt = reportedAt; }

    public Date getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Date resolvedAt) { this.resolvedAt = resolvedAt; }
}