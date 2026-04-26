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
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null || !"Cleaning_Staff".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<Map<String, Object>> pendingRequests = cleaningDAO.getAllPendingRequests();
        List<Map<String, Object>> acceptedRequests = cleaningDAO.getAllAcceptedRequests();
        List<Map<String, Object>> completedRequests = cleaningDAO.getAllCompletedRequests();
        Map<String, Object> stats = cleaningDAO.getStaffStats();

        request.setAttribute("pendingRequests", pendingRequests);
        request.setAttribute("acceptedRequests", acceptedRequests);
        request.setAttribute("completedRequests", completedRequests);
        request.setAttribute("staffStats", stats);

        request.getRequestDispatcher("/dashboard/cleaning_staff/cleaning_dashboard_staff.jsp").forward(request, response);
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
                session.setAttribute("successMsg", "Request accepted! Scheduled for " + assignedDate + " at " + assignedTime);
            } else {
                session.setAttribute("errorMsg", "Failed to accept request. Please try again.");
            }
        } else if ("complete".equals(action)) {
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            if (cleaningDAO.completeRequest(requestId)) {
                session.setAttribute("successMsg", "Cleaning request marked as completed!");
            } else {
                session.setAttribute("errorMsg", "Failed to complete request. Please try again.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/staff/cleaning/dashboard");
    }
}
