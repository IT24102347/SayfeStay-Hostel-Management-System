
package org.example.dao;

import java.sql.*;
import java.util.*;

public class ReviewDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HostelManagementDB;" +
                "encrypt=true;trustServerCertificate=true";
        return DriverManager.getConnection(dbURL, "sa", "Japan@123*");
    }

    public boolean addReview(String studentId, String studentName,
                             int rating, int cleanlinessRating,
                             int wifiRating, int staffRating,
                             String category, String comment) {

        String sql = "INSERT INTO reviews " +
                "(student_Name, category, rating, food_rating, " +
                " wifi_rating, clean_rating, staff_rating, comment, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Pending')";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentName);
            pst.setString(2, category != null ? category : "General");
            pst.setInt(3, rating);
            pst.setInt(4, cleanlinessRating);  // food_rating
            pst.setInt(5, wifiRating);          // wifi_rating ✅ FIXED (was cleanlinessRating)
            pst.setInt(6, cleanlinessRating);   // clean_rating
            pst.setInt(7, staffRating);          // staff_rating
            pst.setString(8, comment != null ? comment : "");

            return pst.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> getApprovedReviews() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, student_Name, rating, food_rating, wifi_rating, " +
                "clean_rating, staff_rating, category, comment, ownerReply, created_at " +
                "FROM reviews WHERE status = 'Approved' ORDER BY created_at DESC";

        try (Connection con = getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id",                rs.getInt("id"));
                m.put("name",              rs.getString("student_Name"));
                m.put("rating",            rs.getInt("rating"));
                m.put("cleanlinessRating", rs.getInt("clean_rating"));
                m.put("wifiRating",        rs.getInt("wifi_rating"));
                m.put("staffRating",       rs.getInt("staff_rating"));
                m.put("foodRating",        rs.getInt("food_rating"));
                m.put("category",          rs.getString("category"));
                m.put("comment",           rs.getString("comment"));
                m.put("ownerReply",        rs.getString("ownerReply"));
                m.put("date",              rs.getTimestamp("created_at"));
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Map<String, Object>> getAllReviews() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, student_Name, rating, food_rating, wifi_rating, " +
                "clean_rating, staff_rating, category, comment, status, ownerReply, created_at " +
                "FROM reviews ORDER BY created_at DESC";

        try (Connection con = getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {

            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id",                rs.getInt("id"));
                m.put("name",              rs.getString("student_Name"));
                m.put("rating",            rs.getInt("rating"));
                m.put("cleanlinessRating", rs.getInt("clean_rating"));
                m.put("wifiRating",        rs.getInt("wifi_rating"));
                m.put("staffRating",       rs.getInt("staff_rating"));
                m.put("foodRating",        rs.getInt("food_rating"));
                m.put("category",          rs.getString("category"));
                m.put("comment",           rs.getString("comment"));
                m.put("status",            rs.getString("status"));
                m.put("ownerReply",        rs.getString("ownerReply"));
                m.put("date",              rs.getTimestamp("created_at"));
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateReviewStatus(int id, String status) {
        String sql = "Deleted".equals(status)
                ? "DELETE FROM reviews WHERE id = ?"
                : "UPDATE reviews SET status = ? WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            if ("Deleted".equals(status)) { pst.setInt(1, id); }
            else { pst.setString(1, status); pst.setInt(2, id); }
            return pst.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateOwnerReply(int reviewId, String reply) {
        String sql = "UPDATE reviews SET ownerReply = ?, status = 'Approved' WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, reply);
            pst.setInt(2, reviewId);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}

