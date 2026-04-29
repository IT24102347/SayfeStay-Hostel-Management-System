package org.example.servlet;

import org.example.dao.InquiryDAO;
import org.example.model.Inquiry;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/inquiries")
public class ManageInquiriesServlet extends HttpServlet {

    private InquiryDAO inquiryDAO = new InquiryDAO();

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
        
        // Only Owner can manage inquiries
        if (!"Owner".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Get filter parameter
        String filter = request.getParameter("filter");
        
        List<Inquiry> inquiries;
        String pageTitle;
        
        if ("pending".equals(filter)) {
            inquiries = inquiryDAO.getPendingInquiries();
            pageTitle = "Pending Inquiries";
        } else {
            inquiries = inquiryDAO.getAllInquiries();
            pageTitle = "All Inquiries";
        }

        // Get statistics
        Map<String, Integer> stats = inquiryDAO.getInquiryStatistics();

        // Set attributes
        request.setAttribute("inquiries", inquiries);
        request.setAttribute("pageTitle", pageTitle);
        request.setAttribute("stats", stats);
        request.setAttribute("currentFilter", filter);
        request.setAttribute("user", user);

        // Forward to JSP
        request.getRequestDispatcher("/admin/manageInquiries.jsp").forward(request, response);
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
        
        // Only Owner can manage inquiries
        if (!"Owner".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");
        int inquiryId = Integer.parseInt(request.getParameter("inquiryId"));

        boolean success = false;

        if ("reply".equals(action)) {
            String replyMessage = request.getParameter("replyMessage");
            
            if (replyMessage == null || replyMessage.trim().isEmpty()) {
                session.setAttribute("error", "Reply message cannot be empty!");
                response.sendRedirect(request.getContextPath() + "/admin/inquiries");
                return;
            }
            
            success = inquiryDAO.replyToInquiry(inquiryId, user.getUserId(), replyMessage.trim());
            
            if (success) {
                session.setAttribute("success", "Reply sent successfully!");
            } else {
                session.setAttribute("error", "Failed to send reply!");
            }
        } else if ("close".equals(action)) {
            success = inquiryDAO.closeInquiry(inquiryId);
            
            if (success) {
                session.setAttribute("success", "Inquiry closed successfully!");
            } else {
                session.setAttribute("error", "Failed to close inquiry!");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/inquiries");
    }
}
