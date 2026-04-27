package org.example.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class AdvancedMealOrder {
    private int id;
    private String orderNo;
    private int sectionId;
    private String studentId;
    private String studentName;
    private Date mealDate;
    private String mealType;
    private String selectedSummary;
    private double totalPrice;
    private String status;
    private Date orderedAt;
    private Date updatedAt;
    private String preparedBy;
    private Date servedAt;
    private List<AdvancedMealOrderItem> orderItems = new ArrayList<>();


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

    public int getSectionId() {
        return sectionId;
    }

    public void setSectionId(int sectionId) {
        this.sectionId = sectionId;
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

    public String getPreparedBy() {
        return preparedBy;
    }

    public void setPreparedBy(String preparedBy) {
        this.preparedBy = preparedBy;
    }

    public Date getServedAt() {
        return servedAt;
    }

    public void setServedAt(Date servedAt) {
        this.servedAt = servedAt;
    }

    public List<AdvancedMealOrderItem> getOrderItems() {
        return orderItems;
    }

    public void setOrderItems(List<AdvancedMealOrderItem> orderItems) {
        this.orderItems = orderItems;
    }
}