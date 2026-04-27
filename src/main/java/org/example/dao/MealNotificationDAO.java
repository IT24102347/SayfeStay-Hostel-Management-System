package org.example.dao;

import org.example.model.MealNotification;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class MealNotificationDAO {

    private static final String JDBC_URL =
            "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=true;trustServerCertificate=true";
    private static final String JDBC_USER = "sa";
    private static final String JDBC_PASSWORD = "Japan@123*"; // change if needed

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("SQL Server JDBC Driver not found.", e);
        }
    }

    private Connection getConnection() throws Exception {
        return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
    }

    public boolean createNotification(MealNotification notification) {
        String sql = "INSERT INTO meal_notifications (message, created_by) VALUES (?, ?)";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, notification.getMessage());
            ps.setString(2, notification.getCreatedBy());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateNotification(int id, String message, String editedBy) {
        if (hasAnyView(id)) {
            return false;
        }

        String sql = "UPDATE meal_notifications SET message = ?, created_by = ? WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, message);
            ps.setString(2, editedBy);
            ps.setInt(3, id);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteNotification(int id) {
        if (hasAnyView(id)) {
            return false;
        }

        String sql = "DELETE FROM meal_notifications WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteAllNotifications() {
        String sqlViews = "DELETE FROM meal_notification_views";
        String sqlNotifications = "DELETE FROM meal_notifications";

        try (Connection con = getConnection()) {
            con.setAutoCommit(false);

            try (PreparedStatement ps1 = con.prepareStatement(sqlViews);
                 PreparedStatement ps2 = con.prepareStatement(sqlNotifications)) {

                ps1.executeUpdate();
                ps2.executeUpdate();

                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
                return false;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean hasAnyView(int notificationId) {
        String sql = "SELECT COUNT(*) FROM meal_notification_views WHERE notification_id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, notificationId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<MealNotification> getAllNotifications() {
        List<MealNotification> list = new ArrayList<>();

        String sql =
                "SELECT n.id, n.message, n.created_by, n.created_at, " +
                        "COUNT(v.id) AS viewed_count " +
                        "FROM meal_notifications n " +
                        "LEFT JOIN meal_notification_views v ON n.id = v.notification_id " +
                        "GROUP BY n.id, n.message, n.created_by, n.created_at " +
                        "ORDER BY n.created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                MealNotification notification = new MealNotification();
                notification.setId(rs.getInt("id"));
                notification.setMessage(rs.getString("message"));
                notification.setCreatedBy(rs.getString("created_by"));

                Timestamp createdAt = rs.getTimestamp("created_at");
                if (createdAt != null) {
                    notification.setCreatedAt(new java.util.Date(createdAt.getTime()));
                }

                notification.setViewedCount(rs.getInt("viewed_count"));
                list.add(notification);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<MealNotification> getAllNotificationsForStudent(String studentId) {
        return getAllNotifications();
    }

    public void markAllAsViewedByStudent(String studentId) {
        List<MealNotification> notifications = getAllNotifications();
        for (MealNotification notification : notifications) {
            markViewed(notification.getId(), studentId);
        }
    }

    public void markViewed(int notificationId, String studentId) {
        String checkSql =
                "SELECT COUNT(*) FROM meal_notification_views WHERE notification_id = ? AND student_id = ?";
        String insertSql =
                "INSERT INTO meal_notification_views (notification_id, student_id) VALUES (?, ?)";

        try (Connection con = getConnection()) {
            boolean alreadyViewed = false;

            try (PreparedStatement checkPs = con.prepareStatement(checkSql)) {
                checkPs.setInt(1, notificationId);
                checkPs.setString(2, studentId);

                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        alreadyViewed = rs.getInt(1) > 0;
                    }
                }
            }

            if (!alreadyViewed) {
                try (PreparedStatement insertPs = con.prepareStatement(insertSql)) {
                    insertPs.setInt(1, notificationId);
                    insertPs.setString(2, studentId);
                    insertPs.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}