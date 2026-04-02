<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="org.example.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    String pageTitle = (String) request.getAttribute("pageTitle");
    Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");
    String currentFilter = (String) request.getAttribute("currentFilter");

    String contextPath = request.getContextPath();
    String requestPath = request.getRequestURI();
    if (requestPath.startsWith(contextPath)) {
        requestPath = requestPath.substring(contextPath.length());
    }

    boolean navRoomsActive = requestPath.equals("/rooms") || requestPath.startsWith("/rooms/");
    boolean navInquiriesActive = requestPath.startsWith("/inquiry");
    boolean navBookingsActive = requestPath.startsWith("/booking/my-bookings");
    boolean navSearchActive = requestPath.startsWith("/rooms/search");
    boolean navDashboardActive = requestPath.startsWith("/dashboard/student");

    String sidebarName = user.getFullName() != null ? user.getFullName().trim() : "Student";
    if (sidebarName.isEmpty()) {
        sidebarName = "Student";
    }
    String sidebarInitial = String.valueOf(Character.toUpperCase(sidebarName.charAt(0)));
    String sidebarUserId = user.getUserId() != null ? user.getUserId() : "N/A";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - SafeStay Hostel</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@0,400;0,600;1,400&family=Sora:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            :root {
            --bg: #f4f5f7;
            --surface: #ffffff;
            --surface-2: #f0f1f4;
            --border: rgba(0,0,0,0.08);
            --accent: #1d6fd8;
            --accent-dim: rgba(29,111,216,0.10);
            --accent-glow: rgba(29,111,216,0.22);
            --text: #1a1a2e;
            --text-muted: #6b6b80;
            --success: #16a34a;
            --warning: #d97706;
            --danger: #dc2626;
            --info: #2563eb;
            --radius: 16px;
            --radius-sm: 10px;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background-color: var(--bg);
            color: var(--text);
            font-family: 'Sora', sans-serif;
            font-size: 15px;
            min-height: 100vh;
            position: relative;
        }
        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background:
                linear-gradient(120deg, rgba(16, 28, 46, 0.65), rgba(16, 28, 46, 0.35)),
                url('images/rooms/102_1.jpg') center/cover no-repeat;
            z-index: -2;
            transform: scale(1.03);
        }
        body::after {
            content: "";
            position: fixed;
            inset: 0;
            background:
                radial-gradient(circle at 15% 15%, rgba(61, 153, 255, 0.2), transparent 42%),
                radial-gradient(circle at 88% 83%, rgba(88, 211, 157, 0.16), transparent 46%),
                linear-gradient(180deg, rgba(244, 245, 247, 0.78), rgba(244, 245, 247, 0.92));
            z-index: -1;
            pointer-events: none;
        }

        /* ── NAVBAR ── */
        .navbar {
            background: rgba(247,249,252,0.82) !important;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--border);
            padding: 0.85rem 1.5rem;
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        .navbar-brand {
            font-family: 'Fraunces', serif;
            font-size: 1.35rem;
            font-weight: 600;
            color: var(--accent) !important;
            letter-spacing: -0.5px;
        }
        .navbar-brand span { color: var(--text); }
        .nav-user-name {
            color: var(--text-muted);
            font-size: 0.85rem;
            font-weight: 400;
        }
        .btn-logout {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text-muted);
            border-radius: 8px;
            font-size: 0.82rem;
            padding: 0.35rem 0.85rem;
            font-weight: 500;
            transition: all 0.2s;
        }
        .btn-logout:hover {
            border-color: var(--danger);
            color: var(--danger);
        }

        /* ── MAIN CONTAINER ── */
        .main-container {
            max-width: 1420px;
            margin: 0 auto;
            padding: 2.5rem 1.5rem;
        }
        .rooms-layout {
            display: grid;
            grid-template-columns: 320px minmax(0, 1fr);
            gap: 1.25rem;
            align-items: start;
        }
        .rooms-sidebar {
            background: linear-gradient(180deg, #1a237e 0%, #0d47a1 100%);
            color: #ffffff;
            border: none;
            border-radius: 20px;
            padding: 1.2rem;
            position: sticky;
            top: 92px;
            box-shadow: 0 16px 30px rgba(9, 21, 46, 0.25);
            display: flex;
            flex-direction: column;
            min-height: calc(100vh - 116px);
        }
        .sidebar-brand {
            text-align: center;
            font-size: 2.55rem;
            font-weight: 700;
            color: #ffffff;
            line-height: 1;
            letter-spacing: -0.03em;
            margin-top: 0.1rem;
            margin-bottom: 1.1rem;
        }
        .sidebar-brand span {
            color: #ffd700;
        }
        .sidebar-divider {
            border: 0;
            border-top: 1px solid rgba(255,255,255,0.14);
            margin: 0.35rem 0 1rem;
        }
        .sidebar-profile {
            display: flex;
            align-items: center;
            gap: 0.9rem;
            padding: 0.95rem;
            border-radius: 16px;
            background: rgba(255,255,255,0.12);
            margin-bottom: 1.15rem;
        }
        .profile-avatar {
            width: 62px;
            height: 62px;
            border-radius: 50%;
            background: #ffd700;
            color: #122166;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            font-weight: 700;
            flex-shrink: 0;
        }
        .profile-name {
            color: #ffffff;
            font-size: 1.06rem;
            font-weight: 700;
            line-height: 1.2;
        }
        .profile-id {
            color: rgba(255,255,255,0.8);
            font-size: 0.83rem;
            margin-top: 0.2rem;
        }
        .side-nav-list {
            display: flex;
            flex-direction: column;
            gap: 0.42rem;
            margin-bottom: 1rem;
        }
        .side-nav-link {
            display: flex;
            align-items: center;
            gap: 0.7rem;
            color: rgba(255,255,255,0.93);
            text-decoration: none;
            font-size: 1.02rem;
            font-weight: 600;
            padding: 0.8rem 0.95rem;
            border-radius: 14px;
            border: none;
            transition: all 0.2s ease;
        }
        .side-nav-link i {
            width: 22px;
            text-align: center;
            color: inherit;
            font-size: 1rem;
        }
        .side-nav-link:hover {
            color: #ffffff;
            background: rgba(255,255,255,0.12);
            transform: none;
        }
        .side-nav-link.active {
            color: #ffd700;
            background: rgba(255,255,255,0.14);
        }
        .side-nav-foot {
            margin-top: auto;
            padding-top: 0.9rem;
            border-top: 1px solid rgba(255,255,255,0.14);
        }
        .side-nav-foot .side-nav-link {
            margin-top: 0.4rem;
        }
        .rooms-main {
            background: rgba(248,250,253,0.66);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border: 1px solid rgba(255,255,255,0.55);
            border-radius: 20px;
            padding: 1.3rem;
            box-shadow: 0 16px 34px rgba(13, 28, 45, 0.08);
        }

        /* ── STATS CARDS ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
            margin-bottom: 3rem;
        }
        @media (max-width: 900px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 480px) { .stats-grid { grid-template-columns: 1fr; } }

        .stat-card {
            background: rgba(255,255,255,0.88);
            border: none;
            border-radius: var(--radius);
            padding: 1.75rem;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.03);
            transition: transform 0.25s, box-shadow 0.25s;
        }
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.06);
        }
        .stat-card::before {
            content: '';
            position: absolute;
            inset: 0;
            opacity: 0.12;
        }
        .stat-card.s-primary::before  { background: linear-gradient(135deg, var(--info), transparent); }
        .stat-card.s-success::before  { background: linear-gradient(135deg, var(--success), transparent); }
        .stat-card.s-warning::before  { background: linear-gradient(135deg, var(--warning), transparent); }
        .stat-card.s-info::before     { background: linear-gradient(135deg, var(--accent), transparent); }

        .stat-label {
            font-size: 0.8rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--text-muted);
            margin-bottom: 0.75rem;
            position: relative;
            z-index: 1;
        }
        .stat-value {
            font-family: 'Fraunces', serif;
            font-size: 2.8rem;
            font-weight: 600;
            line-height: 1;
            position: relative;
            z-index: 1;
        }
        .stat-card.s-primary  .stat-value { color: var(--info); }
        .stat-card.s-success  .stat-value { color: var(--success); }
        .stat-card.s-warning  .stat-value { color: var(--warning); }
        .stat-card.s-info     .stat-value { color: var(--accent); }
        .stat-icon {
            position: absolute;
            right: 1.5rem;
            top: 1.5rem;
            font-size: 1.5rem;
            opacity: 0.15;
            z-index: 1;
        }
        .stat-card.s-primary  .stat-icon { color: var(--info); }
        .stat-card.s-success  .stat-icon { color: var(--success); }
        .stat-card.s-warning  .stat-icon { color: var(--warning); }
        .stat-card.s-info     .stat-icon { color: var(--accent); }

        /* ── PAGE HEADER ── */
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 2rem;
        }
        .page-title {
            font-family: 'Fraunces', serif;
            font-size: 1.75rem;
            font-weight: 600;
            color: var(--text);
            letter-spacing: -0.5px;
        }
        .filter-bar {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            align-items: center;
        }

        /* ── FILTER / ACTION BUTTONS ── */
        .btn-filter {
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--text-muted);
            border-radius: 30px;
            font-size: 0.85rem;
            font-weight: 600;
            padding: 0.5rem 1.25rem;
            text-decoration: none;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            white-space: nowrap;
        }
        .btn-filter:hover {
            border-color: rgba(0,0,0,0.2);
            color: var(--text);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.08);
        }
        .btn-filter.active, .btn-filter:active {
            background: var(--accent-dim);
            border-color: var(--accent);
            color: var(--accent);
        }
        .btn-filter.f-success.active {
            background: rgba(74,222,128,0.1);
            border-color: var(--success);
            color: var(--success);
        }
        .btn-filter.f-warning {
            background: rgba(251,191,36,0.08);
            border-color: rgba(251,191,36,0.3);
            color: var(--warning);
        }
        .btn-filter.f-warning:hover {
            background: rgba(251,191,36,0.15);
            border-color: var(--warning);
        }
        .btn-filter.f-info {
            background: rgba(96,165,250,0.08);
            border-color: rgba(96,165,250,0.3);
            color: var(--info);
        }
        .btn-filter.f-info:hover {
            background: rgba(96,165,250,0.15);
            border-color: var(--info);
        }
        .btn-filter.f-muted {
            background: var(--surface-2);
        }

        /* ── ROOM GRID ── */
        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1.25rem;
        }
        @media (max-width: 920px)  { .rooms-grid { grid-template-columns: 1fr; } }

        /* ── ROOM CARD ── */
        .room-card {
            background: rgba(255,255,255,0.91);
            border: none;
            border-radius: calc(var(--radius) * 1.25);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            box-shadow: 0 4px 20px rgba(0,0,0,0.04);
            transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .room-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 48px rgba(0,0,0,0.08);
        }

        .room-image-wrap {
            position: relative;
            overflow: hidden;
            aspect-ratio: 4/3;
        }
        .room-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transition: transform 0.6s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .room-card:hover .room-image { transform: scale(1.08); }

        .room-status-badge {
            position: absolute;
            top: 1rem;
            right: 1rem;
            font-size: 0.7rem;
            font-weight: 700;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            padding: 0.4rem 0.85rem;
            border-radius: 30px;
            backdrop-filter: blur(12px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .badge-available {
            background: rgba(255,255,255,0.9);
            color: var(--success);
        }
        .badge-partial {
            background: rgba(255,255,255,0.9);
            color: var(--warning);
        }
        .badge-full {
            background: rgba(255,255,255,0.9);
            color: var(--danger);
        }

        .room-body {
            padding: 1.5rem;
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .room-title {
            font-family: 'Fraunces', serif;
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 1rem;
            letter-spacing: -0.3px;
        }

        .room-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1.25rem;
            padding-bottom: 1.25rem;
            border-bottom: 1px solid var(--border);
        }
        .meta-item {
            flex: 1 1 40%;
            font-size: 0.85rem;
            color: var(--text-muted);
        }
        .meta-item strong {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: var(--text-muted);
            opacity: 0.7;
            margin-bottom: 0.2rem;
        }
        .meta-item span {
            color: var(--text);
            font-weight: 600;
            font-size: 0.9rem;
        }

        .price-tag {
            font-family: 'Fraunces', serif;
            font-size: 1.35rem;
            font-weight: 600;
            color: var(--accent);
            margin-bottom: 1rem;
        }
        .price-tag small {
            font-family: 'Sora', sans-serif;
            font-size: 0.72rem;
            color: var(--text-muted);
            font-weight: 400;
        }

        /* Facilities */
        .facilities {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }
        .facility-pill {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 30px;
            padding: 0.35rem 0.75rem;
            font-size: 0.75rem;
            font-weight: 500;
            color: var(--text-muted);
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            transition: all 0.2s;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }
        .facility-pill i { color: var(--accent); font-size: 0.75rem; }
        .room-card:hover .facility-pill {
            border-color: var(--accent-dim);
            background: var(--surface-2);
            color: var(--accent);
        }

        /* Card actions */
        .room-actions {
            margin-top: auto;
            display: flex;
            gap: 0.75rem;
        }
        .btn-details {
            flex: 1;
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text);
            border-radius: 30px;
            font-size: 0.85rem;
            font-weight: 600;
            padding: 0.65rem 1rem;
            text-decoration: none;
            text-align: center;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .btn-details:hover {
            background: var(--surface-2);
            border-color: rgba(0,0,0,0.2);
            color: var(--text);
        }
        .btn-book {
            flex: 1;
            background: var(--accent);
            border: 1px solid var(--accent);
            color: #ffffff;
            border-radius: 30px;
            font-size: 0.85rem;
            font-weight: 600;
            padding: 0.65rem 1rem;
            text-decoration: none;
            text-align: center;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            box-shadow: 0 4px 12px var(--accent-glow);
        }
        .btn-book:hover {
            background: #155bb5;
            border-color: #155bb5;
            color: #ffffff;
            box-shadow: 0 6px 16px rgba(29,111,216,0.35);
            transform: translateY(-2px);
        }

        /* Empty state */
        .empty-state {
            grid-column: 1 / -1;
            background: var(--surface);
            border: none;
            border-radius: var(--radius);
            padding: 5rem 3rem;
            text-align: center;
            color: var(--text-muted);
            box-shadow: 0 4px 20px rgba(0,0,0,0.04);
        }
        .empty-state i { font-size: 3rem; margin-bottom: 1.5rem; opacity: 0.3; color: var(--accent); }
        .empty-state p { font-size: 1.1rem; color: var(--text); }

        /* Divider */
        .section-divider {
            border: none;
            border-top: 1px solid var(--border);
            margin: 0.25rem 0 2rem;
        }

        @media (max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }
        @media (max-width: 1080px) {
            .rooms-layout {
                grid-template-columns: 1fr;
            }
            .rooms-sidebar {
                position: static;
                top: auto;
                min-height: auto;
            }
            .side-nav-foot {
                margin-top: 0.4rem;
            }
        }
        @media (max-width: 640px) {
            .main-container {
                padding: 1.25rem 0.85rem;
            }
            .rooms-sidebar {
                padding: 1rem;
                border-radius: 16px;
            }
            .sidebar-brand {
                font-size: 2.15rem;
            }
            .profile-avatar {
                width: 56px;
                height: 56px;
                font-size: 1.6rem;
            }
            .rooms-main {
                padding: 1rem;
                border-radius: 16px;
            }
            .page-header {
                margin-bottom: 1.4rem;
            }
            .page-title {
                font-size: 1.45rem;
            }
            .stats-grid {
                grid-template-columns: 1fr;
                margin-bottom: 1.8rem;
            }
        }

        /* Animations */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(18px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .stat-card { animation: fadeUp 0.5s ease both; }
        .stat-card:nth-child(1) { animation-delay: 0.05s; }
        .stat-card:nth-child(2) { animation-delay: 0.10s; }
        .stat-card:nth-child(3) { animation-delay: 0.15s; }
        .stat-card:nth-child(4) { animation-delay: 0.20s; }
        .room-card { animation: fadeUp 0.45s ease both; }

        /* Scrollbar */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: var(--bg); }
        ::-webkit-scrollbar-thumb { background: var(--surface-2); border-radius: 3px; }
    </style>
</head>
<body>

    <!-- NAVBAR -->
    <nav class="navbar navbar-expand-lg">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/dashboard/student/index.jsp">Safe<span>Stay</span></a>
            <div class="d-flex align-items-center gap-3 ms-auto">
                <span class="nav-user-name d-none d-sm-inline">
                    <i class="fas fa-user-circle me-1" style="color: var(--accent); opacity:.7;"></i>
                    Welcome, <%= user.getFullName() %>
                </span>
                <a class="btn-logout" href="logout">
                    <i class="fas fa-sign-out-alt me-1"></i> Logout
                </a>
            </div>
        </div>
    </nav>

    <!-- MAIN -->
    <div class="main-container">

        <div class="rooms-layout">
            <aside class="rooms-sidebar">
                <div class="sidebar-brand">Safe<span>Stay</span></div>
                <hr class="sidebar-divider">
                <div class="sidebar-profile">
                    <div class="profile-avatar"><%= sidebarInitial %></div>
                    <div>
                        <div class="profile-name"><%= sidebarName %></div>
                        <div class="profile-id">ID: <%= sidebarUserId %></div>
                    </div>
                </div>
                <nav class="side-nav-list" aria-label="Student page navigation">
                    <a href="<%= request.getContextPath() %>/rooms" class="side-nav-link <%= navRoomsActive ? "active" : "" %>">
                        <i class="fas fa-bed"></i> Browse Rooms
                    </a>
                    <a href="<%= request.getContextPath() %>/inquiry" class="side-nav-link <%= navInquiriesActive ? "active" : "" %>">
                        <i class="fas fa-comments"></i> My Inquiries
                    </a>
                    <a href="<%= request.getContextPath() %>/booking/my-bookings" class="side-nav-link <%= navBookingsActive ? "active" : "" %>">
                        <i class="fas fa-calendar-check"></i> My Bookings
                    </a>
                    <a href="<%= request.getContextPath() %>/rooms/search" class="side-nav-link <%= navSearchActive ? "active" : "" %>">
                        <i class="fas fa-sliders-h"></i> Advanced Search
                    </a>
                </nav>
                <div class="side-nav-foot">
                    <a href="<%= request.getContextPath() %>/dashboard/student/index.jsp" class="side-nav-link <%= navDashboardActive ? "active" : "" %>">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </a>
                    <a href="<%= request.getContextPath() %>/logout" class="side-nav-link">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </aside>

            <main class="rooms-main">

        <!-- STATS -->
        <div class="stats-grid">
            <div class="stat-card s-primary">
                <i class="fas fa-building stat-icon"></i>
                <div class="stat-label">Total Rooms</div>
                <div class="stat-value"><%= stats.get("totalRooms") %></div>
            </div>
            <div class="stat-card s-success">
                <i class="fas fa-door-open stat-icon"></i>
                <div class="stat-label">Available Slots</div>
                <div class="stat-value"><%= stats.get("totalAvailable") %></div>
            </div>
            <div class="stat-card s-warning">
                <i class="fas fa-users stat-icon"></i>
                <div class="stat-label">Occupied</div>
                <div class="stat-value"><%= stats.get("totalOccupied") %></div>
            </div>
            <div class="stat-card s-info">
                <i class="fas fa-layer-group stat-icon"></i>
                <div class="stat-label">Total Capacity</div>
                <div class="stat-value"><%= stats.get("totalCapacity") %></div>
            </div>
        </div>

        <!-- PAGE HEADER -->
        <div class="page-header">
            <div>
                <div class="page-title"><%= pageTitle %></div>
            </div>
            <div class="filter-bar">
                <a href="rooms" class="btn-filter <%= currentFilter == null ? "active" : "" %>">
                    <i class="fas fa-th-large"></i> All Rooms
                </a>
                <a href="rooms?filter=available" class="btn-filter f-success <%= "available".equals(currentFilter) ? "active" : "" %>">
                    <i class="fas fa-check-circle"></i> Available Only
                </a>
                <a href="rooms/search" class="btn-filter f-warning">
                    <i class="fas fa-sliders-h"></i> Advanced Search
                </a>
            </div>
        </div>

        <hr class="section-divider">

        <!-- ROOM CARDS -->
        <div class="rooms-grid">
            <% if (rooms != null && !rooms.isEmpty()) {
                int cardIdx = 0;
                for (Room room : rooms) {
                    cardIdx++;
            %>
            <div class="room-card" style="animation-delay: <%= (cardIdx * 0.06) %>s;">
                <div class="room-image-wrap">
                    <img src="<%= request.getContextPath() + "/" + room.getFirstImage() %>"
                         class="room-image"
                         alt="Room <%= room.getRoomNumber() %>"
                         onerror="this.src='images/rooms/default.jpg'">
                    <span class="room-status-badge <%= room.isAvailable() ? "badge-available" : "badge-full" %>">
                        <%= room.getStatus() %>
                    </span>
                </div>

                <div class="room-body">
                    <div class="room-title">Room <%= room.getRoomNumber() %></div>

                    <div class="room-meta">
                        <div class="meta-item">
                            <strong>Floor</strong>
                            <span><%= room.getFloorNumber() %></span>
                        </div>
                        <div class="meta-item">
                            <strong>Type</strong>
                            <span><%= room.getRoomType() %></span>
                        </div>
                        <div class="meta-item">
                            <strong>Capacity</strong>
                            <span><%= room.getCapacityDisplay() %></span>
                        </div>
                        <div class="meta-item">
                            <strong>Availability</strong>
                            <span><%= room.getAvailabilityDisplay() %></span>
                        </div>
                    </div>

                    <div class="price-tag">
                        <%= room.getFormattedPrice() %> <small>/ month</small>
                    </div>

                    <!-- Facilities -->
                    <div class="facilities">
                        <% if (room.isHasWifi()) { %>
                            <span class="facility-pill"><i class="fas fa-wifi"></i> WiFi</span>
                        <% } %>
                        <% if (room.isHasAc()) { %>
                            <span class="facility-pill"><i class="fas fa-snowflake"></i> AC</span>
                        <% } %>
                        <% if (room.isHasStudyTable()) { %>
                            <span class="facility-pill"><i class="fas fa-desk"></i> Study Table</span>
                        <% } %>
                        <% if (room.isHasCupboard()) { %>
                            <span class="facility-pill"><i class="fas fa-archive"></i> Cupboard</span>
                        <% } %>
                        <% if (room.isHasRoomCleaning()) { %>
                            <span class="facility-pill"><i class="fas fa-broom"></i> Cleaning</span>
                        <% } %>
                    </div>

                    <div class="room-actions">
                        <a href="rooms/details?id=<%= room.getId() %>" class="btn-details">
                            <i class="fas fa-eye me-1"></i> View Details
                        </a>
                        <% if ("Student".equalsIgnoreCase(user.getRole()) && room.isAvailable()) { %>
                            <a href="booking/request?roomId=<%= room.getId() %>" class="btn-book">
                                <i class="fas fa-bolt me-1"></i> Book Now
                            </a>
                        <% } %>
                    </div>
                </div>
            </div>
            <% }
            } else { %>
            <div class="empty-state">
                <i class="fas fa-door-closed d-block"></i>
                <p>No rooms found matching your criteria.</p>
            </div>
            <% } %>
        </div>

            </main>
        </div>

    </div><!-- /.main-container -->

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
