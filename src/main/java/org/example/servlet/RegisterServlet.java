package org.example.servlet;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HostelManagementDB;encrypt=true;trustServerCertificate=true";
    private String dbUser = "sa";
    private String dbPass = "Japan@123*";

    private String generateUserId(String role, Connection con) throws SQLException {
        String prefix = getPrefixForRole(role);

        String query = "SELECT MAX(userId) as maxId FROM users WHERE userId LIKE ?";
        PreparedStatement pst = con.prepareStatement(query);
        pst.setString(1, prefix + "%");
        ResultSet rs = pst.executeQuery();

        if (rs.next() && rs.getString("maxId") != null) {
            String lastId = rs.getString("maxId");
            try {
                String numberStr = lastId.substring(prefix.length());
                int nextNumber = Integer.parseInt(numberStr) + 1;
                return String.format("%s%03d", prefix, nextNumber);
            } catch (Exception e) {
                return prefix + "001";
            }
        } else {
            return prefix + "001";
        }
    }

    private String getPrefixForRole(String role) {
        switch(role.toLowerCase()) {
            case "owner":
                return "OWN";
            case "cleaning_staff":
            case "cleaning staff":
                return "CLN";
            case "laundry_staff":
            case "laundry staff":
                return "LND";
            case "kitchen_staff":
            case "kitchen staff":
                return "KIT";
            case "it_supporter":
            case "it supporter":
                return "SUP";
            case "student":
            default:
                return "STD";
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String role = request.getParameter("role");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        // Student specific
        String studyYearStr = request.getParameter("studyYear");
        String campusName = request.getParameter("campusName");
        String guardianName = request.getParameter("guardianName");
        String guardianPhone = request.getParameter("guardianPhone");
        String guardianRelationship = request.getParameter("guardianRelationship");
        String emergencyContact = request.getParameter("emergencyContact");

        // Staff specific
        String companyName = request.getParameter("companyName");
        String department = request.getParameter("department");
        String staffType = request.getParameter("staffType");
        String workShift = request.getParameter("workShift");

        // Validation
        if (role == null || role.trim().isEmpty()) {
            request.setAttribute("error", "Please select a role!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Common validations
        if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                fullName == null || fullName.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                address == null || address.trim().isEmpty()) {

            request.setAttribute("error", "All basic fields are required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!phone.matches("\\d{10}")) {
            request.setAttribute("error", "Phone number must be 10 digits!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Student specific validation
        if (role.equalsIgnoreCase("Student")) {
            if (studyYearStr == null || studyYearStr.trim().isEmpty() ||
                    campusName == null || campusName.trim().isEmpty() ||
                    guardianName == null || guardianName.trim().isEmpty() ||
                    guardianPhone == null || guardianPhone.trim().isEmpty()) {

                request.setAttribute("error", "All student fields are required!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            if (!guardianPhone.matches("\\d{10}")) {
                request.setAttribute("error", "Guardian phone must be 10 digits!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            try {
                int studyYear = Integer.parseInt(studyYearStr);
                if (studyYear < 1 || studyYear > 5) {
                    request.setAttribute("error", "Study year must be between 1 and 5!");
                    request.getRequestDispatcher("register.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid study year!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
        }

        Connection con = null;
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection(dbURL, dbUser, dbPass);
            con.setAutoCommit(false);

            String userId = generateUserId(role, con);

            // Insert into users table
            String sqlUsers = "INSERT INTO users (userId, username, password, role) VALUES (?, ?, ?, ?)";
            PreparedStatement pstUsers = con.prepareStatement(sqlUsers);
            pstUsers.setString(1, userId);
            pstUsers.setString(2, username.trim());
            pstUsers.setString(3, password);
            pstUsers.setString(4, role);
            pstUsers.executeUpdate();

            // Insert into appropriate table based on role
            switch(role.toLowerCase()) {
                case "student":
                    insertStudentDetails(con, userId, fullName, email, phone, address,
                            campusName, studyYearStr, guardianName,
                            guardianPhone, guardianRelationship, emergencyContact);
                    break;

                case "owner":
                    insertStaffDetails(con, userId, fullName, email, phone, address,
                            "Owner", companyName, department, workShift);
                    break;

                case "cleaning_staff":
                    insertStaffDetails(con, userId, fullName, email, phone, address,
                            "Cleaning Staff", companyName, department, workShift);
                    break;

                case "laundry_staff":
                    insertStaffDetails(con, userId, fullName, email, phone, address,
                            "Laundry Staff", companyName, department, workShift);
                    break;

                case "kitchen_staff":
                    insertStaffDetails(con, userId, fullName, email, phone, address,
                            "Kitchen Staff", companyName, department, workShift);
                    break;

                case "it_supporter":
                    insertStaffDetails(con, userId, fullName, email, phone, address,
                            "IT Supporter", companyName, department, workShift);
                    break;

                default:
                    insertStaffDetails(con, userId, fullName, email, phone, address,
                            role, companyName, department, workShift);
                    break;
            }

            con.commit();

            HttpSession session = request.getSession();
            session.setAttribute("registeredUserId", userId);
            session.setAttribute("registeredRole", role);
            session.setAttribute("registeredName", fullName);

            response.sendRedirect("registrationSuccess.jsp");

        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }

            e.printStackTrace();
            request.setAttribute("error", "Registration failed: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);

        } finally {
            try {
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void insertStudentDetails(Connection con, String userId, String fullName,
                                      String email, String phone, String address,
                                      String campusName, String studyYearStr,
                                      String guardianName, String guardianPhone,
                                      String guardianRelationship, String emergencyContact) throws SQLException {

        int studyYear = Integer.parseInt(studyYearStr);
        if (guardianRelationship == null || guardianRelationship.trim().isEmpty()) {
            guardianRelationship = "Parent";
        }
        if (emergencyContact == null || emergencyContact.trim().isEmpty()) {
            emergencyContact = "Not Provided";
        }

        String sql = "INSERT INTO student_details " +
                "(userId, fullName, email, phone, address, campus_name, studyYear, " +
                "guardian_name, guardian_phone, guardian_relationship, emergency_contact) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement pst = con.prepareStatement(sql);
        pst.setString(1, userId);
        pst.setString(2, fullName.trim());
        pst.setString(3, email.trim().toLowerCase());
        pst.setString(4, phone.trim());
        pst.setString(5, address.trim());
        pst.setString(6, campusName.trim());
        pst.setInt(7, studyYear);
        pst.setString(8, guardianName.trim());
        pst.setString(9, guardianPhone.trim());
        pst.setString(10, guardianRelationship.trim());
        pst.setString(11, emergencyContact.trim());
        pst.executeUpdate();
    }

    private void insertStaffDetails(Connection con, String userId, String fullName,
                                    String email, String phone, String address,
                                    String staffRole, String companyName,
                                    String department, String workShift) throws SQLException {

        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = "Not Provided";
        }
        if (department == null || department.trim().isEmpty()) {
            department = "General";
        }
        if (workShift == null || workShift.trim().isEmpty()) {
            workShift = "Day Shift";
        }

        String sql = "INSERT INTO staff_details " +
                "(userId, fullName, email, phone, address, staff_role, company_name, department, work_shift) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement pst = con.prepareStatement(sql);
        pst.setString(1, userId);
        pst.setString(2, fullName.trim());
        pst.setString(3, email.trim().toLowerCase());
        pst.setString(4, phone.trim());
        pst.setString(5, address.trim());
        pst.setString(6, staffRole);
        pst.setString(7, companyName.trim());
        pst.setString(8, department.trim());
        pst.setString(9, workShift.trim());
        pst.executeUpdate();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }
}