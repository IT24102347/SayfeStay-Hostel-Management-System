package org.example.model;

import java.util.Date;

public class LaundryPayment {
    private int id;
    private String studentId;
    private String paymentNo;
    private Date weekStartDate;
    private Date weekEndDate;
    private double totalAmount;
    private Date paymentDate;

    public LaundryPayment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getPaymentNo() { return paymentNo; }
    public void setPaymentNo(String paymentNo) { this.paymentNo = paymentNo; }

    public Date getWeekStartDate() { return weekStartDate; }
    public void setWeekStartDate(Date weekStartDate) { this.weekStartDate = weekStartDate; }

    public Date getWeekEndDate() { return weekEndDate; }
    public void setWeekEndDate(Date weekEndDate) { this.weekEndDate = weekEndDate; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public Date getPaymentDate() { return paymentDate; }
    public void setPaymentDate(Date paymentDate) { this.paymentDate = paymentDate; }
}