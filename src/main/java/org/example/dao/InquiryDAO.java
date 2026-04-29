package org.example.dao;

import org.example.model.Inquiry;
import java.sql.*;
import java.util.*;

public class InquiryDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
        String dbUser = "sa";
        String dbPass = "Japan@123*";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    // ============================================
    // 1. GENERATE INQUIRY ID
    // ============================================
    private String generateInquiryId(Connection con) throws SQLException {
        String sql = "SELECT MAX(inquiry_id) as maxId FROM inquiry WHERE inquiry_id LIKE 'INQ%'";
        
        try (PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            
            if (rs.next() && rs.getString("maxId") != null) {
                String lastId = rs.getString("maxId");
                try {
                    int nextNumber = Integer.parseInt(lastId.substring(3)) + 1;
                    return String.format("INQ%03d", nextNumber);
                } catch (Exception e) {
                    return "INQ001";
                }
            }
        }
        return "INQ001";
    }

    // ============================================
    // 2. CREATE INQUIRY
    // ============================================
    public boolean createInquiry(Inquiry inquiry) {
        Connection con = null;
        
        try {
            con = getConnection();
            con.setAutoCommit(false);

            // Generate inquiry ID
            String inquiryId = generateInquiryId(con);
            inquiry.setInquiryId(inquiryId);

            String sql = "INSERT INTO inquiry " +
                        "(inquiry_id, student_id, room_id, subject, message, inquiry_type, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, 'Pending')";

            try (PreparedStatement pst = con.prepareStatement(sql)) {
                pst.setString(1, inquiry.getInquiryId());
                pst.setString(2, inquiry.getStudentId());
                
                if (inquiry.getRoomId() != null) {
                    pst.setInt(3, inquiry.getRoomId());
                } else {
                    pst.setNull(3, Types.INTEGER);
                }
                
                pst.setString(4, inquiry.getSubject());
                pst.setString(5, inquiry.getMessage());
                pst.setString(6, inquiry.getInquiryType());

                pst.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // ============================================
    // 3. GET ALL INQUIRIES
    // ============================================
    public List<Inquiry> getAllInquiries() {
        List<Inquiry> inquiries = new ArrayList<>();
        String sql = "SELECT i.*, " +
                     "sd.fullName as student_name, sd.email as student_email, " +
                     "r.room_number, " +
                     "ir.reply_message, ir.replied_at, ir.admin_id as replied_by " +
                     "FROM inquiry i " +
                     "JOIN student_details sd ON i.student_id = sd.userId " +
                     "LEFT JOIN room r ON i.room_id = r.id " +
                     "LEFT JOIN inquiry_reply ir ON i.id = ir.inquiry_id " +
                     "ORDER BY i.created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                inquiries.add(extractInquiryFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return inquiries;
    }

    // ============================================
    // 4. GET INQUIRIES BY STUDENT
    // ============================================
    public List<Inquiry> getInquiriesByStudent(String studentId) {
        List<Inquiry> inquiries = new ArrayList<>();
        String sql = "SELECT i.*, " +
                     "sd.fullName as student_name, sd.email as student_email, " +
                     "r.room_number, " +
                     "ir.reply_message, ir.replied_at, ir.admin_id as replied_by " +
                     "FROM inquiry i " +
                     "JOIN student_details sd ON i.student_id = sd.userId " +
                     "LEFT JOIN room r ON i.room_id = r.id " +
                     "LEFT JOIN inquiry_reply ir ON i.id = ir.inquiry_id " +
                     "WHERE i.student_id = ? " +
                     "ORDER BY i.created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                inquiries.add(extractInquiryFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return inquiries;
    }

    // ============================================
    // 5. GET INQUIRY BY ID
    // ============================================
    public Inquiry getInquiryById(int inquiryId) {
        Inquiry inquiry = null;
        String sql = "SELECT i.*, " +
                     "sd.fullName as student_name, sd.email as student_email, " +
                     "r.room_number, " +
                     "ir.reply_message, ir.replied_at, ir.admin_id as replied_by " +
                     "FROM inquiry i " +
                     "JOIN student_details sd ON i.student_id = sd.userId " +
                     "LEFT JOIN room r ON i.room_id = r.id " +
                     "LEFT JOIN inquiry_reply ir ON i.id = ir.inquiry_id " +
                     "WHERE i.id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, inquiryId);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                inquiry = extractInquiryFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return inquiry;
    }

    // ============================================
    // 6. GET PENDING INQUIRIES
    // ============================================
    public List<Inquiry> getPendingInquiries() {
        List<Inquiry> inquiries = new ArrayList<>();
        String sql = "SELECT i.*, " +
                     "sd.fullName as student_name, sd.email as student_email, " +
                     "r.room_number " +
                     "FROM inquiry i " +
                     "JOIN student_details sd ON i.student_id = sd.userId " +
                     "LEFT JOIN room r ON i.room_id = r.id " +
                     "WHERE i.status = 'Pending' " +
                     "ORDER BY i.created_at ASC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                inquiries.add(extractInquiryFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return inquiries;
    }

    // ============================================
    // 7. REPLY TO INQUIRY
    // ============================================
    public boolean replyToInquiry(int inquiryId, String adminId, String replyMessage) {
        Connection con = null;
        
        try {
            con = getConnection();
            con.setAutoCommit(false);

            // Insert reply
            String insertReply = "INSERT INTO inquiry_reply (inquiry_id, admin_id, reply_message) " +
                                "VALUES (?, ?, ?)";
            
            try (PreparedStatement pst = con.prepareStatement(insertReply)) {
                pst.setInt(1, inquiryId);
                pst.setString(2, adminId);
                pst.setString(3, replyMessage);
                pst.executeUpdate();
            }

            // Update inquiry status
            String updateStatus = "UPDATE inquiry SET status = 'Replied' WHERE id = ?";
            
            try (PreparedStatement pst = con.prepareStatement(updateStatus)) {
                pst.setInt(1, inquiryId);
                pst.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // ============================================
    // 8. CLOSE INQUIRY
    // ============================================
    public boolean closeInquiry(int inquiryId) {
        String sql = "UPDATE inquiry SET status = 'Closed' WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, inquiryId);
            int result = pst.executeUpdate();
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============================================
    // 9. GET INQUIRY STATISTICS
    // ============================================
    public Map<String, Integer> getInquiryStatistics() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(*) as total, " +
                     "SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as pending, " +
                     "SUM(CASE WHEN status = 'Replied' THEN 1 ELSE 0 END) as replied, " +
                     "SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) as closed " +
                     "FROM inquiry";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next()) {
                stats.put("total", rs.getInt("total"));
                stats.put("pending", rs.getInt("pending"));
                stats.put("replied", rs.getInt("replied"));
                stats.put("closed", rs.getInt("closed"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    // ============================================
    // 10. DELETE INQUIRY
    // ============================================
    public boolean deleteInquiry(int inquiryId) {
        String sql = "DELETE FROM inquiry WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, inquiryId);
            int result = pst.executeUpdate();
            return result > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ============================================
    // HELPER METHOD: EXTRACT INQUIRY FROM RESULTSET
    // ============================================
    private Inquiry extractInquiryFromResultSet(ResultSet rs) throws SQLException {
        Inquiry inquiry = new Inquiry();
        
        inquiry.setId(rs.getInt("id"));
        inquiry.setInquiryId(rs.getString("inquiry_id"));
        inquiry.setStudentId(rs.getString("student_id"));
        
        // Room ID can be null
        int roomId = rs.getInt("room_id");
        if (!rs.wasNull()) {
            inquiry.setRoomId(roomId);
        }
        
        inquiry.setSubject(rs.getString("subject"));
        inquiry.setMessage(rs.getString("message"));
        inquiry.setInquiryType(rs.getString("inquiry_type"));
        inquiry.setStatus(rs.getString("status"));
        inquiry.setCreatedAt(rs.getTimestamp("created_at"));
        
        // Student info
        inquiry.setStudentName(rs.getString("student_name"));
        inquiry.setStudentEmail(rs.getString("student_email"));
        
        // Room info (can be null)
        inquiry.setRoomNumber(rs.getString("room_number"));
        
        // Reply info (can be null)
        inquiry.setReplyMessage(rs.getString("reply_message"));
        inquiry.setRepliedAt(rs.getTimestamp("replied_at"));
        inquiry.setRepliedBy(rs.getString("replied_by"));
        
        return inquiry;
    }
}
