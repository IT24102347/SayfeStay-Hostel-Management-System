package org.example.servlet;

import org.example.dao.OwnerDAO;
import org.example.model.User;
import org.example.model.Owner;
import org.example.model.Hostel;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/dashboard/owner")
public class OwnerDashboardServlet extends HttpServlet {

    private OwnerDAO ownerDAO;

    @Override
    public void init() {
        ownerDAO = new OwnerDAO();
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

        // Get data
        Owner owner = ownerDAO.getOwnerByUserId(user.getUserId());
        Hostel hostel = ownerDAO.getHostelByOwnerId(user.getUserId());

        // Get statistics
        Map<String, Object> stats = ownerDAO.getDashboardStats();

        // Set attributes
        request.setAttribute("owner", owner);
        request.setAttribute("hostel", hostel);
        request.setAttribute("stats", stats);

        // Forward to JSP
        request.getRequestDispatcher("/dashboard/owner/index.jsp").forward(request, response);
    }
}