package org.example.servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.example.dao.AdvancedMealDAO;
import org.example.dao.MealNotificationDAO;
import org.example.model.AdvancedMealColumn;
import org.example.model.AdvancedMealColumnPart;
import org.example.model.AdvancedMealOrder;
import org.example.model.AdvancedMealOrderItem;
import org.example.model.AdvancedMealSection;
import org.example.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.*;

@WebServlet("/student/meal/*")
public class MealServlet extends HttpServlet {

    private AdvancedMealDAO dao;
    private MealNotificationDAO notificationDAO;
    private Gson gson;

    @Override
    public void init() {
        dao = new AdvancedMealDAO();
        notificationDAO = new MealNotificationDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss").create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = getStudentUser(request, response);
        if (user == null) return;

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || "/".equals(pathInfo) || "/dashboard".equals(pathInfo)) {
            request.getRequestDispatcher("/dashboard/student/meal-dashboard.jsp").forward(request, response);
            return;
        }
        if ("/layout".equals(pathInfo)) {
            response.setContentType("application/json");
            response.getWriter().write(gson.toJson(buildLayoutResponse()));
            return;
        }
        if ("/orders".equals(pathInfo)) {
            response.setContentType("application/json");
            response.getWriter().write(gson.toJson(buildStudentOrdersResponse(user.getUserId())));
            return;
        }
        if ("/notifications".equals(pathInfo)) {
            response.setContentType("application/json");
            notificationDAO.markAllAsViewedByStudent(user.getUserId());
            response.getWriter().write(gson.toJson(notificationDAO.getAllNotificationsForStudent(user.getUserId())));
            return;
        }
        response.sendRedirect(request.getContextPath() + "/student/meal/dashboard");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = getStudentUser(request, response);
        if (user == null) return;

        response.setContentType("application/json");
        String action = request.getParameter("action");
        try {
            if ("place".equals(action)) {
                handlePlace(request, response, user);
                return;
            }
            if ("edit".equals(action)) {
                handleEdit(request, response, user);
                return;
            }
            if ("delete".equals(action)) {
                handleDelete(request, response, user);
                return;
            }
            response.getWriter().write("{\"success\":false,\"message\":\"Unknown action.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() == null ? "Invalid meal request." : e.getMessage().replace("\"", "'");
            response.getWriter().write("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
    }

    private void handlePlace(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        int sectionId = parsePositiveInt(request.getParameter("sectionId"), "Invalid meal section.");
        List<Integer> selectedColumnIds = parseIdList(request.getParameter("selectedColumnIds"));

        AdvancedMealSection section = dao.getSectionById(sectionId);
        if (section == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Meal section not found.\"}");
            return;
        }
        if (isExpired(section.getOrderBefore())) {
            response.getWriter().write("{\"success\":false,\"message\":\"Deadline passed. Cannot order now.\"}");
            return;
        }

        OrderBuildResult result = buildOrderItemsFromSection(section, selectedColumnIds);
        if (result.items.isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Select at least one column.\"}");
            return;
        }

        AdvancedMealOrder order = new AdvancedMealOrder();
        order.setOrderNo(dao.generateOrderNo());
        order.setSectionId(section.getId());
        order.setStudentId(user.getUserId());
        order.setMealDate(section.getMealDate());
        order.setMealType(section.getMealType());
        order.setSelectedSummary(result.summary);
        order.setTotalPrice(result.totalPrice);
        order.setStatus("Pending");
        order.setOrderItems(result.items);

        boolean ok = dao.placeAdvancedOrder(order);
        response.getWriter().write(ok ? "{\"success\":true}" : "{\"success\":false,\"message\":\"Could not place order.\"}");
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        int orderId = parsePositiveInt(request.getParameter("orderId"), "Invalid order ID.");
        List<Integer> selectedColumnIds = parseIdList(request.getParameter("selectedColumnIds"));

        AdvancedMealOrder existingOrder = dao.getAdvancedOrderByIdForStudent(orderId, user.getUserId());
        if (existingOrder == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Order not found.\"}");
            return;
        }
        if (!"Pending".equalsIgnoreCase(existingOrder.getStatus())) {
            response.getWriter().write("{\"success\":false,\"message\":\"Only pending orders can be edited.\"}");
            return;
        }

        AdvancedMealSection section = dao.getSectionById(existingOrder.getSectionId());
        if (section == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Meal section not found.\"}");
            return;
        }
        if (isExpired(section.getOrderBefore())) {
            response.getWriter().write("{\"success\":false,\"message\":\"Deadline passed. Cannot edit.\"}");
            return;
        }

        OrderBuildResult result = buildOrderItemsFromSection(section, selectedColumnIds);
        if (result.items.isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Select at least one column.\"}");
            return;
        }

        boolean ok = dao.replaceAdvancedOrder(orderId, user.getUserId(), result.summary, result.totalPrice, result.items);
        response.getWriter().write(ok ? "{\"success\":true}" : "{\"success\":false,\"message\":\"Could not update order.\"}");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        int orderId = parsePositiveInt(request.getParameter("orderId"), "Invalid order ID.");
        AdvancedMealOrder existingOrder = dao.getAdvancedOrderByIdForStudent(orderId, user.getUserId());
        if (existingOrder == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Order not found.\"}");
            return;
        }
        AdvancedMealSection section = dao.getSectionById(existingOrder.getSectionId());
        if (section == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Meal section not found.\"}");
            return;
        }
        if (isExpired(section.getOrderBefore())) {
            response.getWriter().write("{\"success\":false,\"message\":\"Deadline passed. Cannot delete.\"}");
            return;
        }
        boolean ok = dao.cancelAdvancedOrder(orderId, user.getUserId());
        response.getWriter().write(ok ? "{\"success\":true}" : "{\"success\":false,\"message\":\"Could not delete order.\"}");
    }

    private User getStudentUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (!"Student".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return null;
        }
        return user;
    }

    private Map<String, Object> buildLayoutResponse() {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("Breakfast", buildEmptySection());
        result.put("Lunch", buildEmptySection());
        result.put("Dinner", buildEmptySection());
        result.put("Tea", buildEmptySection());

        Map<String, AdvancedMealSection> sectionMap = dao.getSectionMapByDate(java.sql.Date.valueOf(LocalDate.now()));
        for (String mealType : sectionMap.keySet()) {
            AdvancedMealSection section = sectionMap.get(mealType);
            if (section != null) result.put(mealType, convertSection(section));
        }
        return result;
    }

    private Map<String, Object> buildEmptySection() {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("sectionId", 0);
        map.put("orderBefore", "");
        map.put("columns", new ArrayList<>());
        return map;
    }

    private Map<String, Object> convertSection(AdvancedMealSection section) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("sectionId", section.getId());
        map.put("orderBefore", toDateTimeString(section.getOrderBefore()));
        List<Map<String, Object>> columns = new ArrayList<>();

        if (section.getColumns() != null) {
            for (AdvancedMealColumn col : section.getColumns()) {
                Map<String, Object> colMap = new LinkedHashMap<>();
                colMap.put("id", col.getId());
                colMap.put("columnNo", col.getColumnNo());
                colMap.put("type", col.isSplitColumn() ? "split" : "normal");
                colMap.put("name", col.isSplitColumn() ? "" : col.getItemName());
                colMap.put("imageData", col.isSplitColumn() ? "" : col.getImagePath());
                colMap.put("price", col.getPrice());

                List<Map<String, Object>> parts = new ArrayList<>();
                if (col.getParts() != null) {
                    for (AdvancedMealColumnPart part : col.getParts()) {
                        Map<String, Object> partMap = new LinkedHashMap<>();
                        partMap.put("name", part.getPartName());
                        partMap.put("imageData", part.getImagePath());
                        parts.add(partMap);
                    }
                }
                colMap.put("parts", parts);
                columns.add(colMap);
            }
        }
        map.put("columns", columns);
        return map;
    }

    private List<Map<String, Object>> buildStudentOrdersResponse(String studentId) {
        List<Map<String, Object>> response = new ArrayList<>();
        List<AdvancedMealOrder> orders = dao.getStudentAdvancedOrders(studentId);

        for (AdvancedMealOrder order : orders) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id", order.getId());
            row.put("mealType", order.getMealType());
            row.put("orderedItems", order.getSelectedSummary());
            row.put("totalPrice", order.getTotalPrice());
            row.put("orderedAt", toDateTimeString(order.getOrderedAt()));

            AdvancedMealSection section = dao.getSectionById(order.getSectionId());
            row.put("orderBefore", section != null ? toDateTimeString(section.getOrderBefore()) : "");

            List<Integer> selectedColumnIds = new ArrayList<>();
            if (order.getOrderItems() != null) {
                for (AdvancedMealOrderItem item : order.getOrderItems()) {
                    selectedColumnIds.add(item.getColumnId());
                }
            }

            row.put("selectedColumnIds", selectedColumnIds);
            row.put("sectionId", order.getSectionId());
            response.add(row);
        }
        return response;
    }

    private OrderBuildResult buildOrderItemsFromSection(AdvancedMealSection section, List<Integer> selectedColumnIds) {
        OrderBuildResult result = new OrderBuildResult();
        if (section.getColumns() == null) return result;

        List<String> labels = new ArrayList<>();
        for (AdvancedMealColumn col : section.getColumns()) {
            if (!selectedColumnIds.contains(col.getId())) continue;

            AdvancedMealOrderItem item = new AdvancedMealOrderItem();
            item.setColumnId(col.getId());
            item.setColumnNo(col.getColumnNo());
            item.setPrice(col.getPrice());

            String label;
            if (col.isSplitColumn()) {
                List<String> names = new ArrayList<>();
                if (col.getParts() != null) {
                    for (AdvancedMealColumnPart part : col.getParts()) {
                        if (part.getPartName() != null && !part.getPartName().trim().isEmpty()) {
                            names.add(part.getPartName().trim());
                        }
                    }
                }
                label = names.isEmpty() ? "Split Column" : String.join(", ", names);
            } else {
                label = (col.getItemName() == null || col.getItemName().trim().isEmpty()) ? "Meal Item" : col.getItemName().trim();
            }

            item.setItemLabel(label);
            result.items.add(item);
            labels.add(label);
            result.totalPrice += col.getPrice();
        }
        result.summary = String.join(" | ", labels);
        return result;
    }

    private List<Integer> parseIdList(String text) {
        List<Integer> ids = new ArrayList<>();
        if (text == null || text.trim().isEmpty()) return ids;
        for (String part : text.split(",")) {
            String s = part.trim();
            if (s.isEmpty()) continue;
            try {
                int id = Integer.parseInt(s);
                if (id > 0) ids.add(id);
            } catch (NumberFormatException ignored) {
            }
        }
        return ids;
    }

    private int parsePositiveInt(String value, String message) {
        try {
            int parsed = Integer.parseInt(value);
            if (parsed <= 0) throw new NumberFormatException();
            return parsed;
        } catch (Exception e) {
            throw new IllegalArgumentException(message);
        }
    }

    private boolean isExpired(Date deadline) {
        return deadline != null && new Date().after(deadline);
    }

    private String toDateTimeString(Date date) {
        return date == null ? "" : new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date);
    }

    private static class OrderBuildResult {
        List<AdvancedMealOrderItem> items = new ArrayList<>();
        String summary = "";
        double totalPrice = 0.0;
    }
}