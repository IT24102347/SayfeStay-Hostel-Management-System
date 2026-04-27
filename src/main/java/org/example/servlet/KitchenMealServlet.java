package org.example.servlet;

import org.example.dao.MealDAO;
import org.example.model.DailyMenu;
import org.example.model.MealOrder;
import org.example.model.User;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet("/kitchen/meal/*")
public class KitchenMealServlet extends HttpServlet {



    private MealDAO mealDAO;

    @Override
    public void init() {
        mealDAO = new MealDAO();
    }

    private boolean isKitchenUser(User user) {
        return user != null && user.getRole() != null && user.getRole().toLowerCase().contains("kitchen");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!isKitchenUser(user)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || "/".equals(pathInfo) || "/dashboard".equals(pathInfo)) {
            List<DailyMenu> todayMenu = mealDAO.getTodaysMenu();
            List<MealOrder> todaysOrders = mealDAO.getTodaysOrders();
            request.setAttribute("todayMenu", todayMenu);
            request.setAttribute("todaysOrders", todaysOrders);
            request.getRequestDispatcher("/dashboard/kitchen_staff/kitchen_dashboard.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/kitchen/meal/dashboard");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!isKitchenUser(user)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String pathInfo = request.getPathInfo();
        boolean success = false;
        String successMessage = null;
        String errorMessage = null;

        try {
            if ("/add".equals(pathInfo)) {
                DailyMenu menu = buildMenuFromRequest(request, user.getUserId());
                success = mealDAO.addMenuItem(menu);
                successMessage = success ? "Menu item saved successfully." : null;
                errorMessage = success ? null : "Failed to save menu item.";
            } else if ("/edit".equals(pathInfo)) {
                DailyMenu menu = buildMenuFromRequest(request, user.getUserId());
                menu.setId(Integer.parseInt(request.getParameter("id")));
                success = mealDAO.updateMenuItem(menu);
                successMessage = success ? "Menu item updated successfully." : null;
                errorMessage = success ? null : "Failed to update menu item.";
            } else if ("/delete".equals(pathInfo)) {
                int id = Integer.parseInt(request.getParameter("id"));
                success = mealDAO.deleteMenuItem(id);
                successMessage = success ? "Menu item deleted successfully." : null;
                errorMessage = success ? null : "Failed to delete menu item.";
            } else if ("/update-status".equals(pathInfo)) {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String status = request.getParameter("status");
                success = mealDAO.updateOrderStatus(orderId, status, user.getUserId());
                successMessage = success ? "Order status updated successfully." : null;
                errorMessage = success ? null : "Failed to update order status.";
            } else {
                errorMessage = "Unknown kitchen action.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "Invalid request data.";
        }

        if (successMessage != null) {
            session.setAttribute("successMessage", successMessage);
        }
        if (errorMessage != null) {
            session.setAttribute("errorMessage", errorMessage);
        }

        response.sendRedirect(request.getContextPath() + "/kitchen/meal/dashboard");
    }

    private DailyMenu buildMenuFromRequest(HttpServletRequest request, String staffId) {
        DailyMenu menu = new DailyMenu();
        String menuDate = request.getParameter("menuDate");
        if (menuDate == null || menuDate.trim().isEmpty()) {
            menu.setMenuDate(new Date(System.currentTimeMillis()));
        } else {
            menu.setMenuDate(Date.valueOf(menuDate));
        }
        menu.setMealType(request.getParameter("mealType"));
        menu.setItemName(request.getParameter("itemName"));
        menu.setDescription(request.getParameter("description"));
        menu.setPrice(Double.parseDouble(request.getParameter("price")));
        menu.setAvailable("1".equals(request.getParameter("isAvailable")) || "true".equalsIgnoreCase(request.getParameter("isAvailable")) || request.getParameter("isAvailable") == null);
        menu.setPreparedBy(staffId);
        return menu;
    }
}
