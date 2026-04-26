<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="org.example.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"Owner".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");
    Room editRoom = (Room) request.getAttribute("editRoom");
    String mode = (String) request.getAttribute("mode");
    Integer defaultHostelId = (Integer) request.getAttribute("defaultHostelId");
    String sidebarOwnerName = user.getFullName() != null && !user.getFullName().trim().isEmpty()
            ? user.getFullName().trim() : "Hostel Owner";
    char sidebarOwnerInitial = Character.toUpperCase(sidebarOwnerName.charAt(0));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Manage Rooms - Admin</title>
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
        }

        .owner-sidebar {
            width: 280px;
            background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
            color: #fff;
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            overflow-y: auto;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            z-index: 100;
        }
        .owner-sidebar-header {
            padding: 30px 25px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .owner-sidebar-header h2 {
            font-size: 28px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            color: #fff;
            margin: 0;
            font-family: 'DM Sans', sans-serif;
        }
        .owner-sidebar-header h2 i { color: #4f46e5; }

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
            color: #fff;
            font-family: 'Fraunces', serif;
        }
        .owner-name {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 5px;
            color: #fff;
        }
        .owner-id {
            font-size: 13px;
            color: rgba(255,255,255,0.7);
            background: rgba(255,255,255,0.1);
            padding: 5px 15px;
            border-radius: 50px;
            display: inline-block;
        }
        .owner-nav-menu { padding: 20px 0; }
        .owner-nav-item {
            display: flex;
            align-items: center;
            padding: 12px 25px;
            color: rgba(255,255,255,0.7);
            text-decoration: none;
            transition: all 0.3s;
            border-left: 4px solid transparent;
            margin-bottom: 2px;
            font-weight: 500;
        }
        .owner-nav-item:hover,
        .owner-nav-item.active {
            background: rgba(79, 70, 229, 0.2);
            color: #fff;
            border-left-color: #4f46e5;
        }
        .owner-nav-item i {
            width: 25px;
            margin-right: 15px;
            font-size: 18px;
        }

        .main-content {
            margin-left: 280px;
            min-height: 100vh;
        }

        .bookings-view {
            display: none;
            padding: 2rem;
            min-height: 100vh;
        }
        .bookings-frame {
            width: 100%;
            min-height: calc(100vh - 4rem);
            border: none;
            border-radius: var(--radius);
            background: var(--surface);
            box-shadow: 0 2px 16px rgba(0,0,0,0.05);
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
        @media (max-width: 900px) { .stats-grid { grid-template-columns: repeat(2,1fr); } }

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
        .stat-card.s-green::after  { background: var(--success); }
        .stat-card.s-yellow::after { background: var(--warning); }
        .stat-card.s-red::after    { background: var(--danger); }
        .stat-label { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em; color: var(--text-muted); margin-bottom: 0.35rem; }
        .stat-value { font-family: 'Fraunces', serif; font-size: 2rem; font-weight: 600; line-height: 1; }
        .stat-card.s-blue   .stat-value { color: var(--accent); }
        .stat-card.s-green  .stat-value { color: var(--success); }
        .stat-card.s-yellow .stat-value { color: var(--warning); }
        .stat-card.s-red    .stat-value { color: var(--danger); }
        .stat-icon { position: absolute; right: 1rem; top: 1rem; font-size: 1.2rem; opacity: 0.15; }
        .stat-card.s-blue   .stat-icon { color: var(--accent); }
        .stat-card.s-green  .stat-icon { color: var(--success); }
        .stat-card.s-yellow .stat-icon { color: var(--warning); }
        .stat-card.s-red    .stat-icon { color: var(--danger); }
        .stat-card:nth-child(1) { animation-delay: 0.05s; }
        .stat-card:nth-child(2) { animation-delay: 0.10s; }
        .stat-card:nth-child(3) { animation-delay: 0.15s; }
        .stat-card:nth-child(4) { animation-delay: 0.20s; }

        /* ── ALERTS ── */
        .alert-custom {
            border-radius: var(--radius-sm);
            padding: 0.8rem 1rem;
            font-size: 0.88rem;
            display: flex; align-items: center;
            justify-content: space-between;
            gap: 1rem; margin-bottom: 1.25rem;
        }
        .alert-custom.success { background: rgba(22,163,74,0.08); border: 1px solid rgba(22,163,74,0.25); color: var(--success); }
        .alert-custom.danger  { background: rgba(220,38,38,0.08);  border: 1px solid rgba(220,38,38,0.25);  color: var(--danger); }
        .close-btn { background: none; border: none; cursor: pointer; font-size: 0.82rem; opacity: 0.6; padding: 0; transition: opacity 0.2s; color: inherit; }
        .close-btn:hover { opacity: 1; }

        /* ── ADD ROOM BUTTON ── */
        .btn-add-room {
            background: var(--accent);
            border: 1px solid var(--accent);
            color: #fff;
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            font-weight: 600;
            padding: 0.6rem 1.3rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s;
            margin-bottom: 1.25rem;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-add-room:hover { background: #1558b0; border-color: #1558b0; color: #fff; box-shadow: 0 4px 16px var(--accent-glow); transform: translateY(-1px); }

        /* ── FORM CARD ── */
        .form-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: 0 2px 16px rgba(0,0,0,0.04);
            margin-bottom: 1.75rem;
            animation: fadeUp 0.4s ease both;
        }
        .form-card-header {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 0.6rem;
        }
        .form-card-header.add-header  { background: rgba(22,163,74,0.06);  border-bottom-color: rgba(22,163,74,0.15); }
        .form-card-header.edit-header { background: rgba(217,119,6,0.06); border-bottom-color: rgba(217,119,6,0.15); }
        .form-card-header h5 { font-family: 'Fraunces', serif; font-size: 1rem; font-weight: 600; margin: 0; }
        .form-card-header.add-header  h5 { color: var(--success); }
        .form-card-header.edit-header h5 { color: var(--warning); }
        .form-card-header.add-header  i  { color: var(--success); font-size: 0.9rem; }
        .form-card-header.edit-header i  { color: var(--warning); font-size: 0.9rem; }

        .form-card-body { padding: 1.5rem; }

        /* ── FORM SECTIONS ── */
        .form-section {
            background: var(--surface-2);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            padding: 1.25rem 1.4rem;
            margin-bottom: 1.1rem;
        }
        .form-section:last-of-type { margin-bottom: 0; }
        .form-section-title {
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.09em;
            color: var(--accent);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
            padding-bottom: 0.7rem;
            border-bottom: 1px solid var(--border);
        }

        /* ── FORM CONTROLS ── */
        .form-label {
            font-size: 0.74rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--text-muted);
            margin-bottom: 0.38rem;
            display: block;
        }
        .form-control, .form-select {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            color: var(--text);
            font-family: 'DM Sans', sans-serif;
            font-size: 0.88rem;
            padding: 0.58rem 0.9rem;
            transition: border-color 0.2s, box-shadow 0.2s;
            width: 100%;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px var(--accent-dim);
            outline: none;
            background: var(--surface);
            color: var(--text);
        }
        .form-control::placeholder { color: var(--text-muted); opacity: 0.6; }
        .form-select option { background: var(--surface); color: var(--text); }
        textarea.form-control { resize: vertical; min-height: 80px; }

        /* ── FACILITY CHECKBOXES ── */
        .facility-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 0.6rem;
        }
        @media (max-width: 640px) { .facility-grid { grid-template-columns: repeat(2,1fr); } }

        .check-tile {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            padding: 0.6rem 0.85rem;
            display: flex;
            align-items: center;
            gap: 0.55rem;
            cursor: pointer;
            transition: border-color 0.2s, background 0.2s;
        }
        .check-tile:has(input:checked) {
            background: var(--accent-dim);
            border-color: rgba(29,111,216,0.35);
        }
        .check-tile input[type="checkbox"] {
            width: 15px; height: 15px;
            accent-color: var(--accent);
            cursor: pointer; flex-shrink: 0;
        }
        .check-tile label {
            font-size: 0.84rem; color: var(--text);
            font-weight: 500; cursor: pointer;
            margin: 0; text-transform: none; letter-spacing: 0;
        }
        .check-tile i { color: var(--accent); font-size: 0.75rem; }

        /* ── IMAGE SECTION ── */
        .existing-images {
            display: flex;
            flex-wrap: wrap;
            gap: 0.6rem;
            margin-top: 0.6rem;
            margin-bottom: 0.5rem;
        }
        .existing-images img {
            width: 80px; height: 80px;
            object-fit: cover;
            border-radius: var(--radius-sm);
            border: 2px solid rgba(22,163,74,0.4);
        }
        .image-preview {
            display: flex;
            flex-wrap: wrap;
            gap: 0.6rem;
            margin-top: 0.75rem;
        }
        .image-preview img {
            width: 80px; height: 80px;
            object-fit: cover;
            border-radius: var(--radius-sm);
            border: 2px solid rgba(29,111,216,0.35);
        }

        .file-upload-zone {
            border: 2px dashed var(--border);
            border-radius: var(--radius-sm);
            padding: 1.25rem;
            text-align: center;
            background: var(--surface);
            position: relative;
            transition: border-color 0.2s, background 0.2s;
            cursor: pointer;
        }
        .file-upload-zone:hover {
            border-color: var(--accent);
            background: var(--accent-dim);
        }
        .file-upload-zone input[type="file"] {
            position: absolute;
            inset: 0;
            width: 100%; height: 100%;
            opacity: 0;
            cursor: pointer;
        }
        .file-upload-zone i { font-size: 1.4rem; color: var(--accent); margin-bottom: 0.4rem; display: block; }
        .file-upload-zone p { font-size: 0.84rem; color: var(--text-muted); margin: 0; }
        .file-upload-zone span { font-size: 0.76rem; color: var(--text-muted); opacity: 0.7; }

        /* ── FORM ACTIONS ── */
        .form-actions {
            display: flex;
            gap: 0.75rem;
            padding-top: 1.25rem;
            flex-wrap: wrap;
        }
        .btn-form-submit {
            background: var(--accent);
            border: 1px solid var(--accent);
            color: #fff;
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            font-weight: 600;
            padding: 0.65rem 1.4rem;
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            cursor: pointer;
            transition: all 0.2s;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-form-submit.add-btn { background: var(--success); border-color: var(--success); }
        .btn-form-submit.add-btn:hover { background: #15803d; border-color: #15803d; }
        .btn-form-submit.edit-btn { background: var(--warning); border-color: var(--warning); }
        .btn-form-submit.edit-btn:hover { background: #b45309; border-color: #b45309; }
        .btn-form-cancel {
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text-muted);
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            font-weight: 500;
            padding: 0.65rem 1.2rem;
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s;
            font-family: 'DM Sans', sans-serif;
        }
        .btn-form-cancel:hover { border-color: var(--danger); color: var(--danger); }

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
        .rooms-table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
            min-width: 980px;
        }
        .rooms-table thead tr { background: var(--surface-2); border-bottom: 1px solid var(--border); }
        .rooms-table thead th {
            padding: 0.8rem 0.9rem;
            font-size: 0.68rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.08em;
            color: var(--text-muted); white-space: nowrap; border: none;
        }
        .rooms-table tbody tr { border-bottom: 1px solid var(--border); transition: background 0.15s; }
        .rooms-table tbody tr:last-child { border-bottom: none; }
        .rooms-table tbody tr:hover { background: rgba(29,111,216,0.025); }
        .rooms-table tbody td {
            padding: 0.8rem 0.9rem;
            font-size: 0.86rem;
            color: var(--text);
            vertical-align: middle;
            border: none;
            line-height: 1.25;
        }

        .rooms-table th:nth-child(1), .rooms-table td:nth-child(1) { width: 72px; }
        .rooms-table th:nth-child(2), .rooms-table td:nth-child(2) { width: 90px; }
        .rooms-table th:nth-child(3), .rooms-table td:nth-child(3) { width: 72px; }
        .rooms-table th:nth-child(4), .rooms-table td:nth-child(4) { width: 120px; }
        .rooms-table th:nth-child(5), .rooms-table td:nth-child(5) { width: 160px; }
        .rooms-table th:nth-child(6), .rooms-table td:nth-child(6) { width: 130px; }
        .rooms-table th:nth-child(7), .rooms-table td:nth-child(7) { width: 150px; }
        .rooms-table th:nth-child(8), .rooms-table td:nth-child(8) { width: 115px; }
        .rooms-table th:nth-child(9), .rooms-table td:nth-child(9) { width: 95px; }

        .rooms-table td:nth-child(4),
        .rooms-table td:nth-child(6),
        .rooms-table td:nth-child(7) {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .room-thumb {
            width: 46px; height: 46px;
            object-fit: cover;
            border-radius: 8px;
            border: 1.5px solid var(--border);
        }
        .room-num-cell { font-family: 'Fraunces', serif; font-weight: 600; color: var(--accent); font-size: 0.9rem; }

        /* Cap/Occ/Avail badges */
        .occ-group { display: flex; align-items: center; gap: 0.3rem; flex-wrap: nowrap; }
        .occ-pill {
            font-size: 0.68rem; font-weight: 700;
            padding: 0.2rem 0.5rem; border-radius: 12px;
        }
        .occ-pill.cap   { background: rgba(29,111,216,0.1);  border: 1px solid rgba(29,111,216,0.25);  color: var(--accent); }
        .occ-pill.occ   { background: rgba(217,119,6,0.1);   border: 1px solid rgba(217,119,6,0.25);   color: var(--warning); }
        .occ-pill.avail { background: rgba(22,163,74,0.1);   border: 1px solid rgba(22,163,74,0.25);   color: var(--success); }
        .occ-sep { color: var(--text-muted); font-size: 0.7rem; opacity: 0.5; }

        /* Status badge */
        .badge {
            font-size: 0.68rem !important; font-weight: 700 !important;
            letter-spacing: 0.04em; padding: 0.28rem 0.6rem !important; border-radius: 20px !important;
        }
        .badge.bg-success   { background: rgba(22,163,74,0.12)  !important; color: var(--success)    !important; border: 1px solid rgba(22,163,74,0.25); }
        .badge.bg-warning   { background: rgba(217,119,6,0.12)  !important; color: var(--warning)    !important; border: 1px solid rgba(217,119,6,0.25); }
        .badge.bg-danger    { background: rgba(220,38,38,0.12)  !important; color: var(--danger)     !important; border: 1px solid rgba(220,38,38,0.25); }
        .badge.bg-info      { background: rgba(37,99,235,0.12)  !important; color: var(--info)       !important; border: 1px solid rgba(37,99,235,0.25); }
        .badge.bg-primary   { background: var(--accent-dim)     !important; color: var(--accent)     !important; border: 1px solid rgba(29,111,216,0.3); }
        .badge.bg-secondary { background: rgba(107,107,128,0.1) !important; color: var(--text-muted) !important; border: 1px solid rgba(107,107,128,0.2); }

        /* Facility icons */
        .facility-icons { display: flex; gap: 0.4rem; align-items: center; flex-wrap: wrap; min-height: 18px; }
        .fac-icon { font-size: 0.8rem; }
        .fac-icon.wifi    { color: var(--success); }
        .fac-icon.ac      { color: var(--accent); }
        .fac-icon.study   { color: var(--info); }
        .fac-icon.broom   { color: var(--warning); }

        /* Action buttons */
        .action-btns { display: flex; gap: 0.4rem; white-space: nowrap; }
        .btn-action {
            width: 30px; height: 30px;
            border-radius: 8px; font-size: 0.75rem;
            display: inline-flex; align-items: center; justify-content: center;
            border: 1px solid; cursor: pointer; transition: all 0.18s;
            text-decoration: none;
        }
        .btn-action-edit {
            background: rgba(217,119,6,0.08); border-color: rgba(217,119,6,0.3); color: var(--warning);
        }
        .btn-action-edit:hover { background: rgba(217,119,6,0.18); border-color: var(--warning); color: var(--warning); }
        .btn-action-delete {
            background: rgba(220,38,38,0.08); border-color: rgba(220,38,38,0.25); color: var(--danger);
        }
        .btn-action-delete:hover { background: rgba(220,38,38,0.18); border-color: var(--danger); }

        /* Empty row */
        .empty-row td { text-align: center; padding: 3rem 1rem; color: var(--text-muted); font-size: 0.88rem; }

        /* ── RESPONSIVE ── */
        @media (max-width: 768px) {
            .page-body { padding: 1.25rem; }
            .bookings-view { padding: 1.25rem; }
            .bookings-frame { min-height: 72vh; }
        }

        @media (max-width: 992px) {
            .owner-sidebar {
                position: static;
                width: 100%;
                height: auto;
            }
            .main-content {
                margin-left: 0;
            }
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

    <div class="owner-sidebar">
        <div class="owner-sidebar-header">
            <h2>
                <i class="fas fa-hotel"></i>
                <span>SafeStay</span>
            </h2>
        </div>

        <div class="owner-profile">
            <div class="owner-avatar"><%= sidebarOwnerInitial %></div>
            <div class="owner-name"><%= sidebarOwnerName %></div>
            <div class="owner-id"><i class="fas fa-id-card"></i> <%= user.getUserId() %></div>
        </div>

        <div class="owner-nav-menu">
            <a href="#" id="sidebarRoomsLink" class="owner-nav-item active">
                <i class="fas fa-door-open"></i>
                <span>Rooms</span>
            </a>
            <a href="#" id="sidebarBookingsLink" class="owner-nav-item" data-bookings-url="<%= request.getContextPath() %>/admin/bookings">
                <i class="fas fa-calendar-check"></i>
                <span>Bookings</span>
            </a>
            <a href="#" id="sidebarInquiriesLink" class="owner-nav-item" data-inquiries-url="<%= request.getContextPath() %>/admin/inquiries">
                <i class="fas fa-comments"></i>
                <span>Inquiries</span>
            </a>
        </div>
    </div>

    <div class="main-content">

    <!-- PAGE BODY -->
    <div class="page-body" id="roomsView">

        <!-- PAGE HEADING -->
        <div class="page-header-row">
            <h1 class="page-heading">Rooms Management</h1>
            <a href="<%= request.getContextPath() %>/dashboard/owner" class="btn-back-owner">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>

        <!-- STATS -->
        <div class="stats-grid">
            <div class="stat-card s-blue">
                <i class="fas fa-building stat-icon"></i>
                <div class="stat-label">Total Rooms</div>
                <div class="stat-value"><%= stats.get("totalRooms") %></div>
            </div>
            <div class="stat-card s-green">
                <i class="fas fa-door-open stat-icon"></i>
                <div class="stat-label">Available Slots</div>
                <div class="stat-value"><%= stats.get("totalAvailable") %></div>
            </div>
            <div class="stat-card s-yellow">
                <i class="fas fa-users stat-icon"></i>
                <div class="stat-label">Occupied</div>
                <div class="stat-value"><%= stats.get("totalOccupied") %></div>
            </div>
            <div class="stat-card s-red">
                <i class="fas fa-ban stat-icon"></i>
                <div class="stat-label">Full Rooms</div>
                <div class="stat-value"><%= stats.get("fullRooms") %></div>
            </div>
        </div>

        <!-- ALERTS -->
        <% String success = (String) session.getAttribute("success");
           if (success != null) { %>
            <div class="alert-custom success" id="alertSuccess">
                <span><i class="fas fa-check-circle me-2"></i><%= success %></span>
                <button class="close-btn" onclick="document.getElementById('alertSuccess').remove()"><i class="fas fa-times"></i></button>
            </div>
            <% session.removeAttribute("success"); %>
        <% } %>

        <% String error = (String) session.getAttribute("error");
           if (error != null) { %>
            <div class="alert-custom danger" id="alertError">
                <span><i class="fas fa-exclamation-circle me-2"></i><%= error %></span>
                <button class="close-btn" onclick="document.getElementById('alertError').remove()"><i class="fas fa-times"></i></button>
            </div>
            <% session.removeAttribute("error"); %>
        <% } %>

        <!-- ADD / EDIT FORM -->
        <% if ("add".equals(mode) || "edit".equals(mode)) { %>
        <div class="form-card">
            <div class="form-card-header <%= "add".equals(mode) ? "add-header" : "edit-header" %>">
                <% if ("add".equals(mode)) { %>
                    <i class="fas fa-plus-circle"></i>
                    <h5>Add New Room</h5>
                <% } else { %>
                    <i class="fas fa-edit"></i>
                    <h5>Edit Room <%= editRoom.getRoomNumber() %></h5>
                <% } %>
            </div>
            <div class="form-card-body">
                <form action="<%= request.getContextPath() %>/admin/rooms" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="<%= "add".equals(mode) ? "add" : "update" %>">
                    <% if ("edit".equals(mode)) { %>
                        <input type="hidden" name="roomId" value="<%= editRoom.getId() %>">
                    <% } else { %>
                        <input type="hidden" name="hostelId" value="<%= defaultHostelId %>">
                    <% } %>

                    <!-- Basic Information -->
                    <div class="form-section">
                        <div class="form-section-title"><i class="fas fa-info-circle"></i> Basic Information</div>
                        <div class="row g-3">
                            <div class="col-md-3 col-sm-6">
                                <label class="form-label">Room Number *</label>
                                <input type="text" name="roomNumber" class="form-control"
                                       value="<%= editRoom != null ? editRoom.getRoomNumber() : "" %>"
                                       placeholder="e.g., 101" required>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <label class="form-label">Floor Number *</label>
                                <select name="floorNumber" class="form-select" required>
                                    <option value="">Select Floor</option>
                                    <% for (int i = 1; i <= 3; i++) { %>
                                        <option value="<%= i %>" <%= editRoom != null && editRoom.getFloorNumber() == i ? "selected" : "" %>>Floor <%= i %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <label class="form-label">Room Type *</label>
                                <select name="roomType" class="form-select" required>
                                    <option value="">Select Type</option>
                                    <option value="AC"     <%= editRoom != null && "AC".equals(editRoom.getRoomType())     ? "selected" : "" %>>AC</option>
                                    <option value="Non-AC" <%= editRoom != null && "Non-AC".equals(editRoom.getRoomType()) ? "selected" : "" %>>Non-AC</option>
                                </select>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <label class="form-label">Monthly Price (Rs.) *</label>
                                <input type="number" name="priceMonthly" class="form-control" step="0.01"
                                       value="<%= editRoom != null ? editRoom.getPriceMonthly() : "" %>"
                                       placeholder="e.g., 8000" required>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <label class="form-label">Capacity *</label>
                                <select name="capacity" class="form-select" required>
                                    <option value="">Select</option>
                                    <% for (int i = 1; i <= 5; i++) { %>
                                        <option value="<%= i %>" <%= editRoom != null && editRoom.getCapacity() == i ? "selected" : "" %>><%= i %> Student<%= i > 1 ? "s" : "" %></option>
                                    <% } %>
                                </select>
                            </div>
                            <% if ("edit".equals(mode)) { %>
                            <div class="col-md-3 col-sm-6">
                                <label class="form-label">Occupied</label>
                                <input type="number" name="occupied" class="form-control"
                                       min="0" max="<%= editRoom.getCapacity() %>"
                                       value="<%= editRoom.getOccupied() %>">
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <label class="form-label">Status</label>
                                <select name="status" class="form-select">
                                    <option value="Available"          <%= "Available".equals(editRoom.getStatus())          ? "selected" : "" %>>Available</option>
                                    <option value="Partially Occupied" <%= "Partially Occupied".equals(editRoom.getStatus()) ? "selected" : "" %>>Partially Occupied</option>
                                    <option value="Full"               <%= "Full".equals(editRoom.getStatus())               ? "selected" : "" %>>Full</option>
                                    <option value="Under Maintenance"  <%= "Under Maintenance".equals(editRoom.getStatus())  ? "selected" : "" %>>Under Maintenance</option>
                                </select>
                            </div>
                            <% } %>
                            <div class="col-md-3 col-sm-6">
                                <label class="form-label">Bed Type *</label>
                                <select name="bedType" class="form-select" required>
                                    <option value="">Select</option>
                                    <option value="Single Bed"      <%= editRoom != null && "Single Bed".equals(editRoom.getBedType())      ? "selected" : "" %>>Single Bed</option>
                                    <option value="Shared Bed for 2" <%= editRoom != null && "Shared Bed for 2".equals(editRoom.getBedType()) ? "selected" : "" %>>Shared Bed for 2</option>
                                    <option value="Bunk Beds"       <%= editRoom != null && "Bunk Beds".equals(editRoom.getBedType())       ? "selected" : "" %>>Bunk Beds</option>
                                </select>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <label class="form-label">Bathroom Type *</label>
                                <select name="bathroomType" class="form-select" required>
                                    <option value="">Select</option>
                                    <option value="Attached Bathroom" <%= editRoom != null && "Attached Bathroom".equals(editRoom.getBathroomType()) ? "selected" : "" %>>Attached</option>
                                    <option value="Common Bathroom"   <%= editRoom != null && "Common Bathroom".equals(editRoom.getBathroomType())   ? "selected" : "" %>>Common</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- Facilities -->
                    <div class="form-section">
                        <div class="form-section-title"><i class="fas fa-star"></i> Facilities &amp; Services</div>
                        <div class="facility-grid">
                            <label class="check-tile">
                                <input class="form-check-input" type="checkbox" name="hasWifi"
                                       <%= editRoom != null && editRoom.isHasWifi() ? "checked" : "" %>>
                                <i class="fas fa-wifi"></i>
                                <label>WiFi</label>
                            </label>
                            <label class="check-tile">
                                <input class="form-check-input" type="checkbox" name="hasAc"
                                       <%= editRoom != null && editRoom.isHasAc() ? "checked" : "" %>>
                                <i class="fas fa-snowflake"></i>
                                <label>Air Conditioning</label>
                            </label>
                            <label class="check-tile">
                                <input class="form-check-input" type="checkbox" name="hasFan"
                                       <%= editRoom != null && editRoom.isHasFan() ? "checked" : "" %>>
                                <i class="fas fa-fan"></i>
                                <label>Fan</label>
                            </label>
                            <label class="check-tile">
                                <input class="form-check-input" type="checkbox" name="hasStudyTable"
                                       <%= editRoom != null && editRoom.isHasStudyTable() ? "checked" : "" %>>
                                <i class="fas fa-desk"></i>
                                <label>Study Table</label>
                            </label>
                            <label class="check-tile">
                                <input class="form-check-input" type="checkbox" name="hasCupboard"
                                       <%= editRoom != null && editRoom.isHasCupboard() ? "checked" : "" %>>
                                <i class="fas fa-archive"></i>
                                <label>Cupboard</label>
                            </label>
                            <label class="check-tile">
                                <input class="form-check-input" type="checkbox" name="hasLaundryAccess"
                                       <%= editRoom != null && editRoom.isHasLaundryAccess() ? "checked" : "" %>>
                                <i class="fas fa-tshirt"></i>
                                <label>Laundry Access</label>
                            </label>
                            <label class="check-tile">
                                <input class="form-check-input" type="checkbox" name="hasRoomCleaning"
                                       <%= editRoom != null && editRoom.isHasRoomCleaning() ? "checked" : "" %>>
                                <i class="fas fa-broom"></i>
                                <label>Room Cleaning</label>
                            </label>
                        </div>
                    </div>

                    <!-- Images & Description -->
                    <div class="form-section">
                        <div class="form-section-title"><i class="fas fa-images"></i> Images &amp; Description</div>

                        <% if ("edit".equals(mode) && editRoom.getImagePaths() != null) { %>
                        <div class="mb-3">
                            <label class="form-label">Current Images</label>
                            <div class="existing-images">
                                <%
                                List<String> images = editRoom.getImageList();
                                for (String img : images) {
                                    String imageSrc = img.startsWith("data:image") ? img : request.getContextPath() + "/" + img;
                                %>
                                    <img src="<%= imageSrc %>"
                                         alt="Room Image"
                                         onerror="this.src='<%= request.getContextPath() %>/images/rooms/default.jpg'">
                                <% } %>
                            </div>
                            <p style="font-size:0.76rem;color:var(--text-muted);margin-top:0.4rem;margin-bottom:0;">Upload new images to replace these</p>
                        </div>
                        <% } %>

                        <div class="mb-3">
                            <label class="form-label"><%= "edit".equals(mode) ? "Upload New Images (Optional)" : "Upload Room Images" %></label>
                            <div class="file-upload-zone">
                                <input type="file" name="roomImages" id="roomImages"
                                       accept="image/*" multiple onchange="previewImages(event)">
                                <i class="fas fa-cloud-upload-alt"></i>
                                <p>Click or drag &amp; drop to upload images</p>
                                <span>JPG, PNG, GIF — Max 10MB each — Multiple allowed</span>
                            </div>
                            <div id="imagePreview" class="image-preview"></div>
                        </div>

                        <div>
                            <label class="form-label">Description</label>
                            <textarea name="description" class="form-control" rows="3"
                                      placeholder="Room description..."><%= editRoom != null && editRoom.getDescription() != null ? editRoom.getDescription() : "" %></textarea>
                        </div>
                    </div>

                    <!-- Actions -->
                    <div class="form-actions">
                        <button type="submit" class="btn-form-submit <%= "add".equals(mode) ? "add-btn" : "edit-btn" %>">
                            <i class="fas fa-<%= "add".equals(mode) ? "plus" : "save" %>"></i>
                            <%= "add".equals(mode) ? "Add Room" : "Update Room" %>
                        </button>
                        <a href="<%= request.getContextPath() %>/admin/rooms" class="btn-form-cancel">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <% } else { %>
        <!-- ADD ROOM BUTTON -->
        <a href="<%= request.getContextPath() %>/admin/rooms?action=add" class="btn-add-room">
            <i class="fas fa-plus-circle"></i> Add New Room
        </a>
        <% } %>

        <!-- ROOMS TABLE -->
        <div class="table-card">
            <div class="table-card-header">
                <h5>All Rooms</h5>
                <span><%= rooms != null ? rooms.size() : 0 %> total</span>
            </div>
            <div style="overflow-x:auto;">
                <table class="rooms-table">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Room</th>
                            <th>Floor</th>
                            <th>Type</th>
                            <th>Cap / Occ / Avail</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Facilities</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (rooms != null && !rooms.isEmpty()) {
                            for (Room room : rooms) {
                                int calculatedAvailable = Math.max(0, room.getCapacity() - room.getOccupied());
                                String roomStatus = room.getStatus() != null ? room.getStatus() : "Unknown";
                                String statusBadgeClass;
                                if ("Available".equalsIgnoreCase(roomStatus)) {
                                    statusBadgeClass = "success";
                                } else if ("Partially Occupied".equalsIgnoreCase(roomStatus)) {
                                    statusBadgeClass = "warning";
                                } else if ("Full".equalsIgnoreCase(roomStatus)) {
                                    statusBadgeClass = "danger";
                                } else {
                                    statusBadgeClass = "secondary";
                                }
                        %>
                        <tr>
                            <td>
                                <%
                                    String firstImage = room.getFirstImage();
                                    String thumbSrc = firstImage.startsWith("data:image") ? firstImage : request.getContextPath() + "/" + firstImage;
                                %>
                                <img src="<%= thumbSrc %>"
                                     class="room-thumb"
                                     alt="Room <%= room.getRoomNumber() %>"
                                     onerror="this.src='<%= request.getContextPath() %>/images/rooms/default.jpg'">
                            </td>
                            <td><span class="room-num-cell"><%= room.getRoomNumber() %></span></td>
                            <td><%= room.getFloorNumber() %></td>
                            <td><%= room.getRoomType() %></td>
                            <td>
                                <div class="occ-group">
                                    <span class="occ-pill cap"><%= room.getCapacity() %></span>
                                    <span class="occ-sep">/</span>
                                    <span class="occ-pill occ"><%= room.getOccupied() %></span>
                                    <span class="occ-sep">/</span>
                                    <span class="occ-pill avail"><%= calculatedAvailable %></span>
                                </div>
                            </td>
                            <td style="font-weight:600;"><%= room.getFormattedPrice() %></td>
                            <td>
                                <span class="badge bg-<%= statusBadgeClass %>">
                                    <%= roomStatus %>
                                </span>
                            </td>
                            <td>
                                <div class="facility-icons">
                                    <% if (room.isHasWifi())        { %><i class="fas fa-wifi fac-icon wifi" title="WiFi"></i><% } %>
                                    <% if (room.isHasAc())          { %><i class="fas fa-snowflake fac-icon ac" title="AC"></i><% } %>
                                    <% if (room.isHasStudyTable())   { %><i class="fas fa-desk fac-icon study" title="Study Table"></i><% } %>
                                    <% if (room.isHasRoomCleaning()) { %><i class="fas fa-broom fac-icon broom" title="Cleaning"></i><% } %>
                                </div>
                            </td>
                            <td>
                                <div class="action-btns">
                                    <a href="<%= request.getContextPath() %>/admin/rooms?edit=<%= room.getId() %>"
                                       class="btn-action btn-action-edit" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <button type="button" class="btn-action btn-action-delete"
                                            onclick="confirmDelete(<%= room.getId() %>, '<%= room.getRoomNumber() %>')"
                                            title="Delete">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% }
                        } else { %>
                        <tr class="empty-row">
                            <td colspan="9">
                                <i class="fas fa-building" style="font-size:1.5rem;display:block;margin-bottom:0.5rem;opacity:0.25;"></i>
                                No rooms found
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

    </div><!-- /.page-body -->

    <div class="bookings-view" id="bookingsView">
        <iframe id="bookingsFrame" class="bookings-frame" title="Bookings Management"></iframe>
    </div>

    <div class="bookings-view" id="inquiriesView">
        <iframe id="inquiriesFrame" class="bookings-frame" title="Inquiries Management"></iframe>
    </div>

    </div><!-- /.main-content -->

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmDelete(roomId, roomNumber) {
            if (confirm('Are you sure you want to delete Room ' + roomNumber + '?\n\nNote: Rooms with existing bookings cannot be deleted.')) {
                window.location.href = '<%= request.getContextPath() %>/admin/rooms?delete=' + roomId;
            }
        }

        function previewImages(event) {
            const preview = document.getElementById('imagePreview');
            preview.innerHTML = '';

            const files = event.target.files;

            if (files.length > 0) {
                for (let i = 0; i < files.length; i++) {
                    const file = files[i];
                    const reader = new FileReader();

                    reader.onload = function(e) {
                        const img = document.createElement('img');
                        img.src = e.target.result;
                        preview.appendChild(img);
                    }

                    reader.readAsDataURL(file);
                }
            }
        }

        const roomsView = document.getElementById('roomsView');
        const bookingsView = document.getElementById('bookingsView');
        const inquiriesView = document.getElementById('inquiriesView');
        const bookingsFrame = document.getElementById('bookingsFrame');
        const inquiriesFrame = document.getElementById('inquiriesFrame');
        const sidebarRoomsLink = document.getElementById('sidebarRoomsLink');
        const sidebarBookingsLink = document.getElementById('sidebarBookingsLink');
        const sidebarInquiriesLink = document.getElementById('sidebarInquiriesLink');

        function showRoomsView() {
            roomsView.style.display = 'block';
            bookingsView.style.display = 'none';
            inquiriesView.style.display = 'none';
            sidebarRoomsLink.classList.add('active');
            sidebarBookingsLink.classList.remove('active');
            sidebarInquiriesLink.classList.remove('active');
        }

        function showBookingsView() {
            roomsView.style.display = 'none';
            bookingsView.style.display = 'block';
            inquiriesView.style.display = 'none';
            sidebarBookingsLink.classList.add('active');
            sidebarRoomsLink.classList.remove('active');
            sidebarInquiriesLink.classList.remove('active');

            if (!bookingsFrame.dataset.loaded) {
                bookingsFrame.src = sidebarBookingsLink.dataset.bookingsUrl;
                bookingsFrame.dataset.loaded = 'true';
            }
        }

        function showInquiriesView() {
            roomsView.style.display = 'none';
            bookingsView.style.display = 'none';
            inquiriesView.style.display = 'block';
            sidebarInquiriesLink.classList.add('active');
            sidebarRoomsLink.classList.remove('active');
            sidebarBookingsLink.classList.remove('active');

            if (!inquiriesFrame.dataset.loaded) {
                inquiriesFrame.src = sidebarInquiriesLink.dataset.inquiriesUrl;
                inquiriesFrame.dataset.loaded = 'true';
            }
        }

        sidebarRoomsLink.addEventListener('click', function (event) {
            event.preventDefault();
            showRoomsView();
        });

        sidebarBookingsLink.addEventListener('click', function (event) {
            event.preventDefault();
            showBookingsView();
        });

        sidebarInquiriesLink.addEventListener('click', function (event) {
            event.preventDefault();
            showInquiriesView();
        });
    </script>
</body>
</html>