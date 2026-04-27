<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="org.example.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"Owner".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<BookingRequest> bookings = (List<BookingRequest>) request.getAttribute("bookings");
    Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");
    String currentFilter = (String) request.getAttribute("currentFilter");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Manage Bookings - Admin</title>
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
            --secondary: #64748b;
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
            display: flex;
            flex-direction: column;
        }

        /* ── PAGE BODY ── */
        .page-body { padding: 2rem; flex: 1; }

        /* ── PAGE HEADING ── */
        .page-header-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            flex-wrap: wrap;
            margin-bottom: 1.75rem;
        }
        .page-heading {
            font-family: 'Fraunces', serif;
            font-size: 1.6rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 0;
        }
        .btn-back-owner {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text-muted);
            border-radius: var(--radius-sm);
            font-size: 0.86rem;
            font-weight: 600;
            padding: 0.55rem 1rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            transition: all 0.2s;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-back-owner:hover {
            border-color: var(--accent);
            color: var(--accent);
            background: var(--accent-dim);
        }

        /* ── STATS GRID ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1rem;
            margin-bottom: 1.75rem;
        }
        @media (max-width: 900px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }

        .stat-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 1.2rem 1.3rem;
            position: relative;
            overflow: hidden;
            transition: transform 0.22s, box-shadow 0.22s;
            animation: fadeUp 0.45s ease both;
        }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,0.08); }
        .stat-card::after { content: ''; position: absolute; inset: 0; border-radius: inherit; opacity: 0.05; }
        .stat-card.s-blue::after   { background: var(--accent); }
        .stat-card.s-yellow::after { background: var(--warning); }
        .stat-card.s-green::after  { background: var(--success); }
        .stat-card.s-red::after    { background: var(--danger); }
        .stat-label { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em; color: var(--text-muted); margin-bottom: 0.35rem; }
        .stat-value { font-family: 'Fraunces', serif; font-size: 2rem; font-weight: 600; line-height: 1; }
        .stat-card.s-blue   .stat-value { color: var(--accent); }
        .stat-card.s-yellow .stat-value { color: var(--warning); }
        .stat-card.s-green  .stat-value { color: var(--success); }
        .stat-card.s-red    .stat-value { color: var(--danger); }
        .stat-icon { position: absolute; right: 1rem; top: 1rem; font-size: 1.2rem; opacity: 0.15; }
        .stat-card.s-blue   .stat-icon { color: var(--accent); }
        .stat-card.s-yellow .stat-icon { color: var(--warning); }
        .stat-card.s-green  .stat-icon { color: var(--success); }
        .stat-card.s-red    .stat-icon { color: var(--danger); }
        .stat-card:nth-child(1) { animation-delay: 0.05s; }
        .stat-card:nth-child(2) { animation-delay: 0.10s; }
        .stat-card:nth-child(3) { animation-delay: 0.15s; }
        .stat-card:nth-child(4) { animation-delay: 0.20s; }

        /* ── FILTER BAR ── */
        .filter-bar {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
        }
        .btn-filter {
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--text-muted);
            border-radius: 8px;
            font-size: 0.82rem;
            font-weight: 500;
            padding: 0.42rem 1rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            transition: all 0.18s;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .btn-filter:hover { border-color: var(--accent); color: var(--accent); background: var(--accent-dim); }
        .btn-filter.active-all  { background: var(--accent-dim); border-color: var(--accent); color: var(--accent); }
        .btn-filter.active-warn { background: rgba(217,119,6,0.08); border-color: rgba(217,119,6,0.4); color: var(--warning); }
        .btn-filter.warn:hover  { background: rgba(217,119,6,0.08); border-color: rgba(217,119,6,0.4); color: var(--warning); }

        /* ── ALERT ── */
        .alert-custom {
            border-radius: var(--radius-sm);
            padding: 0.8rem 1rem;
            font-size: 0.88rem;
            display: flex; align-items: center;
            justify-content: space-between;
            gap: 1rem; margin-bottom: 1.25rem;
        }
        .alert-custom.success { background: rgba(22,163,74,0.08); border: 1px solid rgba(22,163,74,0.25); color: var(--success); }
        .close-btn { background: none; border: none; cursor: pointer; font-size: 0.82rem; opacity: 0.6; padding: 0; transition: opacity 0.2s; color: inherit; }
        .close-btn:hover { opacity: 1; }

        /* ── TABLE CARD ── */
        .table-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: 0 2px 16px rgba(0,0,0,0.04);
            animation: fadeUp 0.45s ease 0.1s both;
        }
        .table-card-header {
            padding: 1rem 1.25rem;
            background: #0f1117;
            border-bottom: 1px solid rgba(255,255,255,0.06);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .table-card-header h5 {
            font-family: 'Fraunces', serif;
            font-size: 1rem;
            font-weight: 600;
            color: #fff;
            margin: 0;
        }
        .table-card-header span { font-size: 0.78rem; color: #6b6d78; }

        /* ── TABLE ── */
        .bookings-table { width: 100%; border-collapse: collapse; }
        .bookings-table thead tr { background: var(--surface-2); border-bottom: 1px solid var(--border); }
        .bookings-table thead th {
            padding: 0.8rem 0.9rem;
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.08em;
            color: var(--text-muted); white-space: nowrap; border: none;
        }
        .bookings-table tbody tr { border-bottom: 1px solid var(--border); transition: background 0.15s; }
        .bookings-table tbody tr:last-child { border-bottom: none; }
        .bookings-table tbody tr:hover { background: rgba(29,111,216,0.025); }
        .bookings-table tbody td { padding: 0.85rem 0.9rem; font-size: 0.86rem; color: var(--text); vertical-align: middle; border: none; }

        /* cell helpers */
        .booking-id-cell { font-family: 'Fraunces', serif; font-weight: 600; color: var(--accent); font-size: 0.88rem; }
        .cell-primary { font-weight: 600; color: var(--text); font-size: 0.88rem; }
        .cell-sub { font-size: 0.76rem; color: var(--text-muted); margin-top: 0.15rem; }
        .amount-cell { font-weight: 700; color: var(--text); font-size: 0.9rem; }

        /* ── BADGES ── */
        .badge {
            font-size: 0.68rem !important; font-weight: 700 !important;
            letter-spacing: 0.04em; padding: 0.28rem 0.6rem !important; border-radius: 20px !important;
        }
        .badge.bg-success   { background: rgba(22,163,74,0.12)   !important; color: var(--success)   !important; border: 1px solid rgba(22,163,74,0.25); }
        .badge.bg-warning   { background: rgba(217,119,6,0.12)   !important; color: var(--warning)   !important; border: 1px solid rgba(217,119,6,0.25); }
        .badge.bg-danger    { background: rgba(220,38,38,0.12)   !important; color: var(--danger)    !important; border: 1px solid rgba(220,38,38,0.25); }
        .badge.bg-info      { background: rgba(37,99,235,0.12)   !important; color: var(--info)      !important; border: 1px solid rgba(37,99,235,0.25); }
        .badge.bg-secondary { background: rgba(100,116,139,0.10) !important; color: var(--secondary) !important; border: 1px solid rgba(100,116,139,0.2); }
        .badge.bg-primary   { background: var(--accent-dim)      !important; color: var(--accent)    !important; border: 1px solid rgba(29,111,216,0.3); }

        /* ── ACTION BUTTONS ── */
        .action-btns { display: flex; gap: 0.4rem; align-items: center; }
        .btn-action {
            width: 30px; height: 30px;
            border-radius: 8px; font-size: 0.75rem;
            display: inline-flex; align-items: center; justify-content: center;
            border: 1px solid; cursor: pointer; transition: all 0.18s;
            text-decoration: none; background: transparent;
        }
        .btn-action-view   { background: rgba(37,99,235,0.08);  border-color: rgba(37,99,235,0.3);  color: var(--info); }
        .btn-action-view:hover   { background: rgba(37,99,235,0.18);  border-color: var(--info); color: var(--info); }
        .btn-action-approve { background: rgba(22,163,74,0.08); border-color: rgba(22,163,74,0.3); color: var(--success); }
        .btn-action-approve:hover { background: rgba(22,163,74,0.18); border-color: var(--success); color: var(--success); }
        .btn-action-reject  { background: rgba(220,38,38,0.08); border-color: rgba(220,38,38,0.25); color: var(--danger); }
        .btn-action-reject:hover  { background: rgba(220,38,38,0.18); border-color: var(--danger); color: var(--danger); }

        /* ── EMPTY ROW ── */
        .empty-row td { text-align: center; padding: 3rem 1rem; color: var(--text-muted); font-size: 0.88rem; }

        /* ── MODALS ── */
        .modal-content {
            border: 1px solid var(--border);
            border-radius: var(--radius) !important;
            box-shadow: 0 20px 60px rgba(0,0,0,0.16);
            font-family: 'DM Sans', sans-serif;
            overflow: hidden;
        }
        .modal-header {
            padding: 1rem 1.25rem;
            border-bottom: 1px solid var(--border);
        }
        .modal-header.h-info    { background: var(--accent); border-bottom-color: rgba(255,255,255,0.15); }
        .modal-header.h-success { background: var(--success); border-bottom-color: rgba(255,255,255,0.15); }
        .modal-header.h-danger  { background: var(--danger);  border-bottom-color: rgba(255,255,255,0.15); }
        .modal-header .modal-title {
            font-family: 'Fraunces', serif;
            font-size: 1rem;
            font-weight: 600;
            color: #fff;
        }
        .modal-header .btn-close { filter: invert(1) brightness(2); opacity: 0.8; }
        .modal-body { padding: 1.4rem; background: #fff; }
        .modal-footer {
            padding: 0.9rem 1.25rem;
            background: var(--surface-2);
            border-top: 1px solid var(--border);
            gap: 0.5rem;
        }

        /* detail sections */
        .detail-section {
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            padding: 1rem 1.1rem;
            margin-bottom: 1rem;
        }
        .detail-section:last-child { margin-bottom: 0; }
        .detail-section-title {
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.09em;
            color: var(--accent);
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.35rem;
            padding-bottom: 0.6rem;
            border-bottom: 1px solid var(--border);
        }
        .detail-row { display: flex; gap: 0.5rem; margin-bottom: 0.45rem; font-size: 0.875rem; }
        .detail-row:last-child { margin-bottom: 0; }
        .detail-label { font-weight: 600; color: var(--text-muted); min-width: 110px; font-size: 0.82rem; }
        .detail-value { color: var(--text); }

        .admin-remarks-block {
            background: rgba(37,99,235,0.06);
            border: 1px solid rgba(37,99,235,0.2);
            border-radius: var(--radius-sm);
            padding: 0.85rem 1rem;
            font-size: 0.88rem;
            color: var(--text);
            line-height: 1.6;
        }
        .special-req-block {
            background: rgba(217,119,6,0.06);
            border: 1px solid rgba(217,119,6,0.2);
            border-radius: var(--radius-sm);
            padding: 0.85rem 1rem;
            font-size: 0.88rem;
            color: var(--text);
            line-height: 1.6;
        }

        /* confirm block inside approve/reject modals */
        .confirm-block {
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            padding: 0.85rem 1rem;
            margin-bottom: 1.1rem;
            font-size: 0.88rem;
            color: var(--text);
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }
        .confirm-block i { font-size: 1rem; }
        .confirm-block.c-success { background: rgba(22,163,74,0.06); border-color: rgba(22,163,74,0.2); }
        .confirm-block.c-success i { color: var(--success); }
        .confirm-block.c-danger  { background: rgba(220,38,38,0.06); border-color: rgba(220,38,38,0.2); }
        .confirm-block.c-danger  i { color: var(--danger); }

        .modal-body .form-label {
            font-size: 0.74rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--text-muted);
            margin-bottom: 0.38rem;
            display: block;
        }
        .modal-body .form-control {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 0.88rem;
            padding: 0.58rem 0.9rem;
            transition: border-color 0.2s, box-shadow 0.2s;
            width: 100%;
            resize: vertical;
        }
        .modal-body .form-control:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px var(--accent-dim);
            outline: none;
        }

        .btn-m-cancel {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text-muted);
            border-radius: 8px;
            font-size: 0.84rem;
            font-weight: 500;
            padding: 0.48rem 1rem;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            transition: all 0.18s;
        }
        .btn-m-cancel:hover { border-color: var(--danger); color: var(--danger); }

        .btn-m-approve {
            background: var(--success);
            border: 1px solid var(--success);
            color: #fff;
            border-radius: 8px;
            font-size: 0.84rem;
            font-weight: 600;
            padding: 0.48rem 1.1rem;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            transition: all 0.18s;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
        }
        .btn-m-approve:hover { background: #15803d; border-color: #15803d; }

        .btn-m-reject {
            background: var(--danger);
            border: 1px solid var(--danger);
            color: #fff;
            border-radius: 8px;
            font-size: 0.84rem;
            font-weight: 600;
            padding: 0.48rem 1.1rem;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            transition: all 0.18s;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
        }
        .btn-m-reject:hover { background: #b91c1c; border-color: #b91c1c; }

        /* ── RESPONSIVE ── */
        @media (max-width: 768px) {
            .page-body { padding: 1.25rem; }
        }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(12px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── SCROLLBAR ── */
        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-track { background: var(--bg); }
        ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
    </style>
</head>
<body>

<!-- PAGE BODY -->
<div class="page-body">

    <!-- PAGE HEADING -->
    <div class="page-header-row">
        <h1 class="page-heading">Booking Management</h1>
        <a href="<%= request.getContextPath() %>/dashboard/owner" class="btn-back-owner" target="_top">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card s-blue">
            <i class="fas fa-calendar-check stat-icon"></i>
            <div class="stat-label">Total Bookings</div>
            <div class="stat-value"><%= stats.get("total") %></div>
        </div>
        <div class="stat-card s-yellow">
            <i class="fas fa-clock stat-icon"></i>
            <div class="stat-label">Pending</div>
            <div class="stat-value"><%= stats.get("pending") %></div>
        </div>
        <div class="stat-card s-green">
            <i class="fas fa-check-circle stat-icon"></i>
            <div class="stat-label">Approved</div>
            <div class="stat-value"><%= stats.get("approved") %></div>
        </div>
        <div class="stat-card s-red">
            <i class="fas fa-times-circle stat-icon"></i>
            <div class="stat-label">Rejected</div>
            <div class="stat-value"><%= stats.get("rejected") %></div>
        </div>
    </div>

    <!-- FILTER BAR -->
    <div class="filter-bar">
        <a href="<%= request.getContextPath() %>/admin/bookings"
           class="btn-filter <%= currentFilter == null ? "active-all" : "" %>">
            <i class="fas fa-th-large"></i> All Bookings
        </a>
        <a href="<%= request.getContextPath() %>/admin/bookings?filter=pending"
           class="btn-filter warn <%= "pending".equals(currentFilter) ? "active-warn" : "" %>">
            <i class="fas fa-clock"></i> Pending Only
        </a>
    </div>

    <!-- SUCCESS ALERT -->
    <% String success = (String) session.getAttribute("success");
       if (success != null) { %>
        <div class="alert-custom success" id="alertSuccess">
            <span><i class="fas fa-check-circle me-2"></i><%= success %></span>
            <button class="close-btn" onclick="document.getElementById('alertSuccess').remove()"><i class="fas fa-times"></i></button>
        </div>
        <% session.removeAttribute("success"); %>
    <% } %>

    <!-- TABLE CARD -->
    <div class="table-card">
        <div class="table-card-header">
            <h5>All Booking Requests</h5>
            <span><%= bookings != null ? bookings.size() : 0 %> total</span>
        </div>
        <div style="overflow-x:auto;">
            <table class="bookings-table">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Student</th>
                        <th>Room</th>
                        <th>Duration</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Requested On</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (bookings != null && !bookings.isEmpty()) {
                        for (BookingRequest booking : bookings) { %>
                    <tr>
                        <td><span class="booking-id-cell"><%= booking.getBookingId() %></span></td>
                        <td>
                            <div class="cell-primary"><%= booking.getStudentName() %></div>
                            <div class="cell-sub"><%= booking.getStudentId() %></div>
                        </td>
                        <td>
                            <div class="cell-primary">Room <%= booking.getRoomNumber() %></div>
                            <div class="cell-sub">Floor <%= booking.getFloorNumber() %></div>
                        </td>
                        <td>
                            <div class="cell-primary"><%= booking.getDurationMonths() %> months</div>
                            <div class="cell-sub">
                                <%= new java.text.SimpleDateFormat("dd/MM/yy").format(booking.getBookingStartDate()) %> –
                                <%= new java.text.SimpleDateFormat("dd/MM/yy").format(booking.getBookingEndDate()) %>
                            </div>
                        </td>
                        <td><span class="amount-cell"><%= booking.getFormattedTotalAmount() %></span></td>
                        <td>
                            <span class="badge bg-<%= booking.getStatusBadgeClass() %>">
                                <%= booking.getStatus() %>
                            </span>
                        </td>
                        <td>
                            <div class="cell-primary"><%= new java.text.SimpleDateFormat("dd MMM yyyy").format(booking.getRequestedAt()) %></div>
                        </td>
                        <td>
                            <div class="action-btns">
                                <button class="btn-action btn-action-view" title="View Details"
                                        data-bs-toggle="modal"
                                        data-bs-target="#detailsModal<%= booking.getId() %>">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <% if ("Pending".equals(booking.getStatus())) { %>
                                <button class="btn-action btn-action-approve" title="Approve"
                                        data-bs-toggle="modal"
                                        data-bs-target="#approveModal<%= booking.getId() %>">
                                    <i class="fas fa-check"></i>
                                </button>
                                <button class="btn-action btn-action-reject" title="Reject"
                                        data-bs-toggle="modal"
                                        data-bs-target="#rejectModal<%= booking.getId() %>">
                                    <i class="fas fa-times"></i>
                                </button>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr class="empty-row">
                        <td colspan="8">
                            <i class="fas fa-calendar-check" style="font-size:1.5rem;display:block;margin-bottom:0.5rem;opacity:0.25;"></i>
                            No booking requests found
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

</div><!-- /.page-body -->

<!-- ═══════════════════════════════════════════════
     ALL MODALS — outside the table, direct children
     of body to ensure correct rendering
════════════════════════════════════════════════ -->
<% if (bookings != null && !bookings.isEmpty()) {
    for (BookingRequest booking : bookings) { %>

<!-- Details Modal -->
<div class="modal fade" id="detailsModal<%= booking.getId() %>" tabindex="-1" aria-labelledby="detailsLabel<%= booking.getId() %>" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header h-info">
                <h5 class="modal-title" id="detailsLabel<%= booking.getId() %>">
                    <i class="fas fa-file-alt me-2"></i>Booking Details &middot; <%= booking.getBookingId() %>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <div class="detail-section">
                            <div class="detail-section-title"><i class="fas fa-user"></i> Student Information</div>
                            <div class="detail-row"><span class="detail-label">Name</span><span class="detail-value"><%= booking.getStudentName() %></span></div>
                            <div class="detail-row"><span class="detail-label">Age</span><span class="detail-value"><%= booking.getStudentAge() %></span></div>
                            <div class="detail-row"><span class="detail-label">Phone</span><span class="detail-value"><%= booking.getStudentPhone() %></span></div>
                            <div class="detail-row"><span class="detail-label">Email</span><span class="detail-value"><%= booking.getStudentEmail() %></span></div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="detail-section">
                            <div class="detail-section-title"><i class="fas fa-user-friends"></i> Guardian Information</div>
                            <div class="detail-row"><span class="detail-label">Name</span><span class="detail-value"><%= booking.getGuardianName() %></span></div>
                            <div class="detail-row"><span class="detail-label">Phone</span><span class="detail-value"><%= booking.getGuardianPhone() %></span></div>
                            <div class="detail-row"><span class="detail-label">Relationship</span><span class="detail-value"><%= booking.getGuardianRelationship() %></span></div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="detail-section">
                            <div class="detail-section-title"><i class="fas fa-door-open"></i> Room Information</div>
                            <div class="detail-row"><span class="detail-label">Room</span><span class="detail-value"><%= booking.getRoomNumber() %></span></div>
                            <div class="detail-row"><span class="detail-label">Type</span><span class="detail-value"><%= booking.getRoomType() %></span></div>
                            <div class="detail-row"><span class="detail-label">Monthly Rent</span><span class="detail-value"><%= booking.getFormattedMonthlyRent() %></span></div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="detail-section">
                            <div class="detail-section-title"><i class="fas fa-credit-card"></i> Payment Information</div>
                            <div class="detail-row"><span class="detail-label">Key Money</span><span class="detail-value"><%= booking.getFormattedKeyMoney() %></span></div>
                            <div class="detail-row"><span class="detail-label">Total Amount</span><span class="detail-value"><%= booking.getFormattedTotalAmount() %></span></div>
                            <div class="detail-row"><span class="detail-label">Method</span><span class="detail-value"><%= booking.getPaymentMethod() %></span></div>
                        </div>
                    </div>
                </div>

                <% if (booking.getSpecialRequests() != null && !booking.getSpecialRequests().isEmpty()) { %>
                <div class="mt-3">
                    <div class="detail-section-title" style="margin-bottom:0.6rem;"><i class="fas fa-star"></i> Special Requests</div>
                    <div class="special-req-block"><%= booking.getSpecialRequests() %></div>
                </div>
                <% } %>

                <% if (booking.getAdminRemarks() != null) { %>
                <div class="mt-3">
                    <div class="detail-section-title" style="margin-bottom:0.6rem;"><i class="fas fa-comment-alt"></i> Admin Remarks</div>
                    <div class="admin-remarks-block"><%= booking.getAdminRemarks() %></div>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<!-- Approve Modal -->
<div class="modal fade" id="approveModal<%= booking.getId() %>" tabindex="-1" aria-labelledby="approveLabel<%= booking.getId() %>" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header h-success">
                <h5 class="modal-title" id="approveLabel<%= booking.getId() %>">
                    <i class="fas fa-check-circle me-2"></i>Approve Booking
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<%= request.getContextPath() %>/admin/bookings" method="post">
                <div class="modal-body">
                    <input type="hidden" name="action" value="approve">
                    <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                    <div class="confirm-block c-success">
                        <i class="fas fa-user-check"></i>
                        <span>Approve booking for <strong><%= booking.getStudentName() %></strong>?</span>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Remarks</label>
                        <textarea name="remarks" class="form-control" rows="3"
                                  placeholder="Optional approval message..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-m-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-m-approve">
                        <i class="fas fa-check"></i> Approve
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Reject Modal -->
<div class="modal fade" id="rejectModal<%= booking.getId() %>" tabindex="-1" aria-labelledby="rejectLabel<%= booking.getId() %>" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header h-danger">
                <h5 class="modal-title" id="rejectLabel<%= booking.getId() %>">
                    <i class="fas fa-times-circle me-2"></i>Reject Booking
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<%= request.getContextPath() %>/admin/bookings" method="post">
                <div class="modal-body">
                    <input type="hidden" name="action" value="reject">
                    <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                    <div class="confirm-block c-danger">
                        <i class="fas fa-user-times"></i>
                        <span>Reject booking for <strong><%= booking.getStudentName() %></strong>?</span>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Reason for Rejection *</label>
                        <textarea name="remarks" class="form-control" rows="3"
                                  placeholder="Please provide a reason..." required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-m-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-m-reject">
                        <i class="fas fa-times"></i> Reject
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<% } } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>