<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
  // 1. මුලින්ම Data ලබාගන්න (සර්ව්ලට් එකෙන් එවන ලිස්ට් එක)
  List<Map<String, Object>> reviews = (List<Map<String, Object>>) request.getAttribute("allReviews");

  // 2. Variables ටික මුලින්ම හදාගන්න (Stats ගණනය කිරීම)
  int totalReviews = 0;
  int pendingCount = 0;
  double totalRating = 0;
  double avgRating = 0;
  int[] starCounts = new int[6]; // 1-5 දක්වා counts තබා ගැනීමට

  if (reviews != null && !reviews.isEmpty()) {
    totalReviews = reviews.size();
    for (Map<String, Object> r : reviews) {
      // Rating එක Number එකක් විදිහට ගන්න
      Object ratingObj = r.get("rating");
      int rVal = (ratingObj instanceof Integer) ? (int)ratingObj : Integer.parseInt(ratingObj.toString());

      totalRating += rVal;

      // Rating Distribution සඳහා ගණනය කිරීම
      if(rVal >= 1 && rVal <= 5) starCounts[rVal]++;

      if ("Pending".equals(r.get("status"))) {
        pendingCount++;
      }
    }
    avgRating = totalRating / totalReviews;
  }
%>
<!DOCTYPE html>
<html>
<head>
  <title>Manage Reviews - Owner</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    :root { --primary: #4f46e5; --success: #10b981; --danger: #ef4444; --warning: #f59e0b; }
    body { font-family: 'Inter', sans-serif; background: #f8fafc; padding: 20px; }
    .review-container { max-width: 1200px; margin: auto; background: white; padding: 30px; border-radius: 15px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }

    .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; border-bottom: 2px solid #f1f5f9; padding-bottom: 15px; }
    .review-table { width: 100%; border-collapse: collapse; }
    .review-table th, .review-table td { padding: 15px; border-bottom: 1px solid #e2e8f0; text-align: left; vertical-align: top; }

    .star-active { color: #fbbf24; }
    .badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 600; text-transform: uppercase; }
    .pending { background: #fef3c7; color: #92400e; }
    .approved { background: #dcfce7; color: #166534; }
    .deleted { background: #fee2e2; color: #991b1b; }

    .btn-group { display: flex; gap: 8px; }
    .btn-action { border: none; padding: 10px; border-radius: 8px; cursor: pointer; transition: 0.3s; color: white; display: flex; align-items: center; justify-content: center; }
    .btn-approve { background: var(--success); }
    .btn-reply { background: var(--primary); }
    .btn-delete { background: var(--danger); }
    .btn-action:hover { opacity: 0.8; transform: translateY(-2px); }

    .reply-section { background: #f1f5f9; padding: 15px; border-radius: 10px; margin-top: 10px; display: none; border: 1px solid #e2e8f0; }
    textarea { width: 100%; border-radius: 8px; border: 1px solid #cbd5e1; padding: 10px; font-family: inherit; margin-bottom: 10px; resize: vertical; }
    .btn-send { background: var(--primary); color: white; border: none; padding: 8px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; }

    .existing-reply { font-size: 13px; color: #475569; background: #f8fafc; padding: 10px; border-radius: 8px; margin-top: 8px; border-left: 3px solid var(--primary); }

    /* Stats Cards Styling */
    .stats-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
    .stat-card { background: white; padding: 20px; border-radius: 15px; display: flex; align-items: center; box-shadow: 0 4px 6px rgba(0,0,0,0.02); border: 1px solid #f1f5f9; }
    .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 20px; margin-right: 15px; }
    .stat-details h3 { margin: 0; font-size: 24px; color: #1e293b; }
    .stat-details p { margin: 0; font-size: 14px; color: #64748b; }
    .bg-blue { background: #e0e7ff; color: #4338ca; }
    .bg-yellow { background: #fef3c7; color: #92400e; }
    .bg-green { background: #dcfce7; color: #166534; }

    /* New Distribution & Modal Styling */
    .rating-distribution { background: white; padding: 25px; border-radius: 15px; border: 1px solid #f1f5f9; }
    .modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:1000; align-items:center; justify-content:center; backdrop-filter: blur(2px); }
  </style>
</head>
<body>

<div class="review-container">
  <div class="header">
    <div>
      <h2><i class="fas fa-star" style="color: var(--warning);"></i> Student Reviews & Ratings</h2>
      <p style="color: #64748b; font-size: 14px; margin-top: 5px;">Manage feedback and respond to student concerns.</p>
    </div>
    <button onclick="location.reload()" class="btn-send" style="background: #e2e8f0; color: #1e293b;"><i class="fas fa-sync"></i> Refresh</button>
  </div>

  <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-bottom: 30px;">
    <div>
      <div class="stats-container" style="grid-template-columns: 1fr 1fr 1fr; gap: 15px; margin-bottom: 20px;">
        <div class="stat-card">
          <div class="stat-icon bg-blue"><i class="fas fa-comments"></i></div>
          <div class="stat-details"><h3><%= totalReviews %></h3><p>Total</p></div>
        </div>
        <div class="stat-card">
          <div class="stat-icon bg-yellow"><i class="fas fa-clock"></i></div>
          <div class="stat-details"><h3><%= pendingCount %></h3><p>Pending</p></div>
        </div>
        <div class="stat-card">
          <div class="stat-icon bg-green"><i class="fas fa-star"></i></div>
          <div class="stat-details"><h3><%= String.format("%.1f", avgRating) %></h3><p>Avg Rating</p></div>
        </div>
      </div>

      <div class="stat-card" style="height: 200px; display: block;">
        <h4 style="margin: 0 0 10px 0; font-size: 14px; color: #1e293b;">Monthly Review Trend</h4>
        <canvas id="reviewChart"></canvas>
      </div>
    </div>

    <div class="rating-distribution">
      <h4 style="margin-top: 0; color: #1e293b; font-size: 16px;">Rating Distribution</h4>
      <% for(int i=5; i>=1; i--) {
        int percentage = (totalReviews > 0) ? (starCounts[i] * 100 / totalReviews) : 0;
      %>
      <div style="display: flex; align-items: center; margin-bottom: 12px; gap: 10px;">
        <span style="width: 50px; font-size: 12px; color: #64748b;"><%= i %> Stars</span>
        <div style="flex: 1; background: #f1f5f9; height: 8px; border-radius: 10px; overflow: hidden;">
          <div style="width: <%= percentage %>%; background: var(--warning); height: 100%; border-radius: 10px;"></div>
        </div>
        <span style="width: 25px; font-size: 12px; color: #1e293b; font-weight: 600;"><%= starCounts[i] %></span>
      </div>
      <% } %>
    </div>
  </div>

  <% if(request.getParameter("success") != null) { %>
  <div style="background: #dcfce7; color: #166534; padding: 15px; border-radius: 10px; margin-bottom: 20px; text-align: center;">
    Action completed successfully!
  </div>
  <% } %>

  <table class="review-table">
    <thead>
    <tr>
      <th style="width: 150px;">Student</th>
      <th style="width: 120px;">Rating</th>
      <th>Feedback & Replies</th>
      <th style="width: 100px;">Status</th>
      <th style="width: 150px;">Actions</th>
    </tr>
    </thead>
    <tbody>
    <%
      if (reviews == null || reviews.isEmpty()) {
    %>
    <tr><td colspan="5" style="text-align: center; padding: 40px; color: #94a3b8;">No reviews found.</td></tr>
    <%
    } else {
      for (Map<String, Object> r : reviews) {
    %>
    <tr>
      <td><strong><%= r.get("name") %></strong><br><small style="color: #94a3b8;"><%= r.get("created_at") %></small></td>
      <td>
        <%
          int stars = Integer.parseInt(r.get("rating").toString());
          for(int i=1; i<=5; i++) {
        %>
        <i class="fas fa-star <%= i <= stars ? "star-active" : "" %>" style="font-size: 12px;"></i>
        <% } %>
      </td>
      <td>
        <div style="color: #334155; font-size: 14px;"><%= r.get("comment") %></div>
        <% if (r.get("ownerReply") != null && !r.get("ownerReply").toString().isEmpty()) { %>
        <div class="existing-reply">
          <strong><i class="fas fa-reply fa-flip-horizontal"></i> Your Reply:</strong><br>
          <%= r.get("ownerReply") %>
        </div>
        <% } %>
        <div class="reply-section" id="replyBox-<%= r.get("id") %>">
          <form action="reviews" method="POST">
            <input type="hidden" name="action" value="addReply">
            <input type="hidden" name="reviewId" value="<%= r.get("id") %>">
            <textarea name="ownerReply" rows="3" placeholder="Write your response..."></textarea>
            <div style="text-align: right;">
              <button type="button" class="btn-send" style="background: #94a3b8;" onclick="toggleReply(<%= r.get("id") %>)">Cancel</button>
              <button type="submit" class="btn-send">Post Reply</button>
            </div>
          </form>
        </div>
      </td>
      <td>
        <span class="badge <%= r.get("status").toString().toLowerCase() %>"><%= r.get("status") %></span>
      </td>
      <td>
        <div class="btn-group">
          <% if ("Pending".equals(r.get("status"))) { %>
          <form action="reviews" method="POST" style="margin:0;">
            <input type="hidden" name="action" value="approve">
            <input type="hidden" name="reviewId" value="<%= r.get("id") %>">
            <button type="submit" class="btn-action btn-approve" title="Approve"><i class="fas fa-check"></i></button>
          </form>
          <% } %>
          <button class="btn-action btn-reply" title="Reply" onclick="toggleReply(<%= r.get("id") %>)"><i class="fas fa-comment-dots"></i></button>
          <form action="reviews" method="POST" style="margin:0;" onsubmit="confirmDelete(event, this)">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="reviewId" value="<%= r.get("id") %>">
            <button type="submit" class="btn-action btn-delete" title="Delete"><i class="fas fa-trash"></i></button>
          </form>
        </div>
      </td>
    </tr>
    <%
        }
      }
    %>
    </tbody>
  </table>
</div>

<div id="deleteModal" class="modal-overlay">
  <div style="background:white; padding:30px; border-radius:15px; max-width:400px; text-align:center; box-shadow:0 20px 25px -5px rgba(0,0,0,0.1);">
    <i class="fas fa-exclamation-triangle" style="font-size: 50px; color: var(--danger); margin-bottom: 20px;"></i>
    <h3 style="margin:0;">Are you sure?</h3>
    <p style="color: #64748b; margin-top: 10px;">This action cannot be undone. This review will be permanently deleted.</p>
    <div style="display:flex; gap:10px; justify-content:center; margin-top:25px;">
      <button onclick="closeDeleteModal()" style="padding:10px 20px; border-radius:8px; border:1px solid #e2e8f0; cursor:pointer; background:white; font-weight:600;">Cancel</button>
      <button id="confirmDeleteBtn" style="padding:10px 20px; border-radius:8px; border:none; background:var(--danger); color:white; cursor:pointer; font-weight:600;">Delete Now</button>
    </div>
  </div>
</div>

<script>
  // --- Basic UI Toggle ---
  function toggleReply(id) {
    const box = document.getElementById('replyBox-' + id);
    box.style.display = (box.style.display === 'block') ? 'none' : 'block';
  }

  // --- Chart.js Configuration ---
  const ctx = document.getElementById('reviewChart').getContext('2d');
  new Chart(ctx, {
    type: 'line',
    data: {
      labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
      datasets: [{
        label: 'Monthly Reviews',
        data: [3, 7, 5, 9, <%= totalReviews %>],
        borderColor: '#4f46e5',
        tension: 0.4,
        fill: true,
        backgroundColor: 'rgba(79, 70, 229, 0.1)'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        y: { beginAtZero: true, ticks: { display: false }, grid: { display: false } },
        x: { grid: { display: false } }
      }
    }
  });

  // --- Custom Delete Confirmation Logic ---
  let currentForm = null;

  function confirmDelete(event, form) {
    event.preventDefault();
    currentForm = form;
    document.getElementById('deleteModal').style.display = 'flex';
  }

  function closeDeleteModal() {
    document.getElementById('deleteModal').style.display = 'none';
  }

  document.getElementById('confirmDeleteBtn').onclick = function() {
    if(currentForm) currentForm.submit();
  };
</script>

</body>
</html>