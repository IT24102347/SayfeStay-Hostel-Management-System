<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.User, java.util.*, java.text.SimpleDateFormat" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  List<Map<String, Object>> pendingRequests = (List<Map<String, Object>>) request.getAttribute("pendingRequests");
  List<Map<String, Object>> acceptedRequests = (List<Map<String, Object>>) request.getAttribute("acceptedRequests");
  List<Map<String, Object>> completedRequests = (List<Map<String, Object>>) request.getAttribute("completedRequests");
  Map<String, Object> stats = (Map<String, Object>) request.getAttribute("staffStats");

  if (pendingRequests == null) pendingRequests = new ArrayList<Map<String, Object>>();
  if (acceptedRequests == null) acceptedRequests = new ArrayList<Map<String, Object>>();
  if (completedRequests == null) completedRequests = new ArrayList<Map<String, Object>>();
  if (stats == null) stats = new HashMap<String, Object>();

  SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");

  String successMsg = (String) session.getAttribute("successMsg");
  String errorMsg = (String) session.getAttribute("errorMsg");
  if (successMsg != null) session.removeAttribute("successMsg");
  if (errorMsg != null) session.removeAttribute("errorMsg");
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

    /* Sidebar */
    .sidebar {
      width: 280px;
      background: linear-gradient(180deg, #1a237e 0%, #0d47a1 100%);
      color: white;
      position: fixed;
      height: 100vh;
      padding: 30px 20px;
      overflow-y: auto;
    }
    .logo-area { text-align: center; padding-bottom: 30px; border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 30px; }
    .logo { font-size: 28px; font-weight: 700; }
    .logo span { color: #ffd700; }
    .staff-name { font-size: 13px; color: rgba(255,255,255,0.7); margin-top: 8px; }
    .nav-item {
      padding: 12px 15px; border-radius: 10px; margin-bottom: 8px;
      cursor: pointer; display: flex; align-items: center; gap: 10px;
      transition: background 0.2s; font-size: 14px;
    }
    .nav-item:hover { background: rgba(255,255,255,0.15); }
    .nav-item.active { background: rgba(255,255,255,0.2); color: #ffd700; font-weight: 600; }
    .nav-badge {
      margin-left: auto; background: #f44336; color: white;
      border-radius: 20px; padding: 2px 8px; font-size: 11px; font-weight: 700;
    }
    .nav-section-title { font-size: 11px; color: rgba(255,255,255,0.4); text-transform: uppercase; letter-spacing: 1px; padding: 10px 15px 5px; }

    /* Main */
    .main-content { flex: 1; margin-left: 280px; padding: 30px; }
    .page-header { margin-bottom: 25px; }
    .page-header h1 { font-size: 24px; color: #1a237e; font-weight: 700; }
    .page-header p { color: #666; font-size: 14px; margin-top: 4px; }

    /* Alerts */
    .alert-success, .alert-error {
      padding: 14px 20px; border-radius: 10px; margin-bottom: 20px;
      display: flex; align-items: center; gap: 10px; font-weight: 500;
    }
    .alert-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
    .alert-error { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }

    /* Stats */
    .stats-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 18px; margin-bottom: 30px; }
    .stat-card {
      background: white; padding: 20px; border-radius: 15px;
      display: flex; justify-content: space-between; align-items: center;
      box-shadow: 0 2px 10px rgba(0,0,0,0.06); border-left: 4px solid transparent;
    }
    .stat-card.blue { border-left-color: #3498db; }
    .stat-card.orange { border-left-color: #f39c12; }
    .stat-card.indigo { border-left-color: #6c5ce7; }
    .stat-card.green { border-left-color: #27ae60; }
    .stat-card.amber { border-left-color: #e67e22; }
    .stat-info h3 { font-size: 12px; color: #888; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; }
    .stat-info .number { font-size: 26px; font-weight: 700; color: #2d3748; }
    .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: white; font-size: 18px; }

    /* Cards */
    .card { background: white; border-radius: 16px; margin-bottom: 25px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.06); }
    .card-header {
      padding: 16px 22px; color: white; display: flex; align-items: center; justify-content: space-between;
    }
    .card-header.pending-header { background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%); }
    .card-header.accepted-header { background: linear-gradient(135deg, #6c5ce7 0%, #4834d4 100%); }
    .card-header.completed-header { background: linear-gradient(135deg, #27ae60 0%, #229954 100%); }
    .card-header h2 { font-size: 16px; font-weight: 600; display: flex; align-items: center; gap: 10px; }
    .count-badge {
      background: rgba(255,255,255,0.25); color: white;
      padding: 3px 10px; border-radius: 20px; font-size: 13px; font-weight: 600;
    }
    .card-body { padding: 0 22px 22px; }

    /* Table */
    table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    th { background: #f8f9fa; padding: 11px 13px; text-align: left; font-size: 12px; font-weight: 600; color: #555; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 2px solid #eee; }
    td { padding: 13px; border-bottom: 1px solid #f0f0f0; font-size: 14px; color: #444; vertical-align: middle; }
    tr:last-child td { border-bottom: none; }
    tr:hover td { background: #fafafa; }
    .student-name { font-weight: 600; color: #2d3748; }
    .student-id { font-size: 12px; color: #888; margin-top: 2px; }

    /* Status badges */
    .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-accepted { background: #e8e3ff; color: #4834d4; }
    .status-completed { background: #d4edda; color: #155724; }

    /* Action forms */
    .action-form { display: flex; flex-direction: column; gap: 8px; min-width: 280px; }
    .form-row { display: flex; gap: 8px; }
    .input-date, .input-time {
      padding: 7px 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px;
      flex: 1; color: #333; background: #fafafa;
    }
    .input-date:focus, .input-time:focus { outline: none; border-color: #6c5ce7; background: white; }
    .input-response {
      padding: 7px 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px;
      width: 100%; color: #333; background: #fafafa;
    }
    .input-response:focus { outline: none; border-color: #6c5ce7; background: white; }
    .btn-accept {
      background: linear-gradient(135deg, #27ae60, #229954); color: white; border: none;
      padding: 8px 16px; border-radius: 8px; cursor: pointer; font-size: 13px; font-weight: 600;
      display: flex; align-items: center; gap: 6px; justify-content: center; transition: opacity 0.2s;
    }
    .btn-accept:hover { opacity: 0.88; }
    .btn-complete {
      background: linear-gradient(135deg, #6c5ce7, #4834d4); color: white; border: none;
      padding: 8px 20px; border-radius: 8px; cursor: pointer; font-size: 13px; font-weight: 600;
      display: flex; align-items: center; gap: 6px; transition: opacity 0.2s; white-space: nowrap;
    }
    .btn-complete:hover { opacity: 0.88; }

    /* Assigned info chip */
    .assigned-chip {
      background: #f0edff; color: #4834d4; border-radius: 8px;
      padding: 4px 10px; font-size: 12px; display: inline-flex; align-items: center; gap: 5px; margin: 2px 0;
    }
    .price-text { font-weight: 600; color: #e67e22; }

    /* Empty state */
    .empty-state { text-align: center; padding: 40px 20px; color: #aaa; }
    .empty-state i { font-size: 36px; margin-bottom: 12px; display: block; }
    .empty-state p { font-size: 14px; }

    @media (max-width: 1200px) {
      .stats-grid { grid-template-columns: repeat(3, 1fr); }
    }
  </style>
</head>
<body>
<div class="dashboard">

  <!-- Sidebar -->
  <div class="sidebar">
    <div class="logo-area">
      <div class="logo">Safe<span>Stay</span></div>
      <div class="staff-name"><i class="fas fa-user-circle"></i> <%= user.getUserId() %></div>
      <div style="font-size: 11px; color: rgba(255,255,255,0.5); margin-top:4px;">Cleaning Staff</div>
    </div>

    <div class="nav-section-title">Management</div>
    <div class="nav-item active">
      <i class="fas fa-broom"></i> Cleaning
      <% int pendingCount = pendingRequests.size(); if (pendingCount > 0) { %>
      <span class="nav-badge"><%= pendingCount %></span>
      <% } %>
    </div>
    <div class="nav-item" onclick="location.href='<%= request.getContextPath() %>/laundry/staff/dashboard'">
      <i class="fas fa-tshirt"></i> Laundry
    </div>

    <div class="nav-section-title" style="margin-top: 20px;">Account</div>
    <div class="nav-item" onclick="location.href='<%= request.getContextPath() %>/logout'" style="color: #ff7675;">
      <i class="fas fa-sign-out-alt"></i> Logout
    </div>
  </div>

  <!-- Main Content -->
  <div class="main-content">

    <div class="page-header">
      <h1><i class="fas fa-broom" style="color:#1a237e;"></i> Cleaning Management</h1>
      <p>Manage and track all cleaning requests from students</p>
    </div>

    <% if (successMsg != null) { %>
    <div class="alert-success"><i class="fas fa-check-circle"></i> <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert-error"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div>
    <% } %>

    <!-- Stats -->
    <div class="stats-grid">
      <div class="stat-card blue">
        <div class="stat-info"><h3>Total</h3><div class="number"><%= stats.getOrDefault("total_requests", 0) %></div></div>
        <div class="stat-icon" style="background:#3498db;"><i class="fas fa-clipboard-list"></i></div>
      </div>
      <div class="stat-card orange">
        <div class="stat-info"><h3>Pending</h3><div class="number"><%= stats.getOrDefault("pending_count", 0) %></div></div>
        <div class="stat-icon" style="background:#f39c12;"><i class="fas fa-hourglass-half"></i></div>
      </div>
      <div class="stat-card indigo">
        <div class="stat-info"><h3>Accepted</h3><div class="number"><%= stats.getOrDefault("accepted_count", 0) %></div></div>
        <div class="stat-icon" style="background:#6c5ce7;"><i class="fas fa-calendar-check"></i></div>
      </div>
      <div class="stat-card green">
        <div class="stat-info"><h3>Completed</h3><div class="number"><%= stats.getOrDefault("completed_count", 0) %></div></div>
        <div class="stat-icon" style="background:#27ae60;"><i class="fas fa-check-double"></i></div>
      </div>
      <div class="stat-card amber">
        <div class="stat-info"><h3>Total Earned</h3><div class="number" style="font-size:20px;">Rs. <%= String.format("%,.0f", stats.getOrDefault("total_earned", 0.0)) %></div></div>
        <div class="stat-icon" style="background:#e67e22;"><i class="fas fa-wallet"></i></div>
      </div>
    </div>

    <!-- ===== PENDING REQUESTS ===== -->
    <div class="card">
      <div class="card-header pending-header">
        <h2><i class="fas fa-hourglass-half"></i> Pending Cleaning Requests</h2>
        <span class="count-badge"><%= pendingRequests.size() %> requests</span>
      </div>
      <div class="card-body">
        <% if (pendingRequests.isEmpty()) { %>
        <div class="empty-state">
          <i class="fas fa-check-circle" style="color:#27ae60;"></i>
          <p>No pending cleaning requests at the moment</p>
        </div>
        <% } else { %>
        <div style="overflow-x: auto;">
          <table>
            <thead>
            <tr>
              <th>#</th>
              <th>Student</th>
              <th>Room</th>
              <th>Floor</th>
              <th>Request Date</th>
              <th>Price</th>
              <th>Schedule & Accept</th>
            </tr>
            </thead>
            <tbody>
            <% for (Map<String, Object> req : pendingRequests) { %>
            <tr>
              <td><strong>#<%= req.get("id") %></strong></td>
              <td>
                <div class="student-name"><%= req.get("studentName") %></div>
                <div class="student-id"><%= req.get("studentId") %></div>
              </td>
              <td><i class="fas fa-door-open" style="color:#888; margin-right:4px;"></i><%= req.get("roomNo") %></td>
              <td>Floor <%= req.get("floorNo") %></td>
              <td><%= dateFormat.format((java.util.Date) req.get("requestDate")) %></td>
              <td><span class="price-text">Rs. <%= String.format("%.2f", req.get("price")) %></span></td>
              <td>
                <form action="<%= request.getContextPath() %>/staff/cleaning/dashboard" method="POST" class="action-form">
                  <input type="hidden" name="requestId" value="<%= req.get("id") %>">
                  <input type="hidden" name="action" value="accept">
                  <div class="form-row">
                    <input type="date" name="assignedDate" class="input-date" required>
                    <input type="time" name="assignedTime" class="input-time" required>
                  </div>
                  <input type="text" name="staffResponse" class="input-response" placeholder="Add a note (optional)">
                  <button type="submit" class="btn-accept">
                    <i class="fas fa-calendar-check"></i> Accept & Schedule
                  </button>
                </form>
              </td>
            </tr>
            <% } %>
            </tbody>
          </table>
        </div>
        <% } %>
      </div>
    </div>

    <!-- ===== ACCEPTED REQUESTS ===== -->
    <div class="card">
      <div class="card-header accepted-header">
        <h2><i class="fas fa-calendar-check"></i> Accepted — Ready to Complete</h2>
        <span class="count-badge"><%= acceptedRequests.size() %> scheduled</span>
      </div>
      <div class="card-body">
        <% if (acceptedRequests.isEmpty()) { %>
        <div class="empty-state">
          <i class="fas fa-calendar" style="color:#6c5ce7;"></i>
          <p>No accepted requests waiting to be completed</p>
        </div>
        <% } else { %>
        <div style="overflow-x: auto;">
          <table>
            <thead>
            <tr>
              <th>#</th>
              <th>Student</th>
              <th>Room</th>
              <th>Floor</th>
              <th>Request Date</th>
              <th>Scheduled</th>
              <th>Note</th>
              <th>Price</th>
              <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <% for (Map<String, Object> req : acceptedRequests) { %>
            <tr>
              <td><strong>#<%= req.get("id") %></strong></td>
              <td>
                <div class="student-name"><%= req.get("studentName") %></div>
                <div class="student-id"><%= req.get("studentId") %></div>
              </td>
              <td><i class="fas fa-door-open" style="color:#888; margin-right:4px;"></i><%= req.get("roomNo") %></td>
              <td>Floor <%= req.get("floorNo") %></td>
              <td><%= dateFormat.format((java.util.Date) req.get("requestDate")) %></td>
              <td>
                <div class="assigned-chip"><i class="fas fa-calendar"></i> <%= req.get("assigned_date") %></div><br>
                <div class="assigned-chip"><i class="fas fa-clock"></i> <%= req.get("assigned_time") %></div>
              </td>
              <td style="font-size:13px; color:#666; max-width:150px;">
                <%= "N/A".equals(req.get("staff_response")) ? "—" : req.get("staff_response") %>
              </td>
              <td><span class="price-text">Rs. <%= String.format("%.2f", req.get("price")) %></span></td>
              <td>
                <form action="<%= request.getContextPath() %>/staff/cleaning/dashboard" method="POST">
                  <input type="hidden" name="requestId" value="<%= req.get("id") %>">
                  <input type="hidden" name="action" value="complete">
                  <button type="submit" class="btn-complete">
                    <i class="fas fa-check-double"></i> Mark Complete
                  </button>
                </form>
              </td>
            </tr>
            <% } %>
            </tbody>
          </table>
        </div>
        <% } %>
      </div>
    </div>

    <!-- ===== COMPLETED HISTORY ===== -->
    <div class="card">
      <div class="card-header completed-header">
        <h2><i class="fas fa-history"></i> Completed Cleaning History</h2>
        <span class="count-badge"><%= completedRequests.size() %> done</span>
      </div>
      <div class="card-body">
        <% if (completedRequests.isEmpty()) { %>
        <div class="empty-state">
          <i class="fas fa-box-open" style="color:#aaa;"></i>
          <p>No completed cleaning requests yet</p>
        </div>
        <% } else { %>
        <div style="overflow-x: auto;">
          <table>
            <thead>
            <tr>
              <th>#</th>
              <th>Student</th>
              <th>Room</th>
              <th>Floor</th>
              <th>Request Date</th>
              <th>Assigned Date</th>
              <th>Assigned Time</th>
              <th>Price</th>
              <th>Status</th>
            </tr>
            </thead>
            <tbody>
            <% for (Map<String, Object> req : completedRequests) { %>
            <tr>
              <td><strong>#<%= req.get("id") %></strong></td>
              <td>
                <div class="student-name"><%= req.get("studentName") %></div>
                <div class="student-id"><%= req.get("studentId") %></div>
              </td>
              <td><i class="fas fa-door-open" style="color:#888; margin-right:4px;"></i><%= req.get("roomNo") %></td>
              <td>Floor <%= req.get("floorNo") %></td>
              <td><%= dateFormat.format((java.util.Date) req.get("requestDate")) %></td>
              <td><%= req.get("assigned_date") %></td>
              <td><%= req.get("assigned_time") %></td>
              <td><span class="price-text">Rs. <%= String.format("%.2f", req.get("price")) %></span></td>
              <td><span class="status-badge status-completed"><i class="fas fa-check"></i> Completed</span></td>
            </tr>
            <% } %>
            </tbody>
          </table>
        </div>
        <% } %>
      </div>
    </div>

  </div><!-- /main-content -->
</div><!-- /dashboard -->
</body>
</html>
