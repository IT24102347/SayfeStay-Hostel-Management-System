package org.example.servlet;

import org.example.dao.BookingDAO;
import org.example.model.User;
import org.example.model.RoomBooking;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/booking/*")
public class BookingServlet extends HttpServlet {

    private BookingDAO bookingDAO;

    @Override
    public void init() {
        bookingDAO = new BookingDAO();
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
        String pathInfo = request.getPathInfo();

        // ============ CREATE NEW BOOKING ============
        if ("/create".equals(pathInfo) && "Student".equalsIgnoreCase(user.getRole())) {

            String roomType = request.getParameter("roomType");
            String floorStr = request.getParameter("floor");
            String needAc = request.getParameter("needAc");
            String needFan = request.getParameter("needFan");

            // Validate inputs
            if (roomType == null || roomType.isEmpty()) {
                roomType = "Any";
            }

            int floor = 0;
            try {
                floor = Integer.parseInt(floorStr);
            } catch (NumberFormatException e) {
                floor = 0;
            }

            if (needAc == null) needAc = "No";
            if (needFan == null) needFan = "Yes";

            // Create booking object
            RoomBooking booking = new RoomBooking();
            booking.setBookingNo(bookingDAO.generateBookingNo());
            booking.setStudentId(user.getUserId());
            booking.setRoomType(roomType);
            booking.setFloor(floor);
            booking.setNeedAc(needAc);
            booking.setNeedFan(needFan);

            // Save to database
            boolean success = bookingDAO.createBooking(booking);

            if (success) {
                session.setAttribute("successMessage", "Booking request submitted successfully!");
                System.out.println("✅ Booking created: " + booking.getBookingNo() + " for student: " + user.getUserId());
            } else {
                session.setAttribute("errorMessage", "Failed to submit booking request!");
                System.out.println("❌ Booking failed for student: " + user.getUserId());
            }

            response.sendRedirect(request.getContextPath() + "/dashboard/student/room-booking.jsp");
        }

        // ============ CANCEL BOOKING ============
        else if ("/cancel".equals(pathInfo) && "Student".equalsIgnoreCase(user.getRole())) {

            String bookingIdStr = request.getParameter("bookingId");

            try {
                int bookingId = Integer.parseInt(bookingIdStr);
                boolean success = bookingDAO.cancelBooking(bookingId, user.getUserId());

                if (success) {
                    session.setAttribute("successMessage", "Booking cancelled successfully!");
                    System.out.println("✅ Booking cancelled: ID " + bookingId);
                } else {
                    session.setAttribute("errorMessage", "Failed to cancel booking!");
                    System.out.println("❌ Cancel failed for booking ID: " + bookingId);
                }

            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Invalid booking ID!");
            }

            response.sendRedirect(request.getContextPath() + "/dashboard/student/room-booking.jsp");
        }

        // ============ UNKNOWN ACTION ============
        else {
            response.sendRedirect(request.getContextPath() + "/dashboard/student/room-booking.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        // ============ QUICK BOOK FROM ROOM CARD ============
        if ("/request".equals(pathInfo) && "Student".equalsIgnoreCase(user.getRole())) {

            String roomId = request.getParameter("roomId");
            String roomType = request.getParameter("roomType");
            String needAc = request.getParameter("needAc");
            String needFan = request.getParameter("needFan");

            // Create booking
            RoomBooking booking = new RoomBooking();
            booking.setBookingNo(bookingDAO.generateBookingNo());
            booking.setStudentId(user.getUserId());
            booking.setRoomType(roomType != null ? roomType : "Any");
            booking.setFloor(0);
            booking.setNeedAc(needAc != null ? needAc : "No");
            booking.setNeedFan(needFan != null ? needFan : "Yes");

            boolean success = bookingDAO.createBooking(booking);

            if (success) {
                session.setAttribute("successMessage", "Booking request submitted!");
                System.out.println("✅ Quick booking created: " + booking.getBookingNo());
            } else {
                session.setAttribute("errorMessage", "Failed to submit booking!");
            }

            response.sendRedirect(request.getContextPath() + "/dashboard/student/room-booking.jsp");
        }
    }
}