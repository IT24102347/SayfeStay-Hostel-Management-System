package org.example.servlet;

import org.example.dao.CleaningDAO;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Calendar;

@WebServlet("/cleaning/request")
public class CleaningServlet extends HttpServlet {
    private final CleaningDAO cleaningDAO = new CleaningDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int year = Calendar.getInstance().get(Calendar.YEAR);
        int month = Calendar.getInstance().get(Calendar.MONTH) + 1;

        request.setAttribute("cleaningHistory", cleaningDAO.getStudentCleaningHistory(user.getUserId()));
        request.setAttribute("cleaningStats", cleaningDAO.getCleaningStats(user.getUserId()));
        request.setAttribute("cleaningRequests", cleaningDAO.getCleaningRequestsByMonth(user.getUserId(), year, month));
        request.setAttribute("currentYear", year);
        request.setAttribute("currentMonth", month);

        request.getRequestDispatcher("/dashboard/student/cleaning-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user != null) {
            String roomNo = request.getParameter("roomNo");
            int floorNo = Integer.parseInt(request.getParameter("floorNo"));
            String type = request.getParameter("cleaningType");
            double price = "Staff".equalsIgnoreCase(type) ? 500.00 : 0.00;

            if (cleaningDAO.createRequest(user.getUserId(), user.getFullName(), roomNo, floorNo, type, price)) {
                session.setAttribute("successMsg", "Request submitted successfully!");
            } else {
                session.setAttribute("errorMsg", "Failed to submit request.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/cleaning/request");
    }
}