<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="org.example.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Inquiry> inquiries = (List<Inquiry>) request.getAttribute("inquiries");
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");

    int preselectedRoomId = 0;
    String roomIdParam = request.getParameter("roomId");
    if (roomIdParam != null) {
        try {
            preselectedRoomId = Integer.parseInt(roomIdParam);
            if (preselectedRoomId < 0) preselectedRoomId = 0;
        } catch (NumberFormatException ignore) {
            preselectedRoomId = 0;
        }
    }

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
    <title>My Inquiries - SafeStay</title>
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

        /* ── LAYOUT ── */
        .inquiry-layout {
            display: block;
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

        /* Form controls */
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
        textarea.form-control { resize: vertical; min-height: 100px; }

        .field-group { margin-bottom: 1rem; }
        .field-group:last-of-type { margin-bottom: 1.25rem; }

        .btn-submit {
            width: 100%;
            background: var(--accent);
            border: 1px solid var(--accent);
            color: #fff;
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            font-weight: 600;
            padding: 0.7rem 1.25rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            transition: all 0.2s;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-submit:hover {
            background: #4d8a0c;
            border-color: #4d8a0c;
            box-shadow: 0 4px 16px var(--accent-glow);
            transform: translateY(-1px);
        }

        /* ── RIGHT COLUMN ── */
        .right-col { animation: fadeUp 0.45s ease 0.07s both; }

        .right-header {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 1.25rem;
        }
        .page-title {
            font-family: 'Fraunces', serif;
            font-size: 1.6rem;
            font-weight: 600;
            color: var(--text);
            letter-spacing: -0.5px;
        }
        .inquiry-count {
            font-size: 0.82rem;
            color: var(--text-muted);
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 0.25rem 0.75rem;
            font-weight: 500;
        }
        .right-header-actions {
            display: flex;
            align-items: center;
            gap: 0.55rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }
        .btn-create-inquiry {
            background: var(--accent);
            border: 1px solid var(--accent);
            color: #fff;
            border-radius: 999px;
            font-size: 0.82rem;
            font-weight: 600;
            padding: 0.46rem 0.95rem;
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            transition: all 0.2s;
            line-height: 1;
        }
        .btn-create-inquiry:hover {
            background: #155bb5;
            border-color: #155bb5;
            color: #fff;
            box-shadow: 0 4px 14px var(--accent-glow);
        }

        /* ── CREATE MODAL ── */
        .create-inquiry-modal .modal-content {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: 0 24px 64px rgba(0,0,0,0.14);
            overflow: hidden;
        }
        .create-inquiry-modal .modal-header {
            background: var(--accent-dim);
            border-bottom: 1px solid rgba(29,111,216,0.22);
            padding: 1rem 1.15rem;
        }
        .create-inquiry-modal .modal-title {
            font-family: 'Fraunces', serif;
            font-size: 1.05rem;
            font-weight: 600;
            color: var(--accent);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .create-inquiry-modal .modal-body {
            padding: 1.15rem;
            background: var(--surface);
        }

        /* ── ALERTS ── */
        .alert-custom {
            border-radius: var(--radius-sm);
            padding: 0.85rem 1.1rem;
            font-size: 0.88rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1.25rem;
        }
        .alert-custom.success {
            background: rgba(22,163,74,0.08);
            border: 1px solid rgba(22,163,74,0.25);
            color: var(--success);
        }
        .alert-custom.danger {
            background: rgba(220,38,38,0.08);
            border: 1px solid rgba(220,38,38,0.25);
            color: var(--danger);
        }
        .alert-custom .close-btn {
            background: none; border: none; cursor: pointer;
            font-size: 0.82rem; opacity: 0.6; padding: 0;
            transition: opacity 0.2s; color: inherit; flex-shrink: 0;
        }
        .alert-custom .close-btn:hover { opacity: 1; }

        /* ── INQUIRY CARDS ── */
        .inquiry-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            margin-bottom: 1.1rem;
            box-shadow: 0 2px 12px rgba(0,0,0,0.04);
            transition: box-shadow 0.25s, transform 0.25s;
        }
        .inquiry-card:hover {
            box-shadow: 0 6px 24px rgba(0,0,0,0.08);
            transform: translateY(-2px);
        }
        .inquiry-card:last-child { margin-bottom: 0; }

        .inquiry-card-header {
            padding: 1rem 1.25rem;
            background: var(--surface-2);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 1rem;
        }
        .inquiry-header-left { flex: 1; min-width: 0; }
        .inquiry-id-subject {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
            margin-bottom: 0.25rem;
        }
        .inquiry-id {
            font-family: 'Fraunces', serif;
            font-size: 0.82rem;
            font-weight: 600;
            color: var(--accent);
            white-space: nowrap;
        }
        .inquiry-subject {
            font-size: 0.92rem;
            font-weight: 600;
            color: var(--text);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .inquiry-meta {
            font-size: 0.77rem;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        .inquiry-meta .dot { opacity: 0.4; }
        .inquiry-type-icon { color: var(--accent); font-size: 0.75rem; }

        /* Status badge */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            font-size: 0.7rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            padding: 0.3rem 0.7rem;
            border-radius: 20px;
            white-space: nowrap;
            flex-shrink: 0;
        }
        .badge-open      { background: rgba(37,99,235,0.1);   border: 1px solid rgba(37,99,235,0.25);   color: var(--info); }
        .badge-pending   { background: rgba(217,119,6,0.1);   border: 1px solid rgba(217,119,6,0.25);   color: var(--warning); }
        .badge-replied   { background: rgba(22,163,74,0.1);   border: 1px solid rgba(22,163,74,0.25);   color: var(--success); }
        .badge-closed    { background: rgba(107,107,128,0.1); border: 1px solid rgba(107,107,128,0.2);  color: var(--text-muted); }
        .badge-success   { background: rgba(22,163,74,0.1);   border: 1px solid rgba(22,163,74,0.25);   color: var(--success); }
        .badge-warning   { background: rgba(217,119,6,0.1);   border: 1px solid rgba(217,119,6,0.25);   color: var(--warning); }
        .badge-danger    { background: rgba(220,38,38,0.1);   border: 1px solid rgba(220,38,38,0.25);   color: var(--danger); }
        .badge-info      { background: rgba(37,99,235,0.1);   border: 1px solid rgba(37,99,235,0.25);   color: var(--info); }
        .badge-secondary { background: rgba(107,107,128,0.1); border: 1px solid rgba(107,107,128,0.2);  color: var(--text-muted); }
        .badge-primary   { background: var(--accent-dim);      border: 1px solid rgba(90,158,15,0.3);    color: var(--accent); }

        /* Card body */
        .inquiry-card-body { padding: 1.1rem 1.25rem; }

        .message-label {
            font-size: 0.72rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            color: var(--text-muted);
            margin-bottom: 0.4rem;
        }
        .message-text {
            font-size: 0.88rem;
            color: var(--text);
            line-height: 1.65;
            margin-bottom: 0;
        }

        /* Admin reply block */
        .reply-block {
            margin-top: 1rem;
            background: rgba(22,163,74,0.05);
            border: 1px solid rgba(22,163,74,0.2);
            border-radius: var(--radius-sm);
            padding: 1rem 1.1rem;
        }
        .reply-header {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
        }
        .reply-label {
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            color: var(--success);
        }
        .reply-icon { color: var(--success); font-size: 0.8rem; }
        .reply-text {
            font-size: 0.88rem;
            color: var(--text);
            line-height: 1.65;
            margin-bottom: 0.5rem;
        }
        .reply-date {
            font-size: 0.75rem;
            color: var(--text-muted);
        }

        /* Card footer */
        .inquiry-card-footer {
            padding: 0.6rem 1.25rem;
            border-top: 1px solid var(--border);
            background: var(--surface);
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }
        .created-date {
            font-size: 0.75rem;
            color: var(--text-muted);
        }

        /* ── EMPTY STATE ── */
        .empty-state {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 3.5rem 2rem;
            text-align: center;
        }
        .empty-icon {
            width: 64px;
            height: 64px;
            background: var(--surface-2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.1rem;
        }
        .empty-icon i { font-size: 1.5rem; color: var(--text-muted); opacity: 0.45; }
        .empty-state h6 {
            font-family: 'Fraunces', serif;
            font-size: 1.05rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 0.4rem;
        }
        .empty-state p { color: var(--text-muted); font-size: 0.85rem; margin: 0; }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .inquiry-card { animation: fadeUp 0.4s ease both; }

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

            <div class="inquiry-layout">
            <!-- RIGHT: INQUIRIES LIST -->
            <div class="right-col">

                <div class="right-header">
                    <div class="page-title">My Inquiries</div>
                    <div class="right-header-actions">
                        <% if (inquiries != null && !inquiries.isEmpty()) { %>
                        <span class="inquiry-count"><%= inquiries.size() %> total</span>
                        <% } %>
                        <button type="button" class="btn-create-inquiry" data-bs-toggle="modal" data-bs-target="#createInquiryModal">
                            <i class="fas fa-plus"></i> Create New Inquiry
                        </button>
                    </div>
                </div>

                <!-- SUCCESS ALERT -->
                <% String success = (String) session.getAttribute("success");
                   if (success != null) { %>
                    <div class="alert-custom success" id="alertSuccess">
                        <span><i class="fas fa-check-circle me-2"></i><%= success %></span>
                        <button class="close-btn" onclick="document.getElementById('alertSuccess').remove()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <% session.removeAttribute("success"); %>
                <% } %>

                <!-- ERROR ALERT -->
                <% String error = (String) session.getAttribute("error");
                   if (error != null) { %>
                    <div class="alert-custom danger" id="alertError">
                        <span><i class="fas fa-exclamation-circle me-2"></i><%= error %></span>
                        <button class="close-btn" onclick="document.getElementById('alertError').remove()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <% session.removeAttribute("error"); %>
                <% } %>

                <!-- INQUIRY CARDS -->
                <% if (inquiries != null && !inquiries.isEmpty()) { %>
                    <% int idx = 0; for (Inquiry inquiry : inquiries) { idx++; %>
                    <div class="inquiry-card" style="animation-delay: <%= idx * 0.06 %>s;">

                        <!-- Card Header -->
                        <div class="inquiry-card-header">
                            <div class="inquiry-header-left">
                                <div class="inquiry-id-subject">
                                    <i class="fas <%= inquiry.getInquiryTypeIcon() %> inquiry-type-icon"></i>
                                    <span class="inquiry-id"><%= inquiry.getInquiryId() %></span>
                                    <span style="color:var(--text-muted);opacity:0.4;">·</span>
                                    <span class="inquiry-subject"><%= inquiry.getSubject() %></span>
                                </div>
                                <div class="inquiry-meta">
                                    <span><%= inquiry.getInquiryType() %></span>
                                    <% if (inquiry.hasRoomReference()) { %>
                                        <span class="dot">·</span>
                                        <span><i class="fas fa-building" style="font-size:0.68rem;"></i> Room <%= inquiry.getRoomNumber() %></span>
                                    <% } %>
                                </div>
                            </div>
                            <span class="status-badge badge-<%= inquiry.getStatusBadgeClass() %>">
                                <%= inquiry.getStatus() %>
                            </span>
                        </div>

                        <!-- Card Body -->
                        <div class="inquiry-card-body">
                            <div class="message-label">Your Message</div>
                            <p class="message-text"><%= inquiry.getMessage() %></p>

                            <% if (inquiry.getReplyMessage() != null) { %>
                            <div class="reply-block">
                                <div class="reply-header">
                                    <i class="fas fa-reply reply-icon"></i>
                                    <span class="reply-label">Admin Reply</span>
                                </div>
                                <p class="reply-text"><%= inquiry.getReplyMessage() %></p>
                                <span class="reply-date">
                                    <i class="fas fa-clock" style="font-size:0.68rem;"></i>
                                    Replied on <%= new java.text.SimpleDateFormat("dd MMM yyyy HH:mm").format(inquiry.getRepliedAt()) %>
                                </span>
                            </div>
                            <% } %>
                        </div>

                        <!-- Card Footer -->
                        <div class="inquiry-card-footer">
                            <i class="fas fa-clock" style="font-size:0.68rem; color:var(--text-muted);"></i>
                            <span class="created-date">
                                Created <%= new java.text.SimpleDateFormat("dd MMM yyyy HH:mm").format(inquiry.getCreatedAt()) %>
                            </span>
                        </div>

                    </div>
                    <% } %>

                <% } else { %>

                <!-- EMPTY STATE -->
                <div class="empty-state">
                    <div class="empty-icon"><i class="fas fa-comments"></i></div>
                    <h6>No Inquiries Yet</h6>
                    <p>You haven't created any inquiries yet. Use the form to ask questions!</p>
                </div>

                <% } %>
            </div><!-- /.right-col -->
            </div><!-- /.inquiry-layout -->

            <div class="modal fade create-inquiry-modal" id="createInquiryModal" tabindex="-1" aria-labelledby="createInquiryModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="createInquiryModalLabel">
                                <i class="fas fa-plus-circle"></i> Create New Inquiry
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <form action="<%= request.getContextPath() %>/inquiry" method="post">
                                <div class="field-group">
                                    <label class="form-label">Inquiry Type *</label>
                                    <select name="inquiryType" class="form-select" required>
                                        <option value="">Select Type</option>
                                        <option value="Room Details">Room Details</option>
                                        <option value="Location">Location Information</option>
                                        <option value="Photos">Additional Photos</option>
                                        <option value="Facilities">Facilities Query</option>
                                        <option value="General">General Query</option>
                                    </select>
                                </div>

                                <div class="field-group">
                                    <label class="form-label">Room <span style="font-weight:400;text-transform:none;letter-spacing:0;font-size:0.75rem;opacity:0.7;">(Optional)</span></label>
                                    <select id="inquiryRoomSelect" name="roomId" class="form-select">
                                        <option value="0" <%= preselectedRoomId == 0 ? "selected" : "" %>>General Inquiry</option>
                                        <% if (rooms != null) {
                                            for (Room room : rooms) { %>
                                            <option value="<%= room.getId() %>" <%= preselectedRoomId == room.getId() ? "selected" : "" %>>
                                                Room <%= room.getRoomNumber() %> — Floor <%= room.getFloorNumber() %>
                                            </option>
                                        <% }
                                        } %>
                                    </select>
                                </div>

                                <div class="field-group">
                                    <label class="form-label">Subject *</label>
                                    <input type="text" name="subject" class="form-control"
                                           placeholder="Brief subject" required>
                                </div>

                                <div class="field-group">
                                    <label class="form-label">Message *</label>
                                    <textarea name="message" class="form-control" rows="4"
                                              placeholder="Your inquiry message..." required></textarea>
                                </div>

                                <button type="submit" class="btn-submit">
                                    <i class="fas fa-paper-plane"></i> Submit Inquiry
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div><!-- /.page-layout -->
    </div><!-- /.main-container -->

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        (function () {
            var preselectedRoomId = <%= preselectedRoomId %>;
            if (preselectedRoomId <= 0) {
                return;
            }

            var modalEl = document.getElementById('createInquiryModal');
            if (!modalEl) {
                return;
            }

            var roomSelect = document.getElementById('inquiryRoomSelect');
            if (roomSelect) {
                roomSelect.value = String(preselectedRoomId);
            }

            var inquiryModal = new bootstrap.Modal(modalEl);
            inquiryModal.show();
        })();
    </script>
</body>
</html>
