<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.User" %>
<%@ page import="org.example.dao.LaundryDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if(user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String amountStr = request.getParameter("amount");
    double amount = 0;
    try {
        if(amountStr != null && !amountStr.isEmpty()) {
            amount = Double.parseDouble(amountStr);
        }
    } catch(Exception e) {
        amount = 0;
    }

    if(amount == 0) {
        Object sessionAmount = session.getAttribute("paymentAmount");
        if(sessionAmount != null) {
            amount = (Double) sessionAmount;
        }
    }

    LaundryDAO laundryDAO = new LaundryDAO();
    double unpaidAmount = laundryDAO.getTotalUnpaidAmount(user.getUserId());
    double finalAmount = amount > 0 ? amount : unpaidAmount;

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy HH:mm");
    String currentDateTime = dateFormat.format(new Date());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Laundry Payment | SafeStay</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }
        body { background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%); min-height: 100vh; display: flex; justify-content: center; align-items: center; padding: 20px; }
        .payment-container { max-width: 550px; width: 100%; background: white; border-radius: 28px; padding: 35px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25); }
        .logo { text-align: center; margin-bottom: 20px; }
        .logo h1 { font-size: 28px; color: #1a237e; }
        .logo span { color: #ffd700; }
        .payment-header { text-align: center; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 1px solid #e2e8f0; }
        .payment-header h2 { font-size: 24px; color: #0f172a; }
        .amount-card { background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%); color: white; border-radius: 20px; padding: 25px; text-align: center; margin-bottom: 25px; }
        .amount-card .amount { font-size: 48px; font-weight: 800; }
        .payment-details { background: #f8fafc; border-radius: 16px; padding: 20px; margin-bottom: 25px; }
        .detail-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #e2e8f0; }
        .detail-row.total { font-weight: 700; font-size: 18px; padding-top: 16px; border-top: 2px solid #e2e8f0; border-bottom: none; }
        .card-input-group { margin-bottom: 20px; }
        .card-input-group label { display: block; margin-bottom: 8px; font-weight: 500; color: #333; }
        .card-input-group input { width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 12px; font-size: 14px; }
        .card-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        .btn-pay { width: 100%; padding: 16px; background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%); color: white; border: none; border-radius: 40px; font-size: 18px; font-weight: 700; cursor: pointer; }
        .btn-back { width: 100%; padding: 12px; background: white; border: 1px solid #e2e8f0; border-radius: 40px; margin-top: 15px; cursor: pointer; }
        .card-icons { display: flex; gap: 10px; margin-top: 8px; margin-bottom: 15px; }
        .card-icons i { font-size: 32px; color: #6c757d; }
    </style>
</head>
<body>
<div class="payment-container">
    <div class="logo"><h1>Safe<span>Stay</span></h1></div>
    <div class="payment-header"><h2>Secure Payment</h2></div>
    <div class="amount-card"><div class="amount">Rs. <%= String.format("%,.2f", finalAmount) %></div></div>

    <div class="payment-details">
        <div class="detail-row"><span>Student ID</span><span><%= user.getUserId() %></span></div>
        <div class="detail-row"><span>Student Name</span><span><%= user.getFullName() %></span></div>
        <div class="detail-row"><span>Payment Date</span><span><%= currentDateTime %></span></div>
        <div class="detail-row total"><span>Total Amount</span><span>Rs. <%= String.format("%,.2f", finalAmount) %></span></div>
    </div>

    <form action="<%= request.getContextPath() %>/laundry-process-card-payment" method="POST">
        <input type="hidden" name="amount" value="<%= finalAmount %>">
        <div class="card-input-group">
            <label>Card Number</label>
            <input type="text" name="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19">
        </div>
        <div class="card-input-group">
            <label>Cardholder Name</label>
            <input type="text" name="cardName" placeholder="Name on card">
        </div>
        <div class="card-row">
            <div class="card-input-group">
                <label>Expiry Date</label>
                <input type="text" name="expiryDate" placeholder="MM/YY" maxlength="5">
            </div>
            <div class="card-input-group">
                <label>CVV</label>
                <input type="password" name="cvv" placeholder="123" maxlength="4">
            </div>
        </div>
        <div class="card-icons">
            <i class="fab fa-cc-visa"></i>
            <i class="fab fa-cc-mastercard"></i>
            <i class="fab fa-cc-amex"></i>
        </div>
        <input type="hidden" name="paymentMethod" value="Credit Card">
        <button type="submit" class="btn-pay">Pay Rs. <%= String.format("%,.2f", finalAmount) %></button>
    </form>

    <button class="btn-back" onclick="location.href='laundry-dashboard.jsp'">Back to Dashboard</button>
</div>
</body>
</html>