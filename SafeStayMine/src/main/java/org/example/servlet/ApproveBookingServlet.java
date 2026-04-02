package org.example.servlet;

import org.example.dao.BookingDAO;
import org.example.dao.RoomDAO;
import org.example.model.User;
import org.example.model.Room;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/owner/approve-booking")
public class ApproveBookingServlet extends HttpServlet {

    private BookingDAO bookingDAO;
    private RoomDAO roomDAO;

    @Override
    public void init() {
        bookingDAO = new BookingDAO();
        roomDAO = new RoomDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String remarks = request.getParameter("remarks");

            Room room = roomDAO.getRoomById(roomId);

            if (room == null || !room.isAvailable()) {
                session.setAttribute("errorMessage", "Room not available!");
                response.sendRedirect(request.getContextPath() + "/dashboard/owner/pending-bookings.jsp");
                return;
            }

            boolean success = bookingDAO.approveBooking(bookingId, roomId, user.getUserId(), remarks);

            if (success) {
                session.setAttribute("successMessage", "Booking approved and room assigned!");
            } else {
                session.setAttribute("errorMessage", "Failed to approve booking!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/dashboard/owner/pending-bookings.jsp");
    }
}