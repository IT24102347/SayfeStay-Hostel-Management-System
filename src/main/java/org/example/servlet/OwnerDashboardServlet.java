package org.example.servlet;

import org.example.dao.*;
import org.example.model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/dashboard/owner")
public class OwnerDashboardServlet extends HttpServlet {

    private OwnerDAO ownerDAO;
    private BookingDAO bookingDAO;
    private RoomDAO roomDAO;

    @Override
    public void init() {
        ownerDAO = new OwnerDAO();
        bookingDAO = new BookingDAO();
        roomDAO = new RoomDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (!"Owner".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard/student/");
            return;
        }

        // Get owner data
        Owner owner = ownerDAO.getOwnerByUserId(user.getUserId());
        Hostel hostel = ownerDAO.getHostelByOwnerId(user.getUserId());
        Map<String, Object> stats = ownerDAO.getDashboardStats();

        // Get pending bookings
        List<BookingRequest> pendingBookings = bookingDAO.getPendingBookings();
        List<Room> availableRooms = roomDAO.getAvailableRooms();

        // Get only first 3 for dashboard
        List<BookingRequest> recentRequests = new ArrayList<>();
        if (pendingBookings.size() > 3) {
            recentRequests = pendingBookings.subList(0, 3);
        } else {
            recentRequests = pendingBookings;
        }

        // Set attributes
        request.setAttribute("owner", owner);
        request.setAttribute("hostel", hostel);
        request.setAttribute("stats", stats);
        request.setAttribute("pendingBookings", pendingBookings);
        request.setAttribute("recentRequests", recentRequests);
        request.setAttribute("pendingCount", pendingBookings.size());
        request.setAttribute("availableRooms", availableRooms);

        // Forward to JSP
        request.getRequestDispatcher("/dashboard/owner/index.jsp").forward(request, response);
    }
}