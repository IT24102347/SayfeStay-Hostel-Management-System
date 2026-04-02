package org.example.dao;

import java.sql.*;
import java.util.*;

public class CleaningDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            System.out.println("✓ Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.out.println("✗ Driver NOT found!");
            e.printStackTrace();
        }
        return DriverManager.getConnection(
                "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;",
                "admin",
                "123456"
        );
    }

    // ==================== STAFF METHODS ====================

    public List<Map<String, Object>> getAllPendingRequests() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, studentId, studentName, roomNo, floorNo, requestDate, price " +
                "FROM cleaning_requests WHERE cleaningType = 'Staff' AND status = 'Pending' ORDER BY requestDate ASC";

        System.out.println("========== getAllPendingRequests ==========");
        System.out.println("SQL: " + sql);

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("studentId", rs.getString("studentId"));
                map.put("studentName", rs.getString("studentName"));
                map.put("roomNo", rs.getString("roomNo"));
                map.put("floorNo", rs.getInt("floorNo"));
                map.put("requestDate", rs.getDate("requestDate"));
                map.put("price", rs.getDouble("price"));
                list.add(map);
                System.out.println("  Found: ID=" + rs.getInt("id") + ", Name=" + rs.getString("studentName"));
            }
            System.out.println("Total pending requests: " + list.size());

        } catch (Exception e) {
            System.out.println("SQL ERROR: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getAllCompletedRequests() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, studentId, studentName, roomNo, floorNo, cleaningType, requestDate, price, " +
                "ISNULL(assigned_date, 'N/A') as assigned_date, " +
                "ISNULL(assigned_time, 'N/A') as assigned_time " +
                "FROM cleaning_requests WHERE status = 'Completed' ORDER BY completed_at DESC";

        System.out.println("========== getAllCompletedRequests ==========");
        System.out.println("SQL: " + sql);

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("studentId", rs.getString("studentId"));
                map.put("studentName", rs.getString("studentName"));
                map.put("roomNo", rs.getString("roomNo"));
                map.put("floorNo", rs.getInt("floorNo"));
                map.put("cleaningType", rs.getString("cleaningType"));
                map.put("requestDate", rs.getDate("requestDate"));
                map.put("price", rs.getDouble("price"));
                map.put("assigned_date", rs.getString("assigned_date"));
                map.put("assigned_time", rs.getString("assigned_time"));
                list.add(map);
                System.out.println("  Found: ID=" + rs.getInt("id"));
            }
            System.out.println("Total completed requests: " + list.size());

        } catch (Exception e) {
            System.out.println("SQL ERROR: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Object> getStaffStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
                "COUNT(*) as total_requests, " +
                "SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as pending_count, " +
                "SUM(CASE WHEN status = 'Accepted' THEN 1 ELSE 0 END) as accepted_count, " +
                "SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as completed_count, " +
                "COALESCE(SUM(price), 0) as total_earned " +
                "FROM cleaning_requests WHERE cleaningType = 'Staff'";

        System.out.println("========== getStaffStats ==========");
        System.out.println("SQL: " + sql);

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next()) {
                stats.put("total_requests", rs.getInt("total_requests"));
                stats.put("pending_count", rs.getInt("pending_count"));
                stats.put("accepted_count", rs.getInt("accepted_count"));
                stats.put("completed_count", rs.getInt("completed_count"));
                stats.put("total_earned", rs.getDouble("total_earned"));
                System.out.println("  total_requests: " + rs.getInt("total_requests"));
                System.out.println("  pending_count: " + rs.getInt("pending_count"));
            }
        } catch (Exception e) {
            System.out.println("SQL ERROR: " + e.getMessage());
            e.printStackTrace();
        }
        return stats;
    }

    public boolean acceptRequest(int id, String assignedDate, String assignedTime, String staffResponse) {
        String sql = "UPDATE cleaning_requests SET status = 'Accepted', assigned_date = ?, assigned_time = ?, staff_response = ? WHERE id = ?";

        System.out.println("========== acceptRequest ==========");
        System.out.println("ID: " + id);
        System.out.println("Assigned Date: " + assignedDate);
        System.out.println("Assigned Time: " + assignedTime);

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, assignedDate);
            pst.setString(2, assignedTime);
            pst.setString(3, staffResponse);
            pst.setInt(4, id);
            int result = pst.executeUpdate();
            System.out.println("Rows affected: " + result);
            return result > 0;

        } catch (Exception e) {
            System.out.println("SQL ERROR: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean completeRequest(int id) {
        String sql = "UPDATE cleaning_requests SET status = 'Completed', completed_at = CONVERT(VARCHAR, GETDATE(), 120) WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, id);
            return pst.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==================== STUDENT METHODS ====================

    public boolean createRequest(String studentId, String name, String room, int floor, String type, double price) {
        String sql = "INSERT INTO cleaning_requests (studentId, studentName, roomNo, floorNo, cleaningType, requestDate, status, price, requestedAt) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        System.out.println("========== createRequest ==========");
        System.out.println("Student: " + studentId);
        System.out.println("Type: " + type);
        System.out.println("Price: " + price);

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            pst.setString(2, name);
            pst.setString(3, room);
            pst.setInt(4, floor);
            pst.setString(5, type);
            pst.setDate(6, new java.sql.Date(System.currentTimeMillis()));
            pst.setString(7, type.equalsIgnoreCase("Self") ? "Completed" : "Pending");
            pst.setDouble(8, price);

            int result = pst.executeUpdate();
            System.out.println("Rows affected: " + result);
            return result > 0;

        } catch (Exception e) {
            System.out.println("SQL ERROR: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> getStudentCleaningHistory(String studentId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, requestDate, roomNo, floorNo, cleaningType, status, price, " +
                "ISNULL(assigned_date, 'N/A') as assigned_date, " +
                "ISNULL(assigned_time, 'N/A') as assigned_time " +
                "FROM cleaning_requests WHERE studentId = ? ORDER BY requestDate DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("date", rs.getDate("requestDate"));
                map.put("roomNo", rs.getString("roomNo"));
                map.put("floorNo", rs.getInt("floorNo"));
                map.put("type", rs.getString("cleaningType"));
                map.put("status", rs.getString("status"));
                map.put("price", rs.getDouble("price"));
                map.put("assigned_date", rs.getString("assigned_date"));
                map.put("assigned_time", rs.getString("assigned_time"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getCleaningRequestsByMonth(String studentId, int year, int month) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT requestDate, cleaningType FROM cleaning_requests " +
                "WHERE studentId = ? AND YEAR(requestDate) = ? AND MONTH(requestDate) = ? ORDER BY requestDate";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            pst.setInt(2, year);
            pst.setInt(3, month);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("date", rs.getDate("requestDate"));
                map.put("type", rs.getString("cleaningType"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Object> getCleaningStats(String studentId) {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
                "COUNT(*) as total, " +
                "SUM(CASE WHEN cleaningType = 'Self' THEN 1 ELSE 0 END) as self_cleaned, " +
                "SUM(CASE WHEN cleaningType = 'Staff' THEN 1 ELSE 0 END) as staff_requested, " +
                "SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as completed, " +
                "SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as pending, " +
                "COALESCE(SUM(price), 0) as total_spent " +
                "FROM cleaning_requests WHERE studentId = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                stats.put("total", rs.getInt("total"));
                stats.put("self_cleaned", rs.getInt("self_cleaned"));
                stats.put("staff_requested", rs.getInt("staff_requested"));
                stats.put("completed", rs.getInt("completed"));
                stats.put("pending", rs.getInt("pending"));
                stats.put("total_spent", rs.getDouble("total_spent"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }
}