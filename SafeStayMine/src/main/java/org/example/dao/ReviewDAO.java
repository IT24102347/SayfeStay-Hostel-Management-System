package org.example.dao;

import java.sql.*;

public class ReviewDAO {
    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
        return DriverManager.getConnection(dbURL, "admin", "123456");
    }

    public boolean addReview(String studentId, String name, int rating, String comment) {
        String sql = "INSERT INTO reviews (studentId, studentName, rating, comment) VALUES (?,?,?,?)";
        try (Connection con = getConnection(); PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            pst.setString(2, name);
            pst.setInt(3, rating);
            pst.setString(4, comment);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}