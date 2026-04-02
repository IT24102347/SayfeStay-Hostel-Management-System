package org.example.dao;

import org.example.model.Announcement;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AnnouncementDAO {
    private Connection getConnection() throws SQLException {
        try { Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); }
        catch (ClassNotFoundException e) { e.printStackTrace(); }
        return DriverManager.getConnection("jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;", "admin", "123456");
    }

    public void addAnnouncement(Announcement ann) throws SQLException {
        String sql = "INSERT INTO laundry_announcements (title, message, posted_by) VALUES (?,?,?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, ann.getTitle());
            ps.setString(2, ann.getMessage());
            ps.setString(3, ann.getPostedBy());
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public List<Announcement> getAllAnnouncements() throws SQLException {
        List<Announcement> list = new ArrayList<>();
        String sql = "SELECT * FROM laundry_announcements ORDER BY posted_at DESC";
        try (Connection con = getConnection(); Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Announcement a = new Announcement();
                a.setId(rs.getInt("id"));
                a.setTitle(rs.getString("title"));
                a.setMessage(rs.getString("message"));
                a.setPostedBy(rs.getString("posted_by"));
                a.setPostedAt(rs.getTimestamp("posted_at"));
                list.add(a);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}