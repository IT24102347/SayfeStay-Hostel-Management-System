<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*, java.util.*, java.text.*" %>
<%
    // ============ SESSION CHECK ============
    User user = (User) session.getAttribute("user");
    if (user == null || !"Owner".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // ============ GET ATTRIBUTES ============
    Owner owner = (Owner) request.getAttribute("owner");
    Hostel hostel = (Hostel) request.getAttribute("hostel");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<RoomBooking> recentRequests = (List<RoomBooking>) request.getAttribute("recentRequests");
    List<Room> availableRooms = (List<Room>) request.getAttribute("availableRooms");
    Integer pendingCount = (Integer) request.getAttribute("pendingCount");

    if (recentRequests == null) recentRequests = new ArrayList<>();
    if (availableRooms == null) availableRooms = new ArrayList<>();
    if (pendingCount == null) pendingCount = 0;

    // ============ NULL CHECKS ============
    if (owner == null) {
        owner = new Owner();
        owner.setFullName("Hostel Owner");
        owner.setCompanyName("SafeStay Hostels");
    }

    if (hostel == null) {
        hostel = new Hostel();
        hostel.setHostelName("SafeStay Hostel");
        hostel.setCity("Colombo");
        hostel.setContactNumber("0112 345678");
        hostel.setEmail("info@safestay.lk");
        hostel.setTotalRooms(0);
        hostel.setAvailableRooms(0);
    }

    if (stats == null) {
        stats = new HashMap<>();
        stats.put("totalStudents", 0);
        stats.put("totalStaff", 0);
        stats.put("totalRooms", hostel.getTotalRooms());
        stats.put("availableRooms", hostel.getAvailableRooms());
        stats.put("occupiedRooms", hostel.getOccupiedRooms());
        stats.put("occupancyRate", hostel.getOccupancyRate());
        stats.put("monthlyRevenue", 0.0);
        stats.put("pendingMaintenance", 0);
    }

    // ============ FORMATTERS ============
    DecimalFormat df = new DecimalFormat("#,###");
    SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("dd MMM hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Owner Dashboard - SafeStay Hostel</title>

    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background: #f8f9fc;
            display: flex;
            min-height: 100vh;
        }

        /* ========== SIDEBAR ========== */
        .sidebar {
            width: 280px;
            background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
            color: white;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            z-index: 100;
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
            color: white;
        }

        .sidebar-header h2 i {
            color: #4f46e5;
        }

        .owner-profile {
            padding: 25px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .owner-avatar {
            width: 90px;
            height: 90px;
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            font-weight: 700;
            margin: 0 auto 15px;
            border: 4px solid rgba(255,255,255,0.2);
            color: white;
        }

        .owner-name {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 5px;
            color: white;
        }

        .owner-id {
            font-size: 13px;
            color: rgba(255,255,255,0.7);
            background: rgba(255,255,255,0.1);
            padding: 5px 15px;
            border-radius: 50px;
            display: inline-block;
            margin-bottom: 10px;
        }

        .company-badge {
            font-size: 13px;
            color: rgba(255,255,255,0.9);
            background: rgba(79, 70, 229, 0.5);
            padding: 8px 15px;
            border-radius: 8px;
            margin-top: 10px;
        }

        .nav-menu {
            padding: 20px 0;
        }

        .nav-item {
            display: flex;
            align-items: center;
            padding: 12px 25px;
            color: rgba(255,255,255,0.7);
            text-decoration: none;
            transition: all 0.3s;
            border-left: 4px solid transparent;
            margin-bottom: 2px;
        }

        .nav-item:hover, .nav-item.active {
            background: rgba(79, 70, 229, 0.2);
            color: white;
            border-left-color: #4f46e5;
        }

        .nav-item i {
            width: 25px;
            margin-right: 15px;
            font-size: 18px;
        }

        .badge {
            background: #ef4444;
            color: white;
            padding: 2px 8px;
            border-radius: 20px;
            font-size: 12px;
            margin-left: 10px;
        }

        /* ========== MAIN CONTENT ========== */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 30px;
            background: #f8fafc;
        }

        /* ========== TOP HEADER ========== */
        .top-header {
            background: white;
            padding: 25px 30px;
            border-radius: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid rgba(0,0,0,0.02);
        }

        .welcome h1 {
            font-size: 26px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 8px;
        }

        .welcome p {
            color: #64748b;
            font-size: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .date-badge {
            background: #f1f5f9;
            padding: 12px 25px;
            border-radius: 50px;
            color: #0f172a;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 12px;
            border: 1px solid #e2e8f0;
        }

        .date-badge i {
            color: #4f46e5;
        }

        .logout-btn {
            background: #ef4444;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 50px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .logout-btn:hover {
            background: #dc2626;
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(239, 68, 68, 0.2);
        }

        /* ========== STATS CARDS ========== */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 25px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            transition: all 0.3s;
            border: 1px solid rgba(0,0,0,0.02);
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: #4f46e5;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.05);
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .stat-icon {
            width: 55px;
            height: 55px;
            background: #eef2ff;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: #4f46e5;
        }

        .stat-value {
            font-size: 32px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #64748b;
            font-size: 14px;
            font-weight: 500;
        }

        .stat-trend {
            font-size: 13px;
            color: #10b981;
            background: #e6f7e6;
            padding: 5px 12px;
            border-radius: 50px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        /* ========== HOSTEL CARD ========== */
        .hostel-card {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            border-radius: 20px;
            padding: 30px;
            color: white;
            margin-bottom: 30px;
            box-shadow: 0 10px 25px -5px rgba(79, 70, 229, 0.3);
        }

        .hostel-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .hostel-name {
            font-size: 26px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .hostel-details {
            display: flex;
            gap: 30px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }

        .hostel-detail-item {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 15px;
            opacity: 0.95;
        }

        .hostel-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-top: 20px;
        }

        .hostel-stat-item {
            text-align: center;
            padding: 15px;
            background: rgba(255,255,255,0.1);
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }

        .hostel-stat-value {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .hostel-stat-label {
            font-size: 13px;
            opacity: 0.9;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* ========== QUICK ACTIONS ========== */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .action-card {
            background: white;
            border-radius: 16px;
            padding: 25px 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            border: 1px solid #e2e8f0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }

        .action-card:hover {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            color: white;
            border-color: transparent;
            transform: translateY(-5px);
            box-shadow: 0 15px 25px -5px rgba(79, 70, 229, 0.2);
        }

        .action-card i {
            font-size: 32px;
            color: #4f46e5;
            margin-bottom: 12px;
            transition: all 0.3s;
        }

        .action-card:hover i {
            color: white;
        }

        .action-card span {
            font-size: 15px;
            font-weight: 600;
            display: block;
        }

        /* ========== DASHBOARD GRID (NOW 3 COLUMNS) ========== */
        .dashboard-grid-3 {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 25px;
            margin-bottom: 25px;
        }

        .card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid rgba(0,0,0,0.02);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f1f5f9;
        }

        .card-header h3 {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 18px;
            font-weight: 600;
            color: #0f172a;
        }

        .card-header h3 i {
            color: #4f46e5;
        }

        .view-all {
            color: #4f46e5;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 5px;
            padding: 8px 15px;
            border-radius: 50px;
            transition: all 0.3s;
        }

        .view-all:hover {
            background: #eef2ff;
        }

        /* ========== STUDENT LIST ========== */
        .student-list {
            list-style: none;
        }

        .student-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .student-item:last-child {
            border-bottom: none;
        }

        .student-info h4 {
            font-size: 15px;
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 4px;
        }

        .student-info p {
            font-size: 13px;
            color: #64748b;
        }

        .student-info p i {
            margin-right: 5px;
            color: #4f46e5;
        }

        .badge {
            padding: 5px 15px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-active {
            background: #d4edda;
            color: #155724;
        }

        .badge-pending {
            background: #fff3cd;
            color: #856404;
        }

        /* ========== PAYMENT LIST ========== */
        .payment-list {
            list-style: none;
        }

        .payment-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .payment-item:last-child {
            border-bottom: none;
        }

        .payment-amount {
            font-size: 16px;
            font-weight: 700;
            color: #0f172a;
        }

        .payment-date {
            font-size: 12px;
            color: #64748b;
            margin-top: 3px;
        }

        .payment-method {
            font-size: 11px;
            color: #64748b;
            padding: 3px 10px;
            background: #f1f5f9;
            border-radius: 50px;
        }

        /* ========== REQUEST LIST ========== */
        .request-list {
            list-style: none;
        }

        .request-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 12px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .request-item:last-child {
            border-bottom: none;
        }

        .request-avatar {
            width: 45px;
            height: 45px;
            background: #eef2ff;
            color: #4f46e5;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 18px;
        }

        .request-info h4 {
            font-size: 15px;
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 4px;
        }

        .request-info p {
            font-size: 12px;
            color: #64748b;
        }

        .request-info p i {
            margin-right: 4px;
            color: #4f46e5;
        }

        .request-type {
            display: inline-block;
            padding: 3px 10px;
            background: #f1f5f9;
            border-radius: 30px;
            font-size: 11px;
            font-weight: 600;
            color: #475569;
            margin-left: 8px;
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #64748b;
        }

        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.5;
            color: #94a3b8;
        }

        .empty-state p {
            font-size: 14px;
        }

        /* ========== ROOM STATUS ========== */
        .room-status-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 15px;
        }

        .room-status-item {
            text-align: center;
            padding: 15px;
            background: #f8fafc;
            border-radius: 12px;
        }

        .room-status-value {
            font-size: 24px;
            font-weight: 700;
            color: #0f172a;
        }

        .room-status-label {
            font-size: 12px;
            color: #64748b;
            margin-top: 5px;
        }

        /* ========== RESPONSIVE ========== */
        @media (max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .quick-actions {
                grid-template-columns: repeat(2, 1fr);
            }

            .dashboard-grid-3 {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 992px) {
            .sidebar {
                width: 80px;
            }

            .sidebar .owner-name,
            .sidebar .owner-id,
            .sidebar .company-badge,
            .sidebar .nav-item span {
                display: none;
            }

            .owner-avatar {
                width: 50px;
                height: 50px;
                font-size: 20px;
            }

            .nav-item {
                justify-content: center;
                padding: 15px;
            }

            .nav-item i {
                margin-right: 0;
            }

            .main-content {
                margin-left: 80px;
            }

            .dashboard-grid-3 {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }

            .sidebar .owner-name,
            .sidebar .owner-id,
            .sidebar .company-badge,
            .sidebar .nav-item span {
                display: block;
            }

            .owner-avatar {
                width: 80px;
                height: 80px;
                font-size: 32px;
            }

            .nav-item {
                justify-content: flex-start;
            }

            .nav-item i {
                margin-right: 15px;
            }

            .main-content {
                margin-left: 0;
            }

            .stats-grid,
            .quick-actions,
            .hostel-stats {
                grid-template-columns: 1fr;
            }

            .top-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }

            .header-right {
                width: 100%;
                justify-content: center;
            }

            .hostel-details {
                flex-direction: column;
                gap: 10px;
            }
        }

        /* ========== ANIMATIONS ========== */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .stat-card,
        .hostel-card,
        .action-card,
        .card {
            animation: fadeIn 0.5s ease-out;
        }
    </style>
</head>
<body>
<!-- ========== SIDEBAR ========== -->
<div class="sidebar">
    <div class="sidebar-header">
        <h2>
            <i class="fas fa-hotel"></i>
            <span>SafeStay</span>
        </h2>
    </div>

    <div class="owner-profile">
        <div class="owner-avatar">
            <%= owner.getFullName() != null && owner.getFullName().length() > 0 ?
                    owner.getFullName().charAt(0) : 'O' %>
        </div>
        <div class="owner-name">
            <%= owner.getFullName() != null ? owner.getFullName() : "Hostel Owner" %>
        </div>
        <div class="owner-id">
            <i class="fas fa-id-card"></i> <%= user.getUserId() %>
        </div>
        <div class="company-badge">
            <i class="fas fa-building"></i>
            <%= owner.getCompanyName() != null ? owner.getCompanyName() : "SafeStay Hostels" %>
        </div>
    </div>

    <div class="nav-menu">
        <a href="<%= request.getContextPath() %>/dashboard/owner" class="nav-item active">
            <i class="fas fa-home"></i>
            <span>Dashboard</span>
        </a>
        <a href="<%= request.getContextPath() %>/dashboard/owner/students" class="nav-item">
            <i class="fas fa-user-graduate"></i>
            <span>Students</span>
        </a>
        <a href="<%= request.getContextPath() %>/dashboard/owner/rooms" class="nav-item">
            <i class="fas fa-door-open"></i>
            <span>Rooms</span>
        </a>
        <a href="<%= request.getContextPath() %>/dashboard/owner/reviews" class="nav-item">
            <i class="fas fa-star"></i>
            <span>Reviews & Ratings</span>
        </a>
        <a href="<%= request.getContextPath() %>/dashboard/owner/payments" class="nav-item">
            <i class="fas fa-credit-card"></i>
            <span>Payments</span>
        </a>
        <a href="<%= request.getContextPath() %>/dashboard/owner/pending-bookings.jsp" class="nav-item">
            <i class="fas fa-clock"></i>
            <span>Requests</span>
            <% if (pendingCount > 0) { %>
            <span class="badge"><%= pendingCount %></span>
            <% } %>
        </a>
        <a href="<%= request.getContextPath() %>/logout" class="nav-item" style="margin-top: 50px;">
            <i class="fas fa-sign-out-alt"></i>
            <span>Logout</span>
        </a>
    </div>
</div>

<!-- ========== MAIN CONTENT ========== -->
<div class="main-content">
    <!-- ========== TOP HEADER ========== -->
    <div class="top-header">
        <div class="welcome">
            <h1>
                Welcome back, <%= owner.getFullName() != null && owner.getFullName().contains(" ") ?
                    owner.getFullName().split(" ")[0] : "Owner" %>! 👋
            </h1>
            <p>
                <i class="fas fa-chart-pie" style="color: #4f46e5;"></i>
                Here's what's happening at your hostel today
            </p>
        </div>
        <div class="header-right">
            <div class="date-badge">
                <i class="far fa-calendar-alt"></i>
                <%= sdf.format(new Date()) %>
            </div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </div>
    </div>

    <!-- ========== STATISTICS CARDS ========== -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-user-graduate"></i>
                </div>
                <span class="stat-trend">
                        <i class="fas fa-arrow-up"></i> +12%
                    </span>
            </div>
            <div class="stat-value">
                <%= stats.get("totalStudents") != null ? stats.get("totalStudents") : 0 %>
            </div>
            <div class="stat-label">Total Students</div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-door-open"></i>
                </div>
            </div>
            <div class="stat-value">
                <%= stats.get("occupancyRate") != null ?
                        Math.round((Double)stats.get("occupancyRate")) : 0 %>%
            </div>
            <div class="stat-label">Occupancy Rate</div>
            <div style="font-size: 13px; color: #64748b; margin-top: 8px;">
                <%= stats.get("occupiedRooms") != null ? stats.get("occupiedRooms") : 0 %>/
                <%= stats.get("totalRooms") != null ? stats.get("totalRooms") : 0 %> rooms
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-coins"></i>
                </div>
            </div>
            <div class="stat-value">
                Rs. <%= df.format(stats.get("monthlyRevenue") != null ? stats.get("monthlyRevenue") : 0) %>
            </div>
            <div class="stat-label">Monthly Revenue</div>
            <div style="font-size: 13px; color: #64748b; margin-top: 8px;">
                This month
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon">
                    <i class="fas fa-tools"></i>
                </div>
            </div>
            <div class="stat-value">
                <%= stats.get("pendingMaintenance") != null ? stats.get("pendingMaintenance") : 0 %>
            </div>
            <div class="stat-label">Maintenance</div>
            <div style="font-size: 13px; color: #64748b; margin-top: 8px;">
                Pending requests
            </div>
        </div>
    </div>

    <!-- ========== HOSTEL CARD ========== -->
    <div class="hostel-card">
        <div class="hostel-header">
            <div class="hostel-name">
                <i class="fas fa-building"></i>
                <%= hostel.getHostelName() != null ? hostel.getHostelName() : "SafeStay Hostel" %>
            </div>
            <a href="<%= request.getContextPath() %>/dashboard/owner/settings"
               style="color: white; background: rgba(255,255,255,0.2); padding: 10px 20px; border-radius: 50px; text-decoration: none; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 8px; transition: all 0.3s;">
                <i class="fas fa-cog"></i> Manage
            </a>
        </div>

        <div class="hostel-details">
            <div class="hostel-detail-item">
                <i class="fas fa-map-marker-alt"></i>
                <%= hostel.getCity() != null ? hostel.getCity() : "Colombo" %>
            </div>
            <div class="hostel-detail-item">
                <i class="fas fa-phone-alt"></i>
                <%= hostel.getContactNumber() != null ? hostel.getContactNumber() : "0112 345678" %>
            </div>
            <div class="hostel-detail-item">
                <i class="fas fa-envelope"></i>
                <%= hostel.getEmail() != null ? hostel.getEmail() : "info@safestay.lk" %>
            </div>
            <div class="hostel-detail-item">
                <i class="fas fa-user-tie"></i>
                Warden: <%= hostel.getWardenName() != null ? hostel.getWardenName() : "Mr. Perera" %>
            </div>
        </div>

        <div class="hostel-stats">
            <div class="hostel-stat-item">
                <div class="hostel-stat-value"><%= hostel.getTotalRooms() %></div>
                <div class="hostel-stat-label">Total Rooms</div>
            </div>
            <div class="hostel-stat-item">
                <div class="hostel-stat-value"><%= hostel.getAvailableRooms() %></div>
                <div class="hostel-stat-label">Available</div>
            </div>
            <div class="hostel-stat-item">
                <div class="hostel-stat-value"><%= hostel.getOccupiedRooms() %></div>
                <div class="hostel-stat-label">Occupied</div>
            </div>
        </div>
    </div>

    <!-- ========== QUICK ACTIONS ========== -->
    <div class="quick-actions">
        <div class="action-card" onclick="location.href='<%= request.getContextPath() %>/dashboard/owner/students?action=add'">
            <i class="fas fa-user-plus"></i>
            <span>Add Student</span>
        </div>
        <div class="action-card" onclick="location.href='<%= request.getContextPath() %>/dashboard/owner/rooms?action=add'">
            <i class="fas fa-door-open"></i>
            <span>Add Room</span>
        </div>
        <div class="action-card" onclick="location.href='<%= request.getContextPath() %>/dashboard/owner/pending-bookings.jsp'">
            <i class="fas fa-clock"></i>
            <span>View Requests</span>
            <% if (pendingCount > 0) { %>
            <span style="background: #ef4444; color: white; padding: 2px 8px; border-radius: 20px; font-size: 12px; margin-left: 5px;">
                    <%= pendingCount %>
                </span>
            <% } %>
        </div>
        <div class="action-card" onclick="location.href='<%= request.getContextPath() %>/dashboard/owner/reports'">
            <i class="fas fa-file-alt"></i>
            <span>View Reports</span>
        </div>
    </div>

    <!-- ========== DASHBOARD GRID 3 COLUMNS ========== -->
    <div class="dashboard-grid-3">
        <!-- ========== RECENT STUDENTS ========== -->
        <div class="card">
            <div class="card-header">
                <h3>
                    <i class="fas fa-user-graduate"></i>
                    Recent Students
                </h3>
                <a href="<%= request.getContextPath() %>/dashboard/owner/students" class="view-all">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>

            <div class="student-list">
                <div class="student-item">
                    <div class="student-info">
                        <h4>Rashmi Perera</h4>
                        <p>
                            <i class="fas fa-id-card"></i> STD001 •
                            <i class="fas fa-graduation-cap"></i> Year 2
                        </p>
                    </div>
                    <span class="badge badge-active">Active</span>
                </div>
                <div class="student-item">
                    <div class="student-info">
                        <h4>Nimal Fernando</h4>
                        <p>
                            <i class="fas fa-id-card"></i> STD002 •
                            <i class="fas fa-graduation-cap"></i> Year 1
                        </p>
                    </div>
                    <span class="badge badge-active">Active</span>
                </div>
                <div class="student-item">
                    <div class="student-info">
                        <h4>Kamal Silva</h4>
                        <p>
                            <i class="fas fa-id-card"></i> STD003 •
                            <i class="fas fa-graduation-cap"></i> Year 3
                        </p>
                    </div>
                    <span class="badge badge-active">Active</span>
                </div>
            </div>
        </div>

        <!-- ========== RECENT PAYMENTS ========== -->
        <div class="card">
            <div class="card-header">
                <h3>
                    <i class="fas fa-credit-card"></i>
                    Recent Payments
                </h3>
                <a href="<%= request.getContextPath() %>/dashboard/owner/payments" class="view-all">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>

            <div class="payment-list">
                <div class="payment-item">
                    <div>
                        <div style="font-weight: 600; margin-bottom: 4px;">Rashmi Perera</div>
                        <span class="payment-method">Card</span>
                    </div>
                    <div style="text-align: right;">
                        <div class="payment-amount">Rs. 15,000</div>
                        <div class="payment-date">15 Jan 2024</div>
                    </div>
                </div>
                <div class="payment-item">
                    <div>
                        <div style="font-weight: 600; margin-bottom: 4px;">Nimal Fernando</div>
                        <span class="payment-method">Cash</span>
                    </div>
                    <div style="text-align: right;">
                        <div class="payment-amount">Rs. 15,000</div>
                        <div class="payment-date">14 Jan 2024</div>
                    </div>
                </div>
                <div class="payment-item">
                    <div>
                        <div style="font-weight: 600; margin-bottom: 4px;">Kamal Silva</div>
                        <span class="payment-method">Bank Transfer</span>
                    </div>
                    <div style="text-align: right;">
                        <div class="payment-amount">Rs. 18,000</div>
                        <div class="payment-date">12 Jan 2024</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ========== BOOKING REQUESTS (NEW) ========== -->
        <div class="card">
            <div class="card-header">
                <h3>
                    <i class="fas fa-clock"></i>
                    Booking Requests
                    <% if (pendingCount > 0) { %>
                    <span style="background: #ef4444; color: white; padding: 2px 10px; border-radius: 30px; font-size: 12px;">
                            <%= pendingCount %> new
                        </span>
                    <% } %>
                </h3>
                <a href="<%= request.getContextPath() %>/dashboard/owner/pending-bookings.jsp" class="view-all">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>

            <% if (recentRequests.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-inbox"></i>
                <p>No pending requests</p>
            </div>
            <% } else { %>
            <div class="request-list">
                <% for (RoomBooking req : recentRequests) { %>
                <div class="request-item">
                    <div class="request-avatar">
                        <%= req.getStudentName() != null ? req.getStudentName().charAt(0) : 'S' %>
                    </div>
                    <div class="request-info">
                        <h4>
                            <%= req.getStudentName() != null ? req.getStudentName() : "Student" %>
                            <span class="request-type"><%= req.getRoomType() %></span>
                        </h4>
                        <p>
                            <i class="fas fa-calendar"></i> <%= timeFormat.format(req.getCreatedAt()) %> •
                            <% if ("Yes".equals(req.getNeedAc())) { %> AC <% } %>
                            <% if ("Yes".equals(req.getNeedFan())) { %> Fan <% } %>
                        </p>
                    </div>
                    <span class="badge badge-pending">Pending</span>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>

    <!-- ========== ROOM STATUS ========== -->
    <div class="card" style="margin-top: 0;">
        <div class="card-header">
            <h3>
                <i class="fas fa-door-open"></i>
                Room Status Overview
            </h3>
            <a href="<%= request.getContextPath() %>/dashboard/owner/rooms" class="view-all">
                Manage Rooms <i class="fas fa-arrow-right"></i>
            </a>
        </div>

        <div class="room-status-grid">
            <div class="room-status-item">
                <div class="room-status-value"><%= hostel.getTotalRooms() %></div>
                <div class="room-status-label">Total Rooms</div>
            </div>
            <div class="room-status-item">
                <div class="room-status-value" style="color: #10b981;"><%= hostel.getAvailableRooms() %></div>
                <div class="room-status-label">Available</div>
            </div>
            <div class="room-status-item">
                <div class="room-status-value" style="color: #4f46e5;"><%= hostel.getOccupiedRooms() %></div>
                <div class="room-status-label">Occupied</div>
            </div>
        </div>

        <div style="margin-top: 20px; display: flex; gap: 10px; flex-wrap: wrap;">
            <span style="background: #eef2ff; color: #4f46e5; padding: 6px 15px; border-radius: 50px; font-size: 13px;">
                <i class="fas fa-bed"></i> Single: 10/15
            </span>
            <span style="background: #eef2ff; color: #4f46e5; padding: 6px 15px; border-radius: 50px; font-size: 13px;">
                <i class="fas fa-bed"></i> Double: 15/20
            </span>
            <span style="background: #eef2ff; color: #4f46e5; padding: 6px 15px; border-radius: 50px; font-size: 13px;">
                <i class="fas fa-bed"></i> Triple: 5/10
            </span>
        </div>
    </div>
</div>

<script>
    function logout() {
        if (confirm('Are you sure you want to logout?')) {
            window.location.href = '<%= request.getContextPath() %>/logout';
        }
    }

    // Auto-hide success/error messages after 5 seconds
    setTimeout(function() {
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(alert) {
            alert.style.transition = 'opacity 0.5s';
            alert.style.opacity = '0';
            setTimeout(function() {
                alert.style.display = 'none';
            }, 500);
        });
    }, 5000);
</script>
</body>
</html>