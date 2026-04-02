package org.example.servlet;

import org.example.dao.AnnouncementDAO;
import org.example.model.Announcement;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/announcement")
public class AnnouncementServlet extends HttpServlet {

    private final AnnouncementDAO announcementDAO = new AnnouncementDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"staff".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String title = req.getParameter("title");
        String message = req.getParameter("message");

        Announcement ann = new Announcement();
        ann.setTitle(title);
        ann.setMessage(message);
        ann.setPostedBy(user.getUserId());

        try {
            announcementDAO.addAnnouncement(ann);
            session.setAttribute("successMsg", "Announcement posted.");
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Failed to post announcement.");
        }
        resp.sendRedirect(req.getContextPath() + "/laundry/staff/dashboard");
    }
}