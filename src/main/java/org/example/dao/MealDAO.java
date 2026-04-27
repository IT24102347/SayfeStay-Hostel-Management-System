package org.example.dao;

import org.example.model.DailyMenu;
import org.example.model.MealEnrollment;
import org.example.model.MealOrder;
import org.example.model.MealPlan;

import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MealDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HostelManagementDB;encrypt=true;trustServerCertificate=true";
        String dbUser = "sa";
        String dbPass = "Japan@123*";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    public List<DailyMenu> getTodaysMenu() {
        List<DailyMenu> list = new ArrayList<>();
        String sql = "SELECT * FROM daily_menu WHERE menu_date = CAST(GETDATE() AS DATE) ORDER BY " +
                "CASE meal_type WHEN 'Breakfast' THEN 1 WHEN 'Lunch' THEN 2 WHEN 'Dinner' THEN 3 WHEN 'Tea' THEN 4 ELSE 5 END, id DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                list.add(mapDailyMenu(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public DailyMenu getMenuItemById(int id) {
        String sql = "SELECT * FROM daily_menu WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, id);
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return mapDailyMenu(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addMenuItem(DailyMenu menu) {
        String sql = "INSERT INTO daily_menu " +
                "(menu_date, meal_type, item_name, description, price, is_available, prepared_by, created_at, updated_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setDate(1, new Date(menu.getMenuDate().getTime()));
            pst.setString(2, menu.getMealType());
            pst.setString(3, menu.getItemName());
            pst.setString(4, menu.getDescription() == null ? "" : menu.getDescription());
            pst.setDouble(5, menu.getPrice());
            pst.setBoolean(6, menu.isAvailable());
            pst.setString(7, menu.getPreparedBy());

            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateMenuItem(DailyMenu menu) {
        String sql = "UPDATE daily_menu SET menu_date = ?, meal_type = ?, item_name = ?, description = ?, " +
                "price = ?, is_available = ?, prepared_by = ?, updated_at = GETDATE() WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setDate(1, new Date(menu.getMenuDate().getTime()));
            pst.setString(2, menu.getMealType());
            pst.setString(3, menu.getItemName());
            pst.setString(4, menu.getDescription() == null ? "" : menu.getDescription());
            pst.setDouble(5, menu.getPrice());
            pst.setBoolean(6, menu.isAvailable());
            pst.setString(7, menu.getPreparedBy());
            pst.setInt(8, menu.getId());

            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteMenuItem(int id) {
        String sql = "DELETE FROM daily_menu WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setInt(1, id);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<MealPlan> getAllMealPlans() {
        List<MealPlan> list = new ArrayList<>();
        String sql = "SELECT * FROM meal_plans WHERE is_active = 1 ORDER BY weekly_price ASC, id ASC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                MealPlan plan = new MealPlan();
                plan.setId(rs.getInt("id"));
                plan.setPlanName(rs.getString("plan_name"));
                plan.setDescription(rs.getString("description"));
                plan.setMealsPerDay(rs.getInt("meals_per_day"));
                plan.setWeeklyPrice(rs.getDouble("weekly_price"));
                plan.setActive(rs.getBoolean("is_active"));
                plan.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(plan);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public MealPlan getStudentEnrollment(String studentId) {
        String sql = "SELECT TOP 1 mp.* " +
                "FROM meal_enrollments me " +
                "JOIN meal_plans mp ON me.plan_id = mp.id " +
                "WHERE me.studentId = ? AND me.is_active = 1 " +
                "ORDER BY me.id DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    MealPlan plan = new MealPlan();
                    plan.setId(rs.getInt("id"));
                    plan.setPlanName(rs.getString("plan_name"));
                    plan.setDescription(rs.getString("description"));
                    plan.setMealsPerDay(rs.getInt("meals_per_day"));
                    plan.setWeeklyPrice(rs.getDouble("weekly_price"));
                    plan.setActive(rs.getBoolean("is_active"));
                    plan.setCreatedAt(rs.getTimestamp("created_at"));
                    return plan;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean enrollInPlan(String studentId, int planId, double weeklyCost) {
        Connection con = null;

        try {
            con = getConnection();
            con.setAutoCommit(false);

            try (PreparedStatement pst1 = con.prepareStatement(
                    "UPDATE meal_enrollments SET is_active = 0, updated_at = GETDATE() WHERE studentId = ? AND is_active = 1")) {
                pst1.setString(1, studentId);
                pst1.executeUpdate();
            }

            try (PreparedStatement pst2 = con.prepareStatement(
                    "INSERT INTO meal_enrollments " +
                            "(studentId, plan_id, start_date, weekly_cost, is_active, created_at, updated_at) " +
                            "VALUES (?, ?, CAST(GETDATE() AS DATE), ?, 1, GETDATE(), GETDATE())")) {
                pst2.setString(1, studentId);
                pst2.setInt(2, planId);
                pst2.setDouble(3, weeklyCost);
                pst2.executeUpdate();
            }

            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ignored) {
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    public String generateOrderNo() {
        return "ORD" + System.currentTimeMillis();
    }

    public boolean placeOrder(String studentId, int menuId) {
        DailyMenu menu = getMenuItemById(menuId);
        if (menu == null || !menu.isAvailable()) {
            return false;
        }

        String sql = "INSERT INTO meal_orders " +
                "(order_no, studentId, meal_date, meal_type, item_name, quantity, price, status, ordered_at) " +
                "VALUES (?, ?, CAST(GETDATE() AS DATE), ?, ?, 1, ?, 'Pending', GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, generateOrderNo());
            pst.setString(2, studentId);
            pst.setString(3, menu.getMealType());
            pst.setString(4, menu.getItemName());
            pst.setDouble(5, menu.getPrice());

            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<MealOrder> getStudentOrders(String studentId) {
        List<MealOrder> list = new ArrayList<>();
        String sql = "SELECT * FROM meal_orders WHERE studentId = ? ORDER BY ordered_at DESC, id DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, studentId);

            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMealOrder(rs, null));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<MealOrder> getTodaysOrders() {
        List<MealOrder> list = new ArrayList<>();
        String sql = "SELECT mo.*, sd.fullName AS studentName " +
                "FROM meal_orders mo " +
                "LEFT JOIN student_details sd ON mo.studentId = sd.userId " +
                "WHERE mo.meal_date = CAST(GETDATE() AS DATE) " +
                "ORDER BY mo.ordered_at DESC, mo.id DESC";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                list.add(mapMealOrder(rs, rs.getString("studentName")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean updateOrderStatus(int orderId, String status, String staffId) {
        String sql;
        if ("Served".equalsIgnoreCase(status)) {
            sql = "UPDATE meal_orders SET status = ?, prepared_by = ?, served_at = GETDATE() WHERE id = ?";
        } else {
            sql = "UPDATE meal_orders SET status = ?, prepared_by = ? WHERE id = ?";
        }

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, status);
            pst.setString(2, staffId);
            pst.setInt(3, orderId);

            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cancelOrder(int orderId, String studentId) {
        String sql = "UPDATE meal_orders SET status = 'Cancelled' WHERE id = ? AND studentId = ? AND status = 'Pending'";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, orderId);
            pst.setString(2, studentId);

            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Map<String, Integer> getOrderStatistics(Date date) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("Pending", 0);
        stats.put("Prepared", 0);
        stats.put("Served", 0);
        stats.put("Cancelled", 0);

        String sql = "SELECT status, COUNT(*) AS cnt FROM meal_orders WHERE meal_date = ? GROUP BY status";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setDate(1, date);

            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    stats.put(rs.getString("status"), rs.getInt("cnt"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return stats;
    }

    public int getTodaysMenuCount() {
        String sql = "SELECT COUNT(*) FROM daily_menu WHERE menu_date = CAST(GETDATE() AS DATE)";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<MealEnrollment> getAllActiveEnrollments() {
        return new ArrayList<>();
    }

    private DailyMenu mapDailyMenu(ResultSet rs) throws SQLException {
        DailyMenu menu = new DailyMenu();
        menu.setId(rs.getInt("id"));
        menu.setMenuDate(rs.getDate("menu_date"));
        menu.setMealType(rs.getString("meal_type"));
        menu.setItemName(rs.getString("item_name"));
        menu.setDescription(rs.getString("description"));
        menu.setPrice(rs.getDouble("price"));
        menu.setAvailable(rs.getBoolean("is_available"));
        menu.setPreparedBy(rs.getString("prepared_by"));
        menu.setCreatedAt(rs.getTimestamp("created_at"));
        menu.setUpdatedAt(rs.getTimestamp("updated_at"));
        return menu;
    }

    private MealOrder mapMealOrder(ResultSet rs, String studentName) throws SQLException {
        MealOrder order = new MealOrder();
        order.setId(rs.getInt("id"));
        order.setOrderNo(rs.getString("order_no"));
        order.setStudentId(rs.getString("studentId"));
        order.setStudentName(studentName != null ? studentName : rs.getString("studentId"));
        order.setMealDate(rs.getDate("meal_date"));
        order.setMealType(rs.getString("meal_type"));
        order.setSelectedSummary(rs.getString("item_name"));
        order.setTotalPrice(rs.getDouble("price"));
        order.setStatus(rs.getString("status"));
        order.setOrderedAt(rs.getTimestamp("ordered_at"));

        Timestamp updated = null;
        try {
            updated = rs.getTimestamp("served_at");
        } catch (SQLException ignored) {
        }
        if (updated == null) {
            updated = rs.getTimestamp("ordered_at");
        }
        order.setUpdatedAt(updated);

        return order;
    }
}