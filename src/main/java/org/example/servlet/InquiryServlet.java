package org.example.servlet;

import org.example.dao.InquiryDAO;
import org.example.dao.RoomDAO;
import org.example.model.Inquiry;
import org.example.model.Room;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/inquiry")
public class InquiryServlet extends HttpServlet {

    private InquiryDAO inquiryDAO = new InquiryDAO();
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
        
        // Only students can view their inquiries
        if (!"Student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Get all inquiries for this student
        List<Inquiry> inquiries = inquiryDAO.getInquiriesByStudent(user.getUserId());

        // Get all rooms for dropdown (when creating new inquiry)
        List<Room> rooms = roomDAO.getAllRooms();

        // Set attributes
        request.setAttribute("inquiries", inquiries);
        request.setAttribute("rooms", rooms);
        request.setAttribute("user", user);

        // Forward to JSP
        request.getRequestDispatcher("/inquiry.jsp").forward(request, response);
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
        
        // Only students can create inquiries
        if (!"Student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        try {
            // Get form parameters
            String roomIdStr = request.getParameter("roomId");
            String subject = request.getParameter("subject");
            String message = request.getParameter("message");
            String inquiryType = request.getParameter("inquiryType");

            // Validate input
            if (subject == null || subject.trim().isEmpty() ||
                message == null || message.trim().isEmpty() ||
                inquiryType == null || inquiryType.trim().isEmpty()) {
                
                session.setAttribute("error", "Please fill all required fields!");
                response.sendRedirect(request.getContextPath() + "/inquiry");
                return;
            }

            // Create inquiry object
            Inquiry inquiry = new Inquiry();
            inquiry.setStudentId(user.getUserId());
            
            // Room ID is optional (for general inquiries)
            if (roomIdStr != null && !roomIdStr.trim().isEmpty() && !"0".equals(roomIdStr)) {
                try {
                    inquiry.setRoomId(Integer.parseInt(roomIdStr));
                } catch (NumberFormatException e) {
                    inquiry.setRoomId(null);
                }
            }
            
            inquiry.setSubject(subject.trim());
            inquiry.setMessage(message.trim());
            inquiry.setInquiryType(inquiryType);

            // Save inquiry
            boolean success = inquiryDAO.createInquiry(inquiry);

            if (success) {
                session.setAttribute("success", "Inquiry submitted successfully! " +
                                               "Inquiry ID: " + inquiry.getInquiryId());
            } else {
                session.setAttribute("error", "Failed to submit inquiry. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error processing inquiry: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/inquiry");
    }
}
