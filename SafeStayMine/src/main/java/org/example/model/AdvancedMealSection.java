package org.example.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class AdvancedMealSection {
    private int id;
    private Date mealDate;
    private String mealType;
    private Date orderBefore;
    private String createdBy;
    private Date createdAt;
    private Date updatedAt;
    private boolean active;
    private List<AdvancedMealColumn> columns = new ArrayList<>();

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Date getMealDate() {
        return mealDate;
    }

    public void setMealDate(Date mealDate) {
        this.mealDate = mealDate;
    }

    public String getMealType() {
        return mealType;
    }

    public void setMealType(String mealType) {
        this.mealType = mealType;
    }

    public Date getOrderBefore() {
        return orderBefore;
    }

    public void setOrderBefore(Date orderBefore) {
        this.orderBefore = orderBefore;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public List<AdvancedMealColumn> getColumns() {
        return columns;
    }

    public void setColumns(List<AdvancedMealColumn> columns) {
        this.columns = columns;
    }
}