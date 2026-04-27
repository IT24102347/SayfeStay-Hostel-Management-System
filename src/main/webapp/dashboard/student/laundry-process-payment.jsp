<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.User" %>
<%@ page import="org.example.dao.LaundryDAO" %>
<%
  User user = (User) session.getAttribute("user");
  if(user == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String amountStr = request.getParameter("amount");
  double amount = 0;
  try {
    amount = Double.parseDouble(amountStr);
  } catch(Exception e) {
    amount = 0;
  }

  LaundryDAO dao = new LaundryDAO();
  boolean success = dao.processAllPayments(user.getUserId());

  if(success && amount > 0) {
    session.setAttribute("successMsg", "Payment of Rs. " + String.format("%.2f", amount) + " completed successfully! You can now submit new laundry requests.");
  } else if(amount <= 0) {
    session.setAttribute("errorMsg", "No pending payments found.");
  } else {
    session.setAttribute("errorMsg", "Payment failed. Please try again.");
  }

  response.sendRedirect("laundry-dashboard.jsp");
%>
