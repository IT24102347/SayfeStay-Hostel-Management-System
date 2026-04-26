<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, org.example.model.User, java.text.SimpleDateFormat" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  List<Map<String, Object>> history = (List<Map<String, Object>>) request.getAttribute("cleaningHistory");
  Map<String, Object> stats = (Map<String, Object>) request.getAttribute("cleaningStats");
  List<Map<String, Object>> cleaningRequests = (List<Map<String, Object>>) request.getAttribute("cleaningRequests");

  if (history == null) history = new ArrayList<Map<String, Object>>();
  if (stats == null) stats = new HashMap<String, Object>();
  if (cleaningRequests == null) cleaningRequests = new ArrayList<Map<String, Object>>();

  int currentYear = request.getAttribute("currentYear") != null ? (Integer) request.getAttribute("currentYear") : Calendar.getInstance().get(Calendar.YEAR);
  int currentMonth = request.getAttribute("currentMonth") != null ? (Integer) request.getAttribute("currentMonth") : Calendar.getInstance().get(Calendar.MONTH) + 1;

  Set<String> cleaningDates = new HashSet<String>();
  Map<String, String> cleaningTypeMap = new HashMap<String, String>();
  for (Map<String, Object> req : cleaningRequests) {
    java.sql.Date date = (java.sql.Date) req.get("date");
    String type = (String) req.get("type");
    if (date != null) {
      String dateStr = new SimpleDateFormat("yyyy-MM-dd").format(date);
      cleaningDates.add(dateStr);
      cleaningTypeMap.put(dateStr, type);
    }
  }

  Calendar cal = Calendar.getInstance();
  cal.set(currentYear, currentMonth - 1, 1);
  int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
  int firstDayOfWeek = cal.get(Calendar.DAY_OF_WEEK);

  String[] monthNames = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
  String[] weekDays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
  SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");

  String successMsg = (String) session.getAttribute("successMsg");
  String errorMsg = (String) session.getAttribute("errorMsg");
  if(successMsg != null) session.removeAttribute("successMsg");
  if(errorMsg != null) session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Cleaning Dashboard | SafeStay</title>
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
    .user-profile {
      display: flex;
      align-items: center;
      gap: 15px;
      padding: 20px;
      background: rgba(255,255,255,0.1);
      border-radius: 15px;
      margin-bottom: 30px;
    }
    .avatar { width: 50px; height: 50px; background: #ffd700; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #1a237e; font-weight: bold; font-size: 20px; }
    .user-info h4 { font-size: 16px; }
    .user-info p { font-size: 12px; opacity: 0.7; }
    .nav-item { padding: 12px 15px; border-radius: 10px; margin-bottom: 10px; cursor: pointer; display: flex; align-items: center; gap: 10px; }
    .nav-item:hover { background: rgba(255,255,255,0.15); }
    .nav-item.active { background: rgba(255,255,255,0.15); color: #ffd700; }
    .main-content { flex: 1; margin-left: 280px; padding: 30px; }
    .stats-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; margin-bottom: 30px; }
    .stat-card { background: white; padding: 20px; border-radius: 15px; text-align: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
    .stat-card h3 { font-size: 13px; color: #666; margin-bottom: 8px; }
    .stat-card .number { font-size: 28px; font-weight: 700; color: #333; }
    .stat-card .icon { font-size: 28px; margin-bottom: 10px; }
    .cleaning-card { background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%); border-radius: 20px; padding: 25px; margin-bottom: 30px; color: white; }
    .cleaning-card h2 { margin-bottom: 15px; display: flex; align-items: center; gap: 10px; }
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
    .form-group input { width: 100%; padding: 12px; border: none; border-radius: 10px; }
    .btn-group { display: flex; gap: 15px; }
    .btn-clean { flex: 1; padding: 12px; border: none; border-radius: 40px; font-size: 16px; font-weight: 600; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; }
    .btn-self { background: #27ae60; color: white; }
    .btn-staff { background: #ff9800; color: white; }
    .calendar-card { background: white; border-radius: 20px; overflow: hidden; margin-bottom: 30px; }
    .calendar-header { background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%); color: white; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; }
    .calendar-nav button { background: rgba(255,255,255,0.2); border: none; color: white; padding: 8px 15px; border-radius: 8px; cursor: pointer; margin: 0 5px; }
    .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); text-align: center; }
    .calendar-day-name { padding: 12px; background: #f8f9fa; font-weight: 600; }
    .calendar-day { padding: 15px 8px; min-height: 80px; border-bottom: 1px solid #eee; border-right: 1px solid #eee; }
    .calendar-day.empty { background: #fafafa; }
    .day-number { font-size: 14px; font-weight: 500; margin-bottom: 8px; }
    .cleaning-badge { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin: 2px; }
    .badge-self { background: #27ae60; }
    .badge-staff { background: #ff9800; }
    .history-card { background: white; border-radius: 20px; overflow: hidden; }
    .history-header { background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%); color: white; padding: 15px 20px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    th { background: #f8f9fa; font-weight: 600; }
    .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 500; display: inline-block; }
    .status-completed { background: #d4edda; color: #155724; }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-accepted { background: #cce5ff; color: #004085; }
    .alert-success, .alert-error { padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; }
    .alert-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
    .alert-error { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }
    .na-text { color: #999; font-style: italic; }
  </style>
</head>
<body>
<div class="dashboard">
  <div class="sidebar">
    <div class="logo-area"><div class="logo">Safe<span>Stay</span></div></div>
    <div class="user-profile"><div class="avatar"><%= user.getFullName().charAt(0) %></div><div class="user-info"><h4><%= user.getFullName() %></h4><p>ID: <%= user.getUserId() %></p></div></div>
    <div class="nav-item active"><i class="fas fa-broom"></i> Cleaning</div>
    <div class="nav-item" onclick="location.href='laundry-dashboard.jsp'"><i class="fas fa-tshirt"></i> Laundry</div>
    <div class="nav-item" onclick="location.href='<%= request.getContextPath() %>/logout'"><i class="fas fa-sign-out-alt"></i> Logout</div>
  </div>

  <div class="main-content">
    <% if(successMsg != null) { %>
    <div class="alert-success"><i class="fas fa-check-circle"></i> <%= successMsg %></div>
    <% } %>
    <% if(errorMsg != null) { %>
    <div class="alert-error"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div>
    <% } %>

    <div class="stats-grid">
      <div class="stat-card"><div class="icon"><i class="fas fa-calendar-check" style="color:#27ae60;"></i></div><h3>Total</h3><div class="number"><%= stats.getOrDefault("total", 0) %></div></div>
      <div class="stat-card"><div class="icon"><i class="fas fa-user-check" style="color:#27ae60;"></i></div><h3>Self</h3><div class="number"><%= stats.getOrDefault("self_cleaned", 0) %></div></div>
      <div class="stat-card"><div class="icon"><i class="fas fa-user-cog" style="color:#ff9800;"></i></div><h3>Staff</h3><div class="number"><%= stats.getOrDefault("staff_requested", 0) %></div></div>
      <div class="stat-card"><div class="icon"><i class="fas fa-check-circle" style="color:#2196f3;"></i></div><h3>Completed</h3><div class="number"><%= stats.getOrDefault("completed", 0) %></div></div>
      <div class="stat-card"><div class="icon"><i class="fas fa-rupee-sign" style="color:#f44336;"></i></div><h3>Spent</h3><div class="number">Rs. <%= String.format("%,.0f", stats.getOrDefault("total_spent", 0.0)) %></div></div>
    </div>

    <div class="cleaning-card">
      <h2><i class="fas fa-broom"></i> Room Hygiene</h2>
      <form action="<%= request.getContextPath() %>/cleaning/request" method="POST">
        <div class="form-row">
          <div class="form-group"><input type="text" name="roomNo" placeholder="Room Number" required></div>
          <div class="form-group"><input type="number" name="floorNo" placeholder="Floor Number" required></div>
        </div>
        <div class="btn-group">
          <button type="submit" name="cleaningType" value="Self" class="btn-clean btn-self"><i class="fas fa-check-circle"></i> Self Clean (Free)</button>
          <button type="submit" name="cleaningType" value="Staff" class="btn-clean btn-staff"><i class="fas fa-user-cog"></i> Request Staff (Rs.500)</button>
        </div>
      </form>
    </div>

    <div class="calendar-card">
      <div class="calendar-header"><h3><%= monthNames[currentMonth-1] %> <%= currentYear %></h3>
        <div class="calendar-nav"><button onclick="changeMonth(-1)"><i class="fas fa-chevron-left"></i></button><button onclick="changeMonth(1)"><i class="fas fa-chevron-right"></i></button></div>
      </div>
      <div class="calendar-grid">
        <% for (String day : weekDays) { %><div class="calendar-day-name"><%= day %></div><% } %>
        <% for (int i = 1; i < firstDayOfWeek; i++) { %><div class="calendar-day empty"></div><% } %>
        <% for (int d = 1; d <= daysInMonth; d++) {
          String dateStr = currentYear + "-" + String.format("%02d", currentMonth) + "-" + String.format("%02d", d);
          String badgeClass = "Self".equals(cleaningTypeMap.get(dateStr)) ? "badge-self" : ("Staff".equals(cleaningTypeMap.get(dateStr)) ? "badge-staff" : "");
        %>
        <div class="calendar-day"><div class="day-number"><%= d %></div><div class="cleaning-badge <%= badgeClass %>"></div></div>
        <% } %>
      </div>
    </div>

    <div class="history-card">
      <div class="history-header"><h3><i class="fas fa-history"></i> Cleaning History</h3></div>
      <div style="overflow-x: auto; padding: 0 20px 20px 20px;">
        <table>
          <thead><tr><th>Date</th><th>Room</th><th>Floor</th><th>Type</th><th>Cost</th><th>Assigned Date</th><th>Assigned Time</th><th>Status</th></tr></thead>
          <tbody>
          <% for (Map<String, Object> row : history) {
            String type = (String) row.get("type");
            String status = (String) row.get("status");
            String statusClass = "Completed".equals(status) ? "status-completed" : ("Accepted".equals(status) ? "status-accepted" : "status-pending");
            String assignedDate = (String) row.get("assigned_date");
            String assignedTime = (String) row.get("assigned_time");
          %>
          <tr>
            <td><%= sdf.format((java.util.Date) row.get("date")) %></td>
            <td><%= row.get("roomNo") %></td>
            <td><%= row.get("floorNo") %></td>
            <td><strong><%= type %></strong></td>
            <td>Rs. <%= String.format("%.2f", row.get("price")) %></td>
            <td class="<%= "N/A".equals(assignedDate) ? "na-text" : "" %>"><%= assignedDate %></td>
            <td class="<%= "N/A".equals(assignedTime) ? "na-text" : "" %>"><%= assignedTime %></td>
            <td><span class="status-badge <%= statusClass %>"><%= status %></span></td>
          </tr>
          <% } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
<script>
  function changeMonth(delta) {
    let year = <%= currentYear %>, month = <%= currentMonth %> + delta;
    if (month > 12) { month = 1; year++; }
    else if (month < 1) { month = 12; year--; }
    window.location.href = '<%= request.getContextPath() %>/cleaning/request?year=' + year + '&month=' + month;
  }
</script>
</body>
</html>