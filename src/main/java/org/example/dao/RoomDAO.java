package org.example.dao;

import org.example.model.Room;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class RoomDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
        String dbUser = "sa";
        String dbPass = "Japan@123*";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // ============================================
    // 1. GET ALL ROOMS WITH HOSTEL INFO
    // ============================================
    public List<Room> getAllRooms() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, h.hostel_name, h.address as hostel_address, h.city " +
            "FROM dbo.room r " +
            "JOIN dbo.hostel h ON r.hostel_id = h.id " +
                "ORDER BY r.floor_number, r.room_number";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                rooms.add(extractRoomFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // ============================================
    // 2. GET AVAILABLE ROOMS ONLY
    // ============================================
    public List<Room> getAvailableRooms() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, h.hostel_name, h.address as hostel_address, h.city " +
            "FROM dbo.room r " +
            "JOIN dbo.hostel h ON r.hostel_id = h.id " +
                "WHERE r.status IN ('Available', 'Partially Occupied') " +
                "AND r.available_slots > 0 " +
                "ORDER BY r.floor_number, r.room_number";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                rooms.add(extractRoomFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // ============================================
    // 3. GET ROOM BY ID
    // ============================================
    public Room getRoomById(int roomId) {
        Room room = null;
        String sql = "SELECT r.*, h.hostel_name, h.address as hostel_address, h.city " +
            "FROM dbo.room r " +
            "JOIN dbo.hostel h ON r.hostel_id = h.id " +
                "WHERE r.id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, roomId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                room = extractRoomFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return room;
    }

    // ============================================
    // 4. ADD NEW ROOM
    // ============================================
    public boolean addRoom(Room room) {
        String sql = "INSERT INTO dbo.room " +
                "(hostel_id, room_number, floor_number, room_type, capacity, occupied, available_slots, " +
                "price_monthly, status, bed_type, bathroom_type, " +
                "has_wifi, has_study_table, has_cupboard, has_fan, has_ac, " +
                "has_laundry_access, has_room_cleaning, description, image_paths) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, room.getHostelId());
            pst.setString(2, room.getRoomNumber());
            pst.setInt(3, room.getFloorNumber());
            pst.setString(4, room.getRoomType());
            pst.setInt(5, room.getCapacity());
            pst.setInt(6, room.getOccupied());
            pst.setInt(7, Math.max(0, room.getCapacity() - room.getOccupied()));
            pst.setBigDecimal(8, room.getPriceMonthly());
            pst.setString(9, room.getStatus() != null ? room.getStatus() : "Available");
            pst.setString(10, room.getBedType());
            pst.setString(11, room.getBathroomType());
            pst.setBoolean(12, room.isHasWifi());
            pst.setBoolean(13, room.isHasStudyTable());
            pst.setBoolean(14, room.isHasCupboard());
            pst.setBoolean(15, room.isHasFan());
            pst.setBoolean(16, room.isHasAc());
            pst.setBoolean(17, room.isHasLaundryAccess());
            pst.setBoolean(18, room.isHasRoomCleaning());
            pst.setString(19, room.getDescription());
            pst.setString(20, room.getImagePaths() != null ? room.getImagePaths() : "images/rooms/default.jpg");

            int result = pst.executeUpdate();
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============================================
    // 5. CHECK IF ROOM NUMBER EXISTS
    // ============================================
    public boolean roomNumberExists(String roomNumber) {
        String sql = "SELECT COUNT(*) as count FROM dbo.room WHERE room_number = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, roomNumber);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ============================================
    // 6. SEARCH ROOMS WITH FILTERS
    // ============================================
    public List<Room> searchRooms(String roomType, Integer capacity, BigDecimal minPrice,
                                  BigDecimal maxPrice, Integer floorNumber,
                                  Boolean hasWifi, Boolean hasAc, String bathroomType) {
        List<Room> rooms = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT r.*, h.hostel_name, h.address as hostel_address, h.city " +
                "FROM dbo.room r " +
                "JOIN dbo.hostel h ON r.hostel_id = h.id " +
                        "WHERE r.status IN ('Available', 'Partially Occupied') " +
                        "AND r.available_slots > 0"
        );

        List<Object> params = new ArrayList<>();

        // Add filters
        if (roomType != null && !roomType.isEmpty()) {
            sql.append(" AND r.room_type = ?");
            params.add(roomType);
        }

        if (capacity != null && capacity > 0) {
            sql.append(" AND r.capacity >= ?");
            params.add(capacity);
        }

        if (minPrice != null) {
            sql.append(" AND r.price_monthly >= ?");
            params.add(minPrice);
        }

        if (maxPrice != null) {
            sql.append(" AND r.price_monthly <= ?");
            params.add(maxPrice);
        }

        if (floorNumber != null && floorNumber > 0) {
            sql.append(" AND r.floor_number = ?");
            params.add(floorNumber);
        }

        if (hasWifi != null && hasWifi) {
            sql.append(" AND r.has_wifi = 1");
        }

        if (hasAc != null && hasAc) {
            sql.append(" AND r.has_ac = 1");
        }

        if (bathroomType != null && !bathroomType.isEmpty()) {
            sql.append(" AND r.bathroom_type = ?");
            params.add(bathroomType);
        }

        sql.append(" ORDER BY r.price_monthly, r.floor_number");

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                pst.setObject(i + 1, params.get(i));
            }

            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                rooms.add(extractRoomFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // ============================================
    // 7. UPDATE ROOM OCCUPANCY
    // ============================================
    public boolean updateRoomOccupancy(int roomId, int newOccupied) {
        String sql = "UPDATE dbo.room SET occupied = ?, updated_at = GETDATE() WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, newOccupied);
            pst.setInt(2, roomId);

            int result = pst.executeUpdate();
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============================================
    // 8. UPDATE ROOM DETAILS (ADMIN)
    // ============================================
    public boolean updateRoom(Room room) {
        String sql = "UPDATE dbo.room SET " +
                "room_number = ?, " +
                "floor_number = ?, " +
                "room_type = ?, " +
                "capacity = ?, " +
                "occupied = ?, " +
                "price_monthly = ?, " +
                "status = ?, " +
                "bed_type = ?, " +
                "bathroom_type = ?, " +
                "has_wifi = ?, " +
                "has_study_table = ?, " +
                "has_cupboard = ?, " +
                "has_fan = ?, " +
                "has_ac = ?, " +
                "has_laundry_access = ?, " +
                "has_room_cleaning = ?, " +
                "description = ?, " +
                "image_paths = ?, " +
                "updated_at = GETDATE() " +
                "WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, room.getRoomNumber());
            pst.setInt(2, room.getFloorNumber());
            pst.setString(3, room.getRoomType());
            pst.setInt(4, room.getCapacity());
            pst.setInt(5, room.getOccupied());
            pst.setBigDecimal(6, room.getPriceMonthly());
            pst.setString(7, room.getStatus());
            pst.setString(8, room.getBedType());
            pst.setString(9, room.getBathroomType());
            pst.setBoolean(10, room.isHasWifi());
            pst.setBoolean(11, room.isHasStudyTable());
            pst.setBoolean(12, room.isHasCupboard());
            pst.setBoolean(13, room.isHasFan());
            pst.setBoolean(14, room.isHasAc());
            pst.setBoolean(15, room.isHasLaundryAccess());
            pst.setBoolean(16, room.isHasRoomCleaning());
            pst.setString(17, room.getDescription());
            pst.setString(18, room.getImagePaths());
            pst.setInt(19, room.getId());

            int result = pst.executeUpdate();
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============================================
    // 9. DELETE ROOM
    // ============================================
    public boolean deleteRoom(int roomId) {
        // Check if room has any bookings
        String checkSql = "SELECT COUNT(*) as count FROM dbo.booking_request WHERE room_id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(checkSql)) {

            pst.setInt(1, roomId);
            ResultSet rs = pst.executeQuery();

            if (rs.next() && rs.getInt("count") > 0) {
                // Room has bookings, cannot delete
                return false;
            }

            // Safe to delete
            String deleteSql = "DELETE FROM dbo.room WHERE id = ?";
            try (PreparedStatement deletePst = con.prepareStatement(deleteSql)) {
                deletePst.setInt(1, roomId);
                int result = deletePst.executeUpdate();
                return result > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============================================
    // 10. GET ROOMS BY FLOOR
    // ============================================
    public List<Room> getRoomsByFloor(int floorNumber) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, h.hostel_name, h.address as hostel_address, h.city " +
                "FROM dbo.room r " +
                "JOIN dbo.hostel h ON r.hostel_id = h.id " +
                "WHERE r.floor_number = ? " +
                "ORDER BY r.room_number";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, floorNumber);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                rooms.add(extractRoomFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // ============================================
    // 11. GET DEFAULT HOSTEL ID
    // ============================================
    public int getDefaultHostelId() {
        String sql = "SELECT TOP 1 id FROM dbo.hostel ORDER BY id";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next()) {
                return rs.getInt("id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 1; // Default to 1
    }

    // ============================================
    // 12. GET STATISTICS
    // ============================================
    public Map<String, Integer> getRoomStatistics() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT " +
                "COUNT(*) as total_rooms, " +
                "SUM(capacity) as total_capacity, " +
                "SUM(occupied) as total_occupied, " +
                "SUM(available_slots) as total_available, " +
                "SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) as fully_available, " +
                "SUM(CASE WHEN status = 'Full' THEN 1 ELSE 0 END) as full_rooms " +
            "FROM dbo.room";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next()) {
                stats.put("totalRooms", rs.getInt("total_rooms"));
                stats.put("totalCapacity", rs.getInt("total_capacity"));
                stats.put("totalOccupied", rs.getInt("total_occupied"));
                stats.put("totalAvailable", rs.getInt("total_available"));
                stats.put("fullyAvailable", rs.getInt("fully_available"));
                stats.put("fullRooms", rs.getInt("full_rooms"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    // ============================================
    // 13. CHECK ROOM AVAILABILITY
    // ============================================
    public boolean isRoomAvailable(int roomId) {
        String sql = "SELECT available_slots FROM dbo.room WHERE id = ? " +
                "AND status IN ('Available', 'Partially Occupied')";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, roomId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                return rs.getInt("available_slots") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ============================================
    // 14. GET PRICE RANGE
    // ============================================
    public Map<String, BigDecimal> getPriceRange() {
        Map<String, BigDecimal> range = new HashMap<>();
        String sql = "SELECT MIN(price_monthly) as min_price, MAX(price_monthly) as max_price FROM dbo.room";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next()) {
                range.put("minPrice", rs.getBigDecimal("min_price"));
                range.put("maxPrice", rs.getBigDecimal("max_price"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return range;
    }

    // ============================================
    // HELPER METHOD: EXTRACT ROOM FROM RESULTSET
    // ============================================
    private Room extractRoomFromResultSet(ResultSet rs) throws SQLException {
        Room room = new Room();

        room.setId(rs.getInt("id"));
        room.setHostelId(rs.getInt("hostel_id"));
        room.setRoomNumber(rs.getString("room_number"));
        room.setFloorNumber(rs.getInt("floor_number"));
        room.setRoomType(rs.getString("room_type"));
        room.setCapacity(rs.getInt("capacity"));
        room.setOccupied(rs.getInt("occupied"));
        room.setAvailableSlots(rs.getInt("available_slots"));
        room.setPriceMonthly(rs.getBigDecimal("price_monthly"));
        room.setStatus(rs.getString("status"));

        room.setBedType(rs.getString("bed_type"));
        room.setBathroomType(rs.getString("bathroom_type"));

        room.setHasWifi(rs.getBoolean("has_wifi"));
        room.setHasStudyTable(rs.getBoolean("has_study_table"));
        room.setHasCupboard(rs.getBoolean("has_cupboard"));
        room.setHasFan(rs.getBoolean("has_fan"));
        room.setHasAc(rs.getBoolean("has_ac"));
        room.setHasLaundryAccess(rs.getBoolean("has_laundry_access"));

        room.setHasRoomCleaning(rs.getBoolean("has_room_cleaning"));

        room.setImagePaths(rs.getString("image_paths"));
        room.setDescription(rs.getString("description"));

        room.setHostelName(rs.getString("hostel_name"));
        room.setHostelAddress(rs.getString("hostel_address"));
        room.setCity(rs.getString("city"));

        room.setCreatedAt(rs.getTimestamp("created_at"));
        room.setUpdatedAt(rs.getTimestamp("updated_at"));

        return room;
    }
}