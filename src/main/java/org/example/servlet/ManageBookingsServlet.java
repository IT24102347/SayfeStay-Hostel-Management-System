package org.example.servlet;

import org.example.dao.BookingDAO;
import org.example.model.BookingRequest;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/bookings")
public class ManageBookingsServlet extends HttpServlet {

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
        
        // Only Owner can manage bookings
        if (!"Owner".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Get filter parameter
        String filter = request.getParameter("filter");
        
        List<BookingRequest> bookings;
        String pageTitle;
        
        if ("pending".equals(filter)) {
            bookings = bookingDAO.getPendingBookings();
            pageTitle = "Pending Booking Requests";
        } else {
            bookings = bookingDAO.getAllBookingRequests();
            pageTitle = "All Booking Requests";
        }

        // Get statistics
        Map<String, Integer> stats = bookingDAO.getBookingStatistics();

        // Set attributes
        request.setAttribute("bookings", bookings);
        request.setAttribute("pageTitle", pageTitle);
        request.setAttribute("stats", stats);
        request.setAttribute("currentFilter", filter);
        request.setAttribute("user", user);

        // Forward to JSP
        request.getRequestDispatcher("/admin/manageBookings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        
        // Only Owner can manage bookings
        if (!"Owner".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");
        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        String remarks = request.getParameter("remarks");

        boolean success = false;

        if ("approve".equals(action)) {
            success = bookingDAO.approveBooking(bookingId, user.getUserId(), remarks);
            if (success) {
                session.setAttribute("success", "Booking approved successfully!");
            } else {
                session.setAttribute("error", "Failed to approve booking!");
            }
        } else if ("reject".equals(action)) {
            success = bookingDAO.rejectBooking(bookingId, user.getUserId(), remarks);
            if (success) {
                session.setAttribute("success", "Booking rejected successfully!");
            } else {
                session.setAttribute("error", "Failed to reject booking!");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/bookings");
    }
}
