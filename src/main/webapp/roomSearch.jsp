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
    Boolean searchPerformed = (Boolean) request.getAttribute("searchPerformed");
    Integer resultCount = (Integer) request.getAttribute("resultCount");

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
    <title>Search Rooms - SafeStay</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Fraunces:ital,wght@0,400;0,600;1,400&display=swap" rel="stylesheet">
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
            font-family: 'DM Sans', sans-serif;
            font-size: 15px;
            min-height: 100vh;
            background-image:
                radial-gradient(ellipse 60% 40% at 80% -10%, rgba(29,111,216,0.07) 0%, transparent 60%),
                radial-gradient(ellipse 40% 30% at -5% 80%, rgba(29,111,216,0.04) 0%, transparent 50%);
        }

        /* ── MAIN ── */
        .main-container {
            max-width: 1420px;
            margin: 0 auto;
            padding: 2.5rem 1.5rem;
        }
        .page-layout {
            position: relative;
            padding-left: calc(320px + 1.25rem);
        }
        .rooms-sidebar {
            background: linear-gradient(180deg, #1a237e 0%, #0d47a1 100%);
            color: #ffffff;
            border: none;
            border-radius: 0 20px 20px 0;
            padding: 1.2rem;
            position: fixed;
            top: 0;
            left: 0;
            width: 320px;
            height: 100vh;
            box-shadow: 0 16px 30px rgba(9, 21, 46, 0.25);
            display: flex;
            flex-direction: column;
            overflow-y: auto;
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
        .search-main {
            min-width: 0;
        }
        @media (max-width: 1080px) {
            .page-layout {
                padding-left: 0;
            }
            .rooms-sidebar {
                position: static;
                top: auto;
                left: auto;
                width: auto;
                height: auto;
                overflow: visible;
                margin-bottom: 1rem;
                border-radius: 16px;
            }
            .side-nav-foot {
                margin-top: 0.4rem;
            }
        }

        /* ── PAGE HEADER ── */
        .page-header {
            margin-bottom: 1.75rem;
        }
        .page-title {
            font-family: 'Fraunces', serif;
            font-size: 1.75rem;
            font-weight: 600;
            color: var(--text);
            letter-spacing: -0.5px;
        }
        .page-subtitle { color: var(--text-muted); font-size: 0.88rem; margin-top: 0.2rem; }

        /* ── SEARCH PANEL ── */
        .search-panel {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: 0 2px 16px rgba(0,0,0,0.04);
            margin-bottom: 2rem;
            animation: fadeUp 0.4s ease both;
        }
        .search-panel-header {
            padding: 1rem 1.5rem;
            background: var(--surface-2);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }
        .search-panel-header h5 {
            font-family: 'Fraunces', serif;
            font-size: 1rem;
            font-weight: 600;
            color: var(--text);
            margin: 0;
        }
        .search-panel-header i { color: var(--accent); font-size: 0.9rem; }
        .search-panel-body { padding: 1.5rem; }

        /* ── FORM CONTROLS ── */
        .form-label {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--text-muted);
            margin-bottom: 0.4rem;
            display: block;
        }
        .form-control, .form-select {
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 0.88rem;
            padding: 0.6rem 0.9rem;
            transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
            width: 100%;
        }
        .form-control:focus, .form-select:focus {
            background: var(--surface);
            border-color: var(--accent);
            box-shadow: 0 0 0 3px var(--accent-dim);
            outline: none;
            color: var(--text);
        }
        .form-control::placeholder { color: var(--text-muted); opacity: 0.6; }
        .form-select option { background: var(--surface); color: var(--text); }

        /* ── CHECKBOX FACILITIES ── */
        .facility-checks {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            padding-top: 0.15rem;
        }
        .check-item {
            display: flex;
            align-items: center;
            gap: 0.55rem;
            cursor: pointer;
        }
        .check-item input[type="checkbox"] {
            width: 16px;
            height: 16px;
            border: 1.5px solid var(--border);
            border-radius: 4px;
            accent-color: var(--accent);
            cursor: pointer;
            flex-shrink: 0;
        }
        .check-item label {
            font-size: 0.88rem;
            color: var(--text);
            font-weight: 400;
            cursor: pointer;
            margin: 0;
            text-transform: none;
            letter-spacing: 0;
        }

        /* ── DIVIDER ── */
        .filter-divider {
            border: none;
            border-top: 1px solid var(--border);
            margin: 1.25rem 0;
        }

        /* ── SEARCH BUTTON ── */
        .btn-search {
            width: 100%;
            background: var(--accent);
            border: 1px solid var(--accent);
            color: #fff;
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            font-weight: 600;
            padding: 0.7rem 1.25rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            transition: all 0.2s;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            height: 100%;
        }
        .btn-search:hover {
            background: #4d8a0c;
            border-color: #4d8a0c;
            box-shadow: 0 4px 16px var(--accent-glow);
            transform: translateY(-1px);
        }

        /* ── RESULTS HEADER ── */
        .results-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 0.75rem;
            margin-bottom: 1.25rem;
            animation: fadeUp 0.4s ease both;
        }
        .results-title {
            font-family: 'Fraunces', serif;
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--text);
        }
        .results-count {
            background: var(--accent-dim);
            border: 1px solid rgba(90,158,15,0.25);
            color: var(--accent);
            font-size: 0.8rem;
            font-weight: 600;
            padding: 0.3rem 0.85rem;
            border-radius: 20px;
        }

        /* ── NO RESULTS ── */
        .no-results {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 3rem 2rem;
            text-align: center;
            animation: fadeUp 0.4s ease both;
        }
        .no-results-icon {
            width: 64px;
            height: 64px;
            background: rgba(217,119,6,0.08);
            border: 1px solid rgba(217,119,6,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
        }
        .no-results-icon i { font-size: 1.5rem; color: var(--warning); }
        .no-results h6 {
            font-family: 'Fraunces', serif;
            font-size: 1.05rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 0.4rem;
        }
        .no-results p { color: var(--text-muted); font-size: 0.88rem; margin: 0; }

        /* ── ROOM GRID ── */
        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.25rem;
            animation: fadeUp 0.45s ease 0.05s both;
        }
        @media (max-width: 1024px) { .rooms-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 580px)  { .rooms-grid { grid-template-columns: 1fr; } }

        /* ── ROOM CARD ── */
        .room-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            transition: transform 0.28s, border-color 0.28s, box-shadow 0.28s;
        }
        .room-card:hover {
            transform: translateY(-5px);
            border-color: rgba(90,158,15,0.25);
            box-shadow: 0 16px 40px rgba(0,0,0,0.1);
        }
        .room-card-img {
            position: relative;
            overflow: hidden;
        }
        .room-card-img img {
            width: 100%;
            height: 185px;
            object-fit: cover;
            display: block;
            transition: transform 0.45s ease;
        }
        .room-card:hover .room-card-img img { transform: scale(1.04); }

        .room-avail-badge {
            position: absolute;
            top: 0.7rem;
            right: 0.7rem;
            font-size: 0.68rem;
            font-weight: 700;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            padding: 0.28rem 0.65rem;
            border-radius: 20px;
            backdrop-filter: blur(6px);
        }
        .badge-available {
            background: rgba(22,163,74,0.15);
            border: 1px solid rgba(22,163,74,0.4);
            color: var(--success);
        }
        .badge-full {
            background: rgba(220,38,38,0.15);
            border: 1px solid rgba(220,38,38,0.4);
            color: var(--danger);
        }

        .room-card-body {
            padding: 1.1rem 1.25rem;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .room-card-title {
            font-family: 'Fraunces', serif;
            font-size: 1rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 0.75rem;
        }
        .room-card-meta {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.5rem 0.75rem;
            margin-bottom: 0.85rem;
        }
        .meta-row { font-size: 0.8rem; }
        .meta-key {
            font-size: 0.68rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--text-muted);
            display: block;
            margin-bottom: 0.05rem;
        }
        .meta-val { color: var(--text); font-weight: 500; font-size: 0.84rem; }

        .room-card-price {
            font-family: 'Fraunces', serif;
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--accent);
            margin-bottom: 0.9rem;
        }
        .room-card-price small {
            font-family: 'DM Sans', sans-serif;
            font-size: 0.72rem;
            color: var(--text-muted);
            font-weight: 400;
        }

        .btn-details {
            width: 100%;
            background: var(--surface-2);
            border: 1px solid var(--border);
            color: var(--text);
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            padding: 0.55rem 1rem;
            text-decoration: none;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            transition: all 0.2s;
            margin-top: auto;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-details:hover {
            background: var(--accent-dim);
            border-color: rgba(90,158,15,0.3);
            color: var(--accent);
        }
        .btn-inquiry {
            width: 100%;
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text);
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            padding: 0.55rem 1rem;
            text-decoration: none;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            transition: all 0.2s;
            margin-top: 0.45rem;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-inquiry:hover {
            background: var(--accent-dim);
            border-color: rgba(29,111,216,0.3);
            color: var(--accent);
        }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── SCROLLBAR ── */
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: var(--bg); }
        ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
    </style>
