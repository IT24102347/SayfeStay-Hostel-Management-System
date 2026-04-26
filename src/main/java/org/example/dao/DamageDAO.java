package org.example.dao;

import org.example.model.DamageReport;
import java.sql.*;
import java.util.*;

public class DamageDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection(
                "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=true;trustServerCertificate=true",
                "sa",
                "Japan@123*"
        );
    }

    public List<DamageReport> getAllDamageReports() {
        List<DamageReport> reports = new ArrayList<>();

        // Simple SELECT without JOIN
        String sql = "SELECT id, student_id, request_no, description, photo1, photo2, photo3, photo4, status, staff_response, reported_at FROM damage_reports ORDER BY reported_at DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                DamageReport report = new DamageReport();
                report.setId(rs.getInt("id"));
                report.setStudentId(rs.getString("student_id"));
                report.setStudentName(rs.getString("student_id")); // Use student_id as name
                report.setRequestNo(rs.getString("request_no"));
                report.setDescription(rs.getString("description"));
                report.setPhoto1(rs.getString("photo1"));
                report.setPhoto2(rs.getString("photo2"));
                report.setPhoto3(rs.getString("photo3"));
                report.setPhoto4(rs.getString("photo4"));
                report.setStatus(rs.getString("status"));
                report.setStaffResponse(rs.getString("staff_response"));
                report.setReportedAt(rs.getTimestamp("reported_at"));
                reports.add(report);

                System.out.println("Loaded: ID=" + report.getId() + ", Student=" + report.getStudentId());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("Total Damage Reports: " + reports.size());
        return reports;
    }

    public int createDamage(DamageReport report) {
        String sql = "INSERT INTO damage_reports (student_id, request_no, description, photo1, photo2, photo3, photo4, status, staff_response, reported_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pst.setString(1, report.getStudentId());
            pst.setString(2, report.getRequestNo());
            pst.setString(3, report.getDescription());
            pst.setString(4, report.getPhoto1());
            pst.setString(5, report.getPhoto2());
            pst.setString(6, report.getPhoto3());
            pst.setString(7, report.getPhoto4());
            pst.setString(8, report.getStatus() != null ? report.getStatus() : "Pending");
            pst.setString(9, report.getStaffResponse() != null ? report.getStaffResponse() : "Not responded yet");

            int affected = pst.executeUpdate();

            if (affected > 0) {
                ResultSet rs = pst.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            return 0;

        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public boolean updateDamageReport(int id, String status, String staffResponse) {
        String sql = "UPDATE damage_reports SET status = ?, staff_response = ?, resolved_at = GETDATE() WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, status);
            pst.setString(2, staffResponse);
            pst.setInt(3, id);

            return pst.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}