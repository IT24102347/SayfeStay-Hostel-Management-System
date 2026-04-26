<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*" %>
<%@ page import="org.example.dao.*" %>
<%
    User user = (User) session.getAttribute("user");
    Room room = (Room) request.getAttribute("room");
    if (user == null || room == null) {
        response.sendRedirect("rooms");
        return;
    }

    // Get student details
    UserDAO userDAO = new UserDAO();
    // Assume you have a method to get student details
    String studentEmail = user.getUserId() + "@safestay.com"; // Placeholder
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Book Room <%= room.getRoomNumber() %> - SafeStay</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Fraunces:ital,wght@0,400;0,600;1,400&display=swap" rel="stylesheet">
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
            font-family: 'Inter', sans-serif;
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
        .btn-logout:hover { border-color: var(--danger); color: var(--danger); }

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
        .breadcrumb-bar a { color: var(--text-muted); text-decoration: none; transition: color 0.2s; }
        .breadcrumb-bar a:hover { color: var(--accent); }
        .breadcrumb-bar .sep { opacity: 0.4; }
        .breadcrumb-bar .current { color: var(--text); font-weight: 500; }

        /* ── PAGE TITLE ── */
        .page-title {
            font-family: 'Fraunces', serif;
            font-size: 1.75rem;
            font-weight: 600;
            color: var(--text);
            letter-spacing: -0.5px;
            margin-bottom: 0.3rem;
        }
        .page-subtitle {
            color: var(--text-muted);
            font-size: 0.88rem;
            margin-bottom: 2rem;
        }

        /* ── LAYOUT ── */
        .booking-layout {
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 1.75rem;
            align-items: start;
        }
        @media (max-width: 900px) {
            .booking-layout { grid-template-columns: 1fr; }
        }

        /* ── FORM CARD ── */
        .form-card {
            background: var(--surface);
            border: none;
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: 0 4px 24px rgba(0,0,0,0.05);
            animation: fadeUp 0.4s ease both;
        }

        /* ── SECTION BLOCKS ── */
        .form-section {
            padding: 1.75rem 2rem;
            border-bottom: 1px solid var(--border);
            background: var(--surface);
        }
        .form-section:last-child { border-bottom: none; }

        .section-title {
            font-family: 'Fraunces', serif;
            font-size: 1.15rem;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        .section-title i {
            color: var(--accent);
            font-size: 1rem;
            width: 24px;
            text-align: center;
        }
        .section-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: var(--accent-dim);
            color: var(--accent);
            font-size: 0.75rem;
            font-weight: 700;
            font-family: 'Inter', sans-serif;
            flex-shrink: 0;
        }

        /* ── FORM CONTROLS ── */
        .form-label {
            font-size: 0.8rem;
            font-weight: 500;
            color: var(--text);
            margin-bottom: 0.5rem;
            display: block;
        }
        .form-control, .form-select {
            background: #f8f9fc;
            border: 1px solid #e1e3ea;
            border-radius: var(--radius-sm);
            color: var(--text);
            font-family: 'Inter', sans-serif;
            font-size: 0.95rem;
            padding: 0.7rem 1rem;
            transition: all 0.2s;
            width: 100%;
        }
        .form-control:focus, .form-select:focus {
            background: var(--surface);
            border-color: var(--accent);
            box-shadow: 0 0 0 4px var(--accent-glow);
            outline: none;
        }
        .form-control::placeholder { color: var(--text-muted); opacity: 0.5; }
        .form-select option { background: var(--surface); color: var(--text); }

        .field-group {
            margin-bottom: 1.1rem;
        }
        .field-row {
            display: grid;
            gap: 1rem;
        }
        .field-row.cols-2 { grid-template-columns: 1fr 1fr; }
        .field-row.cols-3 { grid-template-columns: 1fr 1fr 1fr; }
        .field-row.cols-2-1 { grid-template-columns: 2fr 1fr; }
        .field-row.cols-1-1-1 { grid-template-columns: 1fr 1fr 1fr; }
        @media (max-width: 640px) {
            .field-row.cols-2,
            .field-row.cols-3,
            .field-row.cols-2-1,
            .field-row.cols-1-1-1 { grid-template-columns: 1fr; }
        }

        textarea.form-control { resize: vertical; min-height: 90px; }

        /* ── FORM ACTIONS ── */
        .form-actions {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 1rem;
            padding: 1.5rem 2rem;
            background: #fafbfc;
            border-top: 1px solid var(--border);
            flex-wrap: wrap;
        }
        .btn-cancel {
            background: transparent;
            border: 2px solid transparent;
            color: var(--text-muted);
            border-radius: 30px;
            font-size: 0.95rem;
            font-weight: 600;
            padding: 0.65rem 1.6rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s;
            font-family: 'Inter', sans-serif;
        }
        .btn-cancel:hover { background: rgba(0,0,0,0.05); color: var(--text); }
        .btn-submit {
            background: var(--accent);
            border: 2px solid var(--accent);
            color: #fff;
            border-radius: 30px;
            font-size: 0.95rem;
            font-weight: 600;
            padding: 0.65rem 2rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            cursor: pointer;
            font-family: 'Inter', sans-serif;
            box-shadow: 0 6px 16px var(--accent-glow);
        }
        .btn-submit:hover {
            background: #155bb5;
            border-color: #155bb5;
            box-shadow: 0 8px 24px rgba(29,111,216,0.3);
            transform: translateY(-2px);
        }

        /* ── SIDEBAR ── */
        .sidebar { display: flex; flex-direction: column; gap: 1.25rem; }

        .sidebar-card {
            background: var(--surface);
            border: none;
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: 0 4px 24px rgba(0,0,0,0.05);
            animation: fadeUp 0.45s ease 0.08s both;
            position: sticky;
            top: 5rem;
        }
        .sidebar-card-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 0.75rem;
            background: var(--surface);
        }
        .sidebar-card-header h6 {
            font-family: 'Fraunces', serif;
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text);
            margin: 0;
        }
        .sidebar-card-header i { color: var(--accent); font-size: 0.85rem; }

        /* Room Summary */
        .room-summary-body { padding: 1.25rem; }
        .room-summary-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.55rem 0;
            border-bottom: 1px solid var(--border);
            font-size: 0.87rem;
        }
        .room-summary-item:last-child { border-bottom: none; padding-bottom: 0; }
        .summary-key { color: var(--text-muted); font-weight: 400; }
        .summary-val { color: var(--text); font-weight: 600; }
        .summary-val.accent { color: var(--accent); font-family: 'Fraunces', serif; font-size: 1rem; }

        /* Payment Summary */
        .payment-summary-body { padding: 1.25rem; }
        .payment-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.5rem 0;
            font-size: 0.87rem;
            border-bottom: 1px solid var(--border);
        }
        .payment-row:last-child { border-bottom: none; padding-bottom: 0; }
        .payment-row.total {
            padding-top: 0.75rem;
            margin-top: 0.25rem;
        }
        .payment-row.total .pay-key {
            font-family: 'Fraunces', serif;
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text);
        }
        .payment-row.total .pay-val {
            font-family: 'Fraunces', serif;
            font-size: 1.45rem;
            font-weight: 600;
            color: var(--accent);
        }
        .pay-key { color: var(--text-muted); }
        .pay-val { color: var(--text); font-weight: 600; }

        .empty-summary {
            padding: 2rem 1.25rem;
            text-align: center;
            color: var(--text-muted);
            font-size: 0.95rem;
            background: #fafafa;
        }
        .empty-summary i { display: block; font-size: 2rem; margin-bottom: 1rem; opacity: 0.2; color: var(--accent); }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── SCROLLBAR ── */
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: var(--bg); }
        ::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }
    </style>

    <script>
        function calculateTotal() {
            var months = document.getElementById('durationMonths').value;
            var monthlyRent = <%= room.getPriceMonthly() %>;
            var keyMoney = monthlyRent * 2; // 2 months as key money

            if (months > 0) {
                document.getElementById('keyMoney').value = keyMoney.toFixed(2);
                document.getElementById('monthlyRent').value = monthlyRent.toFixed(2);

                var total = keyMoney + (monthlyRent * months);
                document.getElementById('totalAmount').value = total.toFixed(2);

                document.getElementById('summary').style.display = 'block';
                document.getElementById('emptyPayment').style.display = 'none';
                document.getElementById('summaryKeyMoney').textContent = 'Rs. ' + keyMoney.toFixed(2);
                document.getElementById('summaryMonthly').textContent = 'Rs. ' + monthlyRent.toFixed(2);
                document.getElementById('summaryMonths').textContent = months;
                document.getElementById('summaryTotal').textContent = 'Rs. ' + total.toFixed(2);
            }
        }

        function calculateDuration() {
            var startDate = new Date(document.getElementById('startDate').value);
            var endDate = new Date(document.getElementById('endDate').value);

            if (startDate && endDate && endDate > startDate) {
                var months = (endDate.getFullYear() - startDate.getFullYear()) * 12 +
                            (endDate.getMonth() - startDate.getMonth());
                document.getElementById('durationMonths').value = months;
                calculateTotal();
            }
        }
    </script>
</head>
<body>

    <!-- NAVBAR -->
    <nav class="navbar navbar-expand-lg">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/dashboard/student/index.jsp">Safe<span>Stay</span></a>
            <div class="d-flex align-items-center gap-2 ms-auto">
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
            <a href="<%= request.getContextPath() %>/rooms/details?id=<%= room.getId() %>">Room <%= room.getRoomNumber() %></a>
            <span class="sep"><i class="fas fa-chevron-right" style="font-size:0.65rem;"></i></span>
            <span class="current">Book Room</span>
        </div>

        <div class="page-title">Booking Request</div>
        <div class="page-subtitle">Room <%= room.getRoomNumber() %> &nbsp;·&nbsp; Complete the form below to submit your booking request</div>

        <div class="booking-layout">

            <!-- FORM COLUMN -->
            <div>
                <form action="<%= request.getContextPath() %>/booking/request" method="post">
                    <input type="hidden" name="roomId" value="<%= room.getId() %>">
                    <input type="hidden" name="keyMoney" id="keyMoney">
                    <input type="hidden" name="monthlyRent" id="monthlyRent">
                    <input type="hidden" name="totalAmount" id="totalAmount">

                    <div class="form-card">

                        <!-- Personal Information -->
                        <div class="form-section">
                            <div class="section-title">
                                <span class="section-badge">1</span>
                                Personal Information
                            </div>
                            <div class="field-row cols-2-1" style="grid-template-columns: 2fr 1fr 1fr;">
                                <div class="field-group">
                                    <label class="form-label">Full Name *</label>
                                    <input type="text" name="studentName" class="form-control"
                                           value="<%= user.getFullName() %>" required>
                                </div>
                                <div class="field-group">
                                    <label class="form-label">Age *</label>
                                    <input type="number" name="studentAge" class="form-control"
                                           min="16" max="100" placeholder="e.g. 20" required>
                                </div>
                                <div class="field-group">
                                    <label class="form-label">Phone *</label>
                                    <input type="tel" name="studentPhone" class="form-control"
                                           pattern="[0-9]{10}" placeholder="0712345678" required>
                                </div>
                            </div>
                            <div class="field-group" style="margin-bottom:0;">
                                <label class="form-label">Email *</label>
                                <input type="email" name="studentEmail" class="form-control"
                                       value="<%= studentEmail %>" required>
                            </div>
                        </div>

                        <!-- Guardian Information -->
                        <div class="form-section">
                            <div class="section-title">
                                <span class="section-badge">2</span>
                                Guardian Information
                            </div>
                            <div class="field-row" style="grid-template-columns: 1fr 1fr 1fr;">
                                <div class="field-group" style="margin-bottom:0;">
                                    <label class="form-label">Guardian Name *</label>
                                    <input type="text" name="guardianName" class="form-control" required>
                                </div>
                                <div class="field-group" style="margin-bottom:0;">
                                    <label class="form-label">Guardian Phone *</label>
                                    <input type="tel" name="guardianPhone" class="form-control"
                                           pattern="[0-9]{10}" placeholder="0712345678" required>
                                </div>
                                <div class="field-group" style="margin-bottom:0;">
                                    <label class="form-label">Relationship *</label>
                                    <select name="guardianRelationship" class="form-select" required>
                                        <option value="Parent">Parent</option>
                                        <option value="Guardian">Guardian</option>
                                        <option value="Sibling">Sibling</option>
                                        <option value="Other">Other</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Booking Duration -->
                        <div class="form-section">
                            <div class="section-title">
                                <span class="section-badge">3</span>
                                Booking Duration
                            </div>
                            <div class="field-row" style="grid-template-columns: 1fr 1fr 1fr;">
                                <div class="field-group" style="margin-bottom:0;">
                                    <label class="form-label">Start Date *</label>
                                    <input type="date" name="startDate" id="startDate" class="form-control"
                                           onchange="calculateDuration()" required>
                                </div>
                                <div class="field-group" style="margin-bottom:0;">
                                    <label class="form-label">End Date *</label>
                                    <input type="date" name="endDate" id="endDate" class="form-control"
                                           onchange="calculateDuration()" required>
                                </div>
                                <div class="field-group" style="margin-bottom:0;">
                                    <label class="form-label">Duration (Months) *</label>
                                    <input type="number" name="durationMonths" id="durationMonths"
                                           class="form-control" min="1" placeholder="Auto-calculated"
                                           onchange="calculateTotal()" required>
                                </div>
                            </div>
                        </div>

                        <!-- Payment Information -->
                        <div class="form-section">
                            <div class="section-title">
                                <span class="section-badge">4</span>
                                Payment Information
                            </div>
                            <div class="field-group" style="margin-bottom:0;">
                                <label class="form-label">Payment Method *</label>
                                <select name="paymentMethod" class="form-select" required>
                                    <option value="">Select Payment Method</option>
                                    <option value="Bank Transfer">Bank Transfer</option>
                                    <option value="Online Transfer">Online Transfer</option>
                                </select>
                            </div>
                        </div>

                        <!-- Special Requests -->
                        <div class="form-section">
                            <div class="section-title">
                                <span class="section-badge">5</span>
                                Special Requests
                            </div>
                            <div class="field-group" style="margin-bottom:0;">
                                <label class="form-label">Additional Notes <span style="opacity:0.5;font-weight:400;text-transform:none;letter-spacing:0;">(Optional)</span></label>
                                <textarea name="specialRequests" class="form-control" rows="3"
                                          placeholder="Any special requirements or requests..."></textarea>
                            </div>
                        </div>

                        <!-- Actions -->
                        <div class="form-actions">
                            <a href="<%= request.getContextPath() %>/rooms/details?id=<%= room.getId() %>"
                               class="btn-cancel">
                                <i class="fas fa-times"></i> Cancel
                            </a>
                            <button type="submit" class="btn-submit">
                                <i class="fas fa-paper-plane"></i> Submit Booking Request
                            </button>
                        </div>

                    </div><!-- /.form-card -->
                </form>
            </div>

            <!-- SIDEBAR -->
            <div class="sidebar">

                <!-- Room Summary -->
                <div class="sidebar-card">
                    <div class="sidebar-card-header">
                        <i class="fas fa-building"></i>
                        <h6>Room Summary</h6>
                    </div>
                    <div class="room-summary-body">
                        <div class="room-summary-item">
                            <span class="summary-key">Room</span>
                            <span class="summary-val"><%= room.getRoomNumber() %></span>
                        </div>
                        <div class="room-summary-item">
                            <span class="summary-key">Floor</span>
                            <span class="summary-val"><%= room.getFloorNumber() %></span>
                        </div>
                        <div class="room-summary-item">
                            <span class="summary-key">Type</span>
                            <span class="summary-val"><%= room.getRoomType() %></span>
                        </div>
                        <div class="room-summary-item">
                            <span class="summary-key">Monthly Rent</span>
                            <span class="summary-val accent"><%= room.getFormattedPrice() %></span>
                        </div>
                    </div>
                </div>

                <!-- Payment Summary -->
                <div class="sidebar-card">
                    <div class="sidebar-card-header">
                        <i class="fas fa-receipt"></i>
                        <h6>Payment Summary</h6>
                    </div>

                    <div id="emptyPayment" class="empty-summary">
                        <i class="fas fa-calculator"></i>
                        Select dates to calculate your total
                    </div>

                    <div id="summary" style="display:none;">
                        <div class="payment-summary-body">
                            <div class="payment-row">
                                <span class="pay-key">Key Money</span>
                                <span class="pay-val" id="summaryKeyMoney"></span>
                            </div>
                            <div class="payment-row">
                                <span class="pay-key">Monthly Rent</span>
                                <span class="pay-val" id="summaryMonthly"></span>
                            </div>
                            <div class="payment-row">
                                <span class="pay-key">Duration</span>
                                <span class="pay-val"><span id="summaryMonths"></span> month(s)</span>
                            </div>
                            <div class="payment-row total">
                                <span class="pay-key">Total Amount</span>
                                <span class="pay-val" id="summaryTotal"></span>
                            </div>
                        </div>
                    </div>
                </div>

            </div><!-- /.sidebar -->
        </div><!-- /.booking-layout -->
    </div><!-- /.main-container -->

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
