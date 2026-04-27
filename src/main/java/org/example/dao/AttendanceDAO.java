package org.example.dao;

import org.example.model.Attendance;
import java.sql.*;
import java.util.*;

public class AttendanceDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HostelManagementDB;encrypt=true;trustServerCertificate=true";
        String dbUser = "sa";
        String dbPass = "Japan@123*";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // fullName lives in student_details or staff_details, not in users
    private static final String NAME_COALESCE =
        "COALESCE(sd.fullName, stf.fullName, u.username) AS studentName";

    private static final String NAME_JOIN =
        "JOIN users u ON a.studentId = u.userId " +
        "LEFT JOIN student_details sd  ON a.studentId = sd.userId " +
        "LEFT JOIN staff_details   stf ON a.studentId = stf.userId";

    // ============ 1. CHECK-IN ============
    public boolean checkIn(String studentId, String status, String markedBy, String remarks) {
        String sql = "INSERT INTO attendance (studentId, attendance_date, check_in_time, status, marked_by, remarks) " +
                     "VALUES (?, CAST(GETDATE() AS DATE), GETDATE(), ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            pst.setString(2, status);
            pst.setString(3, markedBy);
            pst.setString(4, remarks != null ? remarks : "");
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============ 2. CHECK-OUT ============
    public boolean checkOut(String studentId) {
        String findSql = "SELECT TOP 1 id FROM attendance WHERE studentId = ? " +
                         "AND attendance_date = CAST(GETDATE() AS DATE) " +
                         "AND check_out_time IS NULL ORDER BY check_in_time DESC";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(findSql)) {
            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                int id = rs.getInt("id");
                String updateSql = "UPDATE attendance SET check_out_time = GETDATE() WHERE id = ?";
                try (PreparedStatement upd = con.prepareStatement(updateSql)) {
                    upd.setInt(1, id);
                    return upd.executeUpdate() > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ============ 3. TODAY'S CHECK-INS ============
    public List<Attendance> getTodayCheckIns(String studentId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, " + NAME_COALESCE + " FROM attendance a " +
                     NAME_JOIN +
                     " WHERE a.studentId = ? AND a.attendance_date = CAST(GETDATE() AS DATE) " +
                     "ORDER BY a.check_in_time DESC";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ============ 4. ALL ATTENDANCE (last N days) ============
    public List<Attendance> getAllAttendance(String studentId, int days) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, " + NAME_COALESCE + " FROM attendance a " +
                     NAME_JOIN +
                     " WHERE a.studentId = ? " +
                     "AND a.attendance_date >= DATEADD(day, -?, GETDATE()) " +
                     "ORDER BY a.attendance_date DESC, a.check_in_time DESC";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            pst.setInt(2, days);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ============ 5. ALL ATTENDANCE (no date limit) ============
    public List<Attendance> getAttendanceByStudent(String studentId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, " + NAME_COALESCE + " FROM attendance a " +
                     NAME_JOIN +
                     " WHERE a.studentId = ? " +
                     "ORDER BY a.attendance_date DESC, a.check_in_time DESC";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ============ 6. STATS ============
    public Map<String, Object> getStats(String studentId, int days) {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(DISTINCT attendance_date) as total_days, " +
                     "SUM(CASE WHEN status='Present' THEN 1 ELSE 0 END) as present_count, " +
                     "SUM(CASE WHEN status='Late'    THEN 1 ELSE 0 END) as late_count, " +
                     "SUM(CASE WHEN status='Absent'  THEN 1 ELSE 0 END) as absent_count " +
                     "FROM attendance WHERE studentId = ? " +
                     "AND attendance_date >= DATEADD(day, -?, GETDATE())";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            pst.setInt(2, days);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                int present = rs.getInt("present_count");
                int late    = rs.getInt("late_count");
                int absent  = rs.getInt("absent_count");
                int total   = present + late + absent;
                stats.put("totalDays",   rs.getInt("total_days"));
                stats.put("presentDays", present);
                stats.put("lateDays",    late);
                stats.put("absentDays",  absent);
                stats.put("percentage",  total > 0 ? (present * 100 / total) : 0);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    // ============ 7. ACTIVE CHECK-IN? ============
    public boolean hasActiveCheckIn(String studentId) {
        String sql = "SELECT COUNT(*) as cnt FROM attendance WHERE studentId = ? " +
                     "AND attendance_date = CAST(GETDATE() AS DATE) AND check_out_time IS NULL";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();
            return rs.next() && rs.getInt("cnt") > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ============ 8. TODAY'S CHECK-IN COUNT ============
    public int getTodayCheckInCount(String studentId) {
        String sql = "SELECT COUNT(*) as cnt FROM attendance " +
                     "WHERE studentId = ? AND attendance_date = CAST(GETDATE() AS DATE)";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();
            return rs.next() ? rs.getInt("cnt") : 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ============ HELPER ============
    private Attendance mapRow(ResultSet rs) throws SQLException {
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
        try { a.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException ignored) {}
        return a;
    }
}
