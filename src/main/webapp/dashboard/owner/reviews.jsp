<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    List<Map<String, Object>> reviews =
            (List<Map<String, Object>>) request.getAttribute("allReviews");

    int totalReviews = 0, pendingCount = 0;
    double totalRating = 0, avgRating = 0;
    int[] starCounts = new int[6]; // index 1-5
    int[] monthlyCounts = new int[6];

    String[] monthNames = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
    String[] monthLabels = new String[6];
    for (int i = 5; i >= 0; i--) {
        Calendar mc = Calendar.getInstance();
        mc.add(Calendar.MONTH, -i);
        monthLabels[5-i] = monthNames[mc.get(Calendar.MONTH)];
    }

    if (reviews != null && !reviews.isEmpty()) {
        totalReviews = reviews.size();
        for (Map<String, Object> r : reviews) {
            int rv = r.get("rating") != null ? (int)r.get("rating") : 0;
            totalRating += rv;
            if (rv >= 1 && rv <= 5) starCounts[rv]++;
            if ("Pending".equals(r.get("status"))) pendingCount++;

            if (r.get("date") != null) {
                Calendar rc = Calendar.getInstance();
                rc.setTime((java.util.Date) r.get("date"));
                for (int i = 0; i < 6; i++) {
                    Calendar mc = Calendar.getInstance();
                    mc.add(Calendar.MONTH, -(5-i));
                    if (rc.get(Calendar.MONTH)==mc.get(Calendar.MONTH)
                            && rc.get(Calendar.YEAR)==mc.get(Calendar.YEAR)) {
                        monthlyCounts[i]++;
                        break;
                    }
                }
            }
        }
        avgRating = totalReviews > 0 ? totalRating / totalReviews : 0;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student Reviews & Ratings</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root { --primary:#4f46e5; --success:#10b981; --danger:#ef4444; --warning:#f59e0b; }
        * { box-sizing:border-box; margin:0; padding:0; }
        body { font-family:'Segoe UI',sans-serif; background:#f8fafc; padding:24px; color:#1e293b; }

        /* ── Header ── */
        .page-hdr { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; }
        .page-hdr h2 { font-size:22px; font-weight:700; display:flex; align-items:center; gap:10px; }
        .btn-refresh { background:#e2e8f0; border:none; padding:10px 18px; border-radius:8px;
            cursor:pointer; font-weight:600; display:flex; align-items:center; gap:6px; }
        .btn-refresh:hover { background:#cbd5e1; }

        /* ── Alert ── */
        .alert { padding:13px 20px; border-radius:10px; margin-bottom:20px; font-weight:500; font-size:14px; }
        .alert-ok  { background:#dcfce7; color:#166534; }
        .alert-err { background:#fee2e2; color:#991b1b; }

        /* ── Stats ── */
        .stats-row { display:grid; grid-template-columns:repeat(3,1fr); gap:16px; margin-bottom:24px; }
        .stat-card { background:white; border-radius:14px; padding:20px;
            display:flex; align-items:center; gap:16px;
            border:1px solid #f1f5f9; box-shadow:0 2px 8px rgba(0,0,0,0.04); }
        .stat-icon { width:52px; height:52px; border-radius:12px;
            display:flex; align-items:center; justify-content:center; font-size:22px; }
        .ic-blue   { background:#e0e7ff; color:#4338ca; }
        .ic-yellow { background:#fef3c7; color:#92400e; }
        .ic-green  { background:#dcfce7; color:#166534; }
        .stat-val  { font-size:28px; font-weight:700; }
        .stat-lbl  { font-size:13px; color:#64748b; margin-top:3px; }

        /* ── Charts Row ── */
        .charts-row { display:grid; grid-template-columns:1fr 1fr 1fr; gap:20px; margin-bottom:24px; }
        .chart-card { background:white; border-radius:14px; padding:22px;
            border:1px solid #f1f5f9; box-shadow:0 2px 8px rgba(0,0,0,0.04); }
        .chart-card h4 { font-size:14px; font-weight:700; margin-bottom:14px; color:#1e293b; }
        .chart-wrap { position:relative; height:180px; }

        /* Distribution bars */
        .dist-row { display:flex; align-items:center; gap:8px; margin-bottom:10px; }
        .dist-lbl  { width:48px; font-size:12px; color:#64748b; }
        .dist-bg   { flex:1; background:#f1f5f9; height:10px; border-radius:10px; overflow:hidden; }
        .dist-fill { height:100%; border-radius:10px; background:var(--warning); }
        .dist-cnt  { width:20px; font-size:12px; font-weight:700; text-align:right; }

        /* ── Table ── */
        .tbl-card { background:white; border-radius:14px;
            border:1px solid #f1f5f9; box-shadow:0 2px 8px rgba(0,0,0,0.04); overflow:hidden; }
        .tbl-card h4 { font-size:14px; font-weight:700; padding:18px 22px;
            border-bottom:1px solid #f1f5f9; }
        table { width:100%; border-collapse:collapse; }
        thead th { background:#f8fafc; padding:12px 14px; text-align:left;
            font-size:11px; font-weight:700; color:#64748b;
            text-transform:uppercase; letter-spacing:.05em; }
        tbody td { padding:14px; border-bottom:1px solid #f1f5f9; vertical-align:top; font-size:13px; }
        tbody tr:last-child td { border-bottom:none; }
        tbody tr:hover { background:#fafbff; }

        .s-name { font-weight:600; color:#1e293b; }
        .s-date { font-size:11px; color:#94a3b8; margin-top:3px; }
        .cat-tag { display:inline-block; background:#e0e7ff; color:#4338ca;
            font-size:10px; font-weight:700; padding:2px 8px;
            border-radius:20px; margin-top:4px; }

        .star-row { display:flex; gap:2px; margin-bottom:6px; }
        .star-row i { font-size:13px; }
        .on { color:var(--warning); } .off { color:#d1d5db; }

        .cat-grid { display:grid; grid-template-columns:1fr 1fr; gap:4px; margin-top:6px; }
        .cat-line { font-size:11px; color:#64748b; display:flex; align-items:center; gap:4px; }
        .mini-stars { display:flex; gap:1px; }
        .mini-stars i { font-size:9px; }

        .cmt-txt { color:#334155; font-size:13px; line-height:1.5; }
        .reply-existing { background:#f1f5f9; border-left:3px solid var(--primary);
            padding:8px 12px; border-radius:0 8px 8px 0;
            font-size:11px; color:#475569; margin-top:8px; }
        .reply-form { background:#f8fafc; border:1px solid #e2e8f0;
            border-radius:10px; padding:12px; margin-top:8px; display:none; }
        .reply-ta { width:100%; border:1px solid #cbd5e1; border-radius:8px;
            padding:8px; font-family:inherit; font-size:12px;
            resize:vertical; margin-bottom:6px; }
        .reply-btns { display:flex; gap:6px; justify-content:flex-end; }

        .badge { padding:4px 10px; border-radius:20px; font-size:10px; font-weight:700; text-transform:uppercase; }
        .b-pending  { background:#fef3c7; color:#92400e; }
        .b-approved { background:#dcfce7; color:#166534; }

        .act-col { display:flex; flex-direction:column; gap:5px; }
        .btn-act { border:none; padding:7px 10px; border-radius:8px; cursor:pointer;
            font-size:11px; font-weight:600; display:flex; align-items:center;
            gap:5px; transition:.15s; width:100%; }
        .btn-approve { background:#dcfce7; color:#166534; }
        .btn-approve:hover { background:#bbf7d0; }
        .btn-reply   { background:#e0e7ff; color:#4338ca; }
        .btn-reply:hover { background:#c7d2fe; }
        .btn-delete  { background:#fee2e2; color:#991b1b; }
        .btn-delete:hover { background:#fecaca; }
        .btn-send    { background:var(--primary); color:white; border:none;
            padding:7px 14px; border-radius:7px; cursor:pointer; font-size:12px; font-weight:600; }
        .btn-cancel-sm { background:#e2e8f0; color:#1e293b; border:none;
            padding:7px 12px; border-radius:7px; cursor:pointer; font-size:12px; font-weight:600; }

        .empty-row td { text-align:center; padding:50px; color:#94a3b8; }

        /* Modal */
        .modal-overlay { display:none; position:fixed; inset:0;
            background:rgba(0,0,0,.45); z-index:1000;
            align-items:center; justify-content:center; }
        .modal-overlay.open { display:flex; }
        .modal-box { background:white; border-radius:16px; padding:34px;
            max-width:360px; width:90%; text-align:center; }
        .modal-icon { font-size:46px; color:var(--danger); margin-bottom:14px; }
        .modal-box h3 { font-size:17px; margin-bottom:8px; }
        .modal-box p  { color:#64748b; font-size:13px; margin-bottom:22px; }
        .modal-btns   { display:flex; gap:10px; justify-content:center; }
        .btn-mc { padding:10px 22px; border-radius:8px; border:1px solid #e2e8f0;
            background:white; cursor:pointer; font-weight:600; }
        .btn-md { padding:10px 22px; border-radius:8px; border:none;
            background:var(--danger); color:white; cursor:pointer; font-weight:600; }
    </style>
</head>
<body>

<!-- Header -->
<div class="page-hdr">
    <h2><i class="fas fa-star" style="color:var(--warning);"></i> Student Reviews &amp; Ratings</h2>
    <button class="btn-refresh" onclick="location.reload()">
        <i class="fas fa-sync-alt"></i> Refresh
    </button>
</div>

<!-- Alerts -->
<% if ("1".equals(request.getParameter("success"))) { %>
<div class="alert alert-ok"><i class="fas fa-check-circle"></i> Action completed successfully!</div>
<% } else if (request.getParameter("error") != null) { %>
<div class="alert alert-err"><i class="fas fa-exclamation-circle"></i> Something went wrong.</div>
<% } %>

<!-- Stats -->
<div class="stats-row">
    <div class="stat-card">
        <div class="stat-icon ic-blue"><i class="fas fa-comments"></i></div>
        <div><div class="stat-val"><%= totalReviews %></div><div class="stat-lbl">Total Reviews</div></div>
    </div>
    <div class="stat-card">
        <div class="stat-icon ic-yellow"><i class="fas fa-clock"></i></div>
        <div><div class="stat-val"><%= pendingCount %></div><div class="stat-lbl">Pending Approval</div></div>
    </div>
    <div class="stat-card">
        <div class="stat-icon ic-green"><i class="fas fa-star"></i></div>
        <div><div class="stat-val"><%= String.format("%.1f", avgRating) %></div><div class="stat-lbl">Average Rating</div></div>
    </div>
</div>

<!-- Charts — 3 columns: Trend + Distribution + Donut -->
<div class="charts-row">

    <!-- Monthly Trend Line -->
    <div class="chart-card">
        <h4>Monthly Review Trend</h4>
        <div class="chart-wrap"><canvas id="trendChart"></canvas></div>
    </div>

    <!-- Rating Distribution Bars -->
    <div class="chart-card">
        <h4>Rating Distribution</h4>
        <% for (int i=5;i>=1;i--) {
            int pct = totalReviews>0 ? starCounts[i]*100/totalReviews : 0; %>
        <div class="dist-row">
            <span class="dist-lbl"><%= i %> Stars</span>
            <div class="dist-bg"><div class="dist-fill" style="width:<%= pct %>%"></div></div>
            <span class="dist-cnt"><%= starCounts[i] %></span>
        </div>
        <% } %>
    </div>

    <!-- Rating Breakdown Donut Chart -->
    <div class="chart-card">
        <h4>Title</h4>
        <div class="chart-wrap"><canvas id="donutChart"></canvas></div>
    </div>

</div>

<!-- Reviews Table -->
<div class="tbl-card">
    <h4><i class="fas fa-list"></i> All Reviews</h4>
    <table>
        <thead>
        <tr>
            <th>Student &amp; Category</th>
            <th>Ratings Details</th>
            <th>Feedback &amp; Reply</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <% if (reviews == null || reviews.isEmpty()) { %>
        <tr class="empty-row">
            <td colspan="5"><i class="fas fa-star-half-alt"></i><br>No reviews yet.</td>
        </tr>
        <% } else { for (Map<String,Object> r : reviews) {
            int stars  = r.get("rating") != null ? (int)r.get("rating") : 0;
            int cr     = r.get("cleanlinessRating") != null ? (int)r.get("cleanlinessRating") : 0;
            int wr     = r.get("wifiRating")        != null ? (int)r.get("wifiRating")        : 0;
            int sr     = r.get("staffRating")       != null ? (int)r.get("staffRating")       : 0;
            int fr     = r.get("foodRating")        != null ? (int)r.get("foodRating")        : 0;
            String cat    = r.get("category")  != null ? r.get("category").toString()  : "";
            String status = r.get("status")    != null ? r.get("status").toString()    : "Pending";
            String date   = r.get("date")      != null ? r.get("date").toString().substring(0,16) : "";
            String rep    = r.get("ownerReply")!= null ? r.get("ownerReply").toString() : "";
        %>
        <tr>
            <!-- Student & Category -->
            <td>
                <div class="s-name"><%= r.get("name") %></div>
                <div class="s-date"><%= date %></div>
                <% if (!cat.isEmpty()) { %>
                <span class="cat-tag"><%= cat %></span>
                <% } %>
            </td>

            <!-- Ratings -->
            <td>
                <div class="star-row">
                    <% for(int i=1;i<=5;i++){%><i class="fas fa-star <%=i<=stars?"on":"off"%>"></i><%}%>
                </div>
                <div class="cat-grid">
                    <div class="cat-line">
                        <i class="fas fa-utensils" style="color:#f59e0b;"></i> Food:
                        <div class="mini-stars"><%for(int i=1;i<=5;i++){%><i class="fas fa-star <%=i<=fr?"on":"off"%>"></i><%}%></div>
                    </div>
                    <div class="cat-line">
                        <i class="fas fa-broom" style="color:#10b981;"></i> Clean:
                        <div class="mini-stars"><%for(int i=1;i<=5;i++){%><i class="fas fa-star <%=i<=cr?"on":"off"%>"></i><%}%></div>
                    </div>
                    <div class="cat-line">
                        <i class="fas fa-wifi" style="color:#3b82f6;"></i> WiFi:
                        <div class="mini-stars"><%for(int i=1;i<=5;i++){%><i class="fas fa-star <%=i<=wr?"on":"off"%>"></i><%}%></div>
                    </div>
                    <div class="cat-line">
                        <i class="fas fa-user-tie" style="color:#8b5cf6;"></i> Staff:
                        <div class="mini-stars"><%for(int i=1;i<=5;i++){%><i class="fas fa-star <%=i<=sr?"on":"off"%>"></i><%}%></div>
                    </div>
                </div>
            </td>

            <!-- Feedback & Reply -->
            <td>
                <div class="cmt-txt"><%= r.get("comment") != null ? r.get("comment") : "—" %></div>
                <% if (!rep.isEmpty()) { %>
                <div class="reply-existing">
                    <strong><i class="fas fa-reply"></i> Your Reply:</strong><br><%= rep %>
                </div>
                <% } %>
                <div class="reply-form" id="rf-<%= r.get("id") %>">
                    <form action="reviews" method="POST">
                        <input type="hidden" name="action" value="addReply">
                        <input type="hidden" name="reviewId" value="<%= r.get("id") %>">
                        <textarea class="reply-ta" name="ownerReply" rows="2"
                                  placeholder="Write reply..."><%= rep %></textarea>
                        <div class="reply-btns">
                            <button type="button" class="btn-cancel-sm"
                                    onclick="toggleReply(<%= r.get("id") %>)">Cancel</button>
                            <button type="submit" class="btn-send">
                                <i class="fas fa-paper-plane"></i> Post
                            </button>
                        </div>
                    </form>
                </div>
            </td>

            <!-- Status -->
            <td>
                <span class="badge <%= "Pending".equals(status) ? "b-pending":"b-approved" %>">
                    <%= status %>
                </span>
            </td>

            <!-- Actions -->
            <td>
                <div class="act-col">
                    <% if ("Pending".equals(status)) { %>
                    <form action="reviews" method="POST" style="margin:0">
                        <input type="hidden" name="action" value="approve">
                        <input type="hidden" name="reviewId" value="<%= r.get("id") %>">
                        <button type="submit" class="btn-act btn-approve">
                            <i class="fas fa-check"></i> Approve
                        </button>
                    </form>
                    <% } %>
                    <button class="btn-act btn-reply" onclick="toggleReply(<%= r.get("id") %>)">
                        <i class="fas fa-comment-dots"></i> Reply
                    </button>
                    <form action="reviews" method="POST" style="margin:0"
                          onsubmit="confirmDel(event,this)">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="reviewId" value="<%= r.get("id") %>">
                        <button type="submit" class="btn-act btn-delete">
                            <i class="fas fa-trash"></i> Delete
                        </button>
                    </form>
                </div>
            </td>
        </tr>
        <% } } %>
        </tbody>
    </table>
</div>

<!-- Delete Modal -->
<div class="modal-overlay" id="delModal">
    <div class="modal-box">
        <div class="modal-icon"><i class="fas fa-exclamation-triangle"></i></div>
        <h3>Delete this review?</h3>
        <p>This cannot be undone.</p>
        <div class="modal-btns">
            <button class="btn-mc" onclick="closeModal()">Cancel</button>
            <button class="btn-md" id="confirmDelBtn">Delete</button>
        </div>
    </div>
</div>

<script>
    // Reply toggle
    function toggleReply(id) {
        var box = document.getElementById('rf-' + id);
        box.style.display = box.style.display === 'block' ? 'none' : 'block';
    }

    // Delete modal
    var pendingForm = null;
    function confirmDel(e, form) {
        e.preventDefault();
        pendingForm = form;
        document.getElementById('delModal').classList.add('open');
    }
    function closeModal() {
        document.getElementById('delModal').classList.remove('open');
    }
    document.getElementById('confirmDelBtn').onclick = function() {
        if (pendingForm) pendingForm.submit();
    };

    // ── Monthly Trend Line Chart ──
    new Chart(document.getElementById('trendChart').getContext('2d'), {
        type: 'line',
        data: {
            labels: [<% for(int i=0;i<6;i++){%>'<%= monthLabels[i] %>'<%= i<5?",":""%><% }%>],
            datasets: [{
                data: [<% for(int i=0;i<6;i++){%><%= monthlyCounts[i] %><%= i<5?",":""%><% }%>],
                borderColor: '#4f46e5',
                backgroundColor: 'rgba(79,70,229,.1)',
                tension: 0.4, fill: true,
                pointBackgroundColor: '#4f46e5', pointRadius: 5
            }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, ticks:{stepSize:1}, grid:{color:'#f1f5f9'} },
                x: { grid:{display:false} }
            }
        }
    });

    // ── Rating Breakdown Donut Chart ──
    new Chart(document.getElementById('donutChart').getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: ['5 Stars', '4 Stars', '3 Stars', '2 Stars', '1 Star'],
            datasets: [{
                data: [
                    <%= starCounts[5] %>,
                    <%= starCounts[4] %>,
                    <%= starCounts[3] %>,
                    <%= starCounts[2] %>,
                    <%= starCounts[1] %>
                ],
                backgroundColor: ['#10b981','#3b82f6','#f59e0b','#f97316','#ef4444'],
                borderWidth: 2,
                borderColor: '#ffffff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { font: { size: 11 }, padding: 10, boxWidth: 12 }
                }
            },
            cutout: '60%'
        }
    });
</script>
</body>
</html>
