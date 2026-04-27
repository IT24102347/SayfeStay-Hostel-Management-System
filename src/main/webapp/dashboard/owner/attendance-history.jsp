<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*, org.example.dao.*, java.util.*, java.text.*, java.sql.*" %>
<%
  // ============ SESSION CHECK ============
  User user = (User) session.getAttribute("user");
  if (user == null || !"Owner".equalsIgnoreCase(user.getRole())) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

  String studentId = request.getParameter("studentId");
  String studentName = request.getParameter("studentName");

  if (studentId == null) studentId = "STD001";
  if (studentName == null) studentName = "Rashmi Perera";

  // ============ DIRECT DATABASE CONNECTION ============
  List<Map<String, Object>> attendanceRecords = new ArrayList<Map<String, Object>>();
  int presentCount = 0, lateCount = 0, absentCount = 0;

  Connection conn = null;
  PreparedStatement pst = null;
  ResultSet rs = null;

  try {
    String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HostelManagementDB;encrypt=true;trustServerCertificate=true";
    String dbUser = "sa";
    String dbPass = "Japan@123*";

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

    String sql = "SELECT * FROM attendance WHERE studentId = ? ORDER BY attendance_date DESC, check_in_time DESC";
    pst = conn.prepareStatement(sql);
    pst.setString(1, studentId);
    rs = pst.executeQuery();

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");

    while (rs.next()) {
      Map<String, Object> record = new HashMap<String, Object>();

      Timestamp checkIn = rs.getTimestamp("check_in_time");
      Timestamp checkOut = rs.getTimestamp("check_out_time");
      String status = rs.getString("status");
      String remarks = rs.getString("remarks");

      record.put("date", dateFormat.format(rs.getDate("attendance_date")));
      record.put("checkIn", checkIn != null ? timeFormat.format(checkIn) : "--:--");
      record.put("checkOut", checkOut != null ? timeFormat.format(checkOut) : "--:--");
      record.put("status", status);
      record.put("remarks", remarks != null ? remarks : "");

      // Calculate duration
      String duration = "--:--";
      if (checkIn != null && checkOut != null) {
        long diff = checkOut.getTime() - checkIn.getTime();
        long hours = diff / (60 * 60 * 1000);
        long minutes = (diff / (60 * 1000)) % 60;
        duration = String.format("%dh %dm", hours, minutes);
      }
      record.put("duration", duration);

      // Count statistics
      if ("Present".equals(status)) presentCount++;
      else if ("Late".equals(status)) lateCount++;
      else if ("Absent".equals(status)) absentCount++;

      attendanceRecords.add(record);
    }

  } catch (Exception e) {
    e.printStackTrace();
  } finally {
    if (rs != null) try { rs.close(); } catch(Exception e) {}
    if (pst != null) try { pst.close(); } catch(Exception e) {}
    if (conn != null) try { conn.close(); } catch(Exception e) {}
  }

  int totalDays = attendanceRecords.size();
  int attendancePercentage = totalDays > 0 ? (presentCount * 100 / totalDays) : 0;

  SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Attendance History - <%= studentName %></title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Poppins', sans-serif;
    }

    body {
      background: #f8fafc;
      display: flex;
      min-height: 100vh;
    }

    /* Sidebar */
    .sidebar {
      width: 280px;
      background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
      color: white;
      position: fixed;
      height: 100vh;
      overflow-y: auto;
    }

    .sidebar-header {
      padding: 30px 25px;
      text-align: center;
      border-bottom: 1px solid rgba(255,255,255,0.1);
    }

    .sidebar-header h2 {
      font-size: 28px;
      font-weight: 700;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
    }

    .owner-profile {
      padding: 25px;
      text-align: center;
      border-bottom: 1px solid rgba(255,255,255,0.1);
    }

    .owner-avatar {
      width: 80px;
      height: 80px;
      background: #4f46e5;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 32px;
      font-weight: 700;
      margin: 0 auto 15px;
    }

    .nav-menu {
      padding: 20px 0;
    }

    .nav-item {
      display: flex;
      align-items: center;
      padding: 12px 25px;
      color: rgba(255,255,255,0.8);
      text-decoration: none;
      transition: all 0.3s;
      border-left: 4px solid transparent;
    }

    .nav-item:hover, .nav-item.active {
      background: rgba(79, 70, 229, 0.2);
      color: white;
      border-left-color: #4f46e5;
    }

    .nav-item i {
      width: 25px;
      margin-right: 15px;
    }

    /* Main Content */
    .main-content {
      flex: 1;
      margin-left: 280px;
      padding: 30px;
    }

    .header {
      background: white;
      border-radius: 20px;
      padding: 25px 30px;
      margin-bottom: 25px;
      box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .header h1 {
      font-size: 28px;
      color: #0f172a;
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .header h1 i {
      color: #4f46e5;
    }

    .back-btn {
      background: #f1f5f9;
      color: #0f172a;
      border: none;
      padding: 12px 25px;
      border-radius: 12px;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 10px;
      cursor: pointer;
      text-decoration: none;
    }

    .back-btn:hover {
      background: #e2e8f0;
      transform: translateX(-5px);
    }

    /* Student Info Card */
    .student-info-card {
      background: linear-gradient(135deg, #4f46e5, #6366f1);
      border-radius: 20px;
      padding: 30px;
      color: white;
      margin-bottom: 25px;
      display: flex;
      align-items: center;
      gap: 30px;
    }

    .student-avatar-large {
      width: 100px;
      height: 100px;
      background: white;
      color: #4f46e5;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 42px;
      font-weight: 700;
    }

    .student-details-large h2 {
      font-size: 28px;
      margin-bottom: 10px;
    }

    .student-details-large p {
      margin-bottom: 5px;
      opacity: 0.9;
      display: flex;
      align-items: center;
      gap: 10px;
    }

    /* Stats Cards */
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
      margin-bottom: 25px;
    }

    .stat-card {
      background: white;
      border-radius: 16px;
      padding: 20px;
      box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
      border-left: 4px solid #4f46e5;
    }

    .stat-value {
      font-size: 32px;
      font-weight: 700;
      color: #0f172a;
    }

    .stat-label {
      color: #64748b;
      font-size: 14px;
    }

    /* Attendance Table */
    .attendance-table {
      background: white;
      border-radius: 20px;
      padding: 25px;
      box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
      overflow-x: auto;
    }

    table {
      width: 100%;
      border-collapse: collapse;
    }

    th {
      text-align: left;
      padding: 15px 10px;
      color: #64748b;
      font-weight: 600;
      font-size: 14px;
      border-bottom: 2px solid #f1f5f9;
    }

    td {
      padding: 15px 10px;
      border-bottom: 1px solid #f1f5f9;
    }

    .badge {
      padding: 5px 15px;
      border-radius: 50px;
      font-size: 12px;
      font-weight: 600;
      display: inline-block;
    }

    .badge-present {
      background: #d4edda;
      color: #155724;
    }

    .badge-late {
      background: #fff3cd;
      color: #856404;
    }

    .badge-absent {
      background: #f8d7da;
      color: #721c24;
    }

    .no-data {
      text-align: center;
      padding: 50px;
      color: #64748b;
    }

    .no-data i {
      font-size: 48px;
      margin-bottom: 15px;
      opacity: 0.5;
    }

    @media (max-width: 1024px) {
      .stats-grid {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    @media (max-width: 768px) {
      .sidebar {
        width: 100%;
        height: auto;
        position: relative;
      }
      .main-content {
        margin-left: 0;
      }
      .student-info-card {
        flex-direction: column;
        text-align: center;
      }
      .stats-grid {
        grid-template-columns: 1fr;
      }
    }
  </style>
</head>
<body>
<!-- Sidebar -->
<div class="sidebar">
  <div class="sidebar-header">
    <h2>
      <i class="fas fa-hotel"></i>
      <span>SafeStay</span>
    </h2>
  </div>

  <div class="owner-profile">
    <div class="owner-avatar">
      <%= user.getFullName() != null ? user.getFullName().charAt(0) : 'O' %>
    </div>
    <h4 style="margin-bottom: 5px;"><%= user.getFullName() != null ? user.getFullName() : "Owner" %></h4>
    <p style="font-size: 12px;"><%= user.getUserId() %></p>
  </div>

  <div class="nav-menu">
    <a href="<%= request.getContextPath() %>/dashboard/owner" class="nav-item">
      <i class="fas fa-home"></i>
      <span>Dashboard</span>
    </a>
    <a href="<%= request.getContextPath() %>/dashboard/owner/students.jsp" class="nav-item">
      <i class="fas fa-user-graduate"></i>
      <span>Students</span>
    </a>
    <a href="#" class="nav-item">
      <i class="fas fa-users"></i>
      <span>Staff</span>
    </a>
    <a href="#" class="nav-item">
      <i class="fas fa-door-open"></i>
      <span>Rooms</span>
    </a>
    <a href="#" class="nav-item">
      <i class="fas fa-credit-card"></i>
      <span>Payments</span>
    </a>
    <a href="<%= request.getContextPath() %>/logout" class="nav-item" style="margin-top: 50px;">
      <i class="fas fa-sign-out-alt"></i>
      <span>Logout</span>
    </a>
  </div>
</div>

<!-- Main Content -->
<div class="main-content">
  <!-- Header -->
  <div class="header">
    <h1>
      <i class="fas fa-calendar-check"></i>
      Attendance History
    </h1>
    <a href="javascript:history.back()" class="back-btn">
      <i class="fas fa-arrow-left"></i> Back
    </a>
  </div>

  <!-- Student Info Card -->
  <div class="student-info-card">
    <div class="student-avatar-large">
      <%= studentName.charAt(0) %>
    </div>
    <div class="student-details-large">
      <h2><%= studentName %></h2>
      <p><i class="fas fa-id-card"></i> Student ID: <%= studentId %></p>
      <p><i class="fas fa-door-open"></i> Room 101 (Single)</p>
      <p><span class="badge" style="background: rgba(255,255,255,0.2); color: white;">Active</span></p>
    </div>
  </div>

  <!-- Stats Cards -->
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-value"><%= attendancePercentage %>%</div>
      <div class="stat-label">Overall Attendance</div>
    </div>
    <div class="stat-card">
      <div class="stat-value"><%= presentCount %></div>
      <div class="stat-label">Present Days</div>
    </div>
    <div class="stat-card">
      <div class="stat-value"><%= lateCount %></div>
      <div class="stat-label">Late Days</div>
    </div>
    <div class="stat-card">
      <div class="stat-value"><%= absentCount %></div>
      <div class="stat-label">Absent Days</div>
    </div>
  </div>

  <!-- Attendance Table -->
  <div class="attendance-table">
    <table>
      <thead>
      <tr>
        <th>Date</th>
        <th>Check In</th>
        <th>Check Out</th>
        <th>Status</th>
        <th>Duration</th>
        <th>Remarks</th>
      </tr>
      </thead>
      <tbody>
      <%
        if (attendanceRecords.isEmpty()) {
      %>
      <tr>
        <td colspan="6" class="no-data">
          <i class="fas fa-calendar-times"></i>
          <p>No attendance records found for this student</p>
        </td>
      </tr>
      <%
      } else {
        for (Map<String, Object> record : attendanceRecords) {
      %>
      <tr>
        <td><%= record.get("date") %></td>
        <td><%= record.get("checkIn") %></td>
        <td><%= record.get("checkOut") %></td>
        <td>
                            <span class="badge badge-<%= ((String)record.get("status")).toLowerCase() %>">
                                <%= record.get("status") %>
                            </span>
        </td>
        <td><%= record.get("duration") %></td>
        <td><%= record.get("remarks") %></td>
      </tr>
      <%
          }
        }
      %>
      </tbody>
    </table>

    <% if (attendanceRecords.size() > 0) { %>
    <div style="display: flex; justify-content: center; gap: 10px; margin-top: 25px;">
      <button class="btn" style="background: #f1f5f9; padding: 8px 16px; border: none; border-radius: 8px; cursor: pointer;">Previous</button>
      <button class="btn" style="background: #4f46e5; color: white; padding: 8px 16px; border: none; border-radius: 8px; cursor: pointer;">1</button>
      <button class="btn" style="background: #f1f5f9; padding: 8px 16px; border: none; border-radius: 8px; cursor: pointer;">2</button>
      <button class="btn" style="background: #f1f5f9; padding: 8px 16px; border: none; border-radius: 8px; cursor: pointer;">3</button>
      <button class="btn" style="background: #f1f5f9; padding: 8px 16px; border: none; border-radius: 8px; cursor: pointer;">Next</button>
    </div>
    <% } %>
  </div>
</div>

<script>
  console.log('Total records loaded: <%= attendanceRecords.size() %>');
</script>
</body>
</html>