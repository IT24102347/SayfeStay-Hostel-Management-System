package org.example.dao;

import java.sql.*;
import java.util.*;

public class StudentDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HostelManagementDB;encrypt=true;trustServerCertificate=true";
        String dbUser = "sa";
        String dbPass = "Japan@123*";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // Get all students
    public List<Map<String, Object>> getAllStudents() {
        List<Map<String, Object>> students = new ArrayList<>();
        String sql = "SELECT s.*, u.username FROM student_details s " +
                "JOIN users u ON s.userId = u.userId " +
                "ORDER BY s.registration_date DESC";

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
                student.put("status", "Active"); // Default status
                student.put("roomNumber", "101"); // Get from room assignment table

                students.add(student);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return students;
    }

    // Get student by ID
    public Map<String, Object> getStudentById(String studentId) {
        Map<String, Object> student = new HashMap<>();
        String sql = "SELECT s.*, u.username FROM student_details s " +
                "JOIN users u ON s.userId = u.userId " +
                "WHERE s.userId = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
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
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return student;
    }
}