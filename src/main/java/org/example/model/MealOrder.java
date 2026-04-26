package org.example.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MealOrder {
    private int id;
    private String orderNo;
    private String studentId;
    private String studentName;
    private int categoryId;
    private Date mealDate;
    private String mealType;
    private String selectedSummary;
    private double totalPrice;
    private String status;
    private Date orderedAt;
    private Date updatedAt;
    private Date deadlineAt;
    private List<Integer> selectedColumnIndexes = new ArrayList<>();

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
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

    public String getSelectedSummary() {
        return selectedSummary;
    }

    public void setSelectedSummary(String selectedSummary) {
        this.selectedSummary = selectedSummary;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getOrderedAt() {
        return orderedAt;
    }

    public void setOrderedAt(Date orderedAt) {
        this.orderedAt = orderedAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Date getDeadlineAt() {
        return deadlineAt;
    }

    public void setDeadlineAt(Date deadlineAt) {
        this.deadlineAt = deadlineAt;
    }

    public List<Integer> getSelectedColumnIndexes() {
        return selectedColumnIndexes;
    }

    public void setSelectedColumnIndexes(List<Integer> selectedColumnIndexes) {
        this.selectedColumnIndexes = selectedColumnIndexes;
    }
}