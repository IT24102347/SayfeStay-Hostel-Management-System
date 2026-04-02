<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    Room room = (Room) request.getAttribute("room");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Room <%= room.getRoomNumber() %> - SafeStay</title>
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

        /* ── NAVBAR ── */
        .navbar {
            background: rgba(244,245,247,0.90) !important;
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
            text-decoration: none;
        }
        .navbar-brand span { color: var(--text); }
        .btn-nav-back {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text-muted);
            border-radius: 8px;
            font-size: 0.82rem;
            padding: 0.35rem 0.85rem;
            font-weight: 500;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
        }
        .btn-nav-back:hover {
            border-color: var(--accent);
            color: var(--accent);
            background: var(--accent-dim);
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
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
        }
        .btn-logout:hover {
            border-color: var(--danger);
            color: var(--danger);
        }

        /* ── MAIN ── */
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2.5rem 1.5rem;
        }

        /* ── BREADCRUMB ── */
        .breadcrumb-bar {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.82rem;
            color: var(--text-muted);
            margin-bottom: 1.75rem;
        }
        .breadcrumb-bar a {
            color: var(--text-muted);
            text-decoration: none;
            transition: color 0.2s;
        }
        .breadcrumb-bar a:hover { color: var(--accent); }
        .breadcrumb-bar .sep { opacity: 0.4; }
        .breadcrumb-bar .current { color: var(--text); font-weight: 500; }

        /* ── LAYOUT ── */
        .detail-layout {
            display: grid;
            grid-template-columns: 1fr 420px;
            gap: 2rem;
            align-items: start;
        }
        @media (max-width: 1024px) {
            .detail-layout { grid-template-columns: 1fr; }
        }

        /* ── GALLERY ── */
        .gallery-wrap {
            position: sticky;
            top: 90px;
        }
        @media (max-width: 1024px) {
            .gallery-wrap { position: static; }
        }

        .gallery-main {
            width: 100%;
            height: 380px;
            object-fit: cover;
            border-radius: var(--radius);
            display: block;
            margin-bottom: 0.75rem;
            transition: opacity 0.3s;
        }
        .gallery-thumbs {
            display: flex;
            gap: 0.6rem;
            flex-wrap: wrap;
        }
        .gallery-thumb {
            width: calc(25% - 0.5rem);
            height: 80px;
            object-fit: cover;
            border-radius: var(--radius-sm);
            cursor: pointer;
            border: 2px solid transparent;
            transition: border-color 0.2s, opacity 0.2s;
            opacity: 0.7;
        }
        .gallery-thumb:hover,
        .gallery-thumb.active {
            border-color: var(--accent);
            opacity: 1;
        }
        @media (max-width: 600px) {
            .gallery-main { height: 240px; }
            .gallery-thumb { width: calc(33.33% - 0.5rem); height: 65px; }
        }

        /* ── ROOM HEADER ── */
        .room-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
        }
        .room-title {
            font-family: 'Fraunces', serif;
            font-size: 2rem;
            font-weight: 600;
            color: var(--text);
            letter-spacing: -0.5px;
            line-height: 1.1;
        }
        .room-subtitle {
            color: var(--text-muted);
            font-size: 0.88rem;
            margin-top: 0.25rem;
        }
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.75rem;
            font-weight: 600;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            padding: 0.4rem 0.9rem;
            border-radius: 20px;
            white-space: nowrap;
        }
        .badge-available {
            background: rgba(22,163,74,0.1);
            border: 1px solid rgba(22,163,74,0.3);
            color: var(--success);
        }
        .badge-full {
            background: rgba(220,38,38,0.1);
            border: 1px solid rgba(220,38,38,0.3);
            color: var(--danger);
        }

        /* ── PRICE TAG ── */
        .price-block {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 1.25rem 1.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 12px rgba(0,0,0,0.04);
        }
        .price-label { font-size: 0.78rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.06em; }
        .price-value {
            font-family: 'Fraunces', serif;
            font-size: 2rem;
            font-weight: 600;
            color: var(--accent);
            line-height: 1;
        }
        .price-value small {
            font-family: 'DM Sans', sans-serif;
            font-size: 0.8rem;
            color: var(--text-muted);
            font-weight: 400;
        }
        .slots-info {
            text-align: right;
        }
        .slots-count {
            font-family: 'Fraunces', serif;
            font-size: 1.6rem;
            font-weight: 600;
            color: var(--info);
            line-height: 1;
        }

        /* ── INFO SECTIONS ── */
        .info-section {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            margin-bottom: 1.25rem;
            overflow: hidden;
            box-shadow: 0 2px 12px rgba(0,0,0,0.04);
            animation: fadeUp 0.5s ease both;
        }
        .info-section:nth-child(1) { animation-delay: 0.05s; }
        .info-section:nth-child(2) { animation-delay: 0.10s; }
        .info-section:nth-child(3) { animation-delay: 0.15s; }
        .info-section:nth-child(4) { animation-delay: 0.20s; }

        .section-header {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }
        .section-header h5 {
            font-family: 'Fraunces', serif;
            font-size: 1rem;
            font-weight: 600;
            color: var(--text);
            margin: 0;
        }
        .section-header i {
            color: var(--accent);
            font-size: 0.9rem;
        }

        /* ── BASIC INFO GRID ── */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0;
        }
        .info-cell {
            padding: 0.9rem 1.5rem;
            border-bottom: 1px solid var(--border);
            border-right: 1px solid var(--border);
        }
        .info-cell:nth-child(even) { border-right: none; }
        .info-cell:nth-last-child(-n+2) { border-bottom: none; }
        .info-cell-label {
            font-size: 0.7rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            color: var(--text-muted);
            margin-bottom: 0.2rem;
        }
        .info-cell-value {
            font-size: 0.9rem;
            font-weight: 500;
            color: var(--text);
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }
        .info-cell-value i {
            color: var(--accent);
            font-size: 0.8rem;
            opacity: 0.8;
        }
        @media (max-width: 500px) {
            .info-grid { grid-template-columns: 1fr; }
            .info-cell { border-right: none; }
            .info-cell:nth-last-child(-n+2) { border-bottom: 1px solid var(--border); }
            .info-cell:last-child { border-bottom: none; }
        }

        /* ── FACILITIES ── */
        .facility-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 0.5rem;
            padding: 1.25rem 1.5rem;
        }
        .facility-item {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            padding: 0.65rem 0.85rem;
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 0.84rem;
            color: var(--text);
            font-weight: 500;
            transition: border-color 0.2s, background 0.2s;
        }
        .facility-item:hover {
            border-color: rgba(90,158,15,0.3);
            background: var(--accent-dim);
        }
        .facility-item i {
            color: var(--accent);
            width: 16px;
            text-align: center;
            font-size: 0.85rem;
        }
        @media (max-width: 500px) {
            .facility-grid { grid-template-columns: 1fr; }
        }

        /* ── DESCRIPTION ── */
        .desc-body {
            padding: 1.25rem 1.5rem;
            color: var(--text-muted);
            font-size: 0.9rem;
            line-height: 1.7;
        }

        /* ── ACTION BUTTONS ── */
        .action-block {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            margin-top: 0.5rem;
        }
        .btn-book {
            background: var(--accent);
            border: 1px solid var(--accent);
            color: #fff;
            border-radius: var(--radius-sm);
            font-size: 0.92rem;
            font-weight: 600;
            padding: 0.85rem 1.5rem;
            text-decoration: none;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            transition: all 0.2s;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-book:hover {
            background: #4d8a0c;
            border-color: #4d8a0c;
            color: #fff;
            box-shadow: 0 4px 18px var(--accent-glow);
            transform: translateY(-1px);
        }
        .btn-book:disabled, .btn-book.disabled {
            background: var(--surface-2);
            border-color: var(--border);
            color: var(--text-muted);
            cursor: not-allowed;
            box-shadow: none;
            transform: none;
        }
        .btn-inquiry {
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--info);
            border-radius: var(--radius-sm);
            font-size: 0.92rem;
            font-weight: 600;
            padding: 0.85rem 1.5rem;
            text-decoration: none;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            transition: all 0.2s;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-inquiry:hover {
            background: rgba(37,99,235,0.06);
            border-color: rgba(37,99,235,0.35);
            color: var(--info);
            transform: translateY(-1px);
        }
        button.btn-book:disabled {
            width: 100%;
            cursor: not-allowed;
        }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .gallery-wrap { animation: fadeUp 0.4s ease both; }
        .detail-col   { animation: fadeUp 0.45s ease 0.08s both; }

        /* ── SCROLLBAR ── */
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: var(--bg); }
        ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
    </style>
