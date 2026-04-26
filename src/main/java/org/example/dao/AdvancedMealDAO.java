package org.example.dao;

import org.example.DBConnection;
import org.example.model.AdvancedMealColumn;
import org.example.model.AdvancedMealColumnPart;
import org.example.model.AdvancedMealOrder;
import org.example.model.AdvancedMealOrderItem;
import org.example.model.AdvancedMealSection;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AdvancedMealDAO {

    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    public String generateOrderNo() {
        return "AORD" + System.currentTimeMillis();
    }

    public AdvancedMealSection getSectionById(int sectionId) {
        String sql = "SELECT * FROM advanced_meal_sections WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, sectionId);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    AdvancedMealSection section = mapSection(rs);
                    section.setColumns(getColumnsBySectionId(sectionId, con));
                    return section;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public AdvancedMealOrder getAdvancedOrderByIdForStudent(int orderId, String studentId) {
        String sql = "SELECT * FROM advanced_meal_orders WHERE id = ? AND studentId = ?";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, orderId);
            pst.setString(2, studentId);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    AdvancedMealOrder order = mapAdvancedOrder(rs);
                    order.setOrderItems(getOrderItemsByOrderId(order.getId(), con));
                    return order;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<AdvancedMealSection> getSectionsByDate(java.util.Date mealDate) {
        List<AdvancedMealSection> list = new ArrayList<>();
        String sql = "SELECT * FROM advanced_meal_sections WHERE meal_date = ? AND is_active = 1 ORDER BY CASE meal_type WHEN 'Breakfast' THEN 1 WHEN 'Lunch' THEN 2 WHEN 'Dinner' THEN 3 WHEN 'Tea' THEN 4 ELSE 5 END";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setDate(1, new java.sql.Date(mealDate.getTime()));

            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    AdvancedMealSection section = mapSection(rs);
                    section.setColumns(getColumnsBySectionId(section.getId(), con));
                    list.add(section);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public Map<String, AdvancedMealSection> getSectionMapByDate(java.util.Date mealDate) {
        Map<String, AdvancedMealSection> map = new LinkedHashMap<>();
        map.put("Breakfast", null);
        map.put("Lunch", null);
        map.put("Dinner", null);
        map.put("Tea", null);
        for (AdvancedMealSection section : getSectionsByDate(mealDate)) {
            map.put(section.getMealType(), section);
        }
        return map;
    }

    public boolean saveOrReplaceSection(AdvancedMealSection section) {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);

            Integer existingId = findExistingSectionId(section, con);
            int sectionId;
            if (existingId != null) {
                if (sectionHasOrders(existingId, con)) {
                    throw new RuntimeException("This meal category already has orders for today. Use Reset first if you want to clear it.");
                }
                updateSection(section, existingId, con);
                deleteColumnsBySectionId(existingId, con);
                sectionId = existingId;
            } else {
                sectionId = insertSection(section, con);
            }

            if (section.getColumns() != null) {
                int colNo = 1;
                for (AdvancedMealColumn column : section.getColumns()) {
                    column.setColumnNo(colNo++);
                    int columnId = insertColumn(sectionId, column, con);
                    if (column.isSplitColumn() && column.getParts() != null) {
                        int partNo = 1;
                        for (AdvancedMealColumnPart part : column.getParts()) {
                            part.setPartNo(partNo++);
                            insertColumnPart(columnId, part, con);
                        }
                    }
                }
            }

            con.commit();
            return true;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignored) {}
            }
            e.printStackTrace();
            throw new RuntimeException("Advanced meal save failed: " + e.getMessage(), e);
        } finally {
            if (con != null) {
                try { con.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public boolean resetTodayData() {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);
            try (PreparedStatement pst = con.prepareStatement(
                    "UPDATE advanced_meal_sections SET is_active = 0, updated_at = GETDATE() WHERE meal_date = CAST(GETDATE() AS DATE)")) {
                pst.executeUpdate();
            }
            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) { try { con.rollback(); } catch (SQLException ignored) {} }
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) { try { con.close(); } catch (SQLException ignored) {} }
        }
    }

    private boolean sectionHasOrders(int sectionId, Connection con) throws SQLException {
        try (PreparedStatement pst = con.prepareStatement("SELECT COUNT(*) FROM advanced_meal_orders WHERE section_id = ?")) {
            pst.setInt(1, sectionId);
            try (ResultSet rs = pst.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private Integer findExistingSectionId(AdvancedMealSection section, Connection con) throws SQLException {
        String sql = "SELECT id FROM advanced_meal_sections WHERE meal_date = ? AND meal_type = ?";
        try (PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setDate(1, new java.sql.Date(section.getMealDate().getTime()));
            pst.setString(2, section.getMealType());
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        }
        return null;
    }

    private int insertSection(AdvancedMealSection section, Connection con) throws SQLException {
        String sql = "INSERT INTO advanced_meal_sections (meal_date, meal_type, order_before, created_by, created_at, updated_at, is_active) VALUES (?, ?, ?, ?, GETDATE(), GETDATE(), 1)";
        try (PreparedStatement pst = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pst.setDate(1, new java.sql.Date(section.getMealDate().getTime()));
            pst.setString(2, section.getMealType());
            pst.setTimestamp(3, new Timestamp(section.getOrderBefore().getTime()));
            pst.setString(4, section.getCreatedBy());
            pst.executeUpdate();
            try (ResultSet rs = pst.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("Failed to insert advanced meal section.");
    }

    private void updateSection(AdvancedMealSection section, int sectionId, Connection con) throws SQLException {
        String sql = "UPDATE advanced_meal_sections SET meal_date=?, meal_type=?, order_before=?, created_by=?, updated_at=GETDATE(), is_active=1 WHERE id=?";
        try (PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setDate(1, new java.sql.Date(section.getMealDate().getTime()));
            pst.setString(2, section.getMealType());
            pst.setTimestamp(3, new Timestamp(section.getOrderBefore().getTime()));
            pst.setString(4, section.getCreatedBy());
            pst.setInt(5, sectionId);
            pst.executeUpdate();
        }
    }

    private int insertColumn(int sectionId, AdvancedMealColumn column, Connection con) throws SQLException {
        String sql = "INSERT INTO advanced_meal_columns (section_id, column_no, column_type, item_name, image_path, price, is_available, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (PreparedStatement pst = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pst.setInt(1, sectionId);
            pst.setInt(2, column.getColumnNo());
            pst.setString(3, column.getColumnType() == null ? "NORMAL" : column.getColumnType().toUpperCase());
            String itemName = column.getItemName();
            if (itemName == null || itemName.trim().isEmpty()) itemName = column.isSplitColumn() ? "Split Column" : "Meal Item";
            pst.setString(4, itemName);
            String imagePath = column.getImagePath();
            if (imagePath != null && imagePath.trim().isEmpty()) imagePath = null;
            pst.setString(5, imagePath);
            pst.setDouble(6, column.getPrice());
            pst.setBoolean(7, column.isAvailable());
            pst.executeUpdate();
            try (ResultSet rs = pst.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("Failed to insert advanced meal column.");
    }

    private void insertColumnPart(int columnId, AdvancedMealColumnPart part, Connection con) throws SQLException {
        String sql = "INSERT INTO advanced_meal_column_parts (column_id, part_no, part_name, image_path, created_at, updated_at) VALUES (?, ?, ?, ?, GETDATE(), GETDATE())";
        try (PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, columnId);
            pst.setInt(2, part.getPartNo());
            String partName = part.getPartName();
            if (partName == null || partName.trim().isEmpty()) partName = "Part " + part.getPartNo();
            pst.setString(3, partName);
            String imagePath = part.getImagePath();
            if (imagePath != null && imagePath.trim().isEmpty()) imagePath = null;
            pst.setString(4, imagePath);
            pst.executeUpdate();
        }
    }

    private void deleteColumnsBySectionId(int sectionId, Connection con) throws SQLException {
        try (PreparedStatement pst = con.prepareStatement("DELETE FROM advanced_meal_columns WHERE section_id = ?")) {
            pst.setInt(1, sectionId);
            pst.executeUpdate();
        }
    }

    private List<AdvancedMealColumn> getColumnsBySectionId(int sectionId, Connection con) throws SQLException {
        List<AdvancedMealColumn> list = new ArrayList<>();
        try (PreparedStatement pst = con.prepareStatement("SELECT * FROM advanced_meal_columns WHERE section_id = ? ORDER BY column_no ASC")) {
            pst.setInt(1, sectionId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    AdvancedMealColumn column = mapColumn(rs);
                    if (column.isSplitColumn()) column.setParts(getPartsByColumnId(column.getId(), con));
                    list.add(column);
                }
            }
        }
        return list;
    }

    private List<AdvancedMealColumnPart> getPartsByColumnId(int columnId, Connection con) throws SQLException {
        List<AdvancedMealColumnPart> list = new ArrayList<>();
        try (PreparedStatement pst = con.prepareStatement("SELECT * FROM advanced_meal_column_parts WHERE column_id = ? ORDER BY part_no ASC")) {
            pst.setInt(1, columnId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) list.add(mapColumnPart(rs));
            }
        }
        return list;
    }

    public boolean placeAdvancedOrder(AdvancedMealOrder order) {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);
            int orderId = insertAdvancedOrder(order, con);
            if (order.getOrderItems() != null) {
                for (AdvancedMealOrderItem item : order.getOrderItems()) insertAdvancedOrderItem(orderId, item, con);
            }
            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) { try { con.rollback(); } catch (SQLException ignored) {} }
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) { try { con.close(); } catch (SQLException ignored) {} }
        }
    }

    private int insertAdvancedOrder(AdvancedMealOrder order, Connection con) throws SQLException {
        String sql = "INSERT INTO advanced_meal_orders (order_no, section_id, studentId, meal_date, meal_type, selected_summary, total_price, status, ordered_at, updated_at, prepared_by, served_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE(), ?, ?)";
        try (PreparedStatement pst = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pst.setString(1, order.getOrderNo());
            pst.setInt(2, order.getSectionId());
            pst.setString(3, order.getStudentId());
            pst.setDate(4, new java.sql.Date(order.getMealDate().getTime()));
            pst.setString(5, order.getMealType());
            pst.setString(6, order.getSelectedSummary());
            pst.setDouble(7, order.getTotalPrice());
            pst.setString(8, order.getStatus());
            if (order.getPreparedBy() == null || order.getPreparedBy().trim().isEmpty()) pst.setNull(9, Types.VARCHAR); else pst.setString(9, order.getPreparedBy());
            if (order.getServedAt() == null) pst.setNull(10, Types.TIMESTAMP); else pst.setTimestamp(10, new Timestamp(order.getServedAt().getTime()));
            pst.executeUpdate();
            try (ResultSet rs = pst.getGeneratedKeys()) { if (rs.next()) return rs.getInt(1); }
        }
        throw new SQLException("Failed to insert advanced meal order.");
    }

    private void insertAdvancedOrderItem(int orderId, AdvancedMealOrderItem item, Connection con) throws SQLException {
        try (PreparedStatement pst = con.prepareStatement("INSERT INTO advanced_meal_order_items (order_id, column_id, column_no, item_label, price) VALUES (?, ?, ?, ?, ?)")) {
            pst.setInt(1, orderId);
            pst.setInt(2, item.getColumnId());
            pst.setInt(3, item.getColumnNo());
            pst.setString(4, item.getItemLabel());
            pst.setDouble(5, item.getPrice());
            pst.executeUpdate();
        }
    }

    public List<AdvancedMealOrder> getStudentAdvancedOrders(String studentId) {
        List<AdvancedMealOrder> list = new ArrayList<>();
        String sql = "SELECT * FROM advanced_meal_orders WHERE studentId = ? ORDER BY ordered_at DESC, id DESC";
        try (Connection con = getConnection(); PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, studentId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    AdvancedMealOrder order = mapAdvancedOrder(rs);
                    order.setOrderItems(getOrderItemsByOrderId(order.getId(), con));
                    list.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<AdvancedMealOrderItem> getOrderItemsByOrderId(int orderId, Connection con) throws SQLException {
        List<AdvancedMealOrderItem> list = new ArrayList<>();
        try (PreparedStatement pst = con.prepareStatement("SELECT * FROM advanced_meal_order_items WHERE order_id = ? ORDER BY column_no ASC")) {
            pst.setInt(1, orderId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) list.add(mapAdvancedOrderItem(rs));
            }
        }
        return list;
    }

    public boolean updateAdvancedOrderStatus(int orderId, String status, String staffId) {
        String sql = "Served".equalsIgnoreCase(status)
                ? "UPDATE advanced_meal_orders SET status=?, prepared_by=?, served_at=GETDATE(), updated_at=GETDATE() WHERE id=?"
                : "UPDATE advanced_meal_orders SET status=?, prepared_by=?, updated_at=GETDATE() WHERE id=?";
        try (Connection con = getConnection(); PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, status);
            pst.setString(2, staffId);
            pst.setInt(3, orderId);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cancelAdvancedOrder(int orderId, String studentId) {
        String sql = "DELETE FROM advanced_meal_orders WHERE id = ? AND studentId = ? AND status = 'Pending'";
        try (Connection con = getConnection(); PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, orderId);
            pst.setString(2, studentId);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean replaceAdvancedOrder(int orderId, String studentId, String selectedSummary, double totalPrice, List<AdvancedMealOrderItem> items) {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);
            try (PreparedStatement pst = con.prepareStatement("UPDATE advanced_meal_orders SET selected_summary=?, total_price=?, updated_at=GETDATE() WHERE id=? AND studentId=? AND status='Pending'")) {
                pst.setString(1, selectedSummary);
                pst.setDouble(2, totalPrice);
                pst.setInt(3, orderId);
                pst.setString(4, studentId);
                if (pst.executeUpdate() <= 0) { con.rollback(); return false; }
            }
            try (PreparedStatement pst = con.prepareStatement("DELETE FROM advanced_meal_order_items WHERE order_id = ?")) {
                pst.setInt(1, orderId);
                pst.executeUpdate();
            }
            if (items != null) {
                for (AdvancedMealOrderItem item : items) insertAdvancedOrderItem(orderId, item, con);
            }
            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) { try { con.rollback(); } catch (SQLException ignored) {} }
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) { try { con.close(); } catch (SQLException ignored) {} }
        }
    }

    public List<AdvancedMealOrder> getTodayOrdersByMealType(String mealType) {
        List<AdvancedMealOrder> list = new ArrayList<>();
        String sql = "SELECT amo.*, sd.fullName AS studentName FROM advanced_meal_orders amo INNER JOIN advanced_meal_sections ams ON amo.section_id = ams.id AND ams.is_active = 1 LEFT JOIN student_details sd ON amo.studentId = sd.userId WHERE ams.meal_date = CAST(GETDATE() AS DATE) AND amo.meal_type = ? ORDER BY amo.ordered_at DESC, amo.id DESC";
        try (Connection con = getConnection(); PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, mealType);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    AdvancedMealOrder order = mapAdvancedOrder(rs);
                    order.setStudentName(rs.getString("studentName"));
                    order.setOrderItems(getOrderItemsByOrderId(order.getId(), con));
                    list.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private AdvancedMealSection mapSection(ResultSet rs) throws SQLException {
        AdvancedMealSection section = new AdvancedMealSection();
        section.setId(rs.getInt("id"));
        section.setMealDate(rs.getDate("meal_date"));
        section.setMealType(rs.getString("meal_type"));
        section.setOrderBefore(rs.getTimestamp("order_before"));
        section.setCreatedBy(rs.getString("created_by"));
        section.setCreatedAt(rs.getTimestamp("created_at"));
        section.setUpdatedAt(rs.getTimestamp("updated_at"));
        section.setActive(rs.getBoolean("is_active"));
        return section;
    }

    private AdvancedMealColumn mapColumn(ResultSet rs) throws SQLException {
        AdvancedMealColumn column = new AdvancedMealColumn();
        column.setId(rs.getInt("id"));
        column.setSectionId(rs.getInt("section_id"));
        column.setColumnNo(rs.getInt("column_no"));
        column.setColumnType(rs.getString("column_type"));
        column.setItemName(rs.getString("item_name"));
        column.setImagePath(rs.getString("image_path"));
        column.setPrice(rs.getDouble("price"));
        column.setAvailable(rs.getBoolean("is_available"));
        column.setCreatedAt(rs.getTimestamp("created_at"));
        column.setUpdatedAt(rs.getTimestamp("updated_at"));
        return column;
    }

    private AdvancedMealColumnPart mapColumnPart(ResultSet rs) throws SQLException {
        AdvancedMealColumnPart part = new AdvancedMealColumnPart();
        part.setId(rs.getInt("id"));
        part.setColumnId(rs.getInt("column_id"));
        part.setPartNo(rs.getInt("part_no"));
        part.setPartName(rs.getString("part_name"));
        part.setImagePath(rs.getString("image_path"));
        part.setCreatedAt(rs.getTimestamp("created_at"));
        part.setUpdatedAt(rs.getTimestamp("updated_at"));
        return part;
    }

    private AdvancedMealOrder mapAdvancedOrder(ResultSet rs) throws SQLException {
        AdvancedMealOrder order = new AdvancedMealOrder();
        order.setId(rs.getInt("id"));
        order.setOrderNo(rs.getString("order_no"));
        order.setSectionId(rs.getInt("section_id"));
        order.setStudentId(rs.getString("studentId"));
        order.setMealDate(rs.getDate("meal_date"));
        order.setMealType(rs.getString("meal_type"));
        order.setSelectedSummary(rs.getString("selected_summary"));
        order.setTotalPrice(rs.getDouble("total_price"));
        order.setStatus(rs.getString("status"));
        order.setOrderedAt(rs.getTimestamp("ordered_at"));
        order.setUpdatedAt(rs.getTimestamp("updated_at"));
        order.setPreparedBy(rs.getString("prepared_by"));
        order.setServedAt(rs.getTimestamp("served_at"));
        return order;
    }

    private AdvancedMealOrderItem mapAdvancedOrderItem(ResultSet rs) throws SQLException {
        AdvancedMealOrderItem item = new AdvancedMealOrderItem();
        item.setId(rs.getInt("id"));
        item.setOrderId(rs.getInt("order_id"));
        item.setColumnId(rs.getInt("column_id"));
        item.setColumnNo(rs.getInt("column_no"));
        item.setItemLabel(rs.getString("item_label"));
        item.setPrice(rs.getDouble("price"));
        return item;
    }
}
