package org.example.servlet;

import org.example.dao.RoomDAO;
import org.example.model.Room;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/rooms/search")
public class RoomSearchServlet extends HttpServlet {

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

        // Get search parameters
        String roomType = request.getParameter("roomType");
        String capacityStr = request.getParameter("capacity");
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String floorStr = request.getParameter("floor");
        String hasWifiStr = request.getParameter("hasWifi");
        String hasAcStr = request.getParameter("hasAc");
        String bathroomType = request.getParameter("bathroomType");

        // Parse parameters
        Integer capacity = null;
        if (capacityStr != null && !capacityStr.trim().isEmpty()) {
            try {
                capacity = Integer.parseInt(capacityStr);
            } catch (NumberFormatException e) {
                capacity = null;
            }
        }

        BigDecimal minPrice = null;
        if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
            try {
                minPrice = new BigDecimal(minPriceStr);
            } catch (NumberFormatException e) {
                minPrice = null;
            }
        }

        BigDecimal maxPrice = null;
        if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
            try {
                maxPrice = new BigDecimal(maxPriceStr);
            } catch (NumberFormatException e) {
                maxPrice = null;
            }
        }

        Integer floorNumber = null;
        if (floorStr != null && !floorStr.trim().isEmpty()) {
            try {
                floorNumber = Integer.parseInt(floorStr);
            } catch (NumberFormatException e) {
                floorNumber = null;
            }
        }

        Boolean hasWifi = "on".equals(hasWifiStr) || "true".equals(hasWifiStr);
        Boolean hasAc = "on".equals(hasAcStr) || "true".equals(hasAcStr);

        // Search rooms
        List<Room> rooms = roomDAO.searchRooms(
            roomType, capacity, minPrice, maxPrice, 
            floorNumber, hasWifi, hasAc, bathroomType
        );

        // Set attributes
        request.setAttribute("rooms", rooms);
        request.setAttribute("searchPerformed", true);
        request.setAttribute("resultCount", rooms.size());
        
        // Keep search parameters for form
        request.setAttribute("roomType", roomType);
        request.setAttribute("capacity", capacityStr);
        request.setAttribute("minPrice", minPriceStr);
        request.setAttribute("maxPrice", maxPriceStr);
        request.setAttribute("floor", floorStr);
        request.setAttribute("hasWifi", hasWifiStr);
        request.setAttribute("hasAc", hasAcStr);
        request.setAttribute("bathroomType", bathroomType);

        // Forward to search results page
        request.getRequestDispatcher("/roomSearch.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