</head>
<body>

    <!-- NAVBAR -->
    <nav class="navbar navbar-expand-lg">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/dashboard/student/index.jsp">Safe<span>Stay</span></a>
            <div class="d-flex align-items-center gap-2 ms-auto">
                <a href="<%= request.getContextPath() %>/rooms" class="btn-nav-back">
                    <i class="fas fa-arrow-left"></i> Back to Rooms
                </a>
                <a class="btn-logout" href="<%= request.getContextPath() %>/logout">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
    </nav>

    <!-- MAIN -->
    <div class="main-container">

        <!-- BREADCRUMB -->
        <div class="breadcrumb-bar">
            <a href="<%= request.getContextPath() %>/rooms"><i class="fas fa-home"></i> Rooms</a>
            <span class="sep"><i class="fas fa-chevron-right" style="font-size:0.65rem;"></i></span>
            <span class="current">Room <%= room.getRoomNumber() %></span>
        </div>

        <!-- LAYOUT -->
        <div class="detail-layout">

            <!-- LEFT: GALLERY -->
            <div class="gallery-wrap">
                <%
                    List<String> images = room.getImageList();
                    String firstImg = images != null && !images.isEmpty() ? images.get(0) : "images/rooms/default.jpg";
                %>
                <img id="mainImg"
                     src="<%= request.getContextPath() + "/" + firstImg %>"
                     class="gallery-main"
                     alt="Room <%= room.getRoomNumber() %>"
                     onerror="this.src='images/rooms/default.jpg'">

                <% if (images != null && images.size() > 1) { %>
                <div class="gallery-thumbs">
                    <% for (int i = 0; i < images.size(); i++) {
                        String img = images.get(i); %>
                        <img src="<%= request.getContextPath() + "/" + img %>"
                             class="gallery-thumb <%= i == 0 ? "active" : "" %>"
                             alt="Room <%= room.getRoomNumber() %>"
                             onerror="this.src='images/rooms/default.jpg'"
                             onclick="switchImage(this, '<%= request.getContextPath() + "/" + img %>')">
                    <% } %>
                </div>
                <% } %>
            </div>

            <!-- RIGHT: DETAILS -->
            <div class="detail-col">

                <!-- Room Title + Status -->
                <div class="room-header">
                    <div>
                        <div class="room-title">Room <%= room.getRoomNumber() %></div>
                        <div class="room-subtitle">
                            <i class="fas fa-layer-group" style="color:var(--accent);font-size:0.75rem;"></i>
                            Floor <%= room.getFloorNumber() %> &nbsp;·&nbsp;
                            <%= room.getRoomType() %>
                        </div>
                    </div>
                    <span class="status-badge <%= room.isAvailable() ? "badge-available" : "badge-full" %>">
                        <i class="fas <%= room.isAvailable() ? "fa-check-circle" : "fa-times-circle" %>"></i>
                        <%= room.getStatus() %>
                    </span>
                </div>

                <!-- Price Block -->
                <div class="price-block">
                    <div>
                        <div class="price-label">Monthly Rent</div>
                        <div class="price-value"><%= room.getFormattedPrice() %> <small>/ month</small></div>
                    </div>
                    <div class="slots-info">
                        <div class="price-label">Available Slots</div>
                        <div class="slots-count"><%= room.getAvailableSlots() %></div>
                    </div>
                </div>

                <!-- Basic Information -->
                <div class="info-section">
                    <div class="section-header">
                        <i class="fas fa-info-circle"></i>
                        <h5>Basic Information</h5>
                    </div>
                    <div class="info-grid">
                        <div class="info-cell">
                            <div class="info-cell-label">Floor</div>
                            <div class="info-cell-value"><i class="fas fa-building"></i><%= room.getFloorNumber() %></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label">Room Type</div>
                            <div class="info-cell-value"><i class="fas fa-door-open"></i><%= room.getRoomType() %></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label">Capacity</div>
                            <div class="info-cell-value"><i class="fas fa-users"></i><%= room.getCapacityDisplay() %></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label">Bed Type</div>
                            <div class="info-cell-value"><i class="fas fa-bed"></i><%= room.getBedType() %></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label">Bathroom</div>
                            <div class="info-cell-value"><i class="fas fa-bath"></i><%= room.getBathroomType() %></div>
                        </div>
                        <div class="info-cell">
                            <div class="info-cell-label">Available Slots</div>
                            <div class="info-cell-value"><i class="fas fa-check-circle"></i><%= room.getAvailableSlots() %></div>
                        </div>
                    </div>
                </div>

                <!-- Facilities -->
                <div class="info-section">
                    <div class="section-header">
                        <i class="fas fa-star"></i>
                        <h5>Facilities &amp; Services</h5>
                    </div>
                    <div class="facility-grid">
                        <% if (room.isHasWifi()) { %>
                            <div class="facility-item"><i class="fas fa-wifi"></i> High-Speed WiFi</div>
                        <% } %>
                        <% if (room.isHasAc()) { %>
                            <div class="facility-item"><i class="fas fa-snowflake"></i> Air Conditioning</div>
                        <% } %>
                        <% if (room.isHasFan()) { %>
                            <div class="facility-item"><i class="fas fa-fan"></i> Ceiling Fan</div>
                        <% } %>
                        <% if (room.isHasStudyTable()) { %>
                            <div class="facility-item"><i class="fas fa-desk"></i> Study Table &amp; Chair</div>
                        <% } %>
                        <% if (room.isHasCupboard()) { %>
                            <div class="facility-item"><i class="fas fa-archive"></i> Personal Cupboard</div>
                        <% } %>
                        <% if (room.isHasLaundryAccess()) { %>
                            <div class="facility-item"><i class="fas fa-tshirt"></i> Laundry Access</div>
                        <% } %>
                        <% if (room.isHasRoomCleaning()) { %>
                            <div class="facility-item"><i class="fas fa-broom"></i> Daily Room Cleaning</div>
                        <% } %>
                    </div>
                </div>

                <!-- Description -->
                <% if (room.getDescription() != null && !room.getDescription().isEmpty()) { %>
                <div class="info-section">
                    <div class="section-header">
                        <i class="fas fa-align-left"></i>
                        <h5>Description</h5>
                    </div>
                    <div class="desc-body"><%= room.getDescription() %></div>
                </div>
                <% } %>

                <!-- Action Buttons -->
                <% if ("Student".equalsIgnoreCase(user.getRole())) { %>
                <div class="action-block">
                    <% if (room.isAvailable()) { %>
                        <a href="<%= request.getContextPath() %>/booking/request?roomId=<%= room.getId() %>"
                           class="btn-book">
                            <i class="fas fa-bolt"></i> Book This Room
                        </a>
                    <% } else { %>
                        <button class="btn-book disabled" disabled>
                            <i class="fas fa-ban"></i> Room Not Available
                        </button>
                    <% } %>
                    <a href="<%= request.getContextPath() %>/inquiry?roomId=<%= room.getId() %>"
                       class="btn-inquiry">
                        <i class="fas fa-comments"></i> Make an Inquiry
                    </a>
                </div>
                <% } %>

            </div><!-- /.detail-col -->
        </div><!-- /.detail-layout -->
    </div><!-- /.main-container -->

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function switchImage(thumb, src) {
            document.getElementById('mainImg').src = src;
            document.querySelectorAll('.gallery-thumb').forEach(t => t.classList.remove('active'));
            thumb.classList.add('active');
        }
    </script>
</body>
</html>
