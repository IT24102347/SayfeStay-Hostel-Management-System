package org.example.dao;

import org.example.model.BookingRequest;

import java.sql.*;
import java.util.*;

public class BookingDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
        String dbUser = "sa";
        String dbPass = "Japan@123*";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }




    // ============================================
    // 1. GENERATE BOOKING ID
    // ============================================
    private String generateBookingId(Connection con) throws SQLException {
        String sql = "SELECT MAX(booking_id) as maxId FROM booking_request WHERE booking_id LIKE 'BR%'";

        try (PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next() && rs.getString("maxId") != null) {
                String lastId = rs.getString("maxId");
                try {
                    int nextNumber = Integer.parseInt(lastId.substring(2)) + 1;
                    return String.format("BR%03d", nextNumber);
                } catch (Exception e) {
                    return "BR001";
                }
            }
        }
        return "BR001";
    }

    // ============================================
    // 2. CREATE BOOKING REQUEST
    // ============================================
    public boolean createBookingRequest(BookingRequest booking) {
        Connection con = null;

        try {
            con = getConnection();
            con.setAutoCommit(false);

            // Generate booking ID
            String bookingId = generateBookingId(con);
            booking.setBookingId(bookingId);

            String sql = "INSERT INTO booking_request " +
                    "(booking_id, student_id, room_id, student_name, student_age, " +
                    "student_phone, student_email, guardian_name, guardian_phone, " +
                    "guardian_relationship, booking_start_date, booking_end_date, " +
                    "duration_months, special_requests, key_money, monthly_rent, " +
                    "total_amount, payment_method, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending')";

            try (PreparedStatement pst = con.prepareStatement(sql)) {
                pst.setString(1, booking.getBookingId());
                pst.setString(2, booking.getStudentId());
                pst.setInt(3, booking.getRoomId());
                pst.setString(4, booking.getStudentName());
                pst.setInt(5, booking.getStudentAge());
                pst.setString(6, booking.getStudentPhone());
                pst.setString(7, booking.getStudentEmail());
                pst.setString(8, booking.getGuardianName());
                pst.setString(9, booking.getGuardianPhone());
                pst.setString(10, booking.getGuardianRelationship());
                pst.setDate(11, booking.getBookingStartDate());
                pst.setDate(12, booking.getBookingEndDate());
                pst.setInt(13, booking.getDurationMonths());
                pst.setString(14, booking.getSpecialRequests());
                pst.setBigDecimal(15, booking.getKeyMoney());
                pst.setBigDecimal(16, booking.getMonthlyRent());
                pst.setBigDecimal(17, booking.getTotalAmount());
                pst.setString(18, booking.getPaymentMethod());

                pst.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // ============================================
    // 3. GET ALL BOOKING REQUESTS
    // ============================================
    public List<BookingRequest> getAllBookingRequests() {
        List<BookingRequest> bookings = new ArrayList<>();
        String sql = "SELECT br.*, r.room_number, r.floor_number, r.room_type, " +
                "r.price_monthly, h.hostel_name, u.username as student_username " +
                "FROM booking_request br " +
                "JOIN room r ON br.room_id = r.id " +
                "JOIN hostel h ON r.hostel_id = h.id " +
                "JOIN users u ON br.student_id = u.userId " +
                "ORDER BY br.requested_at DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                bookings.add(extractBookingFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }

    // ============================================
    // 4. GET BOOKING REQUESTS BY STUDENT
    // ============================================
    public List<BookingRequest> getBookingsByStudent(String studentId) {
        List<BookingRequest> bookings = new ArrayList<>();
        String sql = "SELECT br.*, r.room_number, r.floor_number, r.room_type, " +
                "r.price_monthly, h.hostel_name, u.username as student_username " +
                "FROM booking_request br " +
                "JOIN room r ON br.room_id = r.id " +
                "JOIN hostel h ON r.hostel_id = h.id " +
                "JOIN users u ON br.student_id = u.userId " +
                "WHERE br.student_id = ? " +
                "ORDER BY br.requested_at DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                bookings.add(extractBookingFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }

    // ============================================
    // 5. GET BOOKING BY ID
    // ============================================
    public BookingRequest getBookingById(int bookingId) {
        BookingRequest booking = null;
        String sql = "SELECT br.*, r.room_number, r.floor_number, r.room_type, " +
                "r.price_monthly, h.hostel_name, u.username as student_username " +
                "FROM booking_request br " +
                "JOIN room r ON br.room_id = r.id " +
                "JOIN hostel h ON r.hostel_id = h.id " +
                "JOIN users u ON br.student_id = u.userId " +
                "WHERE br.id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, bookingId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                booking = extractBookingFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return booking;
    }

    // ============================================
    // 6. GET PENDING BOOKINGS
    // ============================================
    public List<BookingRequest> getPendingBookings() {
        List<BookingRequest> bookings = new ArrayList<>();
        String sql = "SELECT br.*, r.room_number, r.floor_number, r.room_type, " +
                "r.price_monthly, h.hostel_name, u.username as student_username " +
                "FROM booking_request br " +
                "JOIN room r ON br.room_id = r.id " +
                "JOIN hostel h ON r.hostel_id = h.id " +
                "JOIN users u ON br.student_id = u.userId " +
                "WHERE br.status = 'Pending' " +
                "ORDER BY br.requested_at ASC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                bookings.add(extractBookingFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }

    // ============================================
    // 7. APPROVE BOOKING
    // ============================================
    public boolean approveBooking(int bookingId, String adminId, String remarks) {
        Connection con = null;

        try {
            con = getConnection();
            con.setAutoCommit(false);

            // Step 1: Get room_id BEFORE updating (no lock conflict yet)
            int roomId = -1;
            String getRoomSql = "SELECT room_id FROM booking_request WHERE id = ?";
            try (PreparedStatement pst = con.prepareStatement(getRoomSql)) {
                pst.setInt(1, bookingId);
                ResultSet rs = pst.executeQuery();
                if (rs.next()) {
                    roomId = rs.getInt("room_id");
                }
            }

            if (roomId == -1) {
                con.rollback();
                return false;
            }

            // Step 2: Update booking status
            String sql = "UPDATE booking_request SET " +
                    "status = 'Approved', " +
                    "admin_remarks = ?, " +
                    "approved_at = GETDATE(), " +
                    "approved_by = ? " +
                    "WHERE id = ?";
            try (PreparedStatement pst = con.prepareStatement(sql)) {
                pst.setString(1, remarks);
                pst.setString(2, adminId);
                pst.setInt(3, bookingId);
                pst.executeUpdate();
            }

            // Step 3: Update room occupancy using same connection
            String updateRoom = "UPDATE room SET occupied = occupied + 1 WHERE id = ?";
            try (PreparedStatement pst = con.prepareStatement(updateRoom)) {
                pst.setInt(1, roomId);
                pst.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            try { if (con != null) con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (con != null) { con.setAutoCommit(true); con.close(); }
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ============================================
    // 8. REJECT BOOKING
    // ============================================
    public boolean rejectBooking(int bookingId, String adminId, String remarks) {
        String sql = "UPDATE booking_request SET " +
                "status = 'Rejected', " +
                "admin_remarks = ?, " +
                "approved_at = GETDATE(), " +
                "approved_by = ? " +
                "WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, remarks);
            pst.setString(2, adminId);
            pst.setInt(3, bookingId);

            int result = pst.executeUpdate();
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============================================
    // 9. CANCEL BOOKING
    // ============================================
    public boolean cancelBooking(int bookingId) {
        String sql = "UPDATE booking_request SET status = 'Cancelled' WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, bookingId);
            int result = pst.executeUpdate();
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============================================
    // 10. UPDATE PAYMENT STATUS
    // ============================================
    public boolean updatePaymentStatus(int bookingId, String status) {
        String sql = "UPDATE booking_request SET payment_status = ? WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, status);
            pst.setInt(2, bookingId);

            int result = pst.executeUpdate();
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============================================
    // 11. GET BOOKING STATISTICS
    // ============================================
    public Map<String, Integer> getBookingStatistics() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT " +
                "COUNT(*) as total, " +
                "SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as pending, " +
                "SUM(CASE WHEN status = 'Approved' THEN 1 ELSE 0 END) as approved, " +
                "SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END) as rejected " +
                "FROM booking_request";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next()) {
                stats.put("total", rs.getInt("total"));
                stats.put("pending", rs.getInt("pending"));
                stats.put("approved", rs.getInt("approved"));
                stats.put("rejected", rs.getInt("rejected"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    // ============================================
    // HELPER METHOD: EXTRACT BOOKING FROM RESULTSET
    // ============================================
    private BookingRequest extractBookingFromResultSet(ResultSet rs) throws SQLException {
        BookingRequest booking = new BookingRequest();

        booking.setId(rs.getInt("id"));
        booking.setBookingId(rs.getString("booking_id"));
        booking.setStudentId(rs.getString("student_id"));
        booking.setRoomId(rs.getInt("room_id"));

        booking.setStudentName(rs.getString("student_name"));
        booking.setStudentAge(rs.getInt("student_age"));
        booking.setStudentPhone(rs.getString("student_phone"));
        booking.setStudentEmail(rs.getString("student_email"));

        booking.setGuardianName(rs.getString("guardian_name"));
        booking.setGuardianPhone(rs.getString("guardian_phone"));
        booking.setGuardianRelationship(rs.getString("guardian_relationship"));

        booking.setBookingStartDate(rs.getDate("booking_start_date"));
        booking.setBookingEndDate(rs.getDate("booking_end_date"));
        booking.setDurationMonths(rs.getInt("duration_months"));

        booking.setSpecialRequests(rs.getString("special_requests"));

        booking.setKeyMoney(rs.getBigDecimal("key_money"));
        booking.setMonthlyRent(rs.getBigDecimal("monthly_rent"));
        booking.setTotalAmount(rs.getBigDecimal("total_amount"));
        booking.setPaymentMethod(rs.getString("payment_method"));
        booking.setPaymentStatus(rs.getString("payment_status"));

        booking.setStatus(rs.getString("status"));
        booking.setAdminRemarks(rs.getString("admin_remarks"));

        booking.setRequestedAt(rs.getTimestamp("requested_at"));
        booking.setApprovedAt(rs.getTimestamp("approved_at"));
        booking.setApprovedBy(rs.getString("approved_by"));

        // Room info
        booking.setRoomNumber(rs.getString("room_number"));
        booking.setFloorNumber(rs.getInt("floor_number"));
        booking.setRoomType(rs.getString("room_type"));
        booking.setPriceMonthly(rs.getBigDecimal("price_monthly"));
        booking.setHostelName(rs.getString("hostel_name"));
        booking.setStudentUsername(rs.getString("student_username"));

        return booking;
    }
}