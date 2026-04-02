<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="org.example.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"Owner".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<Inquiry> inquiries = (List<Inquiry>) request.getAttribute("inquiries");
    Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");
    String currentFilter = (String) request.getAttribute("currentFilter");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Manage Inquiries - Admin</title>
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
            --border: rgba(0,0,0,0.09);
            --accent: #1d6fd8;
            --accent-dim: rgba(29,111,216,0.10);
            --text: #1a1a2e;
            --text-muted: #6b6b80;
            --success: #16a34a;
            --warning: #d97706;
            --danger: #dc2626;
            --info: #2563eb;
            --secondary: #64748b;
            --radius: 14px;
            --radius-sm: 9px;
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: var(--bg);
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 15px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* ── PAGE BODY ── */
        .page-body {
            padding: 2rem;
            flex: 1;
        }

        /* ── PAGE HEADING ── */
        .page-heading {
            font-family: 'Fraunces', serif;
            font-size: 1.6rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 1.75rem;
        }

        /* ── STATS ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1rem;
            margin-bottom: 1.75rem;
        }
        @media(max-width:720px) { .stats-grid { grid-template-columns: 1fr 1fr; } }

        .stat-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 1.2rem 1.3rem;
            position: relative;
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
            animation: fadeUp 0.4s ease both;
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        }
        .stat-card:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.08); }
        .stat-label {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.09em;
            color: var(--text-muted);
            margin-bottom: 0.45rem;
        }
        .stat-value {
            font-family: 'Fraunces', serif;
            font-size: 2rem;
            font-weight: 600;
            line-height: 1;
        }
        .s-blue  .stat-value  { color: var(--accent); }
        .s-yellow .stat-value { color: var(--warning); }
        .s-green  .stat-value { color: var(--success); }
        .s-gray   .stat-value { color: var(--secondary); }
        .stat-icon {
            position: absolute;
            right: 1rem; top: 1rem;
            font-size: 1.35rem;
            opacity: 0.08;
        }
        .s-blue  .stat-icon  { color: var(--accent); }
        .s-yellow .stat-icon { color: var(--warning); }
        .s-green  .stat-icon { color: var(--success); }
        .s-gray   .stat-icon { color: var(--secondary); }
        .stat-card:nth-child(1){animation-delay:.04s}
        .stat-card:nth-child(2){animation-delay:.08s}
        .stat-card:nth-child(3){animation-delay:.12s}
        .stat-card:nth-child(4){animation-delay:.16s}

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

        /* ── SUCCESS ALERT ── */
        .alert-ok {
            background: rgba(22,163,74,0.08);
            border: 1px solid rgba(22,163,74,0.25);
            color: var(--success);
            border-radius: var(--radius-sm);
            padding: 0.8rem 1rem;
            font-size: 0.88rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.25rem;
        }
        .alert-ok button { background: none; border: none; cursor: pointer; color: inherit; opacity: 0.55; }
        .alert-ok button:hover { opacity: 1; }

        /* ── INQUIRY CARD ── */
        .inquiry-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            margin-bottom: 1.1rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            transition: box-shadow 0.2s, transform 0.2s;
            animation: fadeUp 0.4s ease both;
        }
        .inquiry-card:hover {
            box-shadow: 0 6px 24px rgba(0,0,0,0.10);
            transform: translateY(-1px);
        }

        /* accent left border by status */
        .inquiry-card.status-pending { border-left: 3px solid var(--warning); }
        .inquiry-card.status-replied  { border-left: 3px solid var(--success); }
        .inquiry-card.status-closed   { border-left: 3px solid var(--secondary); }

        /* Card header */
        .inq-header {
            background: var(--surface-2);
            border-bottom: 1px solid var(--border);
            padding: 1rem 1.25rem;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 1rem;
            flex-wrap: wrap;
        }
        .inq-header-left { flex: 1; min-width: 0; }

        .inq-id {
            font-family: 'Fraunces', serif;
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--accent);
            letter-spacing: 0.04em;
            margin-bottom: 0.25rem;
            display: inline-block;
        }
        .inq-subject {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 0.4rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .inq-subject i { font-size: 0.82rem; color: var(--accent); }

        .inq-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 0.6rem 1rem;
            font-size: 0.78rem;
            color: var(--text-muted);
        }
        .inq-meta-item { display: flex; align-items: center; gap: 0.3rem; }
        .inq-meta-item i { font-size: 0.7rem; opacity: 0.55; }

        .inq-header-right {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 0.45rem;
            flex-shrink: 0;
        }
        .inq-date {
            font-size: 0.76rem;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }
        .inq-date i { font-size: 0.68rem; opacity: 0.55; }

        /* Badges */
        .badge {
            font-size: 0.68rem !important;
            font-weight: 700 !important;
            padding: 0.3rem 0.7rem !important;
            border-radius: 20px !important;
            letter-spacing: 0.03em;
        }
        .badge.bg-success   { background: rgba(22,163,74,0.12)   !important; color: var(--success)   !important; border: 1px solid rgba(22,163,74,0.3)   !important; }
        .badge.bg-warning   { background: rgba(217,119,6,0.12)   !important; color: var(--warning)   !important; border: 1px solid rgba(217,119,6,0.3)   !important; }
        .badge.bg-danger    { background: rgba(220,38,38,0.12)   !important; color: var(--danger)    !important; border: 1px solid rgba(220,38,38,0.3)   !important; }
        .badge.bg-info      { background: rgba(37,99,235,0.12)   !important; color: var(--info)      !important; border: 1px solid rgba(37,99,235,0.3)   !important; }
        .badge.bg-secondary { background: rgba(100,116,139,0.10) !important; color: var(--secondary) !important; border: 1px solid rgba(100,116,139,0.25) !important; }
        .badge.bg-primary   { background: var(--accent-dim)      !important; color: var(--accent)    !important; border: 1px solid rgba(29,111,216,0.3)  !important; }

        /* Card body */
        .inq-body { padding: 1.25rem 1.25rem 1.1rem; }

        .inq-message-label {
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.09em;
            color: var(--text-muted);
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.35rem;
        }
        .inq-message {
            font-size: 0.9rem;
            color: var(--text);
            line-height: 1.65;
            padding: 0.85rem 1rem;
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            margin-bottom: 1rem;
        }

        /* Reply block */
        .reply-block {
            background: rgba(22,163,74,0.05);
            border: 1px solid rgba(22,163,74,0.2);
            border-radius: var(--radius-sm);
            padding: 0.9rem 1.1rem;
            margin-bottom: 1rem;
        }
        .reply-block-label {
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.09em;
            color: var(--success);
            display: flex;
            align-items: center;
            gap: 0.35rem;
            margin-bottom: 0.45rem;
        }
        .reply-block-text {
            font-size: 0.88rem;
            color: var(--text);
            line-height: 1.6;
            margin-bottom: 0.4rem;
        }
        .reply-block-date {
            font-size: 0.74rem;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }

        /* Action buttons */
        .inq-actions {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
            padding-top: 0.25rem;
            border-top: 1px solid var(--border);
            margin-top: 0.25rem;
        }
        .btn-reply {
            background: var(--accent);
            border: 1px solid var(--accent);
            color: #fff;
            border-radius: 8px;
            font-size: 0.82rem;
            font-weight: 600;
            padding: 0.42rem 0.95rem;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            transition: all 0.18s;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            text-decoration: none;
        }
        .btn-reply:hover { background: #1558b0; border-color: #1558b0; color: #fff; }
        .btn-close-inq {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text-muted);
            border-radius: 8px;
            font-size: 0.82rem;
            font-weight: 500;
            padding: 0.42rem 0.95rem;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            transition: all 0.18s;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
        }
        .btn-close-inq:hover { border-color: var(--secondary); color: var(--secondary); background: rgba(100,116,139,0.06); }

        /* Empty state */
        .empty-state {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 4rem 2rem;
            text-align: center;
            color: var(--text-muted);
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        }
        .empty-state i { font-size: 2.2rem; opacity: 0.2; display: block; margin-bottom: 0.9rem; }
        .empty-state span { font-size: 0.9rem; }

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
            border-bottom: 1px solid rgba(255,255,255,0.15);
            background: var(--accent);
        }
        .modal-header .modal-title {
            font-family: 'Fraunces', serif;
            font-size: 1rem;
            font-weight: 600;
            color: #fff;
        }
        .modal-header .btn-close { filter: invert(1) brightness(2); opacity: 0.8; }
        .modal-body { padding: 1.25rem; background: #fff; }
        .modal-footer {
            padding: 0.9rem 1.25rem;
            background: var(--surface-2);
            border-top: 1px solid var(--border);
            gap: 0.5rem;
        }

        .student-q-block {
            background: rgba(29,111,216,0.06);
            border: 1px solid rgba(29,111,216,0.18);
            border-radius: var(--radius-sm);
            padding: 0.9rem 1rem;
            margin-bottom: 1.1rem;
            font-size: 0.88rem;
            color: var(--text);
            line-height: 1.6;
        }
        .student-q-label {
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.09em;
            color: var(--accent);
            margin-bottom: 0.4rem;
            display: flex;
            align-items: center;
            gap: 0.35rem;
        }
        .modal-body .form-label {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--text-muted);
            margin-bottom: 0.4rem;
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
        .btn-m-send {
            background: var(--accent);
            border: 1px solid var(--accent);
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
        .btn-m-send:hover { background: #1558b0; border-color: #1558b0; }

        @media(max-width:600px) {
            .page-body { padding: 1.25rem; }
            .inq-header { flex-direction: column; }
            .inq-header-right { align-items: flex-start; flex-direction: row; flex-wrap: wrap; }
            .stats-grid { grid-template-columns: 1fr 1fr; }
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(10px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
    </style>
</head>
<body>

<!-- PAGE BODY -->
<div class="page-body">

    <!-- PAGE HEADING -->
    <h1 class="page-heading"><a href="<%= request.getContextPath() %>/dashboard/owner/index.jsp" style="text-decoration:none;color:inherit;">Inquiries Management</a></h1>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card s-blue">
            <i class="fas fa-comments stat-icon"></i>
            <div class="stat-label">Total Inquiries</div>
            <div class="stat-value"><%= stats.get("total") %></div>
        </div>
        <div class="stat-card s-yellow">
            <i class="fas fa-clock stat-icon"></i>
            <div class="stat-label">Pending</div>
            <div class="stat-value"><%= stats.get("pending") %></div>
        </div>
        <div class="stat-card s-green">
            <i class="fas fa-reply stat-icon"></i>
            <div class="stat-label">Replied</div>
            <div class="stat-value"><%= stats.get("replied") %></div>
        </div>
        <div class="stat-card s-gray">
            <i class="fas fa-times-circle stat-icon"></i>
            <div class="stat-label">Closed</div>
            <div class="stat-value"><%= stats.get("closed") %></div>
        </div>
    </div>

    <!-- FILTER -->
    <div class="filter-bar">
        <a href="<%= request.getContextPath() %>/admin/inquiries"
           class="btn-filter <%= currentFilter == null ? "active-all" : "" %>">
            <i class="fas fa-th-large"></i> All Inquiries
        </a>
        <a href="<%= request.getContextPath() %>/admin/inquiries?filter=pending"
           class="btn-filter warn <%= "pending".equals(currentFilter) ? "active-warn" : "" %>">
            <i class="fas fa-clock"></i> Pending Only
        </a>
    </div>

    <!-- SUCCESS ALERT -->
    <% String success = (String) session.getAttribute("success");
       if (success != null) { %>
        <div class="alert-ok" id="sAlert">
            <span><i class="fas fa-check-circle me-2"></i><%= success %></span>
            <button onclick="document.getElementById('sAlert').remove()"><i class="fas fa-times"></i></button>
        </div>
        <% session.removeAttribute("success"); %>
    <% } %>

    <!-- INQUIRY LIST -->
    <% if (inquiries != null && !inquiries.isEmpty()) {
        int cardDelay = 0;
        for (Inquiry inquiry : inquiries) { %>

    <div class="inquiry-card status-<%= inquiry.getStatus().toLowerCase() %>"
         style="animation-delay:<%= cardDelay * 60 %>ms">

        <!-- CARD HEADER -->
        <div class="inq-header">
            <div class="inq-header-left">
                <div class="inq-id">#<%= inquiry.getInquiryId() %></div>
                <div class="inq-subject">
                    <i class="fas <%= inquiry.getInquiryTypeIcon() %>"></i>
                    <%= inquiry.getSubject() %>
                </div>
                <div class="inq-meta">
                    <span class="inq-meta-item"><i class="fas fa-user"></i> <%= inquiry.getStudentName() %></span>
                    <span class="inq-meta-item"><i class="fas fa-envelope"></i> <%= inquiry.getStudentEmail() %></span>
                    <span class="inq-meta-item"><i class="fas fa-tag"></i> <%= inquiry.getInquiryType() %></span>
                    <% if (inquiry.hasRoomReference()) { %>
                    <span class="inq-meta-item"><i class="fas fa-door-open"></i> Room <%= inquiry.getRoomNumber() %></span>
                    <% } %>
                </div>
            </div>
            <div class="inq-header-right">
                <span class="badge bg-<%= inquiry.getStatusBadgeClass() %>"><%= inquiry.getStatus() %></span>
                <span class="inq-date">
                    <i class="fas fa-calendar-alt"></i>
                    <%= new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm").format(inquiry.getCreatedAt()) %>
                </span>
            </div>
        </div>

        <!-- CARD BODY -->
        <div class="inq-body">

            <div class="inq-message-label"><i class="fas fa-comment-dots"></i> Student's Message</div>
            <div class="inq-message"><%= inquiry.getMessage() %></div>

            <% if (inquiry.getReplyMessage() != null) { %>
            <div class="reply-block">
                <div class="reply-block-label"><i class="fas fa-reply"></i> Admin Reply</div>
                <div class="reply-block-text"><%= inquiry.getReplyMessage() %></div>
                <div class="reply-block-date">
                    <i class="fas fa-clock"></i>
                    Replied on <%= new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm").format(inquiry.getRepliedAt()) %>
                </div>
            </div>
            <% } %>

            <div class="inq-actions">
                <% if (inquiry.getReplyMessage() == null) { %>
                <button class="btn-reply" data-bs-toggle="modal"
                        data-bs-target="#replyModal<%= inquiry.getId() %>">
                    <i class="fas fa-reply"></i> Reply
                </button>
                <% } %>
                <% if (!"Closed".equals(inquiry.getStatus())) { %>
                <form action="<%= request.getContextPath() %>/admin/inquiries" method="post" class="d-inline">
                    <input type="hidden" name="action" value="close">
                    <input type="hidden" name="inquiryId" value="<%= inquiry.getId() %>">
                    <button type="submit" class="btn-close-inq">
                        <i class="fas fa-times-circle"></i> Close
                    </button>
                </form>
                <% } %>
            </div>

        </div>
    </div>

    <!-- REPLY MODAL -->
    <div class="modal fade" id="replyModal<%= inquiry.getId() %>" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-reply me-2"></i>Reply to Inquiry &middot; #<%= inquiry.getInquiryId() %>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="<%= request.getContextPath() %>/admin/inquiries" method="post">
                    <div class="modal-body">
                        <input type="hidden" name="action" value="reply">
                        <input type="hidden" name="inquiryId" value="<%= inquiry.getId() %>">
                        <div class="student-q-block">
                            <div class="student-q-label"><i class="fas fa-comment-dots"></i> Student's Question</div>
                            <%= inquiry.getMessage() %>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Your Reply *</label>
                            <textarea name="replyMessage" class="form-control" rows="5"
                                      placeholder="Type your response here..." required></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn-m-cancel" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn-m-send">
                            <i class="fas fa-paper-plane"></i> Send Reply
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <% cardDelay++; }
    } else { %>
    <div class="empty-state">
        <i class="fas fa-comments"></i>
        <span>No inquiries found</span>
    </div>
    <% } %>

</div><!-- /.page-body -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.modal').forEach(function (m) {
            document.body.appendChild(m);
        });
    });
</script>
</body>
</html>