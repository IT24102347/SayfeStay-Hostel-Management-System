package org.example.model;

import java.util.Date;

public class MealEnrollment {
    private int id;
    private String studentId;
    private String studentName;
    private int planId;
    private String planName;
    private Date startDate;
    private double weeklyCost;
    private boolean isActive;
    private Date createdAt;


    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public int getPlanId() { return planId; }
    public void setPlanId(int planId) { this.planId = planId; }

    public String getPlanName() { return planName; }
    public void setPlanName(String planName) { this.planName = planName; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public double getWeeklyCost() { return weeklyCost; }
    public void setWeeklyCost(double weeklyCost) { this.weeklyCost = weeklyCost; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
