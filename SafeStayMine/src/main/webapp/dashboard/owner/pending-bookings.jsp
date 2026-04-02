<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%
  // ============ SESSION CHECK ============
  session = request.getSession(false);
  if (session == null || session.getAttribute("user") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

  // ============ DIRECT DATABASE CONNECTION ============
  List<Map<String, Object>> pendingBookings = new ArrayList<>();
  List<Map<String, Object>> availableRooms = new ArrayList<>();

  Connection conn = null;
  PreparedStatement pst = null;
  ResultSet rs = null;

  try {
    // Database connection
    String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=HostelManagementDB;encrypt=true;trustServerCertificate=true";
    String dbUser = "sa";
    String dbPass = "Japan@123*";

    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

    // ===== GET PENDING BOOKINGS =====
    String sql1 = "SELECT rb.*, u.fullName as studentName " +
            "FROM room_bookings rb " +
            "LEFT JOIN users u ON rb.studentId = u.userId " +
            "WHERE rb.status = 'Pending' " +
            "ORDER BY rb.created_at DESC";

    pst = conn.prepareStatement(sql1);
    rs = pst.executeQuery();

    while (rs.next()) {
      Map<String, Object> booking = new HashMap<>();
      booking.put("id", rs.getInt("id"));
      booking.put("bookingNo", rs.getString("booking_no"));
      booking.put("studentId", rs.getString("studentId"));
      booking.put("studentName", rs.getString("studentName") != null ? rs.getString("studentName") : "Unknown");
      booking.put("roomType", rs.getString("room_type"));
      booking.put("floor", rs.getInt("floor"));
      booking.put("needAc", rs.getString("need_ac"));
      booking.put("needFan", rs.getString("need_fan"));
      booking.put("createdAt", rs.getTimestamp("created_at"));
      pendingBookings.add(booking);
    }

    // ===== GET AVAILABLE ROOMS =====
    String sql2 = "SELECT * FROM room WHERE status = 'Available' ORDER BY floor, room_number";
    pst = conn.prepareStatement(sql2);
    rs = pst.executeQuery();

    while (rs.next()) {
      Map<String, Object> room = new HashMap<>();
      room.put("id", rs.getInt("id"));
      room.put("roomNumber", rs.getString("room_number"));
      room.put("roomType", rs.getString("room_type"));
      room.put("priceMonthly", rs.getDouble("price_monthly"));
      room.put("hasAc", rs.getString("has_ac"));
      room.put("hasFan", rs.getString("has_fan"));
      room.put("floor", rs.getInt("floor"));
      availableRooms.add(room);
    }

  } catch (Exception e) {
    e.printStackTrace();
  } finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (pst != null) pst.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
  }

  SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pending Room Requests - SafeStay</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
    body { background: #f8fafc; padding: 30px; }
    .container { max-width: 1400px; margin: 0 auto; }

    .header {
      background: white; border-radius: 20px; padding: 30px; margin-bottom: 30px;
      box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
      display: flex; justify-content: space-between; align-items: center;
    }
    .header h1 { font-size: 28px; color: #0f172a; display: flex; align-items: center; gap: 12px; }
    .header h1 i { color: #6366f1; }
    .back-btn {
      background: #f1f5f9; color: #0f172a; border: none; padding: 12px 24px; border-radius: 40px;
      font-weight: 600; text-decoration: none; display: flex; align-items: center; gap: 8px;
    }
    .back-btn:hover { background: #e2e8f0; }

    .stats-grid {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 25px; margin-bottom: 30px;
    }
    .stat-card {
      background: white; border-radius: 16px; padding: 25px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
      border-left: 4px solid #6366f1;
    }
    .stat-value { font-size: 36px; font-weight: 700; color: #0f172a; }
    .stat-label { color: #64748b; font-size: 14px; }

    .requests-table {
      background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
      overflow-x: auto;
    }
    table { width: 100%; border-collapse: collapse; }
    th {
      text-align: left; padding: 15px 10px; color: #64748b; font-weight: 600;
      font-size: 14px; border-bottom: 2px solid #e2e8f0;
    }
    td { padding: 15px 10px; border-bottom: 1px solid #e2e8f0; }

    .badge { padding: 5px 15px; border-radius: 40px; font-size: 12px; font-weight: 600; display: inline-block; }
    .badge-warning { background: #fff3cd; color: #856404; }

    .action-btn {
      padding: 8px 16px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; margin: 0 5px;
    }
    .btn-approve { background: #10b981; color: white; }
    .btn-reject { background: #ef4444; color: white; }
    .btn-view { background: #6366f1; color: white; }

    .empty-state {
      text-align: center; padding: 60px; color: #64748b;
    }
    .empty-state i { font-size: 60px; margin-bottom: 20px; opacity: 0.3; }

    .modal {
      display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center;
    }
    .modal-content {
      background: white; border-radius: 20px; padding: 30px; max-width: 500px; width: 90%;
    }
    .modal h3 { margin-bottom: 20px; }
    .modal select, .modal textarea {
      width: 100%; padding: 12px; margin-bottom: 15px; border: 1px solid #e2e8f0; border-radius: 8px;
    }
    .modal-buttons { display: flex; gap: 10px; justify-content: flex-end; }

    .facility-request {
      display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 11px;
      background: #eef2ff; color: #4f46e5; margin: 2px;
    }
  </style>
</head>
<body>
<div class="container">
  <div class="header">
    <h1>
      <i class="fas fa-bed"></i>
      Pending Room Requests
      <% if (pendingBookings.size() > 0) { %>
      <span style="background: #ef4444; color: white; padding: 5px 15px; border-radius: 30px; font-size: 16px;">
                    <%= pendingBookings.size() %> New
                </span>
      <% } %>
    </h1>
    <a href="dashboard.jsp" class="back-btn"><i class="fas fa-arrow-left"></i> Back</a>
  </div>

  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-value"><%= pendingBookings.size() %></div>
      <div class="stat-label">Pending Requests</div>
    </div>
    <div class="stat-card">
      <div class="stat-value"><%= availableRooms.size() %></div>
      <div class="stat-label">Available Rooms</div>
    </div>
    <div class="stat-card">
      <div class="stat-value">
        <%
          double demandRate = 0;
          if (availableRooms.size() > 0) {
            demandRate = (double) pendingBookings.size() / availableRooms.size() * 100;
          }
        %>
        <%= String.format("%.0f", demandRate) %>%
      </div>
      <div class="stat-label">Demand Rate</div>
    </div>
  </div>

  <div class="requests-table">
    <% if (pendingBookings.isEmpty()) { %>
    <div class="empty-state">
      <i class="fas fa-check-circle"></i>
      <h3>No Pending Requests</h3>
      <p>All booking requests have been processed.</p>
    </div>
    <% } else { %>
    <table>
      <thead>
      <tr>
        <th>Booking No.</th>
        <th>Student</th>
        <th>Date</th>
        <th>Room Type</th>
        <th>Facilities</th>
        <th>Floor</th>
        <th>Actions</th>
      </tr>
      </thead>
      <tbody>
      <% for (Map<String, Object> booking : pendingBookings) { %>
      <tr>
        <td><strong><%= booking.get("bookingNo") %></strong></td>
        <td>
          <%= booking.get("studentName") %><br>
          <small style="color: #64748b;"><%= booking.get("studentId") %></small>
        </td>
        <td><%= sdf.format(booking.get("createdAt")) %></td>
        <td><%= booking.get("roomType") %></td>
        <td>
          <% if ("Yes".equals(booking.get("needAc"))) { %>
          <span class="facility-request"><i class="fas fa-wind"></i> AC</span>
          <% } %>
          <% if ("Yes".equals(booking.get("needFan"))) { %>
          <span class="facility-request"><i class="fas fa-fan"></i> Fan</span>
          <% } %>
        </td>
        <td><%= (Integer)booking.get("floor") > 0 ? "Floor " + booking.get("floor") : "Any" %></td>
        <td>
          <button class="action-btn btn-approve" onclick="alert('Approve booking: <%= booking.get("bookingNo") %>')">Approve</button>
          <button class="action-btn btn-reject" onclick="alert('Reject booking: <%= booking.get("bookingNo") %>')">Reject</button>
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
    <% } %>
  </div>
</div>

<script>
  function showApproveModal(bookingId) {
    alert('Approve booking ID: ' + bookingId);
  }

  function showRejectModal(bookingId) {
    alert('Reject booking ID: ' + bookingId);
  }

  function closeModal() {
    // Close modal if any
  }
</script>
</body>
</html>