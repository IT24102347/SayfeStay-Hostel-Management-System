package org.example.model;

import java.util.Date;

public class MealPlan {
    private int id;
    private String planName;
    private String description;
    private int mealsPerDay;
    private double weeklyPrice;
    private boolean isActive;
    private Date createdAt;

    public MealPlan() {
        this.description = "";
        this.isActive = true;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getPlanName() { return planName; }
    public void setPlanName(String planName) { this.planName = planName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getMealsPerDay() { return mealsPerDay; }
    public void setMealsPerDay(int mealsPerDay) { this.mealsPerDay = mealsPerDay; }

    public double getWeeklyPrice() { return weeklyPrice; }
    public void setWeeklyPrice(double weeklyPrice) { this.weeklyPrice = weeklyPrice; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
