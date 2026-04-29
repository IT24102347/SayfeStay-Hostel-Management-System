package org.example.servlet;

import org.example.dao.RoomDAO;
import org.example.model.Room;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/rooms")
public class RoomListServlet extends HttpServlet {

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
        
        // Get filter parameters
        String filter = request.getParameter("filter");
        
        List<Room> rooms;
        String pageTitle;
        
        if ("available".equals(filter)) {
            rooms = roomDAO.getAvailableRooms();
            pageTitle = "Available Rooms";
        } else {
            rooms = roomDAO.getAllRooms();
            pageTitle = "All Rooms";
        }

        // Get room statistics
        Map<String, Integer> stats = roomDAO.getRoomStatistics();
        
        // Get price range for search filters
        Map<String, java.math.BigDecimal> priceRange = roomDAO.getPriceRange();

        // Set attributes
        request.setAttribute("rooms", rooms);
        request.setAttribute("pageTitle", pageTitle);
        request.setAttribute("stats", stats);
        request.setAttribute("priceRange", priceRange);
        request.setAttribute("currentFilter", filter);

        // Forward to JSP
        request.getRequestDispatcher("/rooms.jsp").forward(request, response);
    }
}