</head>
<body>
    <!-- MAIN -->
    <div class="main-container">
        <div class="page-layout">
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
                    <a href="<%= contextPath %>/rooms" class="side-nav-link <%= navRoomsActive ? "active" : "" %>">
                        <i class="fas fa-bed"></i> Browse Rooms
                    </a>
                    <a href="<%= contextPath %>/inquiry" class="side-nav-link <%= navInquiriesActive ? "active" : "" %>">
                        <i class="fas fa-comments"></i> My Inquiries
                    </a>
                    <a href="<%= contextPath %>/booking/my-bookings" class="side-nav-link <%= navBookingsActive ? "active" : "" %>">
                        <i class="fas fa-calendar-check"></i> My Bookings
                    </a>
                    <a href="<%= contextPath %>/rooms/search" class="side-nav-link <%= navSearchActive ? "active" : "" %>">
                        <i class="fas fa-sliders-h"></i> Advanced Search
                    </a>
                </nav>
                <div class="side-nav-foot">
                    <a href="<%= contextPath %>/dashboard/student/index.jsp" class="side-nav-link <%= navDashboardActive ? "active" : "" %>">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </a>
                    <a href="<%= contextPath %>/logout" class="side-nav-link">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </aside>

            <div class="search-main">

        <!-- PAGE HEADER -->
        <div class="page-header">
            <div class="page-title">Search Rooms</div>
            <div class="page-subtitle">Filter and find the perfect room for your needs</div>
        </div>

        <!-- SEARCH PANEL -->
        <div class="search-panel">
            <div class="search-panel-header">
                <i class="fas fa-sliders-h"></i>
                <h5>Filter Options</h5>
            </div>
            <div class="search-panel-body">
                <form action="<%= request.getContextPath() %>/rooms/search" method="get">
                    <div class="row g-3">

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Room Type</label>
                            <select name="roomType" class="form-select">
                                <option value="">Any</option>
                                <option value="AC" <%= "AC".equals(request.getAttribute("roomType")) ? "selected" : "" %>>AC</option>
                                <option value="Non-AC" <%= "Non-AC".equals(request.getAttribute("roomType")) ? "selected" : "" %>>Non-AC</option>
                            </select>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Capacity</label>
                            <select name="capacity" class="form-select">
                                <option value="">Any</option>
                                <option value="1" <%= "1".equals(request.getAttribute("capacity")) ? "selected" : "" %>>Single (1)</option>
                                <option value="2" <%= "2".equals(request.getAttribute("capacity")) ? "selected" : "" %>>Double (2)</option>
                                <option value="3" <%= "3".equals(request.getAttribute("capacity")) ? "selected" : "" %>>Triple (3)</option>
                                <option value="4" <%= "4".equals(request.getAttribute("capacity")) ? "selected" : "" %>>Four (4)</option>
                                <option value="5" <%= "5".equals(request.getAttribute("capacity")) ? "selected" : "" %>>Five (5)</option>
                            </select>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Min Price (Rs.)</label>
                            <input type="number" name="minPrice" class="form-control"
                                   value="<%= request.getAttribute("minPrice") != null ? request.getAttribute("minPrice") : "" %>"
                                   placeholder="e.g., 5000">
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Max Price (Rs.)</label>
                            <input type="number" name="maxPrice" class="form-control"
                                   value="<%= request.getAttribute("maxPrice") != null ? request.getAttribute("maxPrice") : "" %>"
                                   placeholder="e.g., 15000">
                        </div>

                    </div>

                    <hr class="filter-divider">

                    <div class="row g-3 align-items-end">

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Floor Number</label>
                            <select name="floor" class="form-select">
                                <option value="">Any Floor</option>
                                <option value="1" <%= "1".equals(request.getAttribute("floor")) ? "selected" : "" %>>Floor 1</option>
                                <option value="2" <%= "2".equals(request.getAttribute("floor")) ? "selected" : "" %>>Floor 2</option>
                                <option value="3" <%= "3".equals(request.getAttribute("floor")) ? "selected" : "" %>>Floor 3</option>
                                <option value="4" <%= "4".equals(request.getAttribute("floor")) ? "selected" : "" %>>Floor 4</option>
                                <option value="5" <%= "5".equals(request.getAttribute("floor")) ? "selected" : "" %>>Floor 5</option>
                            </select>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Bathroom Type</label>
                            <select name="bathroomType" class="form-select">
                                <option value="">Any</option>
                                <option value="Attached Bathroom" <%= "Attached Bathroom".equals(request.getAttribute("bathroomType")) ? "selected" : "" %>>Attached</option>
                                <option value="Common Bathroom" <%= "Common Bathroom".equals(request.getAttribute("bathroomType")) ? "selected" : "" %>>Common</option>
                            </select>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <label class="form-label">Facilities</label>
                            <div class="facility-checks">
                                <div class="check-item">
                                    <input class="form-check-input" type="checkbox" name="hasWifi" id="hasWifi"
                                           <%= request.getAttribute("hasWifi") != null ? "checked" : "" %>>
                                    <label for="hasWifi"><i class="fas fa-wifi" style="color:var(--accent);font-size:0.75rem;"></i> WiFi</label>
                                </div>
                                <div class="check-item">
                                    <input class="form-check-input" type="checkbox" name="hasAc" id="hasAc"
                                           <%= request.getAttribute("hasAc") != null ? "checked" : "" %>>
                                    <label for="hasAc"><i class="fas fa-snowflake" style="color:var(--accent);font-size:0.75rem;"></i> Air Conditioning</label>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-3 col-sm-6">
                            <button type="submit" class="btn-search">
                                <i class="fas fa-search"></i> Search Rooms
                            </button>
                        </div>

                    </div>
                </form>
            </div>
        </div>

        <!-- SEARCH RESULTS -->
        <% if (searchPerformed != null && searchPerformed) { %>

            <div class="results-header">
                <div class="results-title">Search Results</div>
                <span class="results-count">
                    <i class="fas fa-door-open" style="font-size:0.75rem;"></i>
                    <%= resultCount %> room<%= resultCount != 1 ? "s" : "" %> found
                </span>
            </div>

            <% if (rooms != null && !rooms.isEmpty()) { %>
            <div class="rooms-grid">
                <% int idx = 0; for (Room room : rooms) { idx++; %>
                <div class="room-card" style="animation-delay:<%= idx * 0.06 %>s;">
                    <div class="room-card-img">
                        <%
                            String firstImage = room.getFirstImage();
                            String roomImageSrc = firstImage.startsWith("data:image") ? firstImage : request.getContextPath() + "/" + firstImage;
                        %>
                        <img src="<%= roomImageSrc %>"
                             alt="Room <%= room.getRoomNumber() %>"
                             onerror="this.src='images/rooms/default.jpg'">
                        <span class="room-avail-badge <%= room.isAvailable() ? "badge-available" : "badge-full" %>">
                            <%= room.isAvailable() ? "Available" : "Full" %>
                        </span>
                    </div>
                    <div class="room-card-body">
                        <div class="room-card-title">Room <%= room.getRoomNumber() %></div>
                        <div class="room-card-meta">
                            <div class="meta-row">
                                <span class="meta-key">Type</span>
                                <span class="meta-val"><%= room.getRoomType() %></span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-key">Capacity</span>
                                <span class="meta-val"><%= room.getCapacityDisplay() %></span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-key">Available</span>
                                <span class="meta-val"><%= room.getAvailableSlots() %> slot(s)</span>
                            </div>
                        </div>
                        <div class="room-card-price">
                            <%= room.getFormattedPrice() %> <small>/ month</small>
                        </div>
                        <a href="<%= request.getContextPath() %>/rooms/details?id=<%= room.getId() %>"
                           class="btn-details">
                            <i class="fas fa-eye"></i> View Details
                        </a>
                        <% if ("Student".equalsIgnoreCase(user.getRole())) { %>
                        <a href="<%= request.getContextPath() %>/inquiry?roomId=<%= room.getId() %>"
                           class="btn-inquiry">
                            <i class="fas fa-comments"></i> Make Inquiry
                        </a>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>

            <% } else { %>
            <div class="no-results">
                <div class="no-results-icon"><i class="fas fa-search-minus"></i></div>
                <h6>No Rooms Found</h6>
                <p>No rooms match your search criteria. Try adjusting your filters and searching again.</p>
            </div>
            <% } %>

        <% } %>

            </div><!-- /.search-main -->
        </div><!-- /.page-layout -->
    </div><!-- /.main-container -->

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
