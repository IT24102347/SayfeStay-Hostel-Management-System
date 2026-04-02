package org.example.dao;

import org.example.model.*;
import java.sql.*;
import java.util.*;

public class LaundryDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection(
                "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;",
                "admin",
                "123456"
        );
    }

    public boolean testConnection() {
        try (Connection con = getConnection()) {
            System.out.println("Database connection successful!");
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<LaundryItem> getAllLaundryItems() {
        List<LaundryItem> list = new ArrayList<>();
        String sql = "SELECT id, item_name, base_price FROM laundry_items ORDER BY id";
        try (Connection con = getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                LaundryItem item = new LaundryItem();
                item.setId(rs.getInt("id"));
                item.setItemName(rs.getString("item_name"));
                item.setBasePrice(rs.getDouble("base_price"));
                list.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LaundryRequest> getStudentRequests(String studentId) {
        List<LaundryRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM laundry_requests WHERE studentId = ? ORDER BY id DESC";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) {
                LaundryRequest r = new LaundryRequest();
                r.setId(rs.getInt("id"));
                r.setRequestNo(rs.getString("request_no"));
                r.setStudentId(rs.getString("studentId"));
                r.setStudentName(rs.getString("student_name"));
                r.setFloorNo(rs.getInt("floor_no"));
                r.setRoomNo(rs.getString("room_no"));
                r.setServiceType(rs.getString("service_type"));
                r.setUrgency(rs.getString("urgency"));
                r.setTotalCost(rs.getDouble("total_cost"));
                r.setStatus(rs.getString("status"));
                r.setCollectionDate(rs.getDate("collection_date"));
                r.setAssignedTime(rs.getString("assigned_time"));
                r.setNotes(rs.getString("notes"));
                r.setCreatedAt(rs.getTimestamp("created_at"));

                try {
                    r.setPaymentStatus(rs.getString("payment_status"));
                } catch (Exception e) {
                    r.setPaymentStatus("Pending");
                }
                try {
                    r.setPaymentDate(rs.getTimestamp("payment_date"));
                } catch (Exception e) {
                    r.setPaymentDate(null);
                }

                try {
                    String itemSql = "SELECT COALESCE(SUM(quantity), 0) as total_items FROM laundry_request_items WHERE request_id = ?";
                    PreparedStatement pst2 = con.prepareStatement(itemSql);
                    pst2.setInt(1, r.getId());
                    ResultSet rs2 = pst2.executeQuery();
                    if (rs2.next()) {
                        r.setTotalItems(rs2.getInt("total_items"));
                    }
                    rs2.close();
                    pst2.close();
                } catch(Exception e) {
                    r.setTotalItems(0);
                }
                list.add(r);
            }
            rs.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean createLaundryRequest(LaundryRequest lr, List<LaundryRequestItem> items) {
        Connection con = null;
        PreparedStatement pst = null;
        PreparedStatement itemPst = null;

        try {
            con = getConnection();
            con.setAutoCommit(false);

            String requestNo = "REQ" + System.currentTimeMillis();

            String sql = "INSERT INTO laundry_requests (request_no, studentId, student_name, floor_no, room_no, service_type, urgency, total_cost, status, collection_date, assigned_time, notes, payment_status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
            pst = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            pst.setString(1, requestNo);
            pst.setString(2, lr.getStudentId());
            pst.setString(3, lr.getStudentName());
            pst.setInt(4, lr.getFloorNo());
            pst.setString(5, lr.getRoomNo());
            pst.setString(6, lr.getServiceType());
            pst.setString(7, lr.getUrgency());
            pst.setDouble(8, lr.getTotalCost());
            pst.setString(9, "Pending");
            pst.setDate(10, new java.sql.Date(lr.getCollectionDate().getTime()));
            pst.setString(11, "");
            pst.setString(12, "");
            pst.setString(13, "Pending");

            pst.executeUpdate();

            ResultSet generatedKeys = pst.getGeneratedKeys();
            int requestId = 0;
            if (generatedKeys.next()) {
                requestId = generatedKeys.getInt(1);
            }

            if (items != null && !items.isEmpty()) {
                String itemSql = "INSERT INTO laundry_request_items (request_id, item_id, item_name, quantity, unit_price, total_price) VALUES (?,?,?,?,?,?)";
                itemPst = con.prepareStatement(itemSql);
                for (LaundryRequestItem item : items) {
                    itemPst.setInt(1, requestId);
                    itemPst.setInt(2, item.getItemId());
                    itemPst.setString(3, item.getItemName());
                    itemPst.setInt(4, item.getQuantity());
                    itemPst.setDouble(5, item.getPricePerItem());
                    itemPst.setDouble(6, item.getTotalPrice());
                    itemPst.addBatch();
                }
                itemPst.executeBatch();
            }

            con.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            try {
                if (itemPst != null) itemPst.close();
                if (pst != null) pst.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public boolean createLaundryRequest(LaundryRequest lr) {
        return createLaundryRequest(lr, null);
    }

    // ==================== PAYMENT METHODS ====================

    public double getTotalUnpaidAmount(String studentId) {
        double total = 0;
        String sql = "SELECT COALESCE(SUM(total_cost), 0) as total FROM laundry_requests WHERE studentId = ? AND payment_status = 'Pending'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getDouble("total");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }

    public boolean hasUnpaidPayments(String studentId) {
        return getTotalUnpaidAmount(studentId) > 0;
    }

    public int getPendingLaundryCount(String studentId) {
        int count = 0;
        String sql = "SELECT COUNT(*) as cnt FROM laundry_requests WHERE studentId = ? AND payment_status = 'Pending'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt("cnt");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public boolean processAllPayments(String studentId) {
        String sql = "UPDATE laundry_requests SET payment_status = 'Paid', payment_date = GETDATE() WHERE studentId = ? AND payment_status = 'Pending'";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, studentId);
            int updated = ps.executeUpdate();
            return updated > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<LaundryRequest> getAllRequests() {
        List<LaundryRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM laundry_requests ORDER BY id DESC";
        try (Connection con = getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                LaundryRequest r = new LaundryRequest();
                r.setId(rs.getInt("id"));
                r.setRequestNo(rs.getString("request_no"));
                r.setStudentId(rs.getString("studentId"));
                r.setStudentName(rs.getString("student_name"));
                r.setFloorNo(rs.getInt("floor_no"));
                r.setRoomNo(rs.getString("room_no"));
                r.setServiceType(rs.getString("service_type"));
                r.setUrgency(rs.getString("urgency"));
                r.setTotalCost(rs.getDouble("total_cost"));
                r.setStatus(rs.getString("status"));
                r.setCollectionDate(rs.getDate("collection_date"));
                r.setAssignedTime(rs.getString("assigned_time"));
                r.setNotes(rs.getString("notes"));
                r.setCreatedAt(rs.getTimestamp("created_at"));

                // FIX: Read payment_status and payment_date
                try {
                    r.setPaymentStatus(rs.getString("payment_status"));
                } catch (Exception e) {
                    r.setPaymentStatus("Pending");
                }
                try {
                    r.setPaymentDate(rs.getTimestamp("payment_date"));
                } catch (Exception e) {
                    r.setPaymentDate(null);
                }

                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(int requestId, String status, String time, String notes) {
        String sql = "UPDATE laundry_requests SET status = ?, assigned_time = ?, notes = ? WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, status);
            pst.setString(2, time != null ? time : "");
            pst.setString(3, notes != null ? notes : "");
            pst.setInt(4, requestId);
            return pst.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public LaundryRequest getRequestById(int id) {
        String sql = "SELECT * FROM laundry_requests WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, id);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                LaundryRequest r = new LaundryRequest();
                r.setId(rs.getInt("id"));
                r.setRequestNo(rs.getString("request_no"));
                r.setStudentId(rs.getString("studentId"));
                r.setStudentName(rs.getString("student_name"));
                r.setFloorNo(rs.getInt("floor_no"));
                r.setRoomNo(rs.getString("room_no"));
                r.setServiceType(rs.getString("service_type"));
                r.setUrgency(rs.getString("urgency"));
                r.setTotalCost(rs.getDouble("total_cost"));
                r.setStatus(rs.getString("status"));
                r.setCollectionDate(rs.getDate("collection_date"));
                r.setAssignedTime(rs.getString("assigned_time"));
                r.setNotes(rs.getString("notes"));
                return r;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}