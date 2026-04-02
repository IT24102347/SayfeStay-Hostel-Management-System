package org.example.dao;

import org.example.model.Room;
import org.example.model.RoomBooking;
import org.example.model.RoomAssignment;
import java.sql.*;
import java.util.*;

public class BookingDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
        String dbUser = "admin";
        String dbPass = "123456";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // ============ GENERATE BOOKING NUMBER ============
    public String generateBookingNo() {
        String sql = "SELECT COUNT(*) as count FROM room_bookings";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next()) {
                int count = rs.getInt("count");
                return String.format("BKG%03d", count + 1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "BKG001";
    }

    // ============ CREATE BOOKING ============
    public boolean createBooking(RoomBooking booking) {
        String sql = "INSERT INTO room_bookings (" +
                "booking_no, studentId, room_type, floor, " +
                "need_ac, need_fan, status, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'Pending', GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, booking.getBookingNo());
            pst.setString(2, booking.getStudentId());
            pst.setString(3, booking.getRoomType());
            pst.setInt(4, booking.getFloor());
            pst.setString(5, booking.getNeedAc());
            pst.setString(6, booking.getNeedFan());

            int result = pst.executeUpdate();
            System.out.println("✅ Booking created: " + booking.getBookingNo() + " for student: " + booking.getStudentId());
            return result > 0;

        } catch (SQLException e) {
            System.out.println("❌ Error creating booking: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ============ GET PENDING BOOKINGS ============
    public List<RoomBooking> getPendingBookings() {
        List<RoomBooking> list = new ArrayList<>();
        String sql = "SELECT rb.*, u.fullName as studentName " +
                "FROM room_bookings rb " +
                "LEFT JOIN users u ON rb.studentId = u.userId " +
                "WHERE rb.status = 'Pending' " +
                "ORDER BY rb.created_at DESC";

        System.out.println("🔍 Executing getPendingBookings query...");

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                RoomBooking rb = new RoomBooking();
                rb.setId(rs.getInt("id"));
                rb.setBookingNo(rs.getString("booking_no"));
                rb.setStudentId(rs.getString("studentId"));
                rb.setStudentName(rs.getString("studentName") != null ? rs.getString("studentName") : "Unknown");
                rb.setRoomType(rs.getString("room_type"));
                rb.setFloor(rs.getInt("floor"));
                rb.setNeedAc(rs.getString("need_ac"));
                rb.setNeedFan(rs.getString("need_fan"));
                rb.setStatus(rs.getString("status"));
                rb.setCreatedAt(rs.getTimestamp("created_at"));

                list.add(rb);
                System.out.println("  ✅ Found: " + rb.getBookingNo() + " | " + rb.getStudentName());
            }

            System.out.println("📊 Total pending bookings found: " + list.size());

        } catch (SQLException e) {
            System.out.println("❌ SQL Error in getPendingBookings: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    // ============ GET STUDENT BOOKINGS ============
    public List<RoomBooking> getStudentBookings(String studentId) {
        List<RoomBooking> list = new ArrayList<>();
        String sql = "SELECT * FROM room_bookings WHERE studentId = ? ORDER BY created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                RoomBooking rb = new RoomBooking();
                rb.setId(rs.getInt("id"));
                rb.setBookingNo(rs.getString("booking_no"));
                rb.setStudentId(rs.getString("studentId"));
                rb.setRoomType(rs.getString("room_type"));
                rb.setFloor(rs.getInt("floor"));
                rb.setNeedAc(rs.getString("need_ac"));
                rb.setNeedFan(rs.getString("need_fan"));
                rb.setStatus(rs.getString("status"));
                rb.setAssignedRoomId(rs.getInt("assigned_room_id"));
                rb.setAssignedRoomNumber(rs.getString("assigned_room_number"));
                rb.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(rb);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ============ GET STUDENT ASSIGNMENT ============
    public RoomAssignment getStudentAssignment(String studentId) {
        String sql = "SELECT ra.*, u.fullName as studentName FROM room_assignments ra " +
                "LEFT JOIN users u ON ra.studentId = u.userId " +
                "WHERE ra.studentId = ? AND ra.status = 'Active'";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                RoomAssignment ra = new RoomAssignment();
                ra.setId(rs.getInt("id"));
                ra.setStudentId(rs.getString("studentId"));
                ra.setStudentName(rs.getString("studentName"));
                ra.setRoomId(rs.getInt("room_id"));
                ra.setRoomNumber(rs.getString("room_number"));
                ra.setStartDate(rs.getDate("start_date"));
                ra.setRentAmount(rs.getDouble("rent_amount"));
                return ra;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ============ APPROVE BOOKING (FIXED) ============
    public boolean approveBooking(int bookingId, int roomId, String assignedBy, String remarks) {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);

            // Get room details
            RoomDAO roomDAO = new RoomDAO();
            Room room = roomDAO.getRoomById(roomId);

            if (room == null || !room.isAvailable()) {
                System.out.println("❌ Room not available: ID " + roomId);
                return false;
            }

            // 1. Update booking status
            String sql1 = "UPDATE room_bookings SET " +
                    "status = 'Approved', " +
                    "assigned_room_id = ?, " +
                    "assigned_room_number = ?, " +
                    "assigned_by = ?, " +
                    "remarks = ?, " +
                    "updated_at = GETDATE() " +
                    "WHERE id = ?";

            PreparedStatement pst1 = con.prepareStatement(sql1);
            pst1.setInt(1, roomId);
            pst1.setString(2, room.getRoomNumber());
            pst1.setString(3, assignedBy);
            pst1.setString(4, remarks != null ? remarks : "");
            pst1.setInt(5, bookingId);
            pst1.executeUpdate();

            // 2. Get student ID from booking
            String sql2 = "SELECT studentId FROM room_bookings WHERE id = ?";
            PreparedStatement pst2 = con.prepareStatement(sql2);
            pst2.setInt(1, bookingId);
            ResultSet rs = pst2.executeQuery();

            if (rs.next()) {
                String studentId = rs.getString("studentId");

                // 3. Create room assignment
                String sql3 = "INSERT INTO room_assignments (" +
                        "studentId, room_id, room_number, start_date, rent_amount, status, created_at) " +
                        "VALUES (?, ?, ?, GETDATE(), ?, 'Active', GETDATE())";

                PreparedStatement pst3 = con.prepareStatement(sql3);
                pst3.setString(1, studentId);
                pst3.setInt(2, roomId);
                pst3.setString(3, room.getRoomNumber());
                pst3.setDouble(4, room.getPriceMonthly());
                pst3.executeUpdate();

                // 4. Update room occupied count
                String sql4 = "UPDATE room SET occupied = occupied + 1 WHERE id = ?";
                PreparedStatement pst4 = con.prepareStatement(sql4);
                pst4.setInt(1, roomId);
                pst4.executeUpdate();

                // 5. Update room status if fully occupied
                String sql5 = "UPDATE room SET status = 'Occupied' WHERE id = ? AND occupied >= capacity";
                PreparedStatement pst5 = con.prepareStatement(sql5);
                pst5.setInt(1, roomId);
                pst5.executeUpdate();
            }

            con.commit();
            System.out.println("✅ Booking approved: ID " + bookingId + " -> Room " + room.getRoomNumber());
            return true;

        } catch (SQLException e) {
            try { if (con != null) con.rollback(); } catch (SQLException ex) {}
            System.out.println("❌ Error approving booking: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }

    // ============ REJECT BOOKING ============
    public boolean rejectBooking(int bookingId, String remarks) {
        String sql = "UPDATE room_bookings SET status = 'Rejected', remarks = ? WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, remarks);
            pst.setInt(2, bookingId);

            int result = pst.executeUpdate();
            if (result > 0) {
                System.out.println("✅ Booking rejected: ID " + bookingId);
                return true;
            }
            return false;

        } catch (SQLException e) {
            System.out.println("❌ Error rejecting booking: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ============ CANCEL BOOKING ============
    public boolean cancelBooking(int bookingId, String studentId) {
        String sql = "UPDATE room_bookings SET status = 'Cancelled' " +
                "WHERE id = ? AND studentId = ? AND status = 'Pending'";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, bookingId);
            pst.setString(2, studentId);

            int result = pst.executeUpdate();
            if (result > 0) {
                System.out.println("✅ Booking cancelled: ID " + bookingId);
                return true;
            }
            return false;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}