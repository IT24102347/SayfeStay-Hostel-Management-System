package org.example.servlet;

import org.example.dao.UserDAO;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = request.getParameter("userId");
        String password = request.getParameter("password");

        System.out.println("========== LOGIN ATTEMPT ==========");
        System.out.println("User ID: " + userId);

        UserDAO userDAO = new UserDAO();
        User user = userDAO.login(userId, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("fullname", user.getFullName());
            session.setAttribute("role", user.getRole());

            System.out.println("✅ Login SUCCESSFUL! Role: " + user.getRole());

            // ========== REDIRECT BASED ON ROLE ==========
            if ("Student".equalsIgnoreCase(user.getRole())) {
                // Student goes to student dashboard
                response.sendRedirect("dashboard/student/index.jsp");  // නව student dashboard එකට

            } else if ("Kitchen_Staff".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("dashboard/kitchen_staff/kitchen_dashboard.jsp");

            } else if ("Laundry_Staff".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("laundry/staff/dashboard");

            } else if ("Cleaning_Staff".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("staff/cleaning/dashboard");

            } else if ("Owner".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("dashboard/owner/index.jsp");

            } else {
                response.sendRedirect("index.jsp");
            }

        } else {
            System.out.println("❌ Login FAILED for: " + userId);
            request.setAttribute("errorMessage", "Invalid ID or Password!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}