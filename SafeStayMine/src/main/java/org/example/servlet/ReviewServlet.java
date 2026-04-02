package org.example.servlet;

import org.example.dao.ReviewDAO;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/student/addReview")
public class ReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If a GET request comes in, it is sent directly to the review page.
        response.sendRedirect(request.getContextPath() + "/dashboard/student/review-dashboard.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Checking the session (same as in OwnerDashboardServlet)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            // 2. Retrieving data sent from the form
            String ratingStr = request.getParameter("rating");
            String comment = request.getParameter("comment");

            if (ratingStr != null && !ratingStr.isEmpty() && comment != null) {
                int rating = Integer.parseInt(ratingStr);

                // 3. Inserting data into the database through DAO
                boolean success = reviewDAO.addReview(
                        user.getUserId(),
                        user.getFullName(),
                        rating,
                        comment
                );

                // 4. Redirecting based on the result
                if (success) {
                    response.sendRedirect(request.getContextPath() +
                            "/dashboard/student/review-dashboard.jsp?success=true");
                } else {
                    response.sendRedirect(request.getContextPath() +
                            "/dashboard/student/review-dashboard.jsp?error=db_error");
                }
            } else {
                response.sendRedirect(request.getContextPath() +
                        "/dashboard/student/review-dashboard.jsp?error=invalid_input");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() +
                    "/dashboard/student/review-dashboard.jsp?error=invalid_rating");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() +
                    "/dashboard/student/review-dashboard.jsp?error=unknown");
        }
    }
}