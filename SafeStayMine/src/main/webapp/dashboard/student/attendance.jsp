<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*, java.util.*, java.text.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"Student".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = user.getFullName() != null ? user.getFullName() : "Student";
    String studentId = user.getUserId();
    SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance System · SafeStay</title>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background: #f8fafc;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .header {
            background: white;
            border-radius: 20px;
            padding: 20px 30px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            font-size: 24px;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .header h1 i {
            color: #4f46e5;
        }

        .back-btn {
            background: #f1f5f9;
            color: #0f172a;
            padding: 10px 20px;
            border-radius: 40px;
            text-decoration: none;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .back-btn:hover {
            background: #e2e8f0;
        }

        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
        }

        .card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }

        .card-title {
            font-size: 18px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .status-card {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            border-radius: 16px;
            padding: 20px;
            color: white;
            margin-bottom: 20px;
        }

        .status-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .status-badge {
            background: rgba(255,255,255,0.2);
            padding: 5px 15px;
            border-radius: 40px;
            font-size: 13px;
        }

        .btn {
            padding: 12px 20px;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            justify-content: center;
        }

        .btn-primary {
            background: #4f46e5;
            color: white;
        }

        .btn-primary:hover {
            background: #6366f1;
        }

        .btn-success {
            background: #10b981;
            color: white;
        }

        .btn-warning {
            background: #f59e0b;
            color: white;
        }

        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .stats-card {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            border-radius: 16px;
            padding: 25px;
            color: white;
            margin-bottom: 25px;
        }

        .percentage {
            font-size: 48px;
            font-weight: 800;
            margin-bottom: 10px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 20px;
        }

        .stat-item {
            background: rgba(255,255,255,0.1);
            border-radius: 12px;
            padding: 15px;
            text-align: center;
        }

        .stat-value {
            font-size: 24px;
            font-weight: 700;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            padding: 12px 10px;
            color: #64748b;
            font-weight: 600;
            font-size: 13px;
            border-bottom: 2px solid #f1f5f9;
        }

        td {
            padding: 12px 10px;
            border-bottom: 1px solid #f1f5f9;
        }

        .badge {
            padding: 4px 12px;
            border-radius: 40px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }

        .badge-present {
            background: #d4edda;
            color: #155724;
        }

        .badge-late {
            background: #fff3cd;
            color: #856404;
        }

        .badge-absent {
            background: #f8d7da;
            color: #721c24;
        }

        .loading {
            text-align: center;
            padding: 40px;
            color: #64748b;
        }

        .loading i {
            font-size: 32px;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        .alert {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 25px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: slideIn 0.3s;
            z-index: 1000;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }

        @keyframes slideIn {
            from { transform: translateX(100%); }
            to { transform: translateX(0); }
        }

        @media (max-width: 768px) {
            .grid {
                grid-template-columns: 1fr;
            }

            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <!-- Header -->
    <div class="header">
        <h1>
            <i class="fas fa-clock"></i>
            Attendance System
        </h1>
        <a href="<%= request.getContextPath() %>/dashboard/student/" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>

    <!-- Main Grid -->
    <div class="grid">
        <!-- Left Column -->
        <div>
            <div class="card">
                <div class="card-title">
                    <i class="fas fa-qrcode" style="color: #4f46e5;"></i>
                    QR Scanner
                </div>

                <!-- Today's Status -->
                <div class="status-card" id="todayCard">
                    <div class="status-row">
                        <span>Today's Status</span>
                        <span class="status-badge" id="statusBadge">Loading...</span>
                    </div>

                    <div style="margin: 15px 0;">
                        <strong>Total Check-ins: <span id="todayCount">0</span></strong>
                    </div>

                    <div style="display: flex; gap: 15px; margin-top: 20px;">
                        <button class="btn btn-success" onclick="manualCheckIn()" id="checkInBtn" style="flex:1;">
                            <i class="fas fa-sign-in-alt"></i> Check In
                        </button>
                        <button class="btn btn-warning" onclick="manualCheckOut()" id="checkOutBtn" style="flex:1;">
                            <i class="fas fa-sign-out-alt"></i> Check Out
                        </button>
                    </div>
                </div>

                <!-- Manual Form -->
                <div style="margin-top: 20px;">
                    <div style="margin-bottom: 15px;">
                        <select id="statusSelect" style="width:100%; padding:12px; border:1px solid #e2e8f0; border-radius:12px;">
                            <option value="Present">Present</option>
                            <option value="Late">Late</option>
                            <option value="Absent">Absent</option>
                        </select>
                    </div>
                    <div style="margin-bottom: 15px;">
                        <input type="text" id="remarksInput" style="width:100%; padding:12px; border:1px solid #e2e8f0; border-radius:12px;" placeholder="Remarks (optional)">
                    </div>
                    <button class="btn btn-primary" onclick="submitManualCheckIn()" style="width:100%;">
                        <i class="fas fa-check"></i> Submit
                    </button>
                </div>
            </div>
        </div>

        <!-- Right Column -->
        <div>
            <!-- Stats -->
            <div class="stats-card" id="statsCard">
                <div class="loading">
                    <i class="fas fa-spinner"></i>
                    <p>Loading statistics...</p>
                </div>
            </div>

            <!-- History -->
            <div class="card">
                <div class="card-title">
                    <i class="fas fa-history" style="color: #4f46e5;"></i>
                    Recent Attendance
                </div>
                <div id="historyTable">
                    <div class="loading">
                        <i class="fas fa-spinner"></i>
                        <p>Loading history...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function loadData() {
        fetch('<%= request.getContextPath() %>/attendance/history?studentId=<%= studentId %>')
            .then(response => response.json())
            .then(data => {
                updateUI(data);
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    function updateUI(data) {
        // Update stats
        const stats = data.stats;
        document.getElementById('statsCard').innerHTML = `
                <div class="percentage">${stats.percentage}%</div>
                <div>Last 30 days</div>
                <div class="stats-grid">
                    <div class="stat-item">
                        <div class="stat-value">${stats.presentDays}</div>
                        <div>Present</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${stats.lateDays}</div>
                        <div>Late</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${stats.absentDays}</div>
                        <div>Absent</div>
                    </div>
                </div>
                <div style="margin-top:15px;">Total Days: ${stats.totalDays}</div>
            `;

        // Update today
        document.getElementById('statusBadge').textContent = data.hasActive ? 'Active' : 'Inactive';
        document.getElementById('todayCount').textContent = data.todayCount;
        document.getElementById('checkOutBtn').disabled = !data.hasActive;

        // Update history
        let historyHtml = '<table><tr><th>Date</th><th>Check In</th><th>Check Out</th><th>Status</th></tr>';

        if (data.history.length === 0) {
            historyHtml += '<tr><td colspan="4" style="text-align:center; padding:30px;">No records</td></tr>';
        } else {
            data.history.slice(0, 5).forEach(record => {
                historyHtml += `
                        <tr>
                            <td>${record.date}</td>
                            <td>${record.checkIn}</td>
                            <td>${record.checkOut}</td>
                            <td><span class="badge badge-${record.status.toLowerCase()}">${record.status}</span></td>
                        </tr>
                    `;
            });
        }
        historyHtml += '</table>';
        document.getElementById('historyTable').innerHTML = historyHtml;
    }

    function manualCheckIn() {
        const status = prompt('Select status (Present/Late/Absent):', 'Present');
        if (status) {
            const remarks = prompt('Remarks (optional):', '');
            submitCheckIn(status, remarks);
        }
    }

    function manualCheckOut() {
        if (confirm('Check out now?')) {
            fetch('<%= request.getContextPath() %>/attendance/checkout', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'studentId=<%= studentId %>'
            })
                .then(response => response.json())
                .then(data => {
                    alert(data.message);
                    if (data.success) loadData();
                });
        }
    }

    function submitManualCheckIn() {
        const status = document.getElementById('statusSelect').value;
        const remarks = document.getElementById('remarksInput').value;
        submitCheckIn(status, remarks);
    }

    function submitCheckIn(status, remarks) {
        const formData = new URLSearchParams();
        formData.append('studentId', '<%= studentId %>');
        formData.append('status', status);
        formData.append('remarks', remarks || '');

        fetch('<%= request.getContextPath() %>/attendance/checkin', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
            .then(response => response.json())
            .then(data => {
                alert(data.message);
                if (data.success) {
                    document.getElementById('remarksInput').value = '';
                    loadData();
                }
            });
    }

    window.onload = function() {
        loadData();
        setInterval(loadData, 30000);
    };
</script>
</body>
</html>