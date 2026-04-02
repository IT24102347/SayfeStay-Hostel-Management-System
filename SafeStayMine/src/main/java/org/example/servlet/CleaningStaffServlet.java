package org.example.servlet;

import org.example.dao.CleaningDAO;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/staff/cleaning/dashboard")
public class CleaningStaffServlet extends HttpServlet {
    private final CleaningDAO cleaningDAO = new CleaningDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("\n========== CLEANING STAFF SERVLET doGet() START ==========");

        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        System.out.println("User: " + (user != null ? user.getUserId() : "null"));
        System.out.println("Role: " + (user != null ? user.getRole() : "null"));

        if (user == null || !"Cleaning_Staff".equalsIgnoreCase(user.getRole())) {
            System.out.println("ACCESS DENIED - Redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Get data from database
        List<Map<String, Object>> pendingRequests = cleaningDAO.getAllPendingRequests();
        List<Map<String, Object>> completedRequests = cleaningDAO.getAllCompletedRequests();
        Map<String, Object> stats = cleaningDAO.getStaffStats();

        System.out.println("Pending Requests Count: " + (pendingRequests != null ? pendingRequests.size() : 0));
        System.out.println("Completed Requests Count: " + (completedRequests != null ? completedRequests.size() : 0));

        // Set attributes
        request.setAttribute("pendingRequests", pendingRequests);
        request.setAttribute("completedRequests", completedRequests);
        request.setAttribute("staffStats", stats);

        // Forward to JSP
        request.getRequestDispatcher("/dashboard/cleaning_staff/cleaning_dashboard_staff.jsp").forward(request, response);

        System.out.println("========== CLEANING STAFF SERVLET doGet() END ==========\n");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null || !"Cleaning_Staff".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("accept".equals(action)) {
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            String assignedDate = request.getParameter("assignedDate");
            String assignedTime = request.getParameter("assignedTime");
            String staffResponse = request.getParameter("staffResponse");

            if (cleaningDAO.acceptRequest(requestId, assignedDate, assignedTime, staffResponse)) {
                session.setAttribute("successMsg", "Request accepted! Date: " + assignedDate + ", Time: " + assignedTime);
            } else {
                session.setAttribute("errorMsg", "Failed to accept request.");
            }
        } else if ("complete".equals(action)) {
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            if (cleaningDAO.completeRequest(requestId)) {
                session.setAttribute("successMsg", "Request completed successfully!");
            } else {
                session.setAttribute("errorMsg", "Failed to complete request.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/staff/cleaning/dashboard");
    }
}