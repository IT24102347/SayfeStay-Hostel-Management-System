<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*, java.util.*, java.text.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"Student".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String fullName  = user.getFullName() != null ? user.getFullName() : "Student";
    String studentId = user.getUserId();
    String today     = new SimpleDateFormat("EEEE, MMMM d, yyyy").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance · SafeStay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; font-family:'Inter',sans-serif; }
        body { background:#f1f5f9; min-height:100vh; }

        /* ── HEADER ── */
        .top-bar {
            background:#fff;
            padding:16px 32px;
            display:flex;
            justify-content:space-between;
            align-items:center;
            border-bottom:1px solid #e2e8f0;
            position:sticky; top:0; z-index:100;
            box-shadow:0 1px 3px rgba(0,0,0,.06);
        }
        .top-bar-left { display:flex; align-items:center; gap:14px; }
        .top-bar-left i { color:#4f46e5; font-size:22px; }
        .top-bar-left h1 { font-size:20px; font-weight:700; color:#0f172a; }
        .top-bar-right { display:flex; align-items:center; gap:20px; }
        .live-clock { font-size:18px; font-weight:700; color:#4f46e5; font-variant-numeric:tabular-nums; }
        .today-date { font-size:13px; color:#64748b; }
        .back-btn {
            background:#f1f5f9; color:#0f172a; padding:9px 18px;
            border-radius:40px; text-decoration:none; font-weight:600;
            font-size:13px; display:flex; align-items:center; gap:7px;
            transition:background .2s;
        }
        .back-btn:hover { background:#e2e8f0; }

        /* ── LAYOUT ── */
        .page { max-width:1100px; margin:0 auto; padding:28px 20px; }
        .grid-2 { display:grid; grid-template-columns:1fr 1fr; gap:22px; }
        .grid-4 { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:22px; }

        /* ── CARDS ── */
        .card {
            background:#fff; border-radius:18px; padding:24px;
            box-shadow:0 2px 8px rgba(0,0,0,.06);
        }
        .card-title {
            font-size:15px; font-weight:700; color:#0f172a;
            margin-bottom:20px; display:flex; align-items:center; gap:9px;
        }
        .card-title i { color:#4f46e5; }

        /* ── STAT CARDS ── */
        .stat-card {
            background:#fff; border-radius:16px; padding:20px;
            box-shadow:0 2px 8px rgba(0,0,0,.06);
            border-top:4px solid #4f46e5;
        }
        .stat-card.green  { border-top-color:#10b981; }
        .stat-card.yellow { border-top-color:#f59e0b; }
        .stat-card.red    { border-top-color:#ef4444; }
        .stat-val  { font-size:30px; font-weight:800; color:#0f172a; line-height:1; }
        .stat-lbl  { font-size:12px; color:#64748b; margin-top:5px; font-weight:500; }

        /* ── STATUS BANNER ── */
        .status-banner {
            background:linear-gradient(135deg,#4f46e5,#6366f1);
            border-radius:16px; padding:22px 24px; color:#fff;
            margin-bottom:20px; display:flex;
            justify-content:space-between; align-items:center;
        }
        .status-banner .label { font-size:13px; opacity:.85; margin-bottom:4px; }
        .status-banner .value { font-size:22px; font-weight:700; }
        .status-pill {
            padding:5px 14px; border-radius:40px; font-size:12px; font-weight:600;
            background:rgba(255,255,255,.2);
        }
        .status-pill.active   { background:#10b; }
        .status-pill.inactive { background:rgba(255,255,255,.2); }

        /* ── FORM ELEMENTS ── */
        .form-group { margin-bottom:14px; }
        .form-group label { font-size:12px; font-weight:600; color:#64748b; display:block; margin-bottom:6px; }
        .form-group select,
        .form-group input[type=text] {
            width:100%; padding:11px 14px;
            border:1.5px solid #e2e8f0; border-radius:10px;
            font-size:14px; color:#0f172a; outline:none;
            transition:border-color .2s;
        }
        .form-group select:focus,
        .form-group input[type=text]:focus { border-color:#4f46e5; }

        /* ── BUTTONS ── */
        .btn {
            padding:11px 18px; border:none; border-radius:10px;
            font-weight:600; font-size:14px; cursor:pointer;
            display:inline-flex; align-items:center; gap:7px;
            transition:all .2s; justify-content:center;
        }
        .btn-primary   { background:#4f46e5; color:#fff; }
        .btn-primary:hover:not(:disabled)   { background:#4338ca; }
        .btn-success   { background:#10b981; color:#fff; }
        .btn-success:hover:not(:disabled)   { background:#059669; }
        .btn-warning   { background:#f59e0b; color:#fff; }
        .btn-warning:hover:not(:disabled)   { background:#d97706; }
        .btn:disabled  { opacity:.45; cursor:not-allowed; }
        .btn-full      { width:100%; }

        /* ── TIMELINE ── */
        .timeline { list-style:none; padding:0; }
        .timeline li {
            display:flex; gap:14px; align-items:flex-start;
            padding-bottom:16px; position:relative;
        }
        .timeline li:not(:last-child)::before {
            content:''; position:absolute; left:15px; top:32px;
            width:2px; height:calc(100% - 16px); background:#e2e8f0;
        }
        .tl-icon {
            width:32px; height:32px; border-radius:50%;
            display:flex; align-items:center; justify-content:center;
            font-size:13px; flex-shrink:0;
        }
        .tl-icon.in  { background:#d1fae5; color:#059669; }
        .tl-icon.out { background:#fee2e2; color:#dc2626; }
        .tl-time  { font-size:13px; font-weight:700; color:#0f172a; }
        .tl-label { font-size:12px; color:#64748b; }

        /* ── HISTORY TABLE ── */
        .table-wrap { overflow-x:auto; }
        table { width:100%; border-collapse:collapse; }
        th {
            text-align:left; padding:11px 12px; font-size:12px;
            font-weight:600; color:#64748b; border-bottom:2px solid #f1f5f9;
            white-space:nowrap;
        }
        td { padding:12px 12px; font-size:13px; border-bottom:1px solid #f8fafc; }
        tr:hover td { background:#fafafe; }

        .badge {
            padding:3px 10px; border-radius:40px; font-size:11px;
            font-weight:700; display:inline-block;
        }
        .badge-present { background:#d1fae5; color:#065f46; }
        .badge-late    { background:#fef3c7; color:#92400e; }
        .badge-absent  { background:#fee2e2; color:#991b1b; }

        /* ── PAGINATION ── */
        .pagination { display:flex; gap:8px; justify-content:center; margin-top:20px; flex-wrap:wrap; }
        .page-btn {
            padding:7px 13px; border:1.5px solid #e2e8f0;
            border-radius:8px; background:#fff; font-size:13px;
            font-weight:600; cursor:pointer; color:#0f172a; transition:all .2s;
        }
        .page-btn.active,
        .page-btn:hover { background:#4f46e5; color:#fff; border-color:#4f46e5; }
        .page-btn:disabled { opacity:.4; cursor:not-allowed; }

        /* ── FILTER BAR ── */
        .filter-bar { display:flex; gap:10px; margin-bottom:16px; flex-wrap:wrap; align-items:center; }
        .filter-bar input { flex:1; min-width:160px; padding:9px 12px; border:1.5px solid #e2e8f0; border-radius:10px; font-size:13px; outline:none; }
        .filter-bar input:focus { border-color:#4f46e5; }
        .filter-btn {
            padding:8px 14px; border:1.5px solid #e2e8f0; border-radius:10px;
            background:#fff; font-size:12px; font-weight:600; cursor:pointer;
            color:#64748b; transition:all .2s;
        }
        .filter-btn.active { background:#4f46e5; color:#fff; border-color:#4f46e5; }

        /* ── TOAST ── */
        #toast-container { position:fixed; top:20px; right:20px; z-index:9999; display:flex; flex-direction:column; gap:10px; }
        .toast {
            padding:14px 20px; border-radius:12px; font-size:14px; font-weight:500;
            display:flex; align-items:center; gap:10px; min-width:260px;
            box-shadow:0 8px 24px rgba(0,0,0,.12);
            animation:slideIn .35s ease;
        }
        .toast-success { background:#fff; border-left:4px solid #10b981; color:#065f46; }
        .toast-error   { background:#fff; border-left:4px solid #ef4444; color:#991b1b; }
        .toast-info    { background:#fff; border-left:4px solid #4f46e5; color:#3730a3; }
        @keyframes slideIn { from{transform:translateX(120%);opacity:0} to{transform:translateX(0);opacity:1} }
        @keyframes slideOut{ from{transform:translateX(0);opacity:1} to{transform:translateX(120%);opacity:0} }

        /* ── SPINNER ── */
        .spinner { display:inline-block; width:18px; height:18px; border:2px solid rgba(255,255,255,.4); border-top-color:#fff; border-radius:50%; animation:spin .6s linear infinite; }
        @keyframes spin { to{transform:rotate(360deg)} }

        .empty-state { text-align:center; padding:40px 20px; color:#94a3b8; }
        .empty-state i { font-size:40px; margin-bottom:12px; display:block; }

        @media(max-width:768px) {
            .grid-2 { grid-template-columns:1fr; }
            .grid-4 { grid-template-columns:repeat(2,1fr); }
            .top-bar { flex-wrap:wrap; gap:10px; }
        }
    </style>
</head>
<body>

<!-- ── TOAST CONTAINER ── -->
<div id="toast-container"></div>

<!-- ── TOP BAR ── -->
<div class="top-bar">
    <div class="top-bar-left">
        <i class="fas fa-calendar-check"></i>
        <div>
            <h1>Attendance System</h1>
            <div class="today-date"><%= today %></div>
        </div>
    </div>
    <div class="top-bar-right">
        <div class="live-clock" id="liveClock">--:-- --</div>
        <a href="<%= request.getContextPath() %>/dashboard/student/" class="back-btn">
            <i class="fas fa-arrow-left"></i> Dashboard
        </a>
    </div>
</div>

<!-- ── PAGE ── -->
<div class="page">

    <!-- STAT CARDS -->
    <div class="grid-4" id="statCards">
        <div class="stat-card">
            <div class="stat-val" id="statPct">--</div>
            <div class="stat-lbl">Attendance Rate</div>
        </div>
        <div class="stat-card green">
            <div class="stat-val" id="statPresent">--</div>
            <div class="stat-lbl">Present Days</div>
        </div>
        <div class="stat-card yellow">
            <div class="stat-val" id="statLate">--</div>
            <div class="stat-lbl">Late Days</div>
        </div>
        <div class="stat-card red">
            <div class="stat-val" id="statAbsent">--</div>
            <div class="stat-lbl">Absent Days</div>
        </div>
    </div>

    <!-- MAIN GRID -->
    <div class="grid-2" style="margin-bottom:22px;">

        <!-- LEFT: CHECK IN/OUT -->
        <div class="card">
            <div class="card-title"><i class="fas fa-fingerprint"></i> Mark Attendance</div>

            <!-- Status Banner -->
            <div class="status-banner">
                <div>
                    <div class="label">Today's Status</div>
                    <div class="value" id="currentState">Loading…</div>
                    <div style="font-size:12px;margin-top:4px;opacity:.8;">
                        Check-ins today: <span id="todayCount">0</span>
                    </div>
                </div>
                <span class="status-pill inactive" id="activePill">Inactive</span>
            </div>

            <!-- Form -->
            <div class="form-group">
                <label>Status <span style="color:#ef4444">*</span></label>
                <select id="statusSelect">
                    <option value="">-- Select Status --</option>
                    <option value="Present">Present</option>
                    <option value="Late">Late</option>
                    <option value="Absent">Absent</option>
                </select>
            </div>
            <div class="form-group">
                <label>Remarks <span style="color:#94a3b8">(optional)</span></label>
                <input type="text" id="remarksInput" placeholder="e.g. Returned from campus…" maxlength="200">
            </div>

            <div style="display:flex;gap:10px;margin-top:6px;">
                <button class="btn btn-success" id="checkInBtn" onclick="doCheckIn()" style="flex:1;">
                    <i class="fas fa-sign-in-alt"></i> Check In
                </button>
                <button class="btn btn-warning" id="checkOutBtn" onclick="doCheckOut()" style="flex:1;" disabled>
                    <i class="fas fa-sign-out-alt"></i> Check Out
                </button>
            </div>
        </div>

        <!-- RIGHT: TODAY TIMELINE -->
        <div class="card">
            <div class="card-title"><i class="fas fa-stream"></i> Today's Timeline</div>
            <ul class="timeline" id="todayTimeline">
                <li style="color:#94a3b8;font-size:13px;padding:10px 0;">
                    <i class="fas fa-circle-notch fa-spin" style="margin-right:8px;"></i> Loading…
                </li>
            </ul>
        </div>
    </div>

    <!-- ATTENDANCE HISTORY -->
    <div class="card">
        <div class="card-title"><i class="fas fa-history"></i> Attendance History (Last 30 Days)</div>

        <div class="filter-bar">
            <input type="text" id="searchInput" placeholder="Search by date…" oninput="applyFilter()">
            <button class="filter-btn active" data-filter="All"      onclick="setFilter(this)">All</button>
            <button class="filter-btn"         data-filter="Present" onclick="setFilter(this)">Present</button>
            <button class="filter-btn"         data-filter="Late"    onclick="setFilter(this)">Late</button>
            <button class="filter-btn"         data-filter="Absent"  onclick="setFilter(this)">Absent</button>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Check In</th>
                        <th>Check Out</th>
                        <th>Duration</th>
                        <th>Status</th>
                        <th>Remarks</th>
                    </tr>
                </thead>
                <tbody id="historyBody">
                    <tr><td colspan="6" class="empty-state">
                        <i class="fas fa-circle-notch fa-spin"></i>Loading history…
                    </td></tr>
                </tbody>
            </table>
        </div>

        <div class="pagination" id="pagination"></div>
    </div>
</div>

<script>
    const CTX        = '<%= request.getContextPath() %>';
    const STUDENT_ID = '<%= studentId %>';
    const PAGE_SIZE  = 10;

    let allHistory   = [];
    let filtered     = [];
    let currentPage  = 1;
    let activeFilter = 'All';
    let isBusy       = false;

    // ── LIVE CLOCK ──
    function updateClock() {
        const now  = new Date();
        const h    = now.getHours();
        const m    = String(now.getMinutes()).padStart(2,'0');
        const s    = String(now.getSeconds()).padStart(2,'0');
        const ampm = h >= 12 ? 'PM' : 'AM';
        const hh   = String(h % 12 || 12).padStart(2,'0');
        document.getElementById('liveClock').textContent = hh + ':' + m + ':' + s + ' ' + ampm;
    }
    setInterval(updateClock, 1000);
    updateClock();

    // ── LOAD DATA ──
    function loadData() {
        fetch(CTX + '/attendance/history?studentId=' + STUDENT_ID)
            .then(r => r.json())
            .then(data => {
                if (data.error) { showToast(data.error, 'error'); return; }
                updateStats(data.stats);
                updateStatusBanner(data.hasActive, data.todayCount);
                updateTimeline(data.todayCheckIns);
                allHistory = data.history;
                applyFilter();
            })
            .catch(() => showToast('Failed to load attendance data.', 'error'));
    }

    // ── STATS ──
    function updateStats(s) {
        document.getElementById('statPct').textContent     = (s.percentage || 0) + '%';
        document.getElementById('statPresent').textContent = s.presentDays || 0;
        document.getElementById('statLate').textContent    = s.lateDays    || 0;
        document.getElementById('statAbsent').textContent  = s.absentDays  || 0;
    }

    // ── STATUS BANNER ──
    function updateStatusBanner(hasActive, count) {
        document.getElementById('todayCount').textContent = count;

        const pill  = document.getElementById('activePill');
        const state = document.getElementById('currentState');
        const inBtn  = document.getElementById('checkInBtn');
        const outBtn = document.getElementById('checkOutBtn');

        if (hasActive) {
            state.textContent  = 'Currently Checked In';
            pill.textContent   = 'Active';
            pill.className     = 'status-pill active';
            inBtn.disabled     = true;   // prevent double check-in
            outBtn.disabled    = false;
        } else if (count > 0) {
            state.textContent  = 'Checked Out';
            pill.textContent   = 'Inactive';
            pill.className     = 'status-pill inactive';
            inBtn.disabled     = false;  // can check in again
            outBtn.disabled    = true;
        } else {
            state.textContent  = 'Not Started';
            pill.textContent   = 'Inactive';
            pill.className     = 'status-pill inactive';
            inBtn.disabled     = false;
            outBtn.disabled    = true;
        }
    }

    // ── TIMELINE ──
    function updateTimeline(entries) {
        const ul = document.getElementById('todayTimeline');
        if (!entries || entries.length === 0) {
            ul.innerHTML = '<li><div style="color:#94a3b8;font-size:13px;">No activity recorded today.</div></li>';
            return;
        }
        ul.innerHTML = entries.map(e => `
            <li>
                <div class="tl-icon in"><i class="fas fa-arrow-right"></i></div>
                <div>
                    <div class="tl-time">${e.checkIn}</div>
                    <div class="tl-label">Check In · <span class="badge badge-${e.status.toLowerCase()}">${e.status}</span></div>
                    ${e.remarks ? '<div style="font-size:11px;color:#64748b;margin-top:2px;">'+escHtml(e.remarks)+'</div>' : ''}
                </div>
            </li>
            ${e.checkOut && e.checkOut !== '--:--' ? `
            <li>
                <div class="tl-icon out"><i class="fas fa-arrow-left"></i></div>
                <div>
                    <div class="tl-time">${e.checkOut}</div>
                    <div class="tl-label">Check Out</div>
                </div>
            </li>` : ''}
        `).join('');
    }

    // ── FILTER & PAGINATION ──
    function setFilter(btn) {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        activeFilter = btn.dataset.filter;
        currentPage  = 1;
        applyFilter();
    }

    function applyFilter() {
        const search = document.getElementById('searchInput').value.toLowerCase();
        filtered = allHistory.filter(r => {
            const matchFilter = activeFilter === 'All' || r.status === activeFilter;
            const matchSearch = !search || r.date.toLowerCase().includes(search);
            return matchFilter && matchSearch;
        });
        currentPage = 1;
        renderTable();
        renderPagination();
    }

    function renderTable() {
        const tbody  = document.getElementById('historyBody');
        const start  = (currentPage - 1) * PAGE_SIZE;
        const rows   = filtered.slice(start, start + PAGE_SIZE);

        if (rows.length === 0) {
            tbody.innerHTML = `<tr><td colspan="6" class="empty-state">
                <i class="fas fa-calendar-times"></i> No records found.
            </td></tr>`;
            return;
        }

        tbody.innerHTML = rows.map(r => `
            <tr>
                <td style="font-weight:600;">${escHtml(r.date)}</td>
                <td>${escHtml(r.checkIn)}</td>
                <td>${r.checkOut && r.checkOut !== '--:--' ? escHtml(r.checkOut) : '<span style="color:#94a3b8">—</span>'}</td>
                <td>${calcDuration(r.checkIn, r.checkOut)}</td>
                <td><span class="badge badge-${r.status.toLowerCase()}">${escHtml(r.status)}</span></td>
                <td style="color:#64748b;">${r.remarks ? escHtml(r.remarks) : '—'}</td>
            </tr>
        `).join('');
    }

    function renderPagination() {
        const total = Math.ceil(filtered.length / PAGE_SIZE);
        const pg    = document.getElementById('pagination');
        if (total <= 1) { pg.innerHTML = ''; return; }

        let html = `<button class="page-btn" onclick="goPage(${currentPage-1})" ${currentPage===1?'disabled':''}>
                        <i class="fas fa-chevron-left"></i></button>`;
        for (let i = 1; i <= total; i++) {
            if (total > 7 && Math.abs(i - currentPage) > 2 && i !== 1 && i !== total) {
                if (i === currentPage - 3 || i === currentPage + 3) html += '<span style="padding:0 4px;">…</span>';
                continue;
            }
            html += `<button class="page-btn ${i===currentPage?'active':''}" onclick="goPage(${i})">${i}</button>`;
        }
        html += `<button class="page-btn" onclick="goPage(${currentPage+1})" ${currentPage===total?'disabled':''}>
                     <i class="fas fa-chevron-right"></i></button>`;
        pg.innerHTML = html;
    }

    function goPage(p) {
        const total = Math.ceil(filtered.length / PAGE_SIZE);
        if (p < 1 || p > total) return;
        currentPage = p;
        renderTable();
        renderPagination();
    }

    // ── CHECK IN ──
    function doCheckIn() {
        const status  = document.getElementById('statusSelect').value;
        const remarks = document.getElementById('remarksInput').value.trim();

        if (!status) { showToast('Please select a status before checking in.', 'error'); return; }
        if (isBusy)   return;

        setBusy(true, 'checkInBtn');

        const body = new URLSearchParams({ studentId: STUDENT_ID, status, remarks });
        fetch(CTX + '/attendance/checkin', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body.toString()
        })
        .then(r => r.json())
        .then(data => {
            setBusy(false, 'checkInBtn', '<i class="fas fa-sign-in-alt"></i> Check In');
            if (data.success) {
                showToast(data.message, 'success');
                document.getElementById('remarksInput').value = '';
                document.getElementById('statusSelect').value = '';
                loadData();
            } else {
                showToast(data.message || 'Check-in failed.', 'error');
            }
        })
        .catch(() => {
            setBusy(false, 'checkInBtn', '<i class="fas fa-sign-in-alt"></i> Check In');
            showToast('Network error. Please try again.', 'error');
        });
    }

    // ── CHECK OUT ──
    function doCheckOut() {
        if (isBusy) return;
        setBusy(true, 'checkOutBtn');

        fetch(CTX + '/attendance/checkout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'studentId=' + STUDENT_ID
        })
        .then(r => r.json())
        .then(data => {
            setBusy(false, 'checkOutBtn', '<i class="fas fa-sign-out-alt"></i> Check Out');
            if (data.success) {
                showToast(data.message, 'success');
                loadData();
            } else {
                showToast(data.message || 'Check-out failed.', 'error');
            }
        })
        .catch(() => {
            setBusy(false, 'checkOutBtn', '<i class="fas fa-sign-out-alt"></i> Check Out');
            showToast('Network error. Please try again.', 'error');
        });
    }

    // ── HELPERS ──
    function setBusy(busy, btnId, label) {
        isBusy = busy;
        const btn = document.getElementById(btnId);
        if (busy) {
            btn.disabled = true;
            btn.innerHTML = '<span class="spinner"></span>';
        } else {
            btn.disabled = false;
            btn.innerHTML = label;
        }
    }

    function calcDuration(inTime, outTime) {
        if (!outTime || outTime === '--:--') return '<span style="color:#94a3b8">—</span>';
        try {
            const parseTime = t => {
                const [time, ampm] = t.trim().split(' ');
                let [h, m] = time.split(':').map(Number);
                if (ampm === 'PM' && h !== 12) h += 12;
                if (ampm === 'AM' && h === 12) h = 0;
                return h * 60 + m;
            };
            const diff = parseTime(outTime) - parseTime(inTime);
            if (diff <= 0) return '<span style="color:#94a3b8">—</span>';
            const h = Math.floor(diff / 60), m = diff % 60;
            return (h > 0 ? h + 'h ' : '') + m + 'm';
        } catch { return '—'; }
    }

    function escHtml(str) {
        if (!str) return '';
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function showToast(msg, type) {
        const container = document.getElementById('toast-container');
        const div = document.createElement('div');
        const icon = type === 'success' ? 'fa-circle-check' : type === 'error' ? 'fa-circle-xmark' : 'fa-circle-info';
        div.className = 'toast toast-' + type;
        div.innerHTML = `<i class="fas ${icon}"></i><span>${escHtml(msg)}</span>`;
        container.appendChild(div);
        setTimeout(() => {
            div.style.animation = 'slideOut .35s ease forwards';
            setTimeout(() => div.remove(), 350);
        }, 3500);
    }

    // ── INIT ──
    window.onload = function() {
        loadData();
        setInterval(loadData, 30000);
    };
</script>
</body>
</html>
