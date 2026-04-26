<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="org.example.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<BookingRequest> bookings = (List<BookingRequest>) request.getAttribute("bookings");

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
    <title>My Bookings - SafeStay</title>
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
        .bookings-main {
            min-width: 0;
        }

        /* ── PAGE HEADER ── */
        .page-header {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1rem;
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

        /* ── ALERT ── */
        .alert-success-custom {
            background: rgba(22,163,74,0.08);
            border: 1px solid rgba(22,163,74,0.25);
            color: var(--success);
            border-radius: var(--radius-sm);
            padding: 0.85rem 1.1rem;
            font-size: 0.88rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1.5rem;
            animation: fadeUp 0.3s ease both;
        }
        .alert-success-custom .close-btn {
            background: none;
            border: none;
            color: var(--success);
            cursor: pointer;
            font-size: 0.85rem;
            opacity: 0.7;
            transition: opacity 0.2s;
            padding: 0;
            flex-shrink: 0;
        }
        .alert-success-custom .close-btn:hover { opacity: 1; }

        /* ── TABLE CARD ── */
        .table-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: 0 2px 16px rgba(0,0,0,0.04);
            animation: fadeUp 0.4s ease both;
        }

        /* ── TABLE ── */
        .bookings-table {
            width: 100%;
            border-collapse: collapse;
        }
        .bookings-table thead tr {
            background: var(--surface-2);
            border-bottom: 1px solid var(--border);
        }
        .bookings-table thead th {
            padding: 0.85rem 1.1rem;
            font-size: 0.72rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            color: var(--text-muted);
            white-space: nowrap;
            border: none;
        }
        .bookings-table tbody tr {
            border-bottom: 1px solid var(--border);
            transition: background 0.15s;
        }
        .bookings-table tbody tr:last-child { border-bottom: none; }
        .bookings-table tbody tr:hover { background: rgba(90,158,15,0.03); }
        .bookings-table tbody td {
            padding: 1rem 1.1rem;
            font-size: 0.88rem;
            color: var(--text);
            vertical-align: middle;
            border: none;
        }

        .booking-id {
            font-family: 'Fraunces', serif;
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--accent);
        }
        .room-info .room-num { font-weight: 600; color: var(--text); }
        .room-info .room-floor { font-size: 0.78rem; color: var(--text-muted); margin-top: 0.1rem; }
        .duration-info .dur-months { font-weight: 600; }
        .duration-info .dur-dates { font-size: 0.78rem; color: var(--text-muted); margin-top: 0.1rem; }
        .amount-val { font-weight: 600; color: var(--text); }
        .date-val { font-size: 0.84rem; color: var(--text-muted); }

        /* ── BADGES ── */
        .badge {
            font-size: 0.7rem !important;
            font-weight: 600 !important;
            letter-spacing: 0.04em;
            padding: 0.32rem 0.65rem !important;
            border-radius: 20px !important;
        }
        .badge.bg-success { background: rgba(22,163,74,0.12) !important; color: var(--success) !important; border: 1px solid rgba(22,163,74,0.25); }
        .badge.bg-warning { background: rgba(217,119,6,0.12) !important; color: var(--warning) !important; border: 1px solid rgba(217,119,6,0.25); }
        .badge.bg-danger  { background: rgba(220,38,38,0.12) !important; color: var(--danger)  !important; border: 1px solid rgba(220,38,38,0.25); }
        .badge.bg-info    { background: rgba(37,99,235,0.12) !important; color: var(--info)    !important; border: 1px solid rgba(37,99,235,0.25); }
        .badge.bg-secondary { background: rgba(107,107,128,0.1) !important; color: var(--text-muted) !important; border: 1px solid rgba(107,107,128,0.2); }
        .badge.bg-primary { background: var(--accent-dim) !important; color: var(--accent) !important; border: 1px solid rgba(90,158,15,0.3); }

        /* ── VIEW BUTTON ── */
        .btn-view {
            background: var(--surface-2);
            border: 1px solid var(--border);
            color: var(--info);
            border-radius: 8px;
            font-size: 0.78rem;
            font-weight: 600;
            padding: 0.38rem 0.85rem;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            transition: all 0.2s;
            cursor: pointer;
            white-space: nowrap;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-view:hover {
            background: rgba(37,99,235,0.08);
            border-color: rgba(37,99,235,0.35);
            color: var(--info);
        }

        /* ── EMPTY STATE ── */
        .empty-state {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 4rem 2rem;
            text-align: center;
            animation: fadeUp 0.4s ease both;
        }
        .empty-icon {
            width: 72px;
            height: 72px;
            background: var(--surface-2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.25rem;
        }
        .empty-icon i { font-size: 1.75rem; color: var(--text-muted); opacity: 0.5; }
        .empty-state h5 {
            font-family: 'Fraunces', serif;
            font-size: 1.15rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 0.5rem;
        }
        .empty-state p { color: var(--text-muted); font-size: 0.88rem; margin-bottom: 1.5rem; }
        .btn-browse {
            background: var(--accent);
            border: 1px solid var(--accent);
            color: #fff;
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            font-weight: 600;
            padding: 0.65rem 1.5rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-browse:hover {
            background: #4d8a0c;
            border-color: #4d8a0c;
            color: #fff;
            box-shadow: 0 4px 16px var(--accent-glow);
        }

        /* ── MODAL ── */
        .modal-content {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: 0 24px 64px rgba(0,0,0,0.14);
            overflow: hidden;
        }
        .modal-header {
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            padding: 1.25rem 1.5rem;
        }
        .modal-title {
            font-family: 'Fraunces', serif;
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        .modal-body {
            padding: 1.5rem;
            background: var(--bg);
        }
        .btn-close { opacity: 0.4; transition: opacity 0.2s; }
        .btn-close:hover { opacity: 0.8; }

        /* Modal info sections */
        .modal-section {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            padding: 1.1rem 1.25rem;
            height: 100%;
        }
        .modal-section-title {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.09em;
            color: var(--accent);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
            padding-bottom: 0.65rem;
            border-bottom: 1px solid var(--border);
        }
        .modal-field {
            display: flex;
            flex-direction: column;
            gap: 0.1rem;
            margin-bottom: 0.7rem;
        }
        .modal-field:last-child { margin-bottom: 0; }
        .modal-field-label {
            font-size: 0.7rem;
            color: var(--text-muted);
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .modal-field-value {
            font-size: 0.9rem;
            font-weight: 500;
            color: var(--text);
        }
        .modal-field-value.accent {
            color: var(--accent);
            font-family: 'Fraunces', serif;
            font-size: 1rem;
        }

        .admin-remark {
            background: rgba(37,99,235,0.06);
            border: 1px solid rgba(37,99,235,0.2);
            border-radius: var(--radius-sm);
            padding: 0.85rem 1.1rem;
            color: var(--info);
            font-size: 0.88rem;
            line-height: 1.6;
        }
        .special-request-text {
            font-size: 0.88rem;
            color: var(--text);
            line-height: 1.7;
        }

        /* ── RESPONSIVE TABLE ── */
        .table-responsive-wrap { overflow-x: auto; }
        @media (max-width: 768px) {
            .bookings-table thead { display: none; }
            .bookings-table tbody tr {
                display: block;
                padding: 1rem 1.1rem;
                border-bottom: 1px solid var(--border);
            }
            .bookings-table tbody td {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 0.35rem 0;
                font-size: 0.85rem;
                border: none;
            }
            .bookings-table tbody td::before {
                content: attr(data-label);
                font-size: 0.72rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.06em;
                color: var(--text-muted);
                flex-shrink: 0;
                margin-right: 1rem;
            }
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

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── SCROLLBAR ── */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
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

            <div class="bookings-main">

        <!-- PAGE HEADER -->
        <div class="page-header">
            <div>
                <div class="page-title">My Booking Requests</div>
                <div class="page-subtitle">Track and manage all your room booking requests</div>
            </div>
        </div>

        <!-- SUCCESS ALERT -->
        <% String success = (String) session.getAttribute("success");
           if (success != null) { %>
            <div class="alert-success-custom" id="successAlert">
                <span><i class="fas fa-check-circle me-2"></i><%= success %></span>
                <button class="close-btn" onclick="document.getElementById('successAlert').remove()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <% session.removeAttribute("success"); %>
        <% } %>

        <!-- BOOKINGS TABLE -->
        <% if (bookings != null && !bookings.isEmpty()) { %>
        <div class="table-card">
            <div class="table-responsive-wrap">
                <table class="bookings-table">
                    <thead>
                        <tr>
                            <th>Booking ID</th>
                            <th>Room</th>
                            <th>Duration</th>
                            <th>Total Amount</th>
                            <th>Status</th>
                            <th>Payment</th>
                            <th>Requested On</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (BookingRequest booking : bookings) { %>
                        <tr>
                            <td data-label="Booking ID">
                                <span class="booking-id">#<%= booking.getBookingId() %></span>
                            </td>
                            <td data-label="Room">
                                <div class="room-info">
                                    <div class="room-num">Room <%= booking.getRoomNumber() %></div>
                                    <div class="room-floor">Floor <%= booking.getFloorNumber() %></div>
                                </div>
                            </td>
                            <td data-label="Duration">
                                <div class="duration-info">
                                    <div class="dur-months"><%= booking.getDurationMonths() %> months</div>
                                    <div class="dur-dates">
                                        <%= new java.text.SimpleDateFormat("dd MMM yyyy").format(booking.getBookingStartDate()) %> –
                                        <%= new java.text.SimpleDateFormat("dd MMM yyyy").format(booking.getBookingEndDate()) %>
                                    </div>
                                </div>
                            </td>
                            <td data-label="Total Amount">
                                <span class="amount-val"><%= booking.getFormattedTotalAmount() %></span>
                            </td>
                            <td data-label="Status">
                                <span class="badge bg-<%= booking.getStatusBadgeClass() %>">
                                    <%= booking.getStatus() %>
                                </span>
                            </td>
                            <td data-label="Payment">
                                <span class="badge bg-<%= "Completed".equals(booking.getPaymentStatus()) ? "success" : "warning" %>">
                                    <%= booking.getPaymentStatus() %>
                                </span>
                            </td>
                            <td data-label="Requested On">
                                <span class="date-val">
                                    <%= new java.text.SimpleDateFormat("dd MMM yyyy HH:mm").format(booking.getRequestedAt()) %>
                                </span>
                            </td>
                            <td data-label="Details">
                                <button class="btn-view" data-bs-toggle="modal"
                                        data-bs-target="#detailsModal<%= booking.getId() %>">
                                    <i class="fas fa-eye"></i> View
                                </button>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- ═══════════════════════════════════════════════
             MODALS — placed OUTSIDE the table to fix DOM issue
             ═══════════════════════════════════════════════ --%>
        <% for (BookingRequest booking : bookings) { %>
        <div class="modal fade" id="detailsModal<%= booking.getId() %>" tabindex="-1" aria-labelledby="modalLabel<%= booking.getId() %>" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content">

                    <div class="modal-header">
                        <h5 class="modal-title" id="modalLabel<%= booking.getId() %>">
                            <i class="fas fa-file-alt" style="color:var(--accent);font-size:0.9rem;"></i>
                            Booking Details
                            <span style="color:var(--text-muted);font-weight:400;font-family:'DM Sans',sans-serif;font-size:0.9rem;">·</span>
                            <span style="color:var(--accent);">#<%= booking.getBookingId() %></span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>

                    <div class="modal-body">
                        <div class="row g-3">

                            <!-- Room Information -->
                            <div class="col-md-6">
                                <div class="modal-section">
                                    <div class="modal-section-title">
                                        <i class="fas fa-building"></i> Room Information
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Room Number</span>
                                        <span class="modal-field-value"><%= booking.getRoomNumber() %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Floor</span>
                                        <span class="modal-field-value"><%= booking.getFloorNumber() %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Type</span>
                                        <span class="modal-field-value"><%= booking.getRoomType() %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Monthly Rent</span>
                                        <span class="modal-field-value accent"><%= booking.getFormattedMonthlyRent() %></span>
                                    </div>
                                </div>
                            </div>

                            <!-- Booking Period -->
                            <div class="col-md-6">
                                <div class="modal-section">
                                    <div class="modal-section-title">
                                        <i class="fas fa-calendar-alt"></i> Booking Period
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Start Date</span>
                                        <span class="modal-field-value"><%= new java.text.SimpleDateFormat("dd MMM yyyy").format(booking.getBookingStartDate()) %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">End Date</span>
                                        <span class="modal-field-value"><%= new java.text.SimpleDateFormat("dd MMM yyyy").format(booking.getBookingEndDate()) %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Duration</span>
                                        <span class="modal-field-value"><%= booking.getDurationMonths() %> months</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Payment Details -->
                            <div class="col-md-6">
                                <div class="modal-section">
                                    <div class="modal-section-title">
                                        <i class="fas fa-receipt"></i> Payment Details
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Key Money</span>
                                        <span class="modal-field-value"><%= booking.getFormattedKeyMoney() %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Monthly Rent</span>
                                        <span class="modal-field-value"><%= booking.getFormattedMonthlyRent() %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Total Amount</span>
                                        <span class="modal-field-value accent"><%= booking.getFormattedTotalAmount() %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Payment Method</span>
                                        <span class="modal-field-value"><%= booking.getPaymentMethod() %></span>
                                    </div>
                                </div>
                            </div>

                            <!-- Guardian Information -->
                            <div class="col-md-6">
                                <div class="modal-section">
                                    <div class="modal-section-title">
                                        <i class="fas fa-user-shield"></i> Guardian Information
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Name</span>
                                        <span class="modal-field-value"><%= booking.getGuardianName() %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Phone</span>
                                        <span class="modal-field-value"><%= booking.getGuardianPhone() %></span>
                                    </div>
                                    <div class="modal-field">
                                        <span class="modal-field-label">Relationship</span>
                                        <span class="modal-field-value"><%= booking.getGuardianRelationship() %></span>
                                    </div>
                                </div>
                            </div>

                            <!-- Special Requests -->
                            <% if (booking.getSpecialRequests() != null && !booking.getSpecialRequests().isEmpty()) { %>
                            <div class="col-12">
                                <div class="modal-section">
                                    <div class="modal-section-title">
                                        <i class="fas fa-comment-alt"></i> Special Requests
                                    </div>
                                    <p class="special-request-text"><%= booking.getSpecialRequests() %></p>
                                </div>
                            </div>
                            <% } %>

                            <!-- Admin Remarks -->
                            <% if (booking.getAdminRemarks() != null && !booking.getAdminRemarks().isEmpty()) { %>
                            <div class="col-12">
                                <div class="modal-section">
                                    <div class="modal-section-title">
                                        <i class="fas fa-user-cog"></i> Admin Remarks
                                    </div>
                                    <div class="admin-remark"><%= booking.getAdminRemarks() %></div>
                                </div>
                            </div>
                            <% } %>

                        </div><!-- /.row -->
                    </div><!-- /.modal-body -->

                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->
        <% } %>

        <% } else { %>

        <!-- EMPTY STATE -->
        <div class="empty-state">
            <div class="empty-icon"><i class="fas fa-calendar-times"></i></div>
            <h5>No Booking Requests Yet</h5>
            <p>You haven't made any booking requests yet. Browse available rooms and book your perfect space.</p>
            <a href="<%= request.getContextPath() %>/rooms" class="btn-browse">
                <i class="fas fa-door-open"></i> Browse Available Rooms
            </a>
        </div>

        <% } %>
            </div><!-- /.bookings-main -->
        </div><!-- /.page-layout -->
    </div><!-- /.main-container -->

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
