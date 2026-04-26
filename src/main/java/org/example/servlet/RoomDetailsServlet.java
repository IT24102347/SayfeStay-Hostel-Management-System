package org.example.servlet;

import org.example.dao.RoomDAO;
import org.example.model.Room;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/rooms/details")
public class RoomDetailsServlet extends HttpServlet {

    private RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        
        // Get room ID
        String roomIdStr = request.getParameter("id");
        
        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/rooms");
            return;
        }

        try {
            int roomId = Integer.parseInt(roomIdStr);
            Room room = roomDAO.getRoomById(roomId);

            if (room == null) {
                request.setAttribute("error", "Room not found!");
                request.getRequestDispatcher("/rooms").forward(request, response);
                return;
            }

            // Set attributes
            request.setAttribute("room", room);
            request.setAttribute("user", user);

            // Forward to room details page
            request.getRequestDispatcher("/roomDetails.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/rooms");
        }
    }
}
