package org.example.dao;

import org.example.model.Attendance;
import java.sql.*;
import java.util.*;

public class AttendanceDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
        String dbUser = "admin";
        String dbPass = "123456";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // ============ 1. CHECK-IN (MULTIPLE TIMES PER DAY) ============
    public boolean checkIn(String studentId, String status, String markedBy, String remarks) {
        String sql = "INSERT INTO attendance (studentId, attendance_date, check_in_time, status, marked_by, remarks) " +
                "VALUES (?, CAST(GETDATE() AS DATE), GETDATE(), ?, ?, ?)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            pst.setString(2, status);
            pst.setString(3, markedBy);
            pst.setString(4, remarks != null ? remarks : "");

            int result = pst.executeUpdate();
            System.out.println("✅ Check-in at " + new Timestamp(System.currentTimeMillis()) + " for: " + studentId);
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============ 2. CHECK-OUT (MULTIPLE TIMES PER DAY) ============
    public boolean checkOut(String studentId) {
        // Find the most recent check-in without check-out
        String sql = "SELECT TOP 1 id FROM attendance WHERE studentId = ? AND attendance_date = CAST(GETDATE() AS DATE) " +
                "AND check_out_time IS NULL ORDER BY check_in_time DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                int id = rs.getInt("id");

                // Update that record with check-out time
                String updateSql = "UPDATE attendance SET check_out_time = GETDATE() WHERE id = ?";
                try (PreparedStatement updatePst = con.prepareStatement(updateSql)) {
                    updatePst.setInt(1, id);
                    int result = updatePst.executeUpdate();

                    if (result > 0) {
                        System.out.println("✅ Check-out at " + new Timestamp(System.currentTimeMillis()) + " for: " + studentId);
                        return true;
                    }
                }
            } else {
                System.out.println("❌ No active check-in found for today: " + studentId);
                return false;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ============ 3. GET ALL CHECK-INS FOR TODAY ============
    public List<Attendance> getTodayCheckIns(String studentId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, u.fullName as studentName FROM attendance a " +
                "JOIN users u ON a.studentId = u.userId " +
                "WHERE a.studentId = ? AND a.attendance_date = CAST(GETDATE() AS DATE) " +
                "ORDER BY a.check_in_time DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                Attendance a = new Attendance();
                a.setId(rs.getInt("id"));
                a.setStudentId(rs.getString("studentId"));
                a.setStudentName(rs.getString("studentName"));
                a.setAttendanceDate(rs.getDate("attendance_date"));
                a.setCheckInTime(rs.getTimestamp("check_in_time"));
                a.setCheckOutTime(rs.getTimestamp("check_out_time"));
                a.setStatus(rs.getString("status"));
                a.setRemarks(rs.getString("remarks"));
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ============ 4. GET ALL ATTENDANCE FOR STUDENT ============
    public List<Attendance> getAllAttendance(String studentId, int days) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, u.fullName as studentName FROM attendance a " +
                "JOIN users u ON a.studentId = u.userId " +
                "WHERE a.studentId = ? " +
                "AND a.attendance_date >= DATEADD(day, -?, GETDATE()) " +
                "ORDER BY a.attendance_date DESC, a.check_in_time DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            pst.setInt(2, days);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                Attendance a = new Attendance();
                a.setId(rs.getInt("id"));
                a.setStudentId(rs.getString("studentId"));
                a.setStudentName(rs.getString("studentName"));
                a.setAttendanceDate(rs.getDate("attendance_date"));
                a.setCheckInTime(rs.getTimestamp("check_in_time"));
                a.setCheckOutTime(rs.getTimestamp("check_out_time"));
                a.setStatus(rs.getString("status"));
                a.setRemarks(rs.getString("remarks"));
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ============ GET ATTENDANCE BY STUDENT ID ============
    public List<Attendance> getAttendanceByStudent(String studentId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, u.fullName as studentName FROM attendance a " +
                "JOIN users u ON a.studentId = u.userId " +
                "WHERE a.studentId = ? " +
                "ORDER BY a.attendance_date DESC, a.check_in_time DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                Attendance a = new Attendance();
                a.setId(rs.getInt("id"));
                a.setStudentId(rs.getString("studentId"));
                a.setStudentName(rs.getString("studentName"));
                a.setAttendanceDate(rs.getDate("attendance_date"));
                a.setCheckInTime(rs.getTimestamp("check_in_time"));
                a.setCheckOutTime(rs.getTimestamp("check_out_time"));
                a.setStatus(rs.getString("status"));
                a.setMarkedBy(rs.getString("marked_by"));
                a.setRemarks(rs.getString("remarks"));
                a.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }



    // ============ 5. GET STATISTICS ============
    public Map<String, Object> getStats(String studentId, int days) {
        Map<String, Object> stats = new HashMap<>();

        // Count unique days with at least one check-in
        String sql = "SELECT COUNT(DISTINCT attendance_date) as total_days, " +
                "SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present_count, " +
                "SUM(CASE WHEN status = 'Late' THEN 1 ELSE 0 END) as late_count, " +
                "SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent_count " +
                "FROM attendance WHERE studentId = ? " +
                "AND attendance_date >= DATEADD(day, -?, GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            pst.setInt(2, days);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                int totalDays = rs.getInt("total_days");
                int presentCount = rs.getInt("present_count");
                int lateCount = rs.getInt("late_count");
                int absentCount = rs.getInt("absent_count");

                stats.put("totalDays", totalDays);
                stats.put("presentDays", presentCount);
                stats.put("lateDays", lateCount);
                stats.put("absentDays", absentCount);

                // Calculate percentage based on status counts
                int totalEntries = presentCount + lateCount + absentCount;
                stats.put("percentage", totalEntries > 0 ? (presentCount * 100 / totalEntries) : 0);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    // ============ 6. CHECK IF ACTIVE CHECK-IN EXISTS ============
    public boolean hasActiveCheckIn(String studentId) {
        String sql = "SELECT COUNT(*) as count FROM attendance WHERE studentId = ? " +
                "AND attendance_date = CAST(GETDATE() AS DATE) " +
                "AND check_out_time IS NULL";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                return rs.getInt("count") > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ============ 7. GET TODAY'S CHECK-IN COUNT ============
    public int getTodayCheckInCount(String studentId) {
        String sql = "SELECT COUNT(*) as count FROM attendance WHERE studentId = ? AND attendance_date = CAST(GETDATE() AS DATE)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}