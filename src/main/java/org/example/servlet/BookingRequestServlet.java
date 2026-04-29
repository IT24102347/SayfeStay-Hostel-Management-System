package org.example.servlet;

import org.example.dao.BookingDAO;
import org.example.dao.RoomDAO;
import org.example.model.BookingRequest;
import org.example.model.Room;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

@WebServlet("/booking/request")
public class BookingRequestServlet extends HttpServlet {

    private BookingDAO bookingDAO = new BookingDAO();
    private RoomDAO roomDAO = new RoomDAO();

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
        
        // Only students can book rooms
        if (!"Student".equalsIgnoreCase(user.getRole())) {
            request.setAttribute("error", "Only students can book rooms!");
            request.getRequestDispatcher("/rooms").forward(request, response);
            return;
        }

        // Get room ID
        String roomIdStr = request.getParameter("roomId");
        
        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        try {
            int roomId = Integer.parseInt(roomIdStr);
            Room room = roomDAO.getRoomById(roomId);

            if (room == null) {
                request.setAttribute("error", "Room not found!");
                request.getRequestDispatcher("/rooms").forward(request, response);
                return;
            }

            // Check if room is available
            if (!room.isAvailable()) {
                request.setAttribute("error", "Room is not available!");
                request.setAttribute("room", room);
                request.getRequestDispatcher("/roomDetails.jsp").forward(request, response);
                return;
            }

            // Set attributes for booking form
            request.setAttribute("room", room);
            request.setAttribute("user", user);

            // Forward to booking form
            request.getRequestDispatcher("/bookingForm.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/rooms");
        }
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
        
        // Only students can book rooms
        if (!"Student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        try {
            // Get form parameters
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String studentName = request.getParameter("studentName");
            int studentAge = Integer.parseInt(request.getParameter("studentAge"));
            String studentPhone = request.getParameter("studentPhone");
            String studentEmail = request.getParameter("studentEmail");
            
            String guardianName = request.getParameter("guardianName");
            String guardianPhone = request.getParameter("guardianPhone");
            String guardianRelationship = request.getParameter("guardianRelationship");
            
            Date startDate = Date.valueOf(request.getParameter("startDate"));
            Date endDate = Date.valueOf(request.getParameter("endDate"));
            int durationMonths = Integer.parseInt(request.getParameter("durationMonths"));
            
            String specialRequests = request.getParameter("specialRequests");
            
            BigDecimal keyMoney = new BigDecimal(request.getParameter("keyMoney"));
            BigDecimal monthlyRent = new BigDecimal(request.getParameter("monthlyRent"));
            BigDecimal totalAmount = new BigDecimal(request.getParameter("totalAmount"));
            String paymentMethod = request.getParameter("paymentMethod");

            // Validate room availability
            Room room = roomDAO.getRoomById(roomId);
            if (room == null || !room.isAvailable()) {
                request.setAttribute("error", "Room is not available for booking!");
                request.getRequestDispatcher("/rooms").forward(request, response);
                return;
            }

            // Create booking request object
            BookingRequest booking = new BookingRequest();
            booking.setStudentId(user.getUserId());
            booking.setRoomId(roomId);
            booking.setStudentName(studentName);
            booking.setStudentAge(studentAge);
            booking.setStudentPhone(studentPhone);
            booking.setStudentEmail(studentEmail);
            booking.setGuardianName(guardianName);
            booking.setGuardianPhone(guardianPhone);
            booking.setGuardianRelationship(guardianRelationship);
            booking.setBookingStartDate(startDate);
            booking.setBookingEndDate(endDate);
            booking.setDurationMonths(durationMonths);
            booking.setSpecialRequests(specialRequests);
            booking.setKeyMoney(keyMoney);
            booking.setMonthlyRent(monthlyRent);
            booking.setTotalAmount(totalAmount);
            booking.setPaymentMethod(paymentMethod);

            // Save booking request
            boolean success = bookingDAO.createBookingRequest(booking);

            if (success) {
                session.setAttribute("success", "Booking request submitted successfully! " +
                                               "Booking ID: " + booking.getBookingId());
                response.sendRedirect(request.getContextPath() + "/booking/my-bookings");
            } else {
                request.setAttribute("error", "Failed to submit booking request. Please try again.");
                request.setAttribute("room", room);
                request.getRequestDispatcher("/bookingForm.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error processing booking: " + e.getMessage());
            request.getRequestDispatcher("/rooms").forward(request, response);
        }
    }
}
