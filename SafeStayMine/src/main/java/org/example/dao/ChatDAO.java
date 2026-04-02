package org.example.dao;

import org.example.model.ChatMessage;
import java.sql.*;
import java.util.*;

public class ChatDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection("jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;", "admin", "123456");
    }

    public void sendMessage(ChatMessage msg) {
        String sql = "INSERT INTO laundry_chats (request_no, sender_id, sender_role, message) VALUES (?,?,?,?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, msg.getRequestNo());
            ps.setString(2, msg.getSenderId());
            ps.setString(3, msg.getSenderRole());
            ps.setString(4, msg.getMessage());
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public List<ChatMessage> getMessagesByRequestNo(String requestNo) {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT * FROM laundry_chats WHERE request_no = ? ORDER BY sent_at ASC";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, requestNo);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ChatMessage msg = new ChatMessage();
                msg.setId(rs.getInt("id"));
                msg.setRequestNo(rs.getString("request_no"));
                msg.setSenderId(rs.getString("sender_id"));
                msg.setSenderRole(rs.getString("sender_role"));
                msg.setMessage(rs.getString("message"));
                msg.setSentAt(rs.getTimestamp("sent_at"));
                list.add(msg);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}