<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*" %>
<%@ page import="org.example.dao.LaundryDAO" %>
<%@ page import="org.example.dao.NotificationDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  LaundryDAO laundryDAO = new LaundryDAO();
  NotificationDAO notificationDAO = new NotificationDAO();

  List<LaundryItem> items = laundryDAO.getAllLaundryItems();
  List<LaundryRequest> requests = laundryDAO.getStudentRequests(user.getUserId());
  List<Notification> notifications = notificationDAO.getUnreadNotifications(user.getUserId());

  if (items == null) items = new ArrayList<>();
  if (requests == null) requests = new ArrayList<>();
  if (notifications == null) notifications = new ArrayList<>();

  int pendingCount = 0, acceptedCount = 0, completedCount = 0, rejectedCount = 0;
  double totalSpent = 0;
  int unreadCount = 0;

  for(LaundryRequest r : requests) {
    String status = r.getStatus() != null ? r.getStatus().toLowerCase() : "";
    if("pending".equals(status)) pendingCount++;
    else if("accepted".equals(status)) acceptedCount++;
    else if("completed".equals(status)) completedCount++;
    else if("rejected".equals(status)) rejectedCount++;
    totalSpent += r.getTotalCost();
  }

  for(Notification n : notifications) {
    if(!n.isRead()) unreadCount++;
  }

  double unpaidAmount = laundryDAO.getTotalUnpaidAmount(user.getUserId());
  int pendingRequestCount = laundryDAO.getPendingLaundryCount(user.getUserId());

  SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
  SimpleDateFormat timeFormat = new SimpleDateFormat("dd MMM yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Laundry Dashboard | SafeStay</title>
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
      overflow-y: auto;
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
    .avatar {
      width: 50px;
      height: 50px;
      background: #ffd700;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #1a237e;
      font-weight: bold;
      font-size: 20px;
    }
    .user-info h4 { font-size: 16px; margin-bottom: 5px; }
    .user-info p { font-size: 12px; opacity: 0.7; }
    .nav-item {
      padding: 12px 15px;
      border-radius: 10px;
      margin-bottom: 10px;
      cursor: pointer;
      transition: 0.3s;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .nav-item:hover { background: rgba(255,255,255,0.15); }
    .nav-item.active { background: rgba(255,255,255,0.15); color: #ffd700; }
    .main-content { flex: 1; margin-left: 280px; padding: 30px; }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(5, 1fr);
      gap: 15px;
      margin-bottom: 30px;
    }
    .stat-card {
      background: white;
      padding: 15px;
      border-radius: 15px;
      text-align: center;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      cursor: pointer;
      transition: transform 0.3s;
    }
    .stat-card:hover { transform: translateY(-5px); }
    .stat-card h3 { font-size: 12px; color: #666; margin-bottom: 8px; }
    .stat-card .number { font-size: 24px; font-weight: 700; color: #333; }
    .stat-card .icon { font-size: 24px; margin-bottom: 8px; }

    /* Payment Warning Box */
    .payment-warning {
      background: #fff3cd;
      border-left: 4px solid #ff9800;
      border-radius: 12px;
      padding: 15px 20px;
      margin-bottom: 25px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 15px;
    }
    .payment-warning-content {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .payment-warning-icon {
      font-size: 24px;
      color: #ff9800;
    }
    .payment-warning-text strong {
      font-size: 15px;
      color: #856404;
    }
    .payment-warning-amount {
      font-size: 22px;
      font-weight: 800;
      color: #dc3545;
      margin-left: 10px;
    }
    .pay-now-warning-btn {
      background: #ff9800;
      color: white;
      border: none;
      padding: 8px 20px;
      border-radius: 40px;
      cursor: pointer;
      font-weight: 600;
    }
    .pay-now-warning-btn:hover {
      background: #f57c00;
    }

    .card {
      background: white;
      border-radius: 15px;
      margin-bottom: 30px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      overflow: hidden;
    }
    .blue-header {
      background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%);
      padding: 20px 25px;
      color: white;
    }
    .blue-header h2 { margin: 0; display: flex; align-items: center; gap: 10px; }
    .blue-header .subtitle { font-size: 13px; opacity: 0.8; margin-top: 5px; }
    .form-container { padding: 25px; }

    .form-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 20px;
      margin-bottom: 20px;
    }
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 8px; font-weight: 500; color: #555; }
    .form-control {
      width: 100%;
      padding: 10px;
      border: 1px solid #ddd;
      border-radius: 8px;
      font-size: 14px;
    }

    .items-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
      gap: 18px;
      margin-top: 20px;
      max-height: 550px;
      overflow-y: auto;
      padding: 15px;
      background: #f8f9fa;
      border-radius: 15px;
    }

    .item-card {
      border-radius: 15px;
      padding: 18px;
      transition: all 0.3s;
      cursor: pointer;
      position: relative;
      box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }
    .item-card:hover {
      transform: translateY(-8px);
      box-shadow: 0 15px 30px rgba(0,0,0,0.15);
    }
    .item-card::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      height: 3px;
      background: linear-gradient(90deg, #ffd700, #ff9800, #ff6b6b);
      border-radius: 0 0 15px 15px;
    }
    .item-name {
      font-weight: 700;
      margin-bottom: 10px;
      font-size: 15px;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .item-name i {
      font-size: 18px;
      background: rgba(0,0,0,0.1);
      padding: 8px;
      border-radius: 50%;
    }
    .item-price {
      font-weight: 700;
      margin-bottom: 15px;
      font-size: 18px;
    }
    .item-quantity {
      width: 100%;
      padding: 10px;
      border: 2px solid rgba(0,0,0,0.1);
      border-radius: 10px;
      text-align: center;
      font-weight: 600;
      font-size: 14px;
      background: white;
    }
    .subtotal-text {
      font-size: 12px;
      margin-top: 10px;
      text-align: center;
      padding: 5px;
      border-radius: 8px;
      background: rgba(255,255,255,0.8);
      font-weight: 500;
    }

    .item-card[data-category="clothing"] { background: linear-gradient(135deg, #FFF5F5 0%, #FFE4E1 100%); border-left: 4px solid #E91E63; }
    .item-card[data-category="bedsheets"] { background: linear-gradient(135deg, #E8F0FE 0%, #D4E4FC 100%); border-left: 4px solid #2196F3; }
    .item-card[data-category="towels"] { background: linear-gradient(135deg, #E8F5E9 0%, #C8E6C9 100%); border-left: 4px solid #4CAF50; }
    .item-card[data-category="traditional"] { background: linear-gradient(135deg, #FFF3E0 0%, #FFE0B2 100%); border-left: 4px solid #FF9800; }
    .item-card[data-category="other"] { background: linear-gradient(135deg, #F3E5F5 0%, #E1BEE7 100%); border-left: 4px solid #9C27B0; }

    .total-box {
      background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%);
      color: white;
      padding: 15px 20px;
      border-radius: 12px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 20px;
    }

    .item-count-badge {
      background: #ffd700;
      color: #1a237e;
      padding: 2px 10px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: bold;
      margin-left: 10px;
    }

    .status-badge {
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 500;
      display: inline-block;
    }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-accepted { background: #d4edda; color: #155724; }
    .status-completed { background: #cce5ff; color: #004085; }
    .status-rejected { background: #f8d7da; color: #721c24; }

    .btn {
      padding: 10px 20px;
      border-radius: 8px;
      border: none;
      cursor: pointer;
      font-weight: 500;
      transition: all 0.3s;
    }
    .btn-primary { background: #1a237e; color: white; }
    .btn-primary:hover { background: #0d47a1; }
    .btn-outline { background: white; border: 1px solid #ddd; color: #333; }
    .btn-sm {
      padding: 5px 12px;
      font-size: 12px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      margin: 2px;
    }
    .btn-sm-primary { background: #1a237e; color: white; }

    .action-buttons {
      display: flex;
      justify-content: flex-end;
      gap: 15px;
      margin-top: 20px;
    }
    .btn-submit {
      background: #1a237e;
      color: white;
      border: none;
      padding: 12px 30px;
      border-radius: 40px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    .btn-submit:hover {
      background: #0d47a1;
      transform: translateY(-2px);
    }
    .btn-submit-disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    .btn-pay-small {
      background: #ff9800;
      color: white;
      border: none;
      padding: 12px 30px;
      border-radius: 40px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    .btn-pay-small:hover {
      background: #f57c00;
      transform: translateY(-2px);
    }

    .alert-success, .alert-error {
      padding: 12px 20px;
      border-radius: 8px;
      margin-bottom: 20px;
      border-left: 4px solid;
    }
    .alert-success { background: #d4edda; color: #155724; border-left-color: #28a745; }
    .alert-error { background: #f8d7da; color: #721c24; border-left-color: #dc3545; }

    .schedule-info, .date-warning {
      background: #e8f0fe;
      padding: 10px 15px;
      margin-top: 8px;
      border-radius: 8px;
      font-size: 12px;
      color: #1a237e;
    }
    .date-warning {
      background: #fff3cd;
      color: #856404;
    }
    .room-hint { font-size: 11px; margin-top: 4px; }

    .filter-buttons {
      display: flex;
      gap: 10px;
      padding: 15px 25px;
      background: white;
      border-bottom: 1px solid #eee;
      flex-wrap: wrap;
    }
    .filter-btn {
      padding: 8px 20px;
      border: none;
      border-radius: 20px;
      cursor: pointer;
      font-size: 13px;
      font-weight: 500;
      transition: all 0.3s;
      background: #f0f0f0;
      color: #666;
    }
    .filter-btn:hover { transform: translateY(-2px); }
    .filter-btn.active { background: #1a237e; color: white; }

    .requests-table {
      width: 100%;
      border-collapse: collapse;
    }
    .requests-table th, .requests-table td {
      padding: 12px;
      text-align: left;
      border-bottom: 1px solid #eee;
    }
    .requests-table th {
      background: #f8f9fa;
      font-weight: 600;
    }

    .empty-state { text-align: center; padding: 50px; color: #999; }
    .empty-state i { font-size: 48px; margin-bottom: 15px; color: #ddd; }

    .modal {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.5);
      justify-content: center;
      align-items: center;
      z-index: 1000;
    }
    .modal-content {
      background: white;
      border-radius: 15px;
      width: 90%;
      max-width: 500px;
      padding: 25px;
      max-height: 80vh;
      overflow-y: auto;
    }
    .chat-messages {
      height: 300px;
      overflow-y: auto;
      border: 1px solid #ddd;
      padding: 10px;
      margin-bottom: 10px;
      background: #f9f9f9;
      border-radius: 8px;
    }
    .message {
      margin-bottom: 10px;
      padding: 8px 12px;
      border-radius: 8px;
      max-width: 80%;
    }
    .message.student { background: #e3f2fd; margin-right: auto; }
    .message.staff { background: #f1f8e9; margin-left: auto; text-align: right; }
    .notification-item {
      padding: 12px 15px;
      border-bottom: 1px solid #eee;
      cursor: pointer;
    }
    .notification-item.unread { background: #e3f2fd; border-left: 3px solid #1a237e; }

    .photo-upload-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 15px;
      margin-top: 15px;
      margin-bottom: 20px;
    }
    .photo-upload-box {
      background: #f8f9fa;
      border: 2px dashed #ddd;
      border-radius: 12px;
      padding: 15px;
      text-align: center;
      transition: all 0.3s;
    }
    .photo-upload-box:hover {
      border-color: #1a237e;
      background: #e8f0fe;
    }
    .photo-upload-box i {
      font-size: 32px;
      color: #1a237e;
      margin-bottom: 10px;
      display: block;
    }
    .damage-note {
      background: #fff3cd;
      padding: 12px;
      border-radius: 8px;
      margin-bottom: 15px;
      font-size: 13px;
      color: #856404;
      display: flex;
      align-items: center;
      gap: 10px;
    }
  </style>
</head>
<body>
<div class="dashboard">
  <div class="sidebar">
    <div class="logo-area">
      <div class="logo">Safe<span>Stay</span></div>
      <div style="font-size: 12px;">Hostel Management</div>
    </div>
    <div class="user-profile">
      <div class="avatar"><%= user.getFullName().charAt(0) %></div>
      <div class="user-info">
        <h4><%= user.getFullName() %></h4>
        <p>Student ID: <%= user.getUserId() %></p>
      </div>
    </div>
    <div class="nav-item active"><i class="fas fa-tshirt"></i> Laundry Dashboard</div>
    <div class="nav-item" onclick="location.href='<%= request.getContextPath() %>/logout'"><i class="fas fa-sign-out-alt"></i> Logout</div>
  </div>

  <div class="main-content">
    <%
      String successMsg = (String) session.getAttribute("successMsg");
      String errorMsg = (String) session.getAttribute("errorMsg");
      if(successMsg != null) {
    %>
    <div class="alert-success"><i class="fas fa-check-circle"></i> <%= successMsg %></div>
    <% session.removeAttribute("successMsg"); %>
    <% } %>
    <% if(errorMsg != null) { %>
    <div class="alert-error"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div>
    <% session.removeAttribute("errorMsg"); %>
    <% } %>

    <!-- Statistics Cards -->
    <div class="stats-grid">
      <div class="stat-card" onclick="filterByStatus('pending')">
        <div class="icon"><i class="fas fa-clock" style="color:#ff9800;"></i></div>
        <h3>Pending</h3>
        <div class="number"><%= pendingCount %></div>
      </div>
      <div class="stat-card" onclick="filterByStatus('accepted')">
        <div class="icon"><i class="fas fa-check" style="color:#4caf50;"></i></div>
        <h3>Accepted</h3>
        <div class="number"><%= acceptedCount %></div>
      </div>
      <div class="stat-card" onclick="filterByStatus('completed')">
        <div class="icon"><i class="fas fa-check-double" style="color:#2196f3;"></i></div>
        <h3>Completed</h3>
        <div class="number"><%= completedCount %></div>
      </div>
      <div class="stat-card" onclick="filterByStatus('rejected')">
        <div class="icon"><i class="fas fa-times" style="color:#f44336;"></i></div>
        <h3>Rejected</h3>
        <div class="number"><%= rejectedCount %></div>
      </div>
      <div class="stat-card" onclick="showNotifications()">
        <div class="icon"><i class="fas fa-bell" style="color:#9c27b0;"></i></div>
        <h3>Notifications</h3>
        <div class="number"><%= unreadCount %></div>
      </div>
    </div>

    <!-- PAYMENT WARNING BOX -->
    <% if(unpaidAmount > 0) { %>
    <div class="payment-warning">
      <div class="payment-warning-content">
        <i class="fas fa-exclamation-triangle payment-warning-icon"></i>
        <div class="payment-warning-text">
          <strong>Payment Required!</strong>
          <span class="payment-warning-amount">Rs. <%= String.format("%,.2f", unpaidAmount) %></span>
          <span style="margin-left: 10px;">(<%= pendingRequestCount %> pending request)</span>
        </div>
      </div>
      <button class="pay-now-warning-btn" onclick="location.href='laundry-payment.jsp'">
        <i class="fas fa-credit-card"></i> Pay Now
      </button>
    </div>
    <% } %>

    <!-- New Laundry Request Form -->
    <div class="card">
      <div class="blue-header">
        <h2><i class="fas fa-plus-circle"></i> New Laundry Request</h2>
        <div class="subtitle">Select items and fill details below
          <span class="item-count-badge"><%= items.size() %> items available</span>
        </div>
      </div>
      <div class="form-container">
        <form action="<%= request.getContextPath() %>/student/laundry/request" method="POST" id="laundryForm" onsubmit="return validateForm()">
          <div class="form-grid">
            <div class="form-group">
              <label>Floor Number *</label>
              <select name="floorNo" id="floorNo" class="form-control" required onchange="updateFloorAndRooms()">
                <option value="">Select Floor</option>
                <option value="1">Floor 1 (Rooms 101-110)</option>
                <option value="2">Floor 2 (Rooms 201-210)</option>
                <option value="3">Floor 3 (Rooms 301-310)</option>
              </select>
              <div class="schedule-info" id="scheduleInfo" style="display:none;">
                <i class="fas fa-calendar-alt"></i> <span id="scheduleText"></span>
              </div>
            </div>
            <div class="form-group">
              <label>Room Number *</label>
              <select name="roomNo" id="roomNo" class="form-control" required>
                <option value="">-- Select Room --</option>
              </select>
              <div class="room-hint" id="roomHint"></div>
            </div>
            <div class="form-group">
              <label>Collection Date *</label>
              <input type="date" name="collectionDate" id="collectionDate" class="form-control" required>
              <div class="date-warning" id="dateWarning" style="display:none;">
                <i class="fas fa-exclamation-circle"></i> <span id="warningText"></span>
              </div>
            </div>
            <div class="form-group">
              <label>Service Type</label>
              <select name="serviceType" class="form-control">
                <option value="Wash and Iron">Wash and Iron</option>
                <option value="Wash Only">Wash Only</option>
                <option value="Iron Only">Iron Only</option>
              </select>
            </div>
            <div class="form-group">
              <label>Urgency</label>
              <select name="urgency" id="urgencySelect" class="form-control" onchange="calculateTotal()">
                <option value="Normal">Normal (24-48h)</option>
                <option value="Urgent">Urgent (+50%, 12h)</option>
              </select>
            </div>
          </div>

          <h3 style="margin: 20px 0 15px;">
            <i class="fas fa-tshirt"></i> Select Items
            <span style="font-size:12px; color:#666;">(Enter quantities)</span>
          </h3>

          <% if(items.isEmpty()) { %>
          <div class="empty-state" style="background: #fff3cd; border-radius: 10px; padding: 40px;">
            <i class="fas fa-exclamation-triangle" style="font-size: 48px; color: #ff9800;"></i>
            <p style="margin-top: 15px; font-weight: bold;">No laundry items found in database!</p>
            <p style="font-size: 12px; margin-top: 5px;">Please check laundry_items table</p>
          </div>
          <% } else { %>
          <div class="items-grid" id="itemsGrid">
            <% for(LaundryItem item : items) {
              int itemId = item.getId();
              String itemName = item.getItemName();
              double basePrice = item.getBasePrice();

              String category = "other";
              String icon = "fa-tshirt";
              String lowerName = itemName.toLowerCase();

              if(lowerName.contains("shirt") || lowerName.contains("t-shirt") || lowerName.contains("jeans") || lowerName.contains("trouser") || lowerName.contains("pants") || lowerName.contains("shorts") || lowerName.contains("kurta")) {
                category = "clothing";
                icon = "fa-tshirt";
              } else if(lowerName.contains("bed sheet") || lowerName.contains("pillow cover") || lowerName.contains("curtain")) {
                category = "bedsheets";
                icon = "fa-bed";
              } else if(lowerName.contains("towel")) {
                category = "towels";
                icon = "fa-towel";
              } else if(lowerName.contains("saree") || lowerName.contains("sarong")) {
                category = "traditional";
                icon = "fa-female";
              } else if(lowerName.contains("blanket") || lowerName.contains("comforter")) {
                category = "other";
                icon = "fa-blanket";
              }
            %>
            <div class="item-card" data-category="<%= category %>">
              <div class="item-name">
                <i class="fas <%= icon %>" style="color:#1a237e;"></i>
                <%= itemName %>
              </div>
              <div class="item-price">
                Rs. <%= String.format("%,.2f", basePrice) %>
                <small>per item</small>
              </div>
              <input type="number"
                     name="qty_<%= itemId %>"
                     class="item-quantity"
                     min="0"
                     value="0"
                     data-price="<%= basePrice %>"
                     onchange="updateItemSubtotal(this, <%= itemId %>, <%= basePrice %>)"
                     onkeyup="updateItemSubtotal(this, <%= itemId %>, <%= basePrice %>)">
              <div class="subtotal-text" id="subtotal_<%= itemId %>">
                <i class="fas fa-calculator"></i> Subtotal: Rs. 0.00
              </div>
            </div>
            <% } %>
          </div>
          <% } %>

          <div class="total-box">
            <span><i class="fas fa-calculator"></i> GRAND TOTAL</span>
            <span>Rs. <span id="totalCost">0.00</span></span>
          </div>
          <input type="hidden" name="totalCost" id="hiddenTotal" value="0">

          <!-- Action Buttons -->
          <div class="action-buttons">
            <button type="button" class="btn-pay-small" id="quickPayBtn" onclick="paySelectedItems()">
              <i class="fas fa-credit-card"></i> Pay Selected
            </button>
            <button type="submit" id="submitBtn" class="btn-submit">
              <i class="fas fa-paper-plane"></i> Submit Request
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Damage Report Section -->
    <div class="card">
      <div class="blue-header">
        <h2><i class="fas fa-exclamation-triangle"></i> Report Damage or Issue</h2>
        <div class="subtitle">Report any damaged items or issues with your laundry</div>
      </div>
      <div class="form-container">
        <div class="damage-note">
          <i class="fas fa-info-circle"></i>
          <span>Please provide clear photos of the damage. You can upload up to 4 photos.</span>
        </div>
        <form action="<%= request.getContextPath() %>/student/damage/report" method="POST" enctype="multipart/form-data" id="damageForm">
          <div class="form-grid">
            <div class="form-group">
              <label>Request No (Optional)</label>
              <select name="requestNo" class="form-control">
                <option value="">-- Select Laundry Request (Optional) --</option>
                <% for(LaundryRequest req : requests) { %>
                <option value="<%= req.getRequestNo() %>"><%= req.getRequestNo() %> - <%= req.getStatus() %></option>
                <% } %>
              </select>
            </div>
            <div class="form-group" style="grid-column: span 2;">
              <label>Damage Description *</label>
              <textarea name="description" rows="3" class="form-control" placeholder="Describe the damage or issue in detail..." required></textarea>
            </div>
          </div>

          <h3 style="margin: 20px 0 15px;">
            <i class="fas fa-camera"></i> Upload Photos (Max 4 photos)
            <span style="font-size:12px; color:#666;">(JPEG, PNG only - Max 5MB each)</span>
          </h3>

          <div class="photo-upload-grid">
            <div class="photo-upload-box">
              <i class="fas fa-image"></i>
              <label>Photo 1</label>
              <input type="file" name="photo1" accept="image/jpeg,image/png" class="form-control-file" onchange="previewImage(this, 'preview1')">
              <img id="preview1" style="display:none; max-width:100px; margin-top:8px; border-radius:5px;">
            </div>
            <div class="photo-upload-box">
              <i class="fas fa-image"></i>
              <label>Photo 2</label>
              <input type="file" name="photo2" accept="image/jpeg,image/png" class="form-control-file" onchange="previewImage(this, 'preview2')">
              <img id="preview2" style="display:none; max-width:100px; margin-top:8px; border-radius:5px;">
            </div>
            <div class="photo-upload-box">
              <i class="fas fa-image"></i>
              <label>Photo 3</label>
              <input type="file" name="photo3" accept="image/jpeg,image/png" class="form-control-file" onchange="previewImage(this, 'preview3')">
              <img id="preview3" style="display:none; max-width:100px; margin-top:8px; border-radius:5px;">
            </div>
            <div class="photo-upload-box">
              <i class="fas fa-image"></i>
              <label>Photo 4</label>
              <input type="file" name="photo4" accept="image/jpeg,image/png" class="form-control-file" onchange="previewImage(this, 'preview4')">
              <img id="preview4" style="display:none; max-width:100px; margin-top:8px; border-radius:5px;">
            </div>
          </div>

          <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
            <button type="reset" class="btn btn-outline" onclick="clearDamageForm()">Clear</button>
            <button type="submit" class="btn btn-primary">Submit Damage Report</button>
          </div>
        </form>
      </div>
    </div>

    <!-- History Section -->
    <div class="card">
      <div class="blue-header">
        <h2><i class="fas fa-history"></i> Laundry History</h2>
        <div class="subtitle">Total: <%= requests.size() %> requests | Total Spent: Rs. <%= String.format("%,.2f", totalSpent) %></div>
      </div>

      <div class="filter-buttons">
        <button class="filter-btn active" onclick="filterHistory('all')">All</button>
        <button class="filter-btn" onclick="filterHistory('pending')">Pending (<%= pendingCount %>)</button>
        <button class="filter-btn" onclick="filterHistory('accepted')">Accepted (<%= acceptedCount %>)</button>
        <button class="filter-btn" onclick="filterHistory('completed')">Completed (<%= completedCount %>)</button>
        <button class="filter-btn" onclick="filterHistory('rejected')">Rejected (<%= rejectedCount %>)</button>
      </div>

      <div style="overflow-x: auto; padding: 0 25px 25px 25px;">
        <% if(requests.isEmpty()) { %>
        <div class="empty-state">
          <i class="fas fa-box-open"></i>
          <p>No laundry requests found. Use the form above to create your first request!</p>
        </div>
        <% } else { %>
        <table class="requests-table">
          <thead>
          <tr>
            <th>Request No</th>
            <th>Date</th>
            <th>Floor/Room</th>
            <th>Service</th>
            <th>Items</th>
            <th>Total</th>
            <th>Status</th>
            <th>Payment</th>
            <th>Action</th>
          </thead>
          <tbody id="requestsTableBody">
          <% for(LaundryRequest req : requests) {
            String statusClass = req.getStatus() != null ? req.getStatus().toLowerCase() : "pending";
            String paymentStatus = req.getPaymentStatus() != null ? req.getPaymentStatus() : "Pending";
            String paymentBadge = "Paid".equals(paymentStatus) ?
                    "<span style='background:#d4edda; color:#28a745; padding:2px 8px; border-radius:12px;'><i class='fas fa-check-circle'></i> Paid</span>" :
                    "<span style='background:#fff3cd; color:#856404; padding:2px 8px; border-radius:12px;'><i class='fas fa-clock'></i> Pending</span>";
          %>
          <tr data-status="<%= statusClass %>">
            <td><strong><%= req.getRequestNo() %></strong>
            <td><%= dateFormat.format(req.getCollectionDate()) %>
            <td>Floor <%= req.getFloorNo() %> / Room <%= req.getRoomNo() %>
            <td><%= req.getServiceType() %><br><small><%= req.getUrgency() %></small>
            <td><%= req.getTotalItems() > 0 ? req.getTotalItems() + " items" : "-" %>
            <td><strong>Rs. <%= String.format("%,.2f", req.getTotalCost()) %></strong>
            <td><span class="status-badge status-<%= statusClass %>"><%= req.getStatus() %></span>
            <td><%= paymentBadge %>
            <td><button class="btn-sm btn-sm-primary" onclick="openChat('<%= req.getRequestNo() %>')"><i class="fas fa-comment"></i> Chat</button>
          </tr>
          <% } %>
          </tbody>
        </table>
        <% } %>
      </div>
    </div>
  </div>
</div>

<!-- Chat Modal -->
<div id="chatModal" class="modal">
  <div class="modal-content">
    <h3><i class="fas fa-comments"></i> Chat for Request: <span id="chatRequestNo"></span></h3>
    <div id="chatMessages" class="chat-messages"><div style="text-align:center; padding:20px;">Loading...</div></div>
    <textarea id="chatMessageInput" rows="2" style="width:100%; padding:10px; margin-bottom:10px; border:1px solid #ddd; border-radius:8px;" placeholder="Type your message..."></textarea>
    <button onclick="sendChatMessage()" class="btn btn-primary" style="width:100%; margin-bottom:10px;"><i class="fas fa-paper-plane"></i> Send</button>
    <button onclick="closeChatModal()" class="btn btn-outline" style="width:100%;">Close</button>
  </div>
</div>

<!-- Notifications Modal -->
<div id="notificationsModal" class="modal">
  <div class="modal-content">
    <h3><i class="fas fa-bell"></i> Notifications</h3>
    <div class="notification-list">
      <% if(notifications.isEmpty()) { %>
      <div class="empty-state"><i class="fas fa-bell-slash"></i><p>No notifications</p></div>
      <% } else { for(Notification n : notifications) { %>
      <div class="notification-item <%= !n.isRead() ? "unread" : "" %>" onclick="markNotificationRead(<%= n.getId() %>)">
        <div style="font-weight:bold;"><%= n.getTitle() %></div>
        <div style="font-size:13px; color:#666;"><%= n.getMessage() %></div>
        <div style="font-size:11px; color:#999; margin-top:5px;"><%= timeFormat.format(n.getCreatedAt()) %></div>
      </div>
      <% } } %>
    </div>
    <button onclick="closeNotificationsModal()" class="btn btn-outline" style="width:100%; margin-top:15px;">Close</button>
  </div>
</div>

<script>
  let currentChatRequest = null;
  let chatRefreshInterval = null;

  const floorConfig = {
    1: { days: ['Monday', 'Wednesday'], dayNumbers: [1, 3], scheduleText: 'Collection available on Mondays and Wednesdays only', roomRange: { min: 101, max: 110 }, rooms: generateRooms(101, 110) },
    2: { days: ['Tuesday', 'Thursday'], dayNumbers: [2, 4], scheduleText: 'Collection available on Tuesdays and Thursdays only', roomRange: { min: 201, max: 210 }, rooms: generateRooms(201, 210) },
    3: { days: ['Friday', 'Sunday'], dayNumbers: [5, 0], scheduleText: 'Collection available on Fridays and Sundays only', roomRange: { min: 301, max: 310 }, rooms: generateRooms(301, 310) }
  };

  // Helper function to generate room numbers
  function generateRooms(start, end) {
    const rooms = [];
    for (let i = start; i <= end; i++) {
      rooms.push(i);
    }
    return rooms;
  }

  // Update floor settings and populate room dropdown
  function updateFloorAndRooms() {
    const floor = document.getElementById('floorNo').value;
    const scheduleInfo = document.getElementById('scheduleInfo');
    const scheduleText = document.getElementById('scheduleText');
    const roomSelect = document.getElementById('roomNo');
    const roomHint = document.getElementById('roomHint');
    const dateInput = document.getElementById('collectionDate');

    // Clear current room options
    roomSelect.innerHTML = '<option value="">-- Select Room --</option>';

    if (floor && floorConfig[floor]) {
      // Populate room dropdown
      const rooms = floorConfig[floor].rooms;
      for (let i = 0; i < rooms.length; i++) {
        const option = document.createElement('option');
        option.value = rooms[i];
        option.textContent = rooms[i];
        roomSelect.appendChild(option);
      }

      scheduleInfo.style.display = 'block';
      scheduleText.innerHTML = floorConfig[floor].scheduleText;
      roomHint.innerHTML = "Valid rooms for Floor " + floor + ": " + floorConfig[floor].roomRange.min + " - " + floorConfig[floor].roomRange.max;
      roomHint.style.color = '#28a745';
      dateInput.value = '';
      document.getElementById('dateWarning').style.display = 'none';

      const today = new Date();
      const yyyy = today.getFullYear();
      const mm = String(today.getMonth() + 1).padStart(2, '0');
      const dd = String(today.getDate()).padStart(2, '0');
      dateInput.min = yyyy + '-' + mm + '-' + dd;

      dateInput.onchange = function() { validateDateForFloor(floor, this.value); };
    } else {
      scheduleInfo.style.display = 'none';
      roomHint.innerHTML = '';
    }
  }

  function validateRoomNumber() {
    const floor = document.getElementById('floorNo').value;
    const roomNo = document.getElementById('roomNo').value;
    const roomHint = document.getElementById('roomHint');
    if (!floor || !roomNo) return true;
    const roomNum = parseInt(roomNo);
    const config = floorConfig[floor];
    if (config && (roomNum < config.roomRange.min || roomNum > config.roomRange.max)) {
      roomHint.innerHTML = "Invalid room! Floor " + floor + " rooms are " + config.roomRange.min + " - " + config.roomRange.max;
      roomHint.style.color = '#dc3545';
      return false;
    } else if (config) {
      roomHint.innerHTML = "Valid room for Floor " + floor;
      roomHint.style.color = '#28a745';
      return true;
    }
    return true;
  }

  function validateDateForFloor(floor, dateValue) {
    if (!dateValue || !floor) return true;
    const selectedDate = new Date(dateValue);
    const dayOfWeek = selectedDate.getDay();
    const allowedDays = floorConfig[floor]?.dayNumbers || [];
    if (!allowedDays.includes(dayOfWeek)) {
      const warningText = document.getElementById('warningText');
      const dateWarning = document.getElementById('dateWarning');
      warningText.innerHTML = "For Floor " + floor + ", laundry collection is only available on " + floorConfig[floor]?.days.join(' and ');
      dateWarning.style.display = 'block';
      document.getElementById('collectionDate').value = '';
      return false;
    } else {
      document.getElementById('dateWarning').style.display = 'none';
      return true;
    }
  }

  function validateForm() {
    const floor = document.getElementById('floorNo').value;
    const roomNo = document.getElementById('roomNo').value;
    const dateValue = document.getElementById('collectionDate').value;
    if (!floor) { alert('Please select a floor number'); return false; }
    if (!roomNo) { alert('Please select a room number'); return false; }
    const roomNum = parseInt(roomNo);
    const config = floorConfig[floor];
    if (config && (roomNum < config.roomRange.min || roomNum > config.roomRange.max)) {
      alert('Invalid room number! Floor ' + floor + ' rooms are ' + config.roomRange.min + ' - ' + config.roomRange.max);
      return false;
    }
    if (!dateValue) { alert('Please select a collection date'); return false; }
    const selectedDate = new Date(dateValue);
    const dayOfWeek = selectedDate.getDay();
    const allowedDays = config?.dayNumbers || [];
    if (!allowedDays.includes(dayOfWeek)) {
      alert('For Floor ' + floor + ', laundry collection is only available on ' + config?.days.join(' and '));
      return false;
    }
    let hasItems = false;
    <% for(LaundryItem item : items) { %>
    var qty = parseInt(document.querySelector('input[name="qty_<%= item.getId() %>"]').value) || 0;
    if(qty > 0) hasItems = true;
    <% } %>
    if(!hasItems) { alert('Please select at least one laundry item'); return false; }
    return true;
  }

  function updateItemSubtotal(input, itemId, price) {
    let quantity = parseInt(input.value) || 0;
    let subtotal = quantity * price;
    document.getElementById('subtotal_' + itemId).innerHTML = '<i class="fas fa-calculator"></i> Subtotal: Rs. ' + subtotal.toFixed(2);
    calculateTotal();
  }

  function calculateTotal() {
    let total = 0;
    <% for(LaundryItem item : items) {
        int itemId = item.getId();
        double basePrice = item.getBasePrice();
    %>
    var qty<%= itemId %> = parseInt(document.querySelector('input[name="qty_<%= itemId %>"]').value) || 0;
    total += qty<%= itemId %> * <%= basePrice %>;
    <% } %>
    var urgency = document.getElementById('urgencySelect');
    if(urgency && urgency.value === 'Urgent') total *= 1.5;
    document.getElementById('totalCost').innerHTML = total.toFixed(2);
    document.getElementById('hiddenTotal').value = total.toFixed(2);
  }

  function resetForm() {
    <% for(LaundryItem item : items) {
        int itemId = item.getId();
    %>
    document.querySelector('input[name="qty_<%= itemId %>"]').value = 0;
    document.getElementById('subtotal_<%= itemId %>').innerHTML = '<i class="fas fa-calculator"></i> Subtotal: Rs. 0.00';
    <% } %>
    calculateTotal();
    document.getElementById('floorNo').value = '';
    document.getElementById('roomNo').innerHTML = '<option value="">-- Select Room --</option>';
    document.getElementById('collectionDate').value = '';
    document.getElementById('urgencySelect').value = 'Normal';
    document.getElementById('scheduleInfo').style.display = 'none';
    document.getElementById('dateWarning').style.display = 'none';
    document.getElementById('roomHint').innerHTML = '';
  }

  function filterHistory(status) {
    var rows = document.querySelectorAll('#requestsTableBody tr');
    var buttons = document.querySelectorAll('.filter-btn');
    buttons.forEach(btn => btn.classList.remove('active'));
    if(status === 'all') buttons[0].classList.add('active');
    else if(status === 'pending') buttons[1].classList.add('active');
    else if(status === 'accepted') buttons[2].classList.add('active');
    else if(status === 'completed') buttons[3].classList.add('active');
    else if(status === 'rejected') buttons[4].classList.add('active');
    rows.forEach(row => {
      if(status === 'all') row.style.display = '';
      else row.style.display = row.getAttribute('data-status') === status ? '' : 'none';
    });
  }

  function filterByStatus(status) { filterHistory(status); }
  function showNotifications() { document.getElementById('notificationsModal').style.display = 'flex'; }
  function closeNotificationsModal() { document.getElementById('notificationsModal').style.display = 'none'; }
  function markNotificationRead(id) { fetch('<%= request.getContextPath() %>/markNotificationRead?id=' + id).then(() => location.reload()); }

  function openChat(requestNo) {
    currentChatRequest = requestNo;
    document.getElementById('chatRequestNo').innerText = requestNo;
    document.getElementById('chatModal').style.display = 'flex';
    loadChatMessages();
    if(chatRefreshInterval) clearInterval(chatRefreshInterval);
    chatRefreshInterval = setInterval(loadChatMessages, 5000);
  }

  function loadChatMessages() {
    if(!currentChatRequest) return;
    fetch('<%= request.getContextPath() %>/getMessages?requestNo=' + encodeURIComponent(currentChatRequest))
            .then(r => r.json())
            .then(messages => {
              var container = document.getElementById('chatMessages');
              container.innerHTML = '';
              if(!messages || messages.length === 0) { container.innerHTML = '<div style="text-align:center; padding:20px;">No messages yet.</div>'; return; }
              messages.forEach(msg => {
                var div = document.createElement('div');
                div.className = 'message ' + (msg.senderRole === 'Student' ? 'student' : 'staff');
                div.innerHTML = '<div class="sender">' + (msg.senderRole === 'Student' ? 'You' : 'Staff') + '</div><div class="text">' + escapeHtml(msg.message) + '</div><div class="time">' + new Date(msg.sentAt).toLocaleString() + '</div>';
                container.appendChild(div);
              });
              container.scrollTop = container.scrollHeight;
            }).catch(e => console.error(e));
  }

  function sendChatMessage() {
    var message = document.getElementById('chatMessageInput').value.trim();
    if(!message || !currentChatRequest) { alert('Please enter a message'); return; }
    fetch('<%= request.getContextPath() %>/sendMessage', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'requestNo=' + encodeURIComponent(currentChatRequest) + '&message=' + encodeURIComponent(message)
    }).then(() => { document.getElementById('chatMessageInput').value = ''; loadChatMessages(); }).catch(e => console.error(e));
  }

  function closeChatModal() {
    document.getElementById('chatModal').style.display = 'none';
    if(chatRefreshInterval) { clearInterval(chatRefreshInterval); chatRefreshInterval = null; }
    currentChatRequest = null;
  }

  function escapeHtml(text) {
    if(!text) return '';
    return text.replace(/[&<>]/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;'}[m] || m));
  }

  function previewImage(input, previewId) {
    if (input.files && input.files[0]) {
      var reader = new FileReader();
      reader.onload = function(e) {
        var img = document.getElementById(previewId);
        img.src = e.target.result;
        img.style.display = 'block';
      };
      reader.readAsDataURL(input.files[0]);
    }
  }

  function clearDamageForm() {
    document.querySelectorAll('.photo-upload-box input').forEach(input => input.value = '');
    document.querySelectorAll('.photo-upload-box img').forEach(img => img.style.display = 'none');
  }

  // Pay selected items function
  function paySelectedItems() {
    let total = 0;

    <% for(LaundryItem item : items) {
        int itemId = item.getId();
        double basePrice = item.getBasePrice();
    %>
    var qty<%= itemId %> = parseInt(document.querySelector('input[name="qty_<%= itemId %>"]').value) || 0;
    if(qty<%= itemId %> > 0) {
      total += qty<%= itemId %> * <%= basePrice %>;
    }
    <% } %>

    var urgency = document.getElementById('urgencySelect');
    if(urgency && urgency.value === 'Urgent') total *= 1.5;

    if(total > 0) {
      var form = document.createElement('form');
      form.method = 'POST';
      form.action = 'laundry-payment.jsp';

      var amountField = document.createElement('input');
      amountField.type = 'hidden';
      amountField.name = 'amount';
      amountField.value = total;
      form.appendChild(amountField);

      document.body.appendChild(form);
      form.submit();
    } else {
      alert('Please select at least one item to pay');
    }
  }

  // Disable submit button if unpaid payments exist
  <% if(unpaidAmount > 0) { %>
  document.addEventListener('DOMContentLoaded', function() {
    var submitBtn = document.getElementById('submitBtn');
    if(submitBtn) {
      submitBtn.disabled = true;
      submitBtn.classList.add('btn-submit-disabled');
      submitBtn.title = 'Please pay pending laundry first';
    }
  });
  <% } %>

  document.addEventListener('DOMContentLoaded', function() {
    calculateTotal();
    var today = new Date().toISOString().split('T')[0];
    document.getElementById('collectionDate').min = today;
  });
</script>
</body>
</html>