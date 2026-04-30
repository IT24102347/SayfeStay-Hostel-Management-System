package org.example.servlet;

import org.example.dao.NotificationDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/markNotificationRead")
public class MarkNotificationReadServlet extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);
                notificationDAO.markAsRead(id);
            } catch (NumberFormatException e) {
                // Log error but continue
                e.printStackTrace();
            }
        }
        response.setStatus(HttpServletResponse.SC_OK);
    }
}