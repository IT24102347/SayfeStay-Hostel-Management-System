package org.example.servlet;

import org.example.dao.BookingDAO;
import org.example.model.BookingRequest;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/booking/my-bookings")
public class MyBookingsServlet extends HttpServlet {

    private BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        
        // Only students can view their bookings
        if (!"Student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Get all bookings for this student
        List<BookingRequest> bookings = bookingDAO.getBookingsByStudent(user.getUserId());

        // Set attributes
        request.setAttribute("bookings", bookings);
        request.setAttribute("user", user);

        // Forward to JSP
        request.getRequestDispatcher("/myBookings.jsp").forward(request, response);
    }
}
