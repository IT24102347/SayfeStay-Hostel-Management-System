package org.example.dao;

import org.example.model.User;
import java.sql.*;

public class UserDAO {
    // Change to SQL Server connection
    private String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HostelManagementDB;encrypt=true;trustServerCertificate=true";
    private String dbUser = "sa";
    private String dbPass = "Japan@123*";

    public User login(String userId, String password) {
        User user = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            Connection con = DriverManager.getConnection(dbURL, dbUser, dbPass);

            // ===== UPDATED QUERY =====
            // Get user details from users table first
            String sql = "SELECT u.userId, u.username, u.role, " +
                    "COALESCE(s.fullName, st.fullName, u.username) as fullName " +
                    "FROM users u " +
                    "LEFT JOIN student_details s ON u.userId = s.userId " +
                    "LEFT JOIN staff_details st ON u.userId = st.userId " +
                    "WHERE u.userId = ? AND u.password = ?";

            PreparedStatement pst = con.prepareStatement(sql);
            pst.setString(1, userId);
            pst.setString(2, password);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getString("userId"));
                user.setUsername(rs.getString("username"));
                user.setRole(rs.getString("role"));

                // If fullName is null, use username instead
                String fullName = rs.getString("fullName");
                if (fullName == null || fullName.isEmpty()) {
                    fullName = rs.getString("username");
                }
                user.setFullName(fullName);

                System.out.println("UserDAO: Login successful - " + userId + " (" + user.getRole() + ")");
            } else {
                System.out.println("UserDAO: Login failed - " + userId);
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }

    // Optional: Method to get user by ID
    public User getUserById(String userId) {
        User user = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            Connection con = DriverManager.getConnection(dbURL, dbUser, dbPass);

            String sql = "SELECT u.userId, u.username, u.role, " +
                    "COALESCE(s.fullName, st.fullName, u.username) as fullName " +
                    "FROM users u " +
                    "LEFT JOIN student_details s ON u.userId = s.userId " +
                    "LEFT JOIN staff_details st ON u.userId = st.userId " +
                    "WHERE u.userId = ?";

            PreparedStatement pst = con.prepareStatement(sql);
            pst.setString(1, userId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getString("userId"));
                user.setUsername(rs.getString("username"));
                user.setRole(rs.getString("role"));

                String fullName = rs.getString("fullName");
                if (fullName == null || fullName.isEmpty()) {
                    fullName = rs.getString("username");
                }
                user.setFullName(fullName);
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }
}