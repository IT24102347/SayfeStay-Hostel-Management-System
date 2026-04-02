<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*, org.example.dao.*, java.util.*, java.text.*" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null || !"Owner".equalsIgnoreCase(user.getRole())) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

  RoomDAO roomDAO = new RoomDAO();
  BookingDAO bookingDAO = new BookingDAO();

  List<Room> allRooms = roomDAO.getAllRooms();
  List<Room> availableRooms = roomDAO.getAvailableRooms();
  List<RoomBooking> pendingBookings = bookingDAO.getPendingBookings();

  int totalRooms = allRooms.size();
  int availableCount = availableRooms.size();
  int occupiedCount = totalRooms - availableCount;
  int pendingRequests = pendingBookings.size();

  DecimalFormat df = new DecimalFormat("#,###");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Room Management - SafeStay Owner</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
    body { background: #f8fafc; display: flex; min-height: 100vh; }

    .sidebar {
      width: 280px; background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
      color: white; position: fixed; height: 100vh; overflow-y: auto;
    }
    .sidebar-header { padding: 30px 25px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
    .sidebar-header h2 { font-size: 28px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 10px; }
    .owner-profile { padding: 25px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
    .owner-avatar {
      width: 80px; height: 80px; background: #4f46e5; border-radius: 50%;
      display: flex; align-items: center; justify-content: center; font-size: 32px; font-weight: 700;
      margin: 0 auto 15px;
    }
    .nav-menu { padding: 20px 0; }
    .nav-item {
      display: flex; align-items: center; padding: 12px 25px; color: rgba(255,255,255,0.8);
      text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent;
    }
    .nav-item:hover, .nav-item.active {
      background: rgba(79, 70, 229, 0.2); color: white; border-left-color: #4f46e5;
    }
    .nav-item i { width: 25px; margin-right: 15px; }

    .main-content { flex: 1; margin-left: 280px; padding: 30px; }
    .header {
      background: white; border-radius: 20px; padding: 25px 30px; margin-bottom: 25px;
      box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
      display: flex; justify-content: space-between; align-items: center;
    }
    .header h1 { font-size: 28px; color: #0f172a; display: flex; align-items: center; gap: 12px; }
    .header h1 i { color: #4f46e5; }
    .back-btn {
      background: #f1f5f9; color: #0f172a; border: none; padding: 12px 25px; border-radius: 12px;
      font-weight: 600; display: flex; align-items: center; gap: 10px; cursor: pointer; text-decoration: none;
    }
    .back-btn:hover { background: #e2e8f0; }

    .stats-grid {
      display: grid; grid-template-columns: repeat(4, 1fr); gap: 25px; margin-bottom: 30px;
    }
    .stat-card {
      background: white; border-radius: 16px; padding: 25px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
      border-left: 4px solid #4f46e5;
    }
    .stat-value { font-size: 32px; font-weight: 700; color: #0f172a; }
    .stat-label { color: #64748b; font-size: 14px; }

    .add-btn {
      background: #4f46e5; color: white; border: none; padding: 15px 30px; border-radius: 12px;
      font-weight: 600; display: flex; align-items: center; gap: 10px; cursor: pointer; margin-bottom: 25px;
    }
    .add-btn:hover { background: #6366f1; }

    .rooms-grid {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 25px; margin-bottom: 30px;
    }
    .room-card {
      background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
      transition: all 0.3s; border: 1px solid #e2e8f0;
    }
    .room-card:hover { transform: translateY(-5px); box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); border-color: #4f46e5; }
    .room-header {
      padding: 20px; background: linear-gradient(135deg, #4f46e5, #6366f1); color: white;
      display: flex; justify-content: space-between; align-items: center;
    }
    .room-number { font-size: 24px; font-weight: 700; }
    .room-type { background: rgba(255,255,255,0.2); padding: 4px 12px; border-radius: 20px; font-size: 12px; }
    .room-body { padding: 20px; }
    .room-details {
      display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;
    }
    .detail-item { text-align: center; }
    .detail-value { font-size: 18px; font-weight: 700; color: #0f172a; }
    .detail-label { font-size: 12px; color: #64748b; }

    .facilities { margin-bottom: 15px; }
    .facility-tag {
      display: inline-block; background: #f1f5f9; padding: 4px 10px; border-radius: 20px;
      font-size: 11px; margin: 2px; color: #475569;
    }
    .facility-tag i { margin-right: 4px; color: #4f46e5; }

    .price {
      font-size: 20px; font-weight: 700; color: #10b981; margin-bottom: 15px;
    }
    .status-badge {
      display: inline-block; padding: 5px 15px; border-radius: 20px; font-size: 12px; font-weight: 600;
    }
    .status-available { background: #d4edda; color: #155724; }
    .status-occupied { background: #fff3cd; color: #856404; }
    .status-maintenance { background: #f8d7da; color: #721c24; }

    .room-actions { display: flex; gap: 10px; margin-top: 15px; }
    .action-btn {
      flex: 1; padding: 8px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer;
      transition: all 0.3s;
    }
    .btn-edit { background: #4f46e5; color: white; }
    .btn-delete { background: #ef4444; color: white; }

    @media (max-width: 1200px) {
      .stats-grid { grid-template-columns: repeat(2, 1fr); }
      .rooms-grid { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 992px) {
      .sidebar { width: 80px; }
      .sidebar .nav-item span { display: none; }
      .main-content { margin-left: 80px; }
    }
    @media (max-width: 768px) {
      .stats-grid, .rooms-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
<div class="sidebar">
  <div class="sidebar-header"><h2><i class="fas fa-hotel"></i><span>SafeStay</span></h2></div>
  <div class="owner-profile">
    <div class="owner-avatar"><%= user.getFullName() != null ? user.getFullName().charAt(0) : 'O' %></div>
    <h4><%= user.getFullName() != null ? user.getFullName() : "Owner" %></h4>
    <p><%= user.getUserId() %></p>
  </div>
  <div class="nav-menu">
    <a href="<%= request.getContextPath() %>/dashboard/owner" class="nav-item"><i class="fas fa-home"></i><span>Dashboard</span></a>
    <a href="<%= request.getContextPath() %>/dashboard/owner/students" class="nav-item"><i class="fas fa-user-graduate"></i><span>Students</span></a>
    <a href="<%= request.getContextPath() %>/dashboard/owner/rooms" class="nav-item active"><i class="fas fa-door-open"></i><span>Rooms</span></a>
    <a href="<%= request.getContextPath() %>/dashboard/owner/pending-bookings.jsp" class="nav-item"><i class="fas fa-clock"></i><span>Requests</span></a>
    <a href="<%= request.getContextPath() %>/logout" class="nav-item" style="margin-top:50px;"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
  </div>
</div>

<div class="main-content">
  <div class="header">
    <h1><i class="fas fa-door-open"></i> Room Management</h1>
    <a href="<%= request.getContextPath() %>/dashboard/owner" class="back-btn"><i class="fas fa-arrow-left"></i> Back</a>
  </div>

  <div class="stats-grid">
    <div class="stat-card"><div class="stat-value"><%= totalRooms %></div><div class="stat-label">Total Rooms</div></div>
    <div class="stat-card"><div class="stat-value"><%= availableCount %></div><div class="stat-label">Available</div></div>
    <div class="stat-card"><div class="stat-value"><%= occupiedCount %></div><div class="stat-label">Occupied</div></div>
    <div class="stat-card"><div class="stat-value"><%= pendingRequests %></div><div class="stat-label">Requests</div></div>
  </div>

  <button class="add-btn" onclick="location.href='add-room.jsp'"><i class="fas fa-plus"></i> Add New Room</button>

  <div class="rooms-grid">
    <% for (Room room : allRooms) { %>
    <div class="room-card">
      <div class="room-header">
        <span class="room-number">Room <%= room.getRoomNumber() %></span>
        <span class="room-type"><%= room.getRoomType() %></span>
      </div>
      <div class="room-body">
        <div class="room-details">
          <div class="detail-item"><div class="detail-value">Floor <%= room.getFloor() %></div><div class="detail-label">Floor</div></div>
          <div class="detail-item"><div class="detail-value"><%= room.getCapacity() %></div><div class="detail-label">Capacity</div></div>
          <div class="detail-item"><div class="detail-value"><%= room.getOccupied() %></div><div class="detail-label">Occupied</div></div>
          <div class="detail-item"><div class="detail-value"><%= room.getAvailableBeds() %></div><div class="detail-label">Available</div></div>
        </div>
        <div class="facilities">
          <% if (room.isHasAc()) { %><span class="facility-tag"><i class="fas fa-wind"></i> AC</span><% } %>
          <% if (room.isHasFan()) { %><span class="facility-tag"><i class="fas fa-fan"></i> Fan</span><% } %>
          <% if (room.isHasAttachedBathroom()) { %><span class="facility-tag"><i class="fas fa-shower"></i> Attached Bath</span><% } %>
        </div>
        <div class="price">Rs. <%= df.format(room.getPriceMonthly()) %> <span style="font-size:14px;">/month</span></div>
        <span class="status-badge status-<%= room.getStatus().toLowerCase() %>"><%= room.getStatus() %></span>
        <div class="room-actions">
          <button class="action-btn btn-edit" onclick="editRoom(<%= room.getId() %>)"><i class="fas fa-edit"></i> Edit</button>
          <button class="action-btn btn-delete" onclick="deleteRoom(<%= room.getId() %>)"><i class="fas fa-trash"></i> Delete</button>
        </div>
      </div>
    </div>
    <% } %>
  </div>
</div>

<script>
  function editRoom(id) { location.href = 'edit-room.jsp?id=' + id; }
  function deleteRoom(id) { if(confirm('Delete this room?')) location.href = '<%= request.getContextPath() %>/owner/delete-room?id=' + id; }
</script>
</body>
</html>