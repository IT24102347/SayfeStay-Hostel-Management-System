package org.example.servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.example.dao.AdvancedMealDAO;
import org.example.dao.MealNotificationDAO;
import org.example.model.AdvancedMealColumn;
import org.example.model.AdvancedMealColumnPart;
import org.example.model.AdvancedMealSection;
import org.example.model.MealNotification;
import org.example.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.*;

@WebServlet("/kitchen/advanced-meal/*")
public class KitchenAdvancedMealServlet extends HttpServlet {

    private AdvancedMealDAO dao;
    private MealNotificationDAO notificationDAO;
    private Gson gson;
    private static final Set<String> ALLOWED_MEAL_TYPES =
            new HashSet<>(Arrays.asList("Breakfast", "Lunch", "Dinner", "Tea"));

    @Override
    public void init() {
        dao = new AdvancedMealDAO();
        notificationDAO = new MealNotificationDAO();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss").create();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getPathInfo();
        if ("/save-layout".equals(path)) {
            saveLayout(request, response);
        } else if ("/update-status".equals(path)) {
            updateStatus(request, response);
        } else if ("/reset".equals(path)) {
            resetToday(request, response);
        } else if ("/notification/save".equals(path)) {
            saveNotification(request, response);
        } else if ("/notification/delete".equals(path)) {
            deleteNotification(request, response);
        } else {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Unknown POST path.\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getPathInfo();
        if ("/today".equals(path)) {
            getTodayLayout(request, response);
        } else if ("/orders".equals(path)) {
            getOrdersByMealType(request, response);
        } else if ("/notifications".equals(path)) {
            getNotifications(request, response);
        } else {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Unknown GET path.\"}");
        }
    }

    private void saveLayout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"No session user.\"}");
                return;
            }

            User user = (User) session.getAttribute("user");
            if (user.getRole() == null || !user.getRole().toLowerCase().contains("kitchen")) {
                response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized.\"}");
                return;
            }

            BufferedReader reader = request.getReader();
            Map<String, Object> data = gson.fromJson(reader, Map.class);
            String mealType = stringValue(data.get("mealType"));
            String orderBeforeStr = stringValue(data.get("orderBefore"));

            if (mealType.isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Meal type is required.\"}");
                return;
            }
            if (!ALLOWED_MEAL_TYPES.contains(mealType)) {
                response.getWriter().write("{\"success\":false,\"message\":\"Invalid meal type.\"}");
                return;
            }
            if (orderBeforeStr.isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Order Before is required.\"}");
                return;
            }

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date orderBefore = sdf.parse(orderBeforeStr);
            if (orderBefore.before(new Date())) {
                response.getWriter().write("{\"success\":false,\"message\":\"Order Before cannot be in the past.\"}");
                return;
            }

            AdvancedMealSection section = new AdvancedMealSection();
            section.setMealDate(java.sql.Date.valueOf(LocalDate.now()));
            section.setMealType(mealType);
            section.setOrderBefore(orderBefore);
            section.setCreatedBy(user.getUserId());

            List<AdvancedMealColumn> columns = new ArrayList<>();
            Object rawColumns = data.get("columns");
            if (rawColumns instanceof List) {
                List<?> columnList = (List<?>) rawColumns;
                int colNo = 1;
                for (Object obj : columnList) {
                    if (!(obj instanceof Map)) continue;
                    Map<?, ?> colMap = (Map<?, ?>) obj;

                    AdvancedMealColumn col = new AdvancedMealColumn();
                    col.setColumnNo(colNo++);
                    col.setColumnType(normalizeColumnType(stringValue(colMap.get("type"))));
                    col.setItemName(stringValue(colMap.get("name")));
                    col.setImagePath(stringValue(colMap.get("imageData")));
                    col.setPrice(doubleValue(colMap.get("price")));
                    col.setAvailable(true);

                    if (!col.isSplitColumn() && col.getItemName().isEmpty()) {
                        response.getWriter().write("{\"success\":false,\"message\":\"Item name cannot be empty.\"}");
                        return;
                    }
                    if (col.getPrice() <= 0) {
                        response.getWriter().write("{\"success\":false,\"message\":\"Price must be greater than 0.\"}");
                        return;
                    }

                    if (col.isSplitColumn()) {
                        List<AdvancedMealColumnPart> parts = new ArrayList<>();
                        Object rawParts = colMap.get("parts");
                        if (rawParts instanceof List) {
                            int partNo = 1;
                            for (Object pObj : (List<?>) rawParts) {
                                if (!(pObj instanceof Map)) continue;
                                Map<?, ?> partMap = (Map<?, ?>) pObj;
                                AdvancedMealColumnPart part = new AdvancedMealColumnPart();
                                part.setPartNo(partNo++);
                                part.setPartName(stringValue(partMap.get("name")));
                                part.setImagePath(stringValue(partMap.get("imageData")));
                                if (part.getPartName().isEmpty()) {
                                    response.getWriter().write("{\"success\":false,\"message\":\"Item name cannot be empty.\"}");
                                    return;
                                }
                                parts.add(part);
                            }
                        }
                        col.setParts(parts);
                    }
                    columns.add(col);
                }
            }

            if (columns.isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Add at least one item.\"}");
                return;
            }

            section.setColumns(columns);
            boolean ok = dao.saveOrReplaceSection(section);
            response.getWriter().write(ok ? "{\"success\":true}" : "{\"success\":false,\"message\":\"DAO save failed.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() == null ? "Unknown error" : e.getMessage().replace("\"", "'");
            response.getWriter().write("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
    }


    private void getTodayLayout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            java.sql.Date today = java.sql.Date.valueOf(LocalDate.now());
            response.getWriter().write(gson.toJson(dao.getSectionMapByDate(today)));
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{}");
        }
    }

    private void getOrdersByMealType(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            String mealType = request.getParameter("mealType");
            response.getWriter().write(gson.toJson(dao.getTodayOrdersByMealType(mealType)));
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("[]");
        }
    }

    private void getNotifications(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            response.getWriter().write(gson.toJson(notificationDAO.getAllNotifications()));
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("[]");
        }
    }

    private void saveNotification(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"No session user.\"}");
                return;
            }

            User user = (User) session.getAttribute("user");
            if (user.getRole() == null || !user.getRole().toLowerCase().contains("kitchen")) {
                response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized.\"}");
                return;
            }

            Map<String, Object> data = gson.fromJson(request.getReader(), Map.class);
            int id = parseInt(data.get("id"));
            String message = stringValue(data.get("message"));

            if (message.isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Notification message cannot be empty.\"}");
                return;
            }

            if (id > 0) {
                boolean ok = notificationDAO.updateNotification(id, message, user.getUserId());
                if (!ok) {
                    response.getWriter().write("{\"success\":false,\"message\":\"Notification cannot be edited after a student has viewed it.\"}");
                    return;
                }
                response.getWriter().write("{\"success\":true}");
            } else {
                MealNotification notification = new MealNotification();
                notification.setMessage(message);
                notification.setCreatedBy(user.getUserId());
                boolean ok = notificationDAO.createNotification(notification);
                response.getWriter().write(ok ? "{\"success\":true}" : "{\"success\":false,\"message\":\"Could not save notification.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() == null ? "Notification save failed." : e.getMessage().replace("\"", "'");
            response.getWriter().write("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
    }

    private void deleteNotification(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"No session user.\"}");
                return;
            }

            User user = (User) session.getAttribute("user");
            if (user.getRole() == null || !user.getRole().toLowerCase().contains("kitchen")) {
                response.getWriter().write("{\"success\":false,\"message\":\"Unauthorized.\"}");
                return;
            }

            int id = Integer.parseInt(request.getParameter("id"));
            boolean ok = notificationDAO.deleteNotification(id);

            if (!ok) {
                response.getWriter().write("{\"success\":false,\"message\":\"Notification cannot be deleted after a student has viewed it.\"}");
                return;
            }

            response.getWriter().write("{\"success\":true}");
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage() == null ? "Notification delete failed." : e.getMessage().replace("\"", "'");
            response.getWriter().write("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
    }

    private void updateStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"No session user.\"}");
                return;
            }
            User user = (User) session.getAttribute("user");
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String status = request.getParameter("status");
            boolean ok = dao.updateAdvancedOrderStatus(orderId, status, user.getUserId());
            response.getWriter().write("{\"success\":" + ok + "}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false}");
        }
    }

    private void resetToday(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"No session user.\"}");
                return;
            }

            boolean mealsReset = dao.resetTodayData();
            boolean notificationsReset = notificationDAO.deleteAllNotifications();
            boolean ok = mealsReset && notificationsReset;

            response.getWriter().write(ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Reset failed.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"" +
                    (e.getMessage() == null ? "Reset error" : e.getMessage().replace("\"", "'")) + "\"}");
        }
    }

    private String stringValue(Object value) {
        return value == null ? "" : String.valueOf(value).trim();
    }

    private int parseInt(Object value) {
        if (value == null) return 0;
        try {
            if (value instanceof Number) return ((Number) value).intValue();
            return Integer.parseInt(String.valueOf(value).trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private double doubleValue(Object value) {
        if (value == null) return 0.0;
        if (value instanceof Number) return ((Number) value).doubleValue();
        String s = String.valueOf(value).trim();
        return s.isEmpty() ? 0.0 : Double.parseDouble(s);
    }

    private String normalizeColumnType(String type) {
        return "split".equalsIgnoreCase(type) ? "SPLIT" : "NORMAL";
    }
}