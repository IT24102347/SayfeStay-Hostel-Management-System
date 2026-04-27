package org.example.servlet;

import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String role = user.getRole();

        System.out.println("========== DASHBOARD REDIRECT ==========");
        System.out.println("User: " + user.getUserId());
        System.out.println("Role: " + role);

        // ========== REDIRECT BASED ON ROLE ==========
        if ("Student".equalsIgnoreCase(role)) {
            response.sendRedirect("dashboard/student/index.jsp");

        } else if ("Kitchen_Staff".equalsIgnoreCase(role)) {
            response.sendRedirect("dashboard/kitchen_staff/kitchen_dashboard.jsp");

        } else if ("Laundry_Staff".equalsIgnoreCase(role)) {
            response.sendRedirect("laundry/staff/dashboard");

        } else if ("Cleaning_Staff".equalsIgnoreCase(role)) {
            response.sendRedirect("dashboard/cleaning_staff/dashboard.jsp");

        } else if ("Owner".equalsIgnoreCase(role)) {
            response.sendRedirect("dashboard/owner/index.jsp");

        } else {
            response.sendRedirect("index.jsp");
        }
    }
}