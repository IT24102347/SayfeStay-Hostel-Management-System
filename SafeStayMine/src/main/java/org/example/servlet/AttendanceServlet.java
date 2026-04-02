package org.example.servlet;

import org.example.dao.AttendanceDAO;
import org.example.model.User;
import org.example.model.Attendance;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/attendance/*")
public class AttendanceServlet extends HttpServlet {

    private AttendanceDAO attendanceDAO;
    private SimpleDateFormat timeFormat;

    @Override
    public void init() {
        attendanceDAO = new AttendanceDAO();
        timeFormat = new SimpleDateFormat("hh:mm a");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            if (pathInfo.equals("/history")) {
                String studentId = request.getParameter("studentId");
                if (studentId == null) studentId = user.getUserId();

                // Get last 30 days attendance
                List<Attendance> history = attendanceDAO.getAllAttendance(studentId, 30);
                Map<String, Object> stats = attendanceDAO.getStats(studentId, 30);
                boolean hasActive = attendanceDAO.hasActiveCheckIn(studentId);
                int todayCount = attendanceDAO.getTodayCheckInCount(studentId);
                List<Attendance> todayCheckIns = attendanceDAO.getTodayCheckIns(studentId);

                String json = "{";
                json += "\"history\":" + convertListToJson(history) + ",";
                json += "\"stats\":" + convertMapToJson(stats) + ",";
                json += "\"hasActive\":" + hasActive + ",";
                json += "\"todayCount\":" + todayCount + ",";
                json += "\"todayCheckIns\":" + convertListToJson(todayCheckIns);
                json += "}";

                out.print(json);
            }

        } catch (Exception e) {
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String pathInfo = request.getPathInfo();

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            if (pathInfo.equals("/checkin")) {
                // CHECK-IN (Multiple times allowed)
                String studentId = request.getParameter("studentId");
                String status = request.getParameter("status");
                String remarks = request.getParameter("remarks");

                String json = "{";

                if (studentId == null || studentId.trim().isEmpty()) {
                    json += "\"success\":false,\"message\":\"Student ID required\"";
                } else if (status == null || status.trim().isEmpty()) {
                    json += "\"success\":false,\"message\":\"Status required\"";
                } else {
                    boolean success = attendanceDAO.checkIn(studentId, status, user.getUserId(), remarks);

                    if (success) {
                        json += "\"success\":true,\"message\":\"Check-in successful at " +
                                timeFormat.format(new Date()) + "\"";
                    } else {
                        json += "\"success\":false,\"message\":\"Check-in failed\"";
                    }
                }

                json += "}";
                out.print(json);

            } else if (pathInfo.equals("/checkout")) {
                // CHECK-OUT
                String studentId = request.getParameter("studentId");

                String json = "{";

                if (!attendanceDAO.hasActiveCheckIn(studentId)) {
                    json += "\"success\":false,\"message\":\"No active check-in found\"";
                } else {
                    boolean success = attendanceDAO.checkOut(studentId);

                    if (success) {
                        json += "\"success\":true,\"message\":\"Check-out successful at " +
                                timeFormat.format(new Date()) + "\"";
                    } else {
                        json += "\"success\":false,\"message\":\"Check-out failed\"";
                    }
                }

                json += "}";
                out.print(json);
            }

        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }

    // ============ HELPER METHODS ============

    private String convertListToJson(List<Attendance> list) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            Attendance a = list.get(i);
            json.append("{");
            json.append("\"id\":").append(a.getId()).append(",");
            json.append("\"studentId\":\"").append(a.getStudentId()).append("\",");
            json.append("\"studentName\":\"").append(a.getStudentName() != null ? a.getStudentName() : "").append("\",");
            json.append("\"date\":\"").append(a.getFormattedDate()).append("\",");
            json.append("\"checkIn\":\"").append(a.getFormattedCheckInTime()).append("\",");
            json.append("\"checkOut\":\"").append(a.getFormattedCheckOutTime()).append("\",");
            json.append("\"status\":\"").append(a.getStatus()).append("\"");
            json.append("}");
            if (i < list.size() - 1) json.append(",");
        }
        json.append("]");
        return json.toString();
    }

    private String convertMapToJson(Map<String, Object> map) {
        StringBuilder json = new StringBuilder("{");
        int count = 0;
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            json.append("\"").append(entry.getKey()).append("\":").append(entry.getValue());
            if (count < map.size() - 1) json.append(",");
            count++;
        }
        json.append("}");
        return json.toString();
    }
}