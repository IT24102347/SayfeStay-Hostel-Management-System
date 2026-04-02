package org.example.servlet;

import org.example.dao.RoomDAO;
import org.example.model.Room;
import org.example.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/rooms")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class ManageRoomsServlet extends HttpServlet {

    private RoomDAO roomDAO = new RoomDAO();
    private static final String UPLOAD_DIR = "images/rooms";

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

        // Only Owner can manage rooms
        if (!"Owner".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Check action parameter
        String action = request.getParameter("action");

        // Handle add new room form
        if ("add".equals(action)) {
            request.setAttribute("mode", "add");
            request.setAttribute("defaultHostelId", roomDAO.getDefaultHostelId());
        }

        // Handle edit room form
        String editIdStr = request.getParameter("edit");
        if (editIdStr != null && !editIdStr.trim().isEmpty()) {
            try {
                int roomId = Integer.parseInt(editIdStr);
                Room room = roomDAO.getRoomById(roomId);

                if (room != null) {
                    request.setAttribute("editRoom", room);
                    request.setAttribute("mode", "edit");
                }
            } catch (NumberFormatException e) {
                // Invalid room ID, ignore
            }
        }

        // Handle delete
        String deleteIdStr = request.getParameter("delete");
        if (deleteIdStr != null && !deleteIdStr.trim().isEmpty()) {
            try {
                int roomId = Integer.parseInt(deleteIdStr);
                boolean deleted = roomDAO.deleteRoom(roomId);

                if (deleted) {
                    session.setAttribute("success", "Room deleted successfully!");
                } else {
                    session.setAttribute("error", "Cannot delete room! It may have existing bookings.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Invalid room ID!");
            }
            response.sendRedirect(request.getContextPath() + "/admin/rooms");
            return;
        }

        // Get all rooms
        List<Room> rooms = roomDAO.getAllRooms();

        // Get statistics
        Map<String, Integer> stats = roomDAO.getRoomStatistics();

        // Set attributes
        request.setAttribute("rooms", rooms);
        request.setAttribute("stats", stats);
        request.setAttribute("user", user);

        // Forward to JSP
        request.getRequestDispatcher("/admin/manageRooms.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Only Owner can manage rooms
        if (!"Owner".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                // Add new room
                addNewRoom(request, session);
            } else if ("update".equals(action)) {
                // Update existing room
                updateExistingRoom(request, session);
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error processing request: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/rooms");
    }

    private void addNewRoom(HttpServletRequest request, HttpSession session) {
        try {
            // Get form parameters
            int hostelId = Integer.parseInt(request.getParameter("hostelId"));
            String roomNumber = request.getParameter("roomNumber");
            int floorNumber = Integer.parseInt(request.getParameter("floorNumber"));
            String roomType = request.getParameter("roomType");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            BigDecimal priceMonthly = new BigDecimal(request.getParameter("priceMonthly"));
            String bedType = request.getParameter("bedType");
            String bathroomType = request.getParameter("bathroomType");
            String description = request.getParameter("description");

            // Validate room number
            if (roomDAO.roomNumberExists(roomNumber)) {
                session.setAttribute("error", "Room number already exists!");
                return;
            }

            // Validate floor number
            if (floorNumber < 1 || floorNumber > 5) {
                session.setAttribute("error", "Floor number must be between 1 and 5!");
                return;
            }

            // Validate capacity
            if (capacity < 1 || capacity > 5) {
                session.setAttribute("error", "Capacity must be between 1 and 5!");
                return;
            }

            // Handle image uploads
            String imagePaths = uploadImages(request, roomNumber);

            // Get facilities
            boolean hasWifi = "on".equals(request.getParameter("hasWifi"));
            boolean hasStudyTable = "on".equals(request.getParameter("hasStudyTable"));
            boolean hasCupboard = "on".equals(request.getParameter("hasCupboard"));
            boolean hasFan = "on".equals(request.getParameter("hasFan"));
            boolean hasAc = "on".equals(request.getParameter("hasAc"));
            boolean hasLaundryAccess = "on".equals(request.getParameter("hasLaundryAccess"));
            boolean hasRoomCleaning = "on".equals(request.getParameter("hasRoomCleaning"));

            // Create room object
            Room room = new Room();
            room.setHostelId(hostelId);
            room.setRoomNumber(roomNumber);
            room.setFloorNumber(floorNumber);
            room.setRoomType(roomType);
            room.setCapacity(capacity);
            room.setOccupied(0);
            room.setPriceMonthly(priceMonthly);
            room.setStatus("Available");
            room.setBedType(bedType);
            room.setBathroomType(bathroomType);
            room.setHasWifi(hasWifi);
            room.setHasStudyTable(hasStudyTable);
            room.setHasCupboard(hasCupboard);
            room.setHasFan(hasFan);
            room.setHasAc(hasAc);
            room.setHasLaundryAccess(hasLaundryAccess);
            room.setHasRoomCleaning(hasRoomCleaning);
            room.setDescription(description);
            room.setImagePaths(imagePaths);

            // Add room to database
            boolean success = roomDAO.addRoom(room);

            if (success) {
                session.setAttribute("success", "Room " + roomNumber + " added successfully!");
            } else {
                session.setAttribute("error", "Failed to add room!");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid input format!");
            e.printStackTrace();
        } catch (Exception e) {
            session.setAttribute("error", "Error adding room: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void updateExistingRoom(HttpServletRequest request, HttpSession session) {
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));

            // Get current room
            Room room = roomDAO.getRoomById(roomId);

            if (room == null) {
                session.setAttribute("error", "Room not found!");
                return;
            }

            // Update fields
            String roomNumber = request.getParameter("roomNumber");
            String floorNumberStr = request.getParameter("floorNumber");
            String roomType = request.getParameter("roomType");
            String capacityStr = request.getParameter("capacity");
            String occupiedStr = request.getParameter("occupied");
            String priceStr = request.getParameter("priceMonthly");
            String status = request.getParameter("status");
            String bedType = request.getParameter("bedType");
            String bathroomType = request.getParameter("bathroomType");
            String description = request.getParameter("description");

            // Validate and set room number
            if (roomNumber != null && !roomNumber.trim().isEmpty()) {
                if (!roomNumber.equals(room.getRoomNumber()) && roomDAO.roomNumberExists(roomNumber)) {
                    session.setAttribute("error", "Room number already exists!");
                    return;
                }
                room.setRoomNumber(roomNumber);
            }

            // Validate and set floor number
            if (floorNumberStr != null && !floorNumberStr.trim().isEmpty()) {
                int floorNumber = Integer.parseInt(floorNumberStr);
                if (floorNumber < 1 || floorNumber > 5) {
                    session.setAttribute("error", "Floor number must be between 1 and 5!");
                    return;
                }
                room.setFloorNumber(floorNumber);
            }

            if (roomType != null && !roomType.trim().isEmpty()) {
                room.setRoomType(roomType);
            }

            if (capacityStr != null && !capacityStr.trim().isEmpty()) {
                int capacity = Integer.parseInt(capacityStr);
                if (capacity < 1 || capacity > 5) {
                    session.setAttribute("error", "Capacity must be between 1 and 5!");
                    return;
                }
                room.setCapacity(capacity);
            }

            if (occupiedStr != null && !occupiedStr.trim().isEmpty()) {
                int occupied = Integer.parseInt(occupiedStr);
                if (occupied < 0 || occupied > room.getCapacity()) {
                    session.setAttribute("error", "Occupied must be between 0 and capacity!");
                    return;
                }
                room.setOccupied(occupied);
            }

            if (priceStr != null && !priceStr.trim().isEmpty()) {
                room.setPriceMonthly(new BigDecimal(priceStr));
            }

            if (status != null && !status.trim().isEmpty()) {
                room.setStatus(status);
            }

            if (bedType != null && !bedType.trim().isEmpty()) {
                room.setBedType(bedType);
            }
            if (bathroomType != null && !bathroomType.trim().isEmpty()) {
                room.setBathroomType(bathroomType);
            }

            if (description != null) {
                room.setDescription(description.trim());
            }

            // Handle new image uploads
            String newImagePaths = uploadImages(request, room.getRoomNumber());
            if (newImagePaths != null && !newImagePaths.isEmpty()) {
                // If new images uploaded, replace old paths
                room.setImagePaths(newImagePaths);
            }
            // If no new images, keep existing paths

            // Set facilities
            room.setHasWifi("on".equals(request.getParameter("hasWifi")));
            room.setHasStudyTable("on".equals(request.getParameter("hasStudyTable")));
            room.setHasCupboard("on".equals(request.getParameter("hasCupboard")));
            room.setHasFan("on".equals(request.getParameter("hasFan")));
            room.setHasAc("on".equals(request.getParameter("hasAc")));
            room.setHasLaundryAccess("on".equals(request.getParameter("hasLaundryAccess")));
            room.setHasRoomCleaning("on".equals(request.getParameter("hasRoomCleaning")));

            // Update room
            boolean success = roomDAO.updateRoom(room);

            if (success) {
                session.setAttribute("success", "Room updated successfully!");
            } else {
                session.setAttribute("error", "Failed to update room!");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid input format!");
            e.printStackTrace();
        } catch (Exception e) {
            session.setAttribute("error", "Error updating room: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Upload multiple images and return semicolon-separated paths
     */
    private String uploadImages(HttpServletRequest request, String roomNumber) throws IOException, ServletException {
        // Get the real path to webapp directory
        String appPath = request.getServletContext().getRealPath("");
        String uploadPath = appPath + File.separator + UPLOAD_DIR;

        // Create directory if not exists
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        List<String> imagePaths = new ArrayList<>();
        int imageCounter = 1;

        // Get all uploaded files
        for (Part part : request.getParts()) {
            if (part.getName().equals("roomImages") && part.getSize() > 0) {
                String fileName = extractFileName(part);

                // Generate unique filename: roomNumber_counter.extension
                String fileExtension = getFileExtension(fileName);
                String newFileName = roomNumber + "_" + imageCounter + fileExtension;

                // Save file
                String filePath = uploadPath + File.separator + newFileName;
                part.write(filePath);

                // Add relative path to list
                imagePaths.add(UPLOAD_DIR + "/" + newFileName);
                imageCounter++;
            }
        }

        // If no images uploaded, return default or null
        if (imagePaths.isEmpty()) {
            return null;
        }

        // Join paths with semicolon
        return String.join(";", imagePaths);
    }

    /**
     * Extract filename from part header
     */
    private String extractFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] items = contentDisposition.split(";");
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                return item.substring(item.indexOf("=") + 2, item.length() - 1);
            }
        }
        return "";
    }

    /**
     * Get file extension
     */
    private String getFileExtension(String fileName) {
        if (fileName.lastIndexOf(".") != -1 && fileName.lastIndexOf(".") != 0) {
            return fileName.substring(fileName.lastIndexOf("."));
        }
        return ".jpg"; // default
    }
}