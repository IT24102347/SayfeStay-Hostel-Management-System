package org.example.servlet;

import org.example.dao.ReviewDAO;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/student/addReview")
@MultipartConfig(maxFileSize = 5242880)
public class ReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            List<Map<String, Object>> approved = reviewDAO.getApprovedReviews();
            request.setAttribute("approvedReviews", approved);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("approvedReviews", new ArrayList<>());
        }

        request.getRequestDispatcher("/dashboard/student/review-dashboard.jsp")
                .forward(request, response);
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

        try {
            String ratingStr = request.getParameter("rating");

            if (ratingStr == null || ratingStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() +
                        "/student/addReview?error=invalid_input");
                return;
            }

            int rating            = Integer.parseInt(ratingStr.trim());
            int cleanlinessRating = safe(request.getParameter("cleanlinessRating"));
            int wifiRating        = safe(request.getParameter("wifiRating"));
            int staffRating       = safe(request.getParameter("staffRating"));
            String category       = request.getParameter("category");
            String comment        = request.getParameter("comment");

            if (category == null || category.trim().isEmpty()) category = "General";
            if (comment  == null) comment = "";

            boolean success = reviewDAO.addReview(
                    user.getUserId(),
                    user.getFullName(),
                    rating,
                    cleanlinessRating,
                    wifiRating,
                    staffRating,
                    category,
                    comment
            );

            response.sendRedirect(request.getContextPath() +
                    "/student/addReview?" + (success ? "success=true" : "error=db_error"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() +
                    "/student/addReview?error=unknown");
        }
    }

    private int safe(String v) {
        try {
            return (v != null && !v.trim().isEmpty()) ? Integer.parseInt(v.trim()) : 0;
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
