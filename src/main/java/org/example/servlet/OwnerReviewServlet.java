package org.example.servlet;

import org.example.dao.ReviewDAO;
import org.example.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboard/owner/reviews")
public class OwnerReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (!"owner".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<Map<String, Object>> allReviews = reviewDAO.getAllReviews();
        request.setAttribute("allReviews", allReviews);
        request.getRequestDispatcher("/dashboard/owner/reviews.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action      = request.getParameter("action");
        String reviewIdStr = request.getParameter("reviewId");

        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            boolean success = false;

            if ("approve".equals(action)) {
                success = reviewDAO.updateReviewStatus(reviewId, "Approved");
            } else if ("delete".equals(action)) {
                success = reviewDAO.updateReviewStatus(reviewId, "Deleted");
            } else if ("addReply".equals(action)) {
                String reply = request.getParameter("ownerReply");
                if (reply != null && !reply.trim().isEmpty()) {
                    success = reviewDAO.updateOwnerReply(reviewId, reply.trim());
                }
            }

            response.sendRedirect(request.getContextPath() +
                    "/dashboard/owner/reviews?success=" + (success ? "1" : "0"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard/owner/reviews?error=1");
        }
    }
}
