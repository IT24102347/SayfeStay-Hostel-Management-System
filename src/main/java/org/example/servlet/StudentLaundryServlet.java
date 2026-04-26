package org.example.servlet;

import org.example.dao.LaundryDAO;
import org.example.dao.NotificationDAO;
import org.example.model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/student/laundry/request")
public class StudentLaundryServlet extends HttpServlet {
    private LaundryDAO laundryDAO;
    private NotificationDAO notificationDAO;

    @Override
    public void init() throws ServletException {
        laundryDAO = new LaundryDAO();
        notificationDAO = new NotificationDAO();
        System.out.println("=== StudentLaundryServlet INIT ===");
        laundryDAO.testConnection();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        List<LaundryItem> items = laundryDAO.getAllLaundryItems();
        List<LaundryRequest> requests = laundryDAO.getStudentRequests(user.getUserId());
        List<Notification> notifications = notificationDAO.getUnreadNotifications(user.getUserId());

        if (items == null) items = new ArrayList<>();
        if (requests == null) requests = new ArrayList<>();
        if (notifications == null) notifications = new ArrayList<>();

        request.setAttribute("laundryItems", items);
        request.setAttribute("requests", requests);
        request.setAttribute("notifications", notifications);
        request.getRequestDispatcher("/dashboard/student/laundry-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // CHECK FOR UNPAID PAYMENTS
        boolean hasUnpaid = laundryDAO.hasUnpaidPayments(user.getUserId());
        if (hasUnpaid) {
            double unpaidAmount = laundryDAO.getTotalUnpaidAmount(user.getUserId());
            session.setAttribute("errorMsg", "You have unpaid laundry payments of Rs. " +
                    String.format("%.2f", unpaidAmount) +
                    ". Please pay before submitting new requests.");
            response.sendRedirect(request.getContextPath() + "/dashboard/student/laundry-dashboard.jsp");
            return;
        }

        try {
            String floorNoStr = request.getParameter("floorNo");
            String roomNo = request.getParameter("roomNo");
            String collectionDateStr = request.getParameter("collectionDate");
            String serviceType = request.getParameter("serviceType");
            String urgency = request.getParameter("urgency");
            String totalCostStr = request.getParameter("totalCost");

            if (floorNoStr == null || floorNoStr.isEmpty() ||
                    roomNo == null || roomNo.isEmpty() ||
                    collectionDateStr == null || collectionDateStr.isEmpty() ||
                    totalCostStr == null || totalCostStr.isEmpty()) {
                session.setAttribute("errorMsg", "Please fill all required fields");
                response.sendRedirect(request.getContextPath() + "/dashboard/student/laundry-dashboard.jsp");
                return;
            }

            int floorNo = Integer.parseInt(floorNoStr);
            double totalCost = Double.parseDouble(totalCostStr);

            LaundryRequest lr = new LaundryRequest();
            lr.setStudentId(user.getUserId());
            lr.setStudentName(user.getFullName());
            lr.setFloorNo(floorNo);
            lr.setRoomNo(roomNo);
            lr.setServiceType(serviceType != null ? serviceType : "Wash and Iron");
            lr.setUrgency(urgency != null ? urgency : "Normal");
            lr.setTotalCost(totalCost);

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            lr.setCollectionDate(sdf.parse(collectionDateStr));

            List<LaundryItem> allItems = laundryDAO.getAllLaundryItems();
            if(allItems == null || allItems.isEmpty()) {
                allItems = new ArrayList<>();
                allItems.add(new LaundryItem(1, "T-Shirt", 150.00));
                allItems.add(new LaundryItem(2, "Shirt", 180.00));
                allItems.add(new LaundryItem(3, "Jeans", 250.00));
            }

            List<LaundryRequestItem> selectedItems = new ArrayList<>();
            int totalItemsCount = 0;

            for (LaundryItem item : allItems) {
                String qtyParam = request.getParameter("qty_" + item.getId());
                if (qtyParam != null && !qtyParam.isEmpty()) {
                    try {
                        int quantity = Integer.parseInt(qtyParam);
                        if (quantity > 0) {
                            totalItemsCount += quantity;
                            LaundryRequestItem reqItem = new LaundryRequestItem();
                            reqItem.setItemId(item.getId());
                            reqItem.setItemName(item.getItemName());
                            reqItem.setQuantity(quantity);
                            reqItem.setPricePerItem(item.getBasePrice());
                            reqItem.setTotalPrice(quantity * item.getBasePrice());
                            selectedItems.add(reqItem);
                        }
                    } catch (NumberFormatException e) {}
                }
            }

            lr.setTotalItems(totalItemsCount);

            if (selectedItems.isEmpty()) {
                session.setAttribute("errorMsg", "Please select at least one item");
                response.sendRedirect(request.getContextPath() + "/dashboard/student/laundry-dashboard.jsp");
                return;
            }

            boolean success = laundryDAO.createLaundryRequest(lr, selectedItems);

            if (success) {
                session.setAttribute("successMsg", "Laundry request submitted successfully! " + totalItemsCount + " items selected.");
            } else {
                session.setAttribute("errorMsg", "Failed to submit laundry request.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Failed to submit request: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/dashboard/student/laundry-dashboard.jsp");
    }
}