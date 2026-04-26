package org.example.servlet;

import org.example.dao.LaundryDAO;
import org.example.dao.NotificationDAO;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/laundry-process-card-payment")
public class LaundryProcessCardPaymentServlet extends HttpServlet {

    private LaundryDAO laundryDAO;
    private NotificationDAO notificationDAO;

    @Override
    public void init() {
        laundryDAO = new LaundryDAO();
        notificationDAO = new NotificationDAO();
        System.out.println("=== LaundryProcessCardPaymentServlet INIT ===");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            String amountStr = request.getParameter("amount");
            String paymentMethod = request.getParameter("paymentMethod");
            String cardNumber = request.getParameter("cardNumber");
            String cardName = request.getParameter("cardName");

            double amount = Double.parseDouble(amountStr);

            if (amount <= 0) {
                session.setAttribute("errorMsg", "Invalid payment amount");
                response.sendRedirect(request.getContextPath() + "/dashboard/student/laundry-payment.jsp");
                return;
            }

            // Mask card number
            String maskedCard = "**** **** **** ";
            if (cardNumber != null && cardNumber.length() >= 4) {
                String lastFour = cardNumber.replaceAll("\\s", "");
                lastFour = lastFour.substring(lastFour.length() - 4);
                maskedCard += lastFour;
            }

            boolean success = laundryDAO.processAllPayments(user.getUserId());

            if (success) {
                notificationDAO.createNotification(
                        user.getUserId(),
                        "Laundry Payment Successful",
                        "Your payment of Rs. " + String.format("%.2f", amount) +
                                " was successful. Card: " + maskedCard +
                                " | Method: " + paymentMethod
                );

                session.setAttribute("successMsg", "Payment of Rs. " + String.format("%.2f", amount) +
                        " completed successfully! You can now submit new laundry requests.");
                session.removeAttribute("paymentAmount");

            } else {
                session.setAttribute("errorMsg", "Payment failed. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Payment failed: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/dashboard/student/laundry-dashboard.jsp");
    }
}