<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*, java.util.*, java.text.SimpleDateFormat" %>
<%
    List<LaundryRequest> allRequests = (List<LaundryRequest>) request.getAttribute("allRequests");
    List<DamageReport> allDamages = (List<DamageReport>) request.getAttribute("allDamages");

    if (allRequests == null) allRequests = new ArrayList<>();
    if (allDamages == null) allDamages = new ArrayList<>();

    int pendingCount = 0, acceptedCount = 0, completedCount = 0, rejectedCount = 0;
    double totalCollected = 0;

    for(LaundryRequest r : allRequests) {
        if("Pending".equalsIgnoreCase(r.getStatus())) pendingCount++;
        if("Accepted".equalsIgnoreCase(r.getStatus())) acceptedCount++;
        if("Completed".equalsIgnoreCase(r.getStatus())) completedCount++;
        if("Rejected".equalsIgnoreCase(r.getStatus())) rejectedCount++;

        String paymentStatus = r.getPaymentStatus();
        if("Paid".equalsIgnoreCase(paymentStatus)) {
            totalCollected += r.getTotalCost();
        }
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Staff Laundry Dashboard - SafeStay</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; }
        body { background: #f0f2f5; }

        .dashboard { display: flex; min-height: 100vh; }

        .sidebar {
            width: 280px;
            background: linear-gradient(180deg, #1a237e 0%, #0d47a1 100%);
            color: white;
            position: fixed;
            height: 100vh;
            padding: 30px 20px;
        }
        .logo-area { text-align: center; padding-bottom: 30px; border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 30px; }
        .logo { font-size: 28px; font-weight: 700; }
        .logo span { color: #ffd700; }

        .main-content { flex: 1; margin-left: 280px; padding: 30px; }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .stat-info h3 { font-size: 14px; color: #666; margin-bottom: 10px; }
        .stat-info .number { font-size: 28px; font-weight: 700; color: #333; }
        .stat-icon { width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; }
        .total-collected {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
        }
        .total-collected .stat-info .number { color: white; }
        .total-collected .stat-info h3 { color: rgba(255,255,255,0.9); }

        .card {
            background: white;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            overflow: hidden;
        }

        .blue-header {
            background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%);
            padding: 20px 25px;
            color: white;
        }
        .blue-header h2 { margin: 0; display: flex; align-items: center; gap: 10px; }

        .tabs {
            display: flex;
            gap: 10px;
            padding: 0 25px;
            background: white;
            border-bottom: 1px solid #eee;
        }
        .tab {
            padding: 12px 20px;
            cursor: pointer;
            border: none;
            background: none;
            font-size: 14px;
            font-weight: 500;
            color: #666;
        }
        .tab.active { color: #1a237e; border-bottom: 2px solid #1a237e; }
        .tab-content { display: none; padding: 25px; }
        .tab-content.active { display: block; }

        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; vertical-align: top; }
        th { background: #f8f9fa; font-weight: 600; }

        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-accepted { background: #d4edda; color: #155724; }
        .status-completed { background: #cce5ff; color: #004085; }
        .status-rejected { background: #f8d7da; color: #721c24; }

        .payment-paid {
            background: #d4edda;
            color: #155724;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }
        .payment-pending {
            background: #fff3cd;
            color: #856404;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }

        .btn {
            padding: 8px 15px;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            font-weight: 500;
        }
        .btn-accept { background: #27ae60; color: white; }
        .btn-reject { background: #c0392b; color: white; }
        .btn-complete { background: #2980b9; color: white; }
        .btn-sm { padding: 4px 10px; font-size: 12px; margin: 2px; }
        .btn-sm-primary { background: #1a237e; color: white; }
        .btn-outline {
            background: #6c757d;
            color: white;
            padding: 5px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .btn-outline:hover { background: #5a6268; }

        .input-time { padding: 6px; border: 1px solid #ddd; border-radius: 4px; width: 120px; }
        .action-form { display: inline-flex; gap: 5px; align-items: center; flex-wrap: wrap; }

        .damage-photo {
            width: 60px;
            height: 60px;
            object-fit: cover;
            margin: 2px;
            cursor: pointer;
            border-radius: 8px;
            border: 2px solid #ddd;
            transition: all 0.2s;
        }
        .damage-photo:hover {
            transform: scale(1.05);
            border-color: #1a237e;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
        .photo-container {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;
        }
        .no-photo {
            color: #999;
            font-size: 11px;
            font-style: italic;
            background: #f5f5f5;
            padding: 5px 10px;
            border-radius: 5px;
        }
        .badge-na {
            background: #e9ecef;
            color: #6c757d;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            display: inline-block;
        }
        .view-all-btn {
            background: #1a237e;
            color: white;
            border: none;
            padding: 4px 10px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 11px;
        }
        .view-all-btn:hover { background: #0d47a1; }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .modal-content {
            background: white;
            border-radius: 15px;
            width: 90%;
            max-width: 500px;
            padding: 25px;
            max-height: 80vh;
            overflow-y: auto;
        }
        .image-preview-modal {
            max-width: 90vw;
            max-height: 90vh;
            text-align: center;
        }
        .image-preview-modal img {
            max-width: 100%;
            max-height: 80vh;
            border-radius: 10px;
        }
        .image-preview-modal .photo-navigation {
            margin-top: 15px;
            display: flex;
            justify-content: center;
            gap: 10px;
        }

        .chat-messages {
            height: 300px;
            overflow-y: auto;
            border: 1px solid #ddd;
            padding: 10px;
            margin-bottom: 10px;
            background: #f9f9f9;
            border-radius: 8px;
        }
        .message {
            margin-bottom: 10px;
            padding: 8px 12px;
            border-radius: 8px;
            max-width: 80%;
        }
        .message.student { background: #e3f2fd; margin-right: auto; }
        .message.staff { background: #f1f8e9; margin-left: auto; text-align: right; }
        .message .sender { font-weight: bold; font-size: 12px; margin-bottom: 4px; }
        .message .text { font-size: 14px; }
        .message .time { font-size: 10px; color: #888; margin-top: 4px; }

        .empty-state { text-align: center; padding: 40px; color: #888; }
        .urgent-tag { background: #f44336; color: white; padding: 2px 6px; border-radius: 4px; font-size: 10px; margin-left: 5px; }
        .form-group { margin-bottom: 15px; }
        .form-control {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        textarea.form-control {
            resize: vertical;
            min-height: 80px;
        }

        .description-cell {
            max-width: 250px;
            word-wrap: break-word;
        }
    </style>
</head>
<body>
<div class="dashboard">
    <div class="sidebar">
        <div class="logo-area">
            <div class="logo">Safe<span>Stay</span></div>
            <div style="font-size: 12px;">Staff Portal</div>
        </div>
        <div class="nav-item active" style="padding: 12px;"><i class="fas fa-tshirt"></i> Laundry Management</div>
    </div>

    <div class="main-content">
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-info"><h3>Pending</h3><div class="number"><%= pendingCount %></div></div><div class="stat-icon" style="background:#ff9800;"><i class="fas fa-clock"></i></div></div>
            <div class="stat-card"><div class="stat-info"><h3>Accepted</h3><div class="number"><%= acceptedCount %></div></div><div class="stat-icon" style="background:#4caf50;"><i class="fas fa-check"></i></div></div>
            <div class="stat-card"><div class="stat-info"><h3>Completed</h3><div class="number"><%= completedCount %></div></div><div class="stat-icon" style="background:#2196f3;"><i class="fas fa-check-double"></i></div></div>
            <div class="stat-card"><div class="stat-info"><h3>Rejected</h3><div class="number"><%= rejectedCount %></div></div><div class="stat-icon" style="background:#f44336;"><i class="fas fa-times"></i></div></div>
            <div class="stat-card total-collected"><div class="stat-info"><h3>Total Collected</h3><div class="number">Rs. <%= String.format("%,.2f", totalCollected) %></div></div><div class="stat-icon" style="background:rgba(255,255,255,0.2);"><i class="fas fa-rupee-sign"></i></div></div>
        </div>

        <div class="card">
            <div class="blue-header">
                <h2><i class="fas fa-tshirt"></i> Laundry Management</h2>
            </div>
            <div class="tabs">
                <button class="tab active" onclick="showTab('requests')">Laundry Requests</button>
                <button class="tab" onclick="showTab('damages')">Damage Reports</button>
            </div>

            <!-- Requests Tab -->
            <div id="requestsTab" class="tab-content active">
                <div style="overflow-x: auto;">
                    <table class="requests-table">
                        <thead>
                        <tr>
                            <th>Request No</th><th>Student</th><th>Room</th><th>Service</th><th>Total</th><th>Status</th><th>Payment</th><th>Action</th><th>Chat</th>
                        </thead>
                        <tbody>
                        <% for (LaundryRequest r : allRequests) {
                            String statusLower = r.getStatus().toLowerCase();
                            String paymentStatus = r.getPaymentStatus();
                            if(paymentStatus == null) paymentStatus = "Pending";

                            String paymentBadge = "";
                            if("Paid".equalsIgnoreCase(paymentStatus)) {
                                paymentBadge = "<span class='payment-paid'><i class='fas fa-check-circle'></i> Paid</span>";
                            } else if("Pending".equalsIgnoreCase(paymentStatus)) {
                                paymentBadge = "<span class='payment-pending'><i class='fas fa-clock'></i> Pending</span>";
                            } else {
                                paymentBadge = "<span class='badge-na'>" + paymentStatus + "</span>";
                            }
                        %>
                        <tr>
                            <td><strong><%= r.getRequestNo() %></strong></td>
                            <td><%= r.getStudentName() != null ? r.getStudentName() : r.getStudentId() %></td>
                            <td>Floor <%= r.getFloorNo() %>, Room <%= r.getRoomNo() %></td>
                            <td><%= r.getServiceType() %><% if ("Urgent".equals(r.getUrgency())) { %><span class="urgent-tag">URGENT</span><% } %></td>
                            <td>Rs. <%= String.format("%.2f", r.getTotalCost()) %></td>
                            <td><span class="status-badge status-<%= statusLower %>"><%= r.getStatus() %></span></td>
                            <td><%= paymentBadge %></td>
                            <td>
                                <% if ("Pending".equals(r.getStatus())) { %>
                                <form action="<%= request.getContextPath() %>/laundry/staff/dashboard" method="POST" class="action-form">
                                    <input type="hidden" name="requestId" value="<%= r.getId() %>">
                                    <input type="hidden" name="action" value="accept">
                                    <input type="text" name="assignedTime" class="input-time" placeholder="Time (e.g. 10:30 AM)" required>
                                    <button type="submit" class="btn btn-accept">Accept</button>
                                </form>
                                <form action="<%= request.getContextPath() %>/laundry/staff/dashboard" method="POST" class="action-form">
                                    <input type="hidden" name="requestId" value="<%= r.getId() %>">
                                    <input type="hidden" name="action" value="reject">
                                    <input type="text" name="reason" class="input-time" placeholder="Reason" required>
                                    <button type="submit" class="btn btn-reject">Reject</button>
                                </form>
                                <% } else if ("Accepted".equals(r.getStatus())) { %>
                                <form action="<%= request.getContextPath() %>/laundry/staff/dashboard" method="POST">
                                    <input type="hidden" name="requestId" value="<%= r.getId() %>">
                                    <input type="hidden" name="action" value="complete">
                                    <button type="submit" class="btn btn-complete">Mark Completed</button>
                                </form>
                                <% } else { %>
                                <span style="color:#999;">-</span>
                                <% } %>
                            </td>
                            <td>
                                <button class="btn-sm btn-sm-primary" onclick="openChat('<%= r.getRequestNo() %>')">
                                    <i class="fas fa-comment"></i> Chat
                                </button>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Damage Reports Tab - UPDATED VERSION -->
            <div id="damagesTab" class="tab-content">
                <div style="overflow-x: auto;">
                    <table style="width:100%;">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Student</th>
                            <th>Request No</th>
                            <th>Description</th>
                            <th>Photos</th>
                            <th>Status</th>
                            <th>Staff Response</th>
                            <th>Reported Date</th>
                            <th>Action</th>
                        </thead>
                        <tbody>
                        <% if(allDamages == null || allDamages.isEmpty()) { %>
                        <tr>
                            <td colspan="9" style="text-align:center; padding:40px;">
                                <i class="fas fa-image" style="font-size:48px; color:#ccc;"></i>
                                <p>No damage reports found</p>
                            </td>
                        </tr>
                        <% } else {
                            for (DamageReport d : allDamages) {
                                String statusClass = d.getStatus() != null ? d.getStatus().toLowerCase() : "pending";
                                String requestNoDisplay = (d.getRequestNo() != null && !d.getRequestNo().isEmpty() && !"null".equals(d.getRequestNo()))
                                        ? d.getRequestNo() : "<span class='badge-na'>Not related</span>";
                                String staffResponseDisplay = (d.getStaffResponse() != null && !d.getStaffResponse().isEmpty() && !"null".equals(d.getStaffResponse()))
                                        ? d.getStaffResponse() : "<span class='badge-na'>Not responded</span>";

                                // Collect valid photos
                                List<String> validPhotos = new ArrayList<>();
                                if(d.getPhoto1() != null && !d.getPhoto1().isEmpty() && !"null".equals(d.getPhoto1())) validPhotos.add(d.getPhoto1());
                                if(d.getPhoto2() != null && !d.getPhoto2().isEmpty() && !"null".equals(d.getPhoto2())) validPhotos.add(d.getPhoto2());
                                if(d.getPhoto3() != null && !d.getPhoto3().isEmpty() && !"null".equals(d.getPhoto3())) validPhotos.add(d.getPhoto3());
                                if(d.getPhoto4() != null && !d.getPhoto4().isEmpty() && !"null".equals(d.getPhoto4())) validPhotos.add(d.getPhoto4());
                        %>
                        <tr>
                            <td style="vertical-align:middle;"><%= d.getId() %></td>
                            <td style="vertical-align:middle;"><%= d.getStudentName() != null ? d.getStudentName() : d.getStudentId() %></td>
                            <td style="vertical-align:middle;"><%= requestNoDisplay %></td>
                            <td class="description-cell"><%= d.getDescription() != null ? d.getDescription() : "-" %></td>
                            <td style="vertical-align:middle;">
                                <div class="photo-container" id="photos-<%= d.getId() %>">
                                    <% if(validPhotos.isEmpty()) { %>
                                    <span class="no-photo"><i class="fas fa-image"></i> No photos</span>
                                    <% } else {
                                        for(int i = 0; i < validPhotos.size(); i++) {
                                            String photo = validPhotos.get(i);
                                            String encodedPhoto = photo.replace(" ", "%20");
                                            String fullPath = request.getContextPath() + "/" + encodedPhoto;
                                    %>
                                    <img src="<%= fullPath %>"
                                         class="damage-photo"
                                         data-photo-url="<%= fullPath %>"
                                         onclick="viewPhoto('<%= fullPath %>')"
                                         onerror="this.style.display='none';"
                                         title="Photo <%= i+1 %>">
                                    <% } } %>
                                    <% if(validPhotos.size() > 0) { %>
                                    <button class="view-all-btn" onclick="viewAllPhotos(<%= d.getId() %>)">
                                        <i class="fas fa-images"></i> View All (<%= validPhotos.size() %>)
                                    </button>
                                    <% } %>
                                </div>
                            </td>
                            <td style="vertical-align:middle;"><span class="status-badge status-<%= statusClass %>"><%= d.getStatus() != null ? d.getStatus() : "Pending" %></span></td>
                            <td style="vertical-align:middle;"><%= staffResponseDisplay %></td>
                            <td style="vertical-align:middle;"><%= d.getReportedAt() != null ? dateFormat.format(d.getReportedAt()) : "-" %></td>
                            <td style="vertical-align:middle;">
                                <button class="btn btn-sm" onclick="updateDamage(<%= d.getId() %>, '<%= d.getStatus() %>', '<%= (d.getStaffResponse() != null && !"Not responded yet".equals(d.getStaffResponse()) && !"null".equals(d.getStaffResponse())) ? d.getStaffResponse().replace("'","\\'").replace("\n"," ").replace("\r"," ") : "" %>')">
                                    <i class="fas fa-edit"></i> Update
                                </button>
                            </td>
                        </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
</div>

<!-- Image Preview Modal (Single Photo) -->
<div id="imageModal" class="modal" onclick="closeImageModal()">
    <div class="modal-content image-preview-modal" onclick="event.stopPropagation()">
        <img id="previewImage" src="" alt="Preview" style="max-width:100%; max-height:70vh;">
        <button onclick="closeImageModal()" style="margin-top:15px; width:100%;" class="btn btn-reject">Close</button>
    </div>
</div>

<!-- Gallery Modal (Multiple Photos) -->
<div id="galleryModal" class="modal">
    <div class="modal-content image-preview-modal">
        <h3 id="galleryTitle">Damage Photos</h3>
        <img id="galleryImage" src="" alt="Damage photo" style="max-width:100%; max-height:60vh; margin:10px 0;">
        <div class="photo-navigation">
            <button class="btn-outline" onclick="previousPhoto()"><i class="fas fa-chevron-left"></i> Previous</button>
            <span id="photoCounter" style="margin:0 15px;">Photo 1 / 1</span>
            <button class="btn-outline" onclick="nextPhoto()">Next <i class="fas fa-chevron-right"></i></button>
        </div>
        <button onclick="closeGalleryModal()" class="btn btn-reject" style="width:100%; margin-top:15px;">Close</button>
    </div>
</div>

<!-- Damage Update Modal -->
<div id="damageUpdateModal" class="modal">
    <div class="modal-content">
        <h3>Update Damage Report</h3>
        <form action="<%= request.getContextPath() %>/staff/updateDamage" method="POST">
            <input type="hidden" name="damageId" id="damageId">
            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="Pending">Pending</option>
                    <option value="Resolved">Resolved</option>
                </select>
            </div>
            <div class="form-group">
                <label>Staff Response</label>
                <textarea name="staffResponse" rows="3" class="form-control" placeholder="Enter your response..."></textarea>
            </div>
            <button type="submit" class="btn btn-accept">Update</button>
            <button type="button" onclick="closeDamageUpdate()" class="btn btn-reject">Cancel</button>
        </form>
    </div>
</div>

<!-- Chat Modal -->
<div id="chatModal" class="modal">
    <div class="modal-content">
        <h3><i class="fas fa-comments"></i> Chat for Request: <span id="chatRequestNo"></span></h3>
        <div id="chatMessages" class="chat-messages">
            <div style="text-align:center; padding:20px;">Loading messages...</div>
        </div>
        <textarea id="chatMessageInput" rows="2" style="width:100%; padding:10px; margin-bottom:10px; border:1px solid #ddd; border-radius:8px;" placeholder="Type your message..."></textarea>
        <button onclick="sendChatMessage()" class="btn btn-accept" style="width:100%; margin-bottom:10px;">
            <i class="fas fa-paper-plane"></i> Send Message
        </button>
        <button onclick="closeChatModal()" class="btn btn-reject" style="width:100%;">Close</button>
    </div>
</div>

<script>
    let currentChatRequest = null;
    let chatRefreshInterval = null;

    let currentGalleryPhotos = [];
    let currentGalleryIndex = 0;

    function showTab(tab) {
        var tabs = document.querySelectorAll('.tab');
        var contents = document.querySelectorAll('.tab-content');

        for(var i = 0; i < tabs.length; i++) {
            tabs[i].classList.remove('active');
        }
        for(var i = 0; i < contents.length; i++) {
            contents[i].classList.remove('active');
        }

        if(tab === 'requests') {
            tabs[0].classList.add('active');
            document.getElementById('requestsTab').classList.add('active');
        } else {
            tabs[1].classList.add('active');
            document.getElementById('damagesTab').classList.add('active');
        }
    }

    function viewPhoto(photoUrl) {
        var modal = document.getElementById('imageModal');
        var img = document.getElementById('previewImage');
        img.src = photoUrl;
        modal.style.display = 'flex';
    }

    function closeImageModal() {
        document.getElementById('imageModal').style.display = 'none';
    }

    function viewAllPhotos(damageId) {
        const container = document.getElementById('photos-' + damageId);
        const images = container.querySelectorAll('.damage-photo');

        currentGalleryPhotos = [];
        images.forEach(img => {
            let photoUrl = img.getAttribute('data-photo-url');
            if(photoUrl && photoUrl !== '') {
                currentGalleryPhotos.push(photoUrl);
            }
        });

        if(currentGalleryPhotos.length > 0) {
            currentGalleryIndex = 0;
            openGalleryModal();
        }
    }

    function openGalleryModal() {
        const modal = document.getElementById('galleryModal');
        const img = document.getElementById('galleryImage');
        const counter = document.getElementById('photoCounter');

        if(currentGalleryPhotos.length > 0) {
            img.src = currentGalleryPhotos[currentGalleryIndex];
            counter.innerHTML = 'Photo ' + (currentGalleryIndex + 1) + ' / ' + currentGalleryPhotos.length;
            document.getElementById('galleryTitle').innerHTML = 'Damage Photos (' + currentGalleryPhotos.length + ' photos)';
            modal.style.display = 'flex';
        }
    }

    function previousPhoto() {
        if(currentGalleryPhotos.length > 0) {
            currentGalleryIndex = (currentGalleryIndex - 1 + currentGalleryPhotos.length) % currentGalleryPhotos.length;
            document.getElementById('galleryImage').src = currentGalleryPhotos[currentGalleryIndex];
            document.getElementById('photoCounter').innerHTML = 'Photo ' + (currentGalleryIndex + 1) + ' / ' + currentGalleryPhotos.length;
        }
    }

    function nextPhoto() {
        if(currentGalleryPhotos.length > 0) {
            currentGalleryIndex = (currentGalleryIndex + 1) % currentGalleryPhotos.length;
            document.getElementById('galleryImage').src = currentGalleryPhotos[currentGalleryIndex];
            document.getElementById('photoCounter').innerHTML = 'Photo ' + (currentGalleryIndex + 1) + ' / ' + currentGalleryPhotos.length;
        }
    }

    function closeGalleryModal() {
        document.getElementById('galleryModal').style.display = 'none';
        currentGalleryPhotos = [];
        currentGalleryIndex = 0;
    }

    function updateDamage(id, status, response) {
        document.getElementById('damageId').value = id;
        var statusSelect = document.querySelector('#damageUpdateModal select[name="status"]');
        var responseText = document.querySelector('#damageUpdateModal textarea[name="staffResponse"]');
        if(statusSelect) statusSelect.value = status;
        if(responseText) responseText.value = response;
        document.getElementById('damageUpdateModal').style.display = 'flex';
    }

    function closeDamageUpdate() {
        document.getElementById('damageUpdateModal').style.display = 'none';
    }

    function openChat(requestNo) {
        currentChatRequest = requestNo;
        document.getElementById('chatRequestNo').innerText = requestNo;
        document.getElementById('chatModal').style.display = 'flex';
        loadChatMessages();
        if(chatRefreshInterval) clearInterval(chatRefreshInterval);
        chatRefreshInterval = setInterval(loadChatMessages, 5000);
    }

    function loadChatMessages() {
        if(!currentChatRequest) return;

        fetch('<%= request.getContextPath() %>/getMessages?requestNo=' + encodeURIComponent(currentChatRequest))
            .then(function(response) { return response.json(); })
            .then(function(messages) {
                var container = document.getElementById('chatMessages');
                container.innerHTML = '';

                if(!messages || messages.length === 0) {
                    container.innerHTML = '<div style="text-align:center; padding:20px;">No messages yet. Start the conversation!</div>';
                    return;
                }

                for(var i = 0; i < messages.length; i++) {
                    var msg = messages[i];
                    var div = document.createElement('div');
                    var isStudent = msg.senderRole === 'Student';
                    div.className = 'message ' + (isStudent ? 'student' : 'staff');
                    var senderName = isStudent ? 'Student' : 'You';
                    var sentDate = new Date(msg.sentAt);
                    div.innerHTML = '<div class="sender">' + senderName + '</div>' +
                        '<div class="text">' + escapeHtml(msg.message) + '</div>' +
                        '<div class="time">' + sentDate.toLocaleString() + '</div>';
                    container.appendChild(div);
                }
                container.scrollTop = container.scrollHeight;
            })
            .catch(function(error) {
                console.error('Error loading messages:', error);
                var container = document.getElementById('chatMessages');
                container.innerHTML = '<div style="text-align:center; color:#dc3545; padding:20px;">Error loading messages</div>';
            });
    }

    function sendChatMessage() {
        var message = document.getElementById('chatMessageInput').value.trim();
        if(!message || !currentChatRequest) {
            alert('Please enter a message');
            return;
        }

        fetch('<%= request.getContextPath() %>/sendMessage', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'requestNo=' + encodeURIComponent(currentChatRequest) + '&message=' + encodeURIComponent(message)
        })
            .then(function() {
                document.getElementById('chatMessageInput').value = '';
                loadChatMessages();
            })
            .catch(function(error) {
                console.error('Error sending message:', error);
                alert('Failed to send message');
            });
    }

    function closeChatModal() {
        document.getElementById('chatModal').style.display = 'none';
        if(chatRefreshInterval) {
            clearInterval(chatRefreshInterval);
            chatRefreshInterval = null;
        }
        currentChatRequest = null;
    }

    function escapeHtml(text) {
        if(!text) return '';
        return text.replace(/[&<>]/g, function(m) {
            if(m === '&') return '&amp;';
            if(m === '<') return '&lt;';
            if(m === '>') return '&gt;';
            return m;
        });
    }

    window.onclick = function(event) {
        var imageModal = document.getElementById('imageModal');
        var galleryModal = document.getElementById('galleryModal');
        var damageModal = document.getElementById('damageUpdateModal');
        var chatModal = document.getElementById('chatModal');

        if (event.target == imageModal) {
            imageModal.style.display = 'none';
        }
        if (event.target == galleryModal) {
            galleryModal.style.display = 'none';
        }
        if (event.target == damageModal) {
            damageModal.style.display = 'none';
        }
        if (event.target == chatModal) {
            closeChatModal();
        }
    }
</script>
</body>
</html>