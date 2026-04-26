package org.example.servlet;

import org.example.dao.LaundryDAO;
import org.example.dao.NotificationDAO;
import org.example.dao.DamageDAO;
import org.example.model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/laundry/staff/dashboard")
public class LaundryStaffServlet extends HttpServlet {
    private LaundryDAO laundryDAO;
    private NotificationDAO notificationDAO;
    private DamageDAO damageDAO;

    @Override
    public void init() throws ServletException {
        laundryDAO = new LaundryDAO();
        notificationDAO = new NotificationDAO();
        damageDAO = new DamageDAO();
        System.out.println("=== LaundryStaffServlet INIT ===");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"Laundry_Staff".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/student/laundry/request");
            return;
        }

        List<LaundryRequest> allRequests = laundryDAO.getAllRequests();
        List<DamageReport> allDamages = damageDAO.getAllDamageReports();

        // DEBUG PRINTS
        System.out.println("========== STAFF DASHBOARD DEBUG ==========");
        System.out.println("All Requests Count: " + (allRequests != null ? allRequests.size() : 0));
        System.out.println("All Damages Count: " + (allDamages != null ? allDamages.size() : 0));

        if(allDamages != null && !allDamages.isEmpty()) {
            for(DamageReport d : allDamages) {
                System.out.println("Damage ID: " + d.getId() +
                        ", Student: " + d.getStudentId() +
                        ", Photo1: " + d.getPhoto1() +
                        ", Photo2: " + d.getPhoto2() +
                        ", Photo3: " + d.getPhoto3() +
                        ", Photo4: " + d.getPhoto4());
            }
        } else {
            System.out.println("No damage reports found in database!");
        }
        System.out.println("===========================================");

        request.setAttribute("allRequests", allRequests);
        request.setAttribute("allDamages", allDamages);
        request.getRequestDispatcher("/dashboard/laundry_staff/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"Laundry_Staff".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            int id = Integer.parseInt(request.getParameter("requestId"));
            LaundryRequest req = laundryDAO.getRequestById(id);

            if (req == null) {
                session.setAttribute("errorMsg", "Request not found");
                response.sendRedirect(request.getContextPath() + "/laundry/staff/dashboard");
                return;
            }

            if ("accept".equals(action)) {
                String time = request.getParameter("assignedTime");
                boolean updated = laundryDAO.updateStatus(id, "Accepted", time, null);
                if (updated) {
                    notificationDAO.createNotification(req.getStudentId(), "Laundry Request Accepted",
                            "Your laundry request " + req.getRequestNo() + " has been accepted. Pickup time: " + time);
                    session.setAttribute("successMsg", "Request accepted successfully!");
                } else {
                    session.setAttribute("errorMsg", "Failed to accept request.");
                }

            } else if ("reject".equals(action)) {
                String reason = request.getParameter("reason");
                boolean updated = laundryDAO.updateStatus(id, "Rejected", null, reason);
                if (updated) {
                    notificationDAO.createNotification(req.getStudentId(), "Laundry Request Rejected",
                            "Your laundry request " + req.getRequestNo() + " has been rejected. Reason: " + reason);
                    session.setAttribute("successMsg", "Request rejected successfully!");
                } else {
                    session.setAttribute("errorMsg", "Failed to reject request.");
                }

            } else if ("complete".equals(action)) {
                boolean updated = laundryDAO.updateStatus(id, "Completed", null, null);
                if (updated) {
                    notificationDAO.createNotification(req.getStudentId(), "Laundry Completed",
                            "Your laundry request " + req.getRequestNo() + " has been completed. Please collect your laundry.");
                    session.setAttribute("successMsg", "Request marked as completed!");
                } else {
                    session.setAttribute("errorMsg", "Failed to complete request.");
                }
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMsg", "Invalid request ID");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/laundry/staff/dashboard");
    }
}