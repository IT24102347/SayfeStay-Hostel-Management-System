<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.User, java.util.*, java.text.SimpleDateFormat" %>
<%
  System.out.println("\n========== JSP START ==========");

  User user = (User) session.getAttribute("user");
  System.out.println("JSP - User: " + (user != null ? user.getUserId() : "null"));
  System.out.println("JSP - Role: " + (user != null ? user.getRole() : "null"));

  if (user == null) {
    System.out.println("JSP - User is null, redirecting to login");
    response.sendRedirect("login.jsp");
    return;
  }

  List<Map<String, Object>> pendingRequests = (List<Map<String, Object>>) request.getAttribute("pendingRequests");
  List<Map<String, Object>> completedRequests = (List<Map<String, Object>>) request.getAttribute("completedRequests");
  Map<String, Object> stats = (Map<String, Object>) request.getAttribute("staffStats");

  System.out.println("JSP - pendingRequests from request: " + (pendingRequests != null ? pendingRequests.size() : "null"));
  System.out.println("JSP - completedRequests from request: " + (completedRequests != null ? completedRequests.size() : "null"));

  if (pendingRequests == null) pendingRequests = new ArrayList<>();
  if (completedRequests == null) completedRequests = new ArrayList<>();
  if (stats == null) stats = new HashMap<>();

  System.out.println("JSP - pendingRequests size after null check: " + pendingRequests.size());
  if(pendingRequests != null && !pendingRequests.isEmpty()) {
    for(Map<String, Object> req : pendingRequests) {
      System.out.println("JSP - Request in JSP: ID=" + req.get("id") + ", Student=" + req.get("studentName"));
    }
  } else {
    System.out.println("JSP - No pending requests to display!");
  }

  SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");

  String successMsg = (String) session.getAttribute("successMsg");
  String errorMsg = (String) session.getAttribute("errorMsg");
  if(successMsg != null) session.removeAttribute("successMsg");
  if(errorMsg != null) session.removeAttribute("errorMsg");

  System.out.println("========== JSP END ==========\n");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Staff Cleaning Dashboard | SafeStay</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }
    body { background: #f0f2f5; }
    .dashboard { display: flex; min-height: 100vh; }
    .sidebar {
      width: 280px;
      background: linear-gradient(180deg, #1a237e 0%, #0d47a1 100%);
      color: white;
      position: fixed;
      height: 100vh;
      padding: 30px 20px;
    }
    .logo-area { text-align: center; padding-bottom: 30px; border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 30px; }
    .logo { font-size: 28px; font-weight: 700; }
    .logo span { color: #ffd700; }
    .main-content { flex: 1; margin-left: 280px; padding: 30px; }
    .stats-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 20px; margin-bottom: 30px; }
    .stat-card { background: white; padding: 20px; border-radius: 15px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
    .stat-info h3 { font-size: 14px; color: #666; margin-bottom: 10px; }
    .stat-info .number { font-size: 28px; font-weight: 700; color: #333; }
    .stat-icon { width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; }
    .card { background: white; border-radius: 15px; margin-bottom: 30px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
    .card-header { background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%); padding: 15px 20px; color: white; }
    .card-header h2 { margin: 0; font-size: 18px; display: flex; align-items: center; gap: 10px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    th { background: #f8f9fa; font-weight: 600; }
    .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 500; display: inline-block; }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-completed { background: #d4edda; color: #155724; }
    .btn-accept, .btn-complete { border: none; padding: 6px 15px; border-radius: 5px; cursor: pointer; color: white; }
    .btn-accept { background: #27ae60; }
    .btn-complete { background: #2980b9; }
    .input-small { padding: 5px 8px; border: 1px solid #ddd; border-radius: 5px; font-size: 12px; margin: 2px; }
    .action-form { display: inline-flex; gap: 5px; align-items: center; flex-wrap: wrap; }
    .empty-state { text-align: center; padding: 40px; color: #999; }
    .alert-success, .alert-error { padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; }
    .alert-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
    .alert-error { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }
    .nav-item { padding: 12px 15px; border-radius: 10px; margin-bottom: 10px; cursor: pointer; display: flex; align-items: center; gap: 10px; }
    .nav-item:hover { background: rgba(255,255,255,0.15); }
    .nav-item.active { background: rgba(255,255,255,0.15); color: #ffd700; }
    .debug-box { background: #f0f0f0; border: 1px solid #ccc; padding: 10px; margin: 10px 0; border-radius: 5px; font-family: monospace; font-size: 12px; }
  </style>
</head>
<body>
<div class="dashboard">
  <div class="sidebar">
    <div class="logo-area"><div class="logo">Safe<span>Stay</span></div><div style="font-size: 12px;">Staff Portal</div></div>
    <div class="nav-item active"><i class="fas fa-broom"></i> Cleaning Management</div>
    <div class="nav-item" onclick="location.href='<%= request.getContextPath() %>/laundry/staff/dashboard'"><i class="fas fa-tshirt"></i> Laundry</div>
    <div class="nav-item" onclick="location.href='<%= request.getContextPath() %>/logout'"><i class="fas fa-sign-out-alt"></i> Logout</div>
  </div>

  <div class="main-content">
    <% if(successMsg != null) { %>
    <div class="alert-success"><i class="fas fa-check-circle"></i> <%= successMsg %></div>
    <% } %>
    <% if(errorMsg != null) { %>
    <div class="alert-error"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div>
    <% } %>

    <!-- Debug Info (Remove after testing) -->
    <div class="debug-box">
      <strong>Debug Info:</strong><br>
      User: <%= user.getUserId() %> (Role: <%= user.getRole() %>)<br>
      Pending Requests Size: <%= pendingRequests.size() %><br>
      Completed Requests Size: <%= completedRequests.size() %>
    </div>

    <div class="stats-grid">
      <div class="stat-card"><div class="stat-info"><h3>Total Requests</h3><div class="number"><%= stats.getOrDefault("total_requests", 0) %></div></div><div class="stat-icon" style="background:#3498db;"><i class="fas fa-clipboard-list"></i></div></div>
      <div class="stat-card"><div class="stat-info"><h3>Pending</h3><div class="number"><%= stats.getOrDefault("pending_count", 0) %></div></div><div class="stat-icon" style="background:#f39c12;"><i class="fas fa-clock"></i></div></div>
      <div class="stat-card"><div class="stat-info"><h3>Accepted</h3><div class="number"><%= stats.getOrDefault("accepted_count", 0) %></div></div><div class="stat-icon" style="background:#2980b9;"><i class="fas fa-check"></i></div></div>
      <div class="stat-card"><div class="stat-info"><h3>Completed</h3><div class="number"><%= stats.getOrDefault("completed_count", 0) %></div></div><div class="stat-icon" style="background:#27ae60;"><i class="fas fa-check-double"></i></div></div>
      <div class="stat-card"><div class="stat-info"><h3>Total Earned</h3><div class="number">Rs. <%= String.format("%,.0f", stats.getOrDefault("total_earned", 0.0)) %></div></div><div class="stat-icon" style="background:#e67e22;"><i class="fas fa-rupee-sign"></i></div></div>
    </div>

    <div class="card">
      <div class="card-header"><h2><i class="fas fa-clock"></i> Pending Cleaning Requests</h2></div>
      <div style="overflow-x: auto; padding: 0 20px 20px 20px;">
        <% if (pendingRequests.isEmpty()) { %>
        <div class="empty-state">
          <i class="fas fa-check-circle"></i>
          <p>No pending cleaning requests</p>
          <p style="font-size: 12px; color: #999;">(Debug: Database query returned 0 rows)</p>
        </div>
        <% } else { %>
        <table class="data-table">
          <thead>
          <tr><th>ID</th><th>Student</th><th>Room</th><th>Floor</th><th>Request Date</th><th>Price</th><th>Action</th></tr>
          </thead>
          <tbody>
          <% for (Map<String, Object> req : pendingRequests) { %>
          <tr>
            <td><%= req.get("id") %></td>
            <td><strong><%= req.get("studentName") %></strong><br><small><%= req.get("studentId") %></small></td>
            <td><%= req.get("roomNo") %></td>
            <td><%= req.get("floorNo") %></td>
            <td><%= dateFormat.format((java.util.Date) req.get("requestDate")) %></td>
            <td>Rs. <%= String.format("%.2f", req.get("price")) %></td>
            <td>
              <form action="<%= request.getContextPath() %>/staff/cleaning/dashboard" method="POST" class="action-form">
                <input type="hidden" name="requestId" value="<%= req.get("id") %>">
                <input type="hidden" name="action" value="accept">
                <input type="date" name="assignedDate" class="input-small" required>
                <input type="time" name="assignedTime" class="input-small" required>
                <input type="text" name="staffResponse" class="input-small" placeholder="Response" style="width:150px;">
                <button type="submit" class="btn-accept"><i class="fas fa-calendar-check"></i> Accept</button>
              </form>
            </td>
          </tr>
          <% } %>
          </tbody>
        </table>
        <% } %>
      </div>
    </div>

    <div class="card">
      <div class="card-header"><h2><i class="fas fa-history"></i> Completed Cleaning History</h2></div>
      <div style="overflow-x: auto; padding: 0 20px 20px 20px;">
        <% if (completedRequests.isEmpty()) { %>
        <div class="empty-state"><i class="fas fa-box-open"></i><p>No completed cleaning requests</p></div>
        <% } else { %>
        <table class="data-table">
          <thead>
          <tr><th>ID</th><th>Student</th><th>Room</th><th>Floor</th><th>Request Date</th><th>Assigned Date</th><th>Assigned Time</th><th>Price</th><th>Status</th></tr>
          </thead>
          <tbody>
          <% for (Map<String, Object> req : completedRequests) { %>
          <tr>
            <td><%= req.get("id") %></td>
            <td><strong><%= req.get("studentName") %></strong><br><small><%= req.get("studentId") %></small></td>
            <td><%= req.get("roomNo") %></td>
            <td><%= req.get("floorNo") %></td>
            <td><%= dateFormat.format((java.util.Date) req.get("requestDate")) %></td>
            <td><%= req.get("assigned_date") %></td>
            <td><%= req.get("assigned_time") %></td>
            <td>Rs. <%= String.format("%.2f", req.get("price")) %></td>
            <td><span class="status-badge status-completed">Completed</span></td>
          </tr>
          <% } %>
          </tbody>
        </table>
        <% } %>
      </div>
    </div>
  </div>
</div>
</body>
</html>