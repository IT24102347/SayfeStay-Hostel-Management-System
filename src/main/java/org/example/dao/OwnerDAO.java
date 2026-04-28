package org.example.dao;

import org.example.model.Owner;
import org.example.model.Hostel;
import org.example.model.Room;
import org.example.model.Payment;
import java.sql.*;
import java.util.*;

public class OwnerDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HostelManagementDB;encrypt=true;trustServerCertificate=true";
        String dbUser = "sa";
        String dbPass = "Japan@123*";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // ============ GET OWNER BY USER ID ============
    public Owner getOwnerByUserId(String userId) {
        Owner owner = null;
        String sql = "SELECT * FROM owner WHERE userId = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, userId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                owner = new Owner();
                owner.setUserId(rs.getString("userId"));
                owner.setFullName(rs.getString("fullName"));
                owner.setEmail(rs.getString("email"));
                owner.setPhone(rs.getString("phone"));
                owner.setAddress(rs.getString("address"));
                owner.setCompanyName(rs.getString("company_name"));
                owner.setCreatedAt(rs.getTimestamp("created_at"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return owner;
    }

    // ============ GET HOSTEL BY OWNER ID (FIXED - REMOVED EXTRA FIELDS) ============
    public Hostel getHostelByOwnerId(String ownerId) {
        Hostel hostel = null;
        String sql = "SELECT id, ownerId, hostel_name, address, city, total_rooms, available_rooms, " +
                "contact_number, email, warden_name, warden_phone, status, created_at " +
                "FROM hostel WHERE ownerId = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, ownerId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                hostel = new Hostel();
                hostel.setId(rs.getInt("id"));
                hostel.setOwnerId(rs.getString("ownerId"));
                hostel.setHostelName(rs.getString("hostel_name"));
                hostel.setAddress(rs.getString("address"));
                hostel.setCity(rs.getString("city"));
                hostel.setTotalRooms(rs.getInt("total_rooms"));
                hostel.setAvailableRooms(rs.getInt("available_rooms"));
                hostel.setContactNumber(rs.getString("contact_number"));
                hostel.setEmail(rs.getString("email"));
                hostel.setWardenName(rs.getString("warden_name"));
                hostel.setWardenPhone(rs.getString("warden_phone"));
                hostel.setStatus(rs.getString("status"));
                hostel.setCreatedAt(rs.getTimestamp("created_at"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return hostel;
    }

    // ============ GET DASHBOARD STATISTICS ============
    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();

        String sql = "SELECT " +
                "(SELECT COUNT(*) FROM users WHERE role = 'Student') as totalStudents, " +
                "(SELECT COUNT(*) FROM staff_details) as totalStaff, " +
                "(SELECT SUM(total_rooms) FROM hostel) as totalRooms, " +
                "(SELECT SUM(available_rooms) FROM hostel) as availableRooms, " +
                "(SELECT ISNULL(SUM(amount), 0) FROM payment WHERE MONTH(payment_date) = MONTH(GETDATE()) AND YEAR(payment_date) = YEAR(GETDATE())) as monthlyRevenue, " +
                "(SELECT COUNT(*) FROM maintenance WHERE status = 'Pending') as pendingMaintenance";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next()) {
                int totalRooms = rs.getInt("totalRooms");
                int availableRooms = rs.getInt("availableRooms");
                int occupiedRooms = totalRooms - availableRooms;

                stats.put("totalStudents", rs.getInt("totalStudents"));
                stats.put("totalStaff", rs.getInt("totalStaff"));
                stats.put("totalRooms", totalRooms);
                stats.put("availableRooms", availableRooms);
                stats.put("occupiedRooms", occupiedRooms);

                double occupancyRate = 0;
                if (totalRooms > 0) {
                    occupancyRate = (double) occupiedRooms / totalRooms * 100;
                }
                stats.put("occupancyRate", occupancyRate);

                stats.put("monthlyRevenue", rs.getDouble("monthlyRevenue"));
                stats.put("pendingMaintenance", rs.getInt("pendingMaintenance"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        stats.putIfAbsent("totalStudents", 0);
        stats.putIfAbsent("totalStaff", 0);
        stats.putIfAbsent("totalRooms", 0);
        stats.putIfAbsent("availableRooms", 0);
        stats.putIfAbsent("occupiedRooms", 0);
        stats.putIfAbsent("occupancyRate", 0.0);
        stats.putIfAbsent("monthlyRevenue", 0.0);
        stats.putIfAbsent("pendingMaintenance", 0);

        return stats;
    }

    // ============ GET ALL STUDENTS ============
    public List<Map<String, Object>> getAllStudents() {
        List<Map<String, Object>> students = new ArrayList<>();
        String sql = "SELECT s.*, u.username FROM student_details s JOIN users u ON s.userId = u.userId ORDER BY s.registration_date DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> student = new HashMap<>();
                student.put("userId", rs.getString("userId"));
                student.put("fullName", rs.getString("fullName"));
                student.put("email", rs.getString("email"));
                student.put("phone", rs.getString("phone"));
                student.put("address", rs.getString("address"));
                student.put("campusName", rs.getString("campus_name"));
                student.put("studyYear", rs.getInt("studyYear"));
                student.put("guardianName", rs.getString("guardian_name"));
                student.put("guardianPhone", rs.getString("guardian_phone"));
                student.put("guardianRelationship", rs.getString("guardian_relationship"));
                student.put("emergencyContact", rs.getString("emergency_contact"));
                student.put("registrationDate", rs.getTimestamp("registration_date"));
                student.put("status", "Active");
                students.add(student);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return students;
    }

    // ============ GET ALL STAFF ============
    public List<Map<String, Object>> getAllStaff() {
        List<Map<String, Object>> staffList = new ArrayList<>();
        String sql = "SELECT s.*, u.username FROM staff_details s JOIN users u ON s.userId = u.userId ORDER BY s.registration_date DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> staff = new HashMap<>();
                staff.put("userId", rs.getString("userId"));
                staff.put("fullName", rs.getString("fullName"));
                staff.put("email", rs.getString("email"));
                staff.put("phone", rs.getString("phone"));
                staff.put("staffRole", rs.getString("staff_role"));
                staff.put("department", rs.getString("department"));
                staff.put("workShift", rs.getString("work_shift"));
                staff.put("joinDate", rs.getDate("join_date"));
                staffList.add(staff);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return staffList;
    }

    // ============ GET RECENT PAYMENTS ============
    public List<Payment> getRecentPayments(int limit) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT TOP (?) p.*, u.fullName as studentName FROM payment p JOIN users u ON p.studentId = u.userId ORDER BY p.created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, limit);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                Payment payment = new Payment();
                payment.setId(rs.getInt("id"));
                payment.setPaymentNo(rs.getString("payment_no"));
                payment.setStudentId(rs.getString("studentId"));
                payment.setStudentName(rs.getString("studentName"));
                payment.setAmount(rs.getDouble("amount"));
                payment.setPaymentDate(rs.getDate("payment_date"));
                payment.setPaymentMethod(rs.getString("payment_method"));
                payment.setStatus(rs.getString("status"));
                payment.setCreatedAt(rs.getDate("created_at"));
                payments.add(payment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return payments;
    }

    // ============ UPDATE HOSTEL ============
    public boolean updateHostel(Hostel hostel) {
        String sql = "UPDATE hostel SET hostel_name=?, address=?, city=?, total_rooms=?, available_rooms=?, " +
                "contact_number=?, email=?, warden_name=?, warden_phone=?, status=? " +
                "WHERE ownerId=?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, hostel.getHostelName());
            pst.setString(2, hostel.getAddress());
            pst.setString(3, hostel.getCity());
            pst.setInt(4, hostel.getTotalRooms());
            pst.setInt(5, hostel.getAvailableRooms());
            pst.setString(6, hostel.getContactNumber());
            pst.setString(7, hostel.getEmail());
            pst.setString(8, hostel.getWardenName());
            pst.setString(9, hostel.getWardenPhone());
            pst.setString(10, hostel.getStatus());
            pst.setString(11, hostel.getOwnerId());

            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============ REVIEW MANAGEMENT (UPDATED & FIXED) ============

    // 1. Get all Reviews  (Including Owner Reply)
    public List<Map<String, Object>> getAllReviews() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, studentName, rating, comment, status, ownerReply, created_at FROM reviews ORDER BY created_at DESC";
        try (Connection con = getConnection(); Statement st = con.createStatement()) {
            ResultSet rs = st.executeQuery(sql);
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("name", rs.getString("studentName"));
                map.put("rating", rs.getInt("rating"));
                map.put("comment", rs.getString("comment"));
                map.put("status", rs.getString("status"));
                map.put("ownerReply", rs.getString("ownerReply"));
                map.put("date", rs.getTimestamp("created_at"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 2. Status  Update (Approve or Delete) - FIXED SERVLET ERROR
    public boolean updateReviewStatus(int id, String status) {
        String sql;
        if ("Deleted".equals(status)) {
            sql = "DELETE FROM reviews WHERE id = ?";
        } else {
            sql = "UPDATE reviews SET status = ? WHERE id = ?";
        }

        try (Connection con = getConnection(); PreparedStatement pst = con.prepareStatement(sql)) {
            if ("Deleted".equals(status)) {
                pst.setInt(1, id);
            } else {
                pst.setString(1, status);
                pst.setInt(2, id);
            }
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 3. Owner's Reply  Update
    public boolean updateOwnerReply(int reviewId, String reply) {
        String sql = "UPDATE reviews SET ownerReply = ?, repliedAt = GETDATE(), status = 'Approved' WHERE id = ?";
        try (Connection con = getConnection(); PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, reply);
            pst.setInt(2, reviewId);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
