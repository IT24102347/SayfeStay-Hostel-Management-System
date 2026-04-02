<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.User" %>
<%
    // Session check
    User user = (User) session.getAttribute("user");
    if (user == null || !user.getRole().equalsIgnoreCase("Student")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Mock data - replace with actual DAO calls
    String fullName = user.getFullName() != null ? user.getFullName() : "Student";
    String studentId = user.getUserId();
    String roomNumber = "Room 101";
    int attendance = 92;
    String dueAmount = "15,000";
    int mealsRemaining = 7;
    String laundryStatus = "Ready";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard · SafeStay</title>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background: #f1f5f9;
            min-height: 100vh;
        }

        /* Student Dashboard Styles */
        .dashboard {
            max-width: 1400px;
            margin: 0 auto;
            padding: 30px;
        }

        /* Header */
        .header {
            background: white;
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .greeting h1 {
            font-size: 28px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 8px;
        }

        .greeting p {
            color: #64748b;
            font-size: 16px;
        }

        .date-badge {
            background: #f8fafc;
            padding: 12px 24px;
            border-radius: 40px;
            font-weight: 500;
            color: #0f172a;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 25px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
            transition: all 0.3s;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 15px;
        }

        .stat-value {
            font-size: 28px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #64748b;
            font-size: 14px;
            margin-bottom: 15px;
        }

        .progress-bar {
            width: 100%;
            height: 6px;
            background: #e2e8f0;
            border-radius: 3px;
            overflow: hidden;
            margin-bottom: 10px;
        }

        .progress {
            height: 100%;
            background: #10b981;
            border-radius: 3px;
        }

        .stat-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
        }

        .btn-action {
            background: none;
            border: none;
            color: #6366f1;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        /* Quick Actions */
        .section-title {
            font-size: 20px;
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .quick-actions {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 15px;
            margin-bottom: 30px;
        }

        .quick-action {
            background: white;
            border-radius: 16px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            border: 1px solid #e2e8f0;
        }

        .quick-action:hover {
            border-color: #6366f1;
            transform: translateY(-3px);
            box-shadow: 0 10px 15px -3px rgba(99,102,241,0.1);
        }

        .quick-action i {
            font-size: 28px;
            color: #6366f1;
            margin-bottom: 10px;
        }

        .quick-action span {
            font-size: 14px;
            font-weight: 500;
            color: #0f172a;
        }

        /* Dashboard Grid */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 25px;
            margin-bottom: 30px;
        }

        .card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .card-header h3 {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 18px;
            font-weight: 600;
            color: #0f172a;
        }

        .view-all {
            color: #6366f1;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
        }

        /* Schedule List */
        .schedule-item {
            display: flex;
            align-items: center;
            padding: 15px;
            background: #f8fafc;
            border-radius: 12px;
            margin-bottom: 10px;
        }

        .time {
            min-width: 80px;
            font-weight: 600;
            color: #6366f1;
        }

        .event {
            flex: 1;
        }

        .event h4 {
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .event p {
            font-size: 13px;
            color: #64748b;
        }

        .status {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .status.completed {
            background: #d4edda;
            color: #155724;
        }

        .status.ongoing {
            background: #cce5ff;
            color: #004085;
        }

        .status.pending {
            background: #fff3cd;
            color: #856404;
        }

        /* Notifications */
        .notification-item {
            display: flex;
            gap: 15px;
            padding: 15px;
            background: #f8fafc;
            border-radius: 12px;
            margin-bottom: 10px;
            border-left: 4px solid transparent;
        }

        .notification-item.warning {
            border-left-color: #f59e0b;
        }

        .notification-icon {
            font-size: 20px;
        }

        .notification-content h4 {
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .notification-content p {
            font-size: 13px;
            color: #64748b;
            margin-bottom: 4px;
        }

        .notification-content .time {
            font-size: 11px;
            color: #94a3b8;
        }

        /* Logout Button */
        .logout-btn {
            background: #ef4444;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 40px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .logout-btn:hover {
            background: #dc2626;
            transform: translateY(-2px);
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .quick-actions {
                grid-template-columns: repeat(3, 1fr);
            }

            .dashboard-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .dashboard {
                padding: 15px;
            }

            .header {
                flex-direction: column;
                text-align: center;
                gap: 15px;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .quick-actions {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
<div class="dashboard">
    <!-- Header -->
    <div class="header">
        <div class="greeting">
            <h1>Welcome back, <%= fullName.split(" ")[0] %>! 👋</h1>
            <p>Here's what's happening at your hostel today</p>
        </div>
        <div style="display: flex; align-items: center; gap: 15px;">
            <div class="date-badge">
                <i class="far fa-calendar-alt"></i>
                <%= new java.text.SimpleDateFormat("EEEE, MMMM d, yyyy").format(new java.util.Date()) %>
            </div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(16,185,129,0.1); color: #10b981;">
                <i class="fas fa-clipboard-check"></i>
            </div>
            <div class="stat-value"><%= attendance %>%</div>
            <div class="stat-label">Attendance Rate</div>
            <div class="progress-bar">
                <div class="progress" style="width: <%= attendance %>%"></div>
            </div>
            <div class="stat-footer">
                <span style="color: #64748b; font-size: 13px;">Present: 23/25 days</span>
                <button class="btn-action" onclick="location.href='attendance.jsp'">
                    Details <i class="fas fa-arrow-right"></i>
                </button>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(245,158,11,0.1); color: #f59e0b;">
                <i class="fas fa-credit-card"></i>
            </div>
            <div class="stat-value">Rs. <%= dueAmount %></div>
            <div class="stat-label">Due Amount</div>
            <div style="font-size: 13px; color: #64748b; margin: 10px 0;">
                Due by Jan 5, 2024
            </div>
            <div class="stat-footer">
                <span style="color: #64748b; font-size: 13px;">Pending</span>
                <button class="btn-action" onclick="location.href='payments.jsp'">
                    Pay Now <i class="fas fa-arrow-right"></i>
                </button>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(59,130,246,0.1); color: #3b82f6;">
                <i class="fas fa-utensils"></i>
            </div>
            <div class="stat-value"><%= mealsRemaining %></div>
            <div class="stat-label">Meals Remaining</div>
            <div style="font-size: 13px; color: #64748b; margin: 10px 0;">
                This week
            </div>
            <div class="stat-footer">
                <span style="color: #64748b; font-size: 13px;">14/21 meals</span>
                <button class="btn-action" onclick="location.href='meals.jsp'">
                    Book <i class="fas fa-arrow-right"></i>
                </button>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon" style="background: rgba(139,92,246,0.1); color: #8b5cf6;">
                <i class="fas fa-tshirt"></i>
            </div>
            <div class="stat-value"><%= laundryStatus %></div>
            <div class="stat-label">Laundry Status</div>
            <div style="font-size: 13px; color: #64748b; margin: 10px 0;">
                2 items pending
            </div>
            <div class="stat-footer">
                <span style="color: #64748b; font-size: 13px;">Ready for pickup</span>
                <button class="btn-action" onclick="location.href='laundry.jsp'">
                    Schedule <i class="fas fa-arrow-right"></i>
                </button>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <h2 class="section-title">
        <i class="fas fa-bolt" style="color: #f59e0b;"></i>
        Quick Actions
    </h2>
    <div class="quick-actions">
        <div class="quick-action" onclick="location.href='<%= request.getContextPath() %>/dashboard/student/attendance.jsp'">
            <i class="fas fa-qrcode"></i>
            <span>Mark Attendance</span>
        </div>
        <div class="quick-action" onclick="location.href='laundry-dashboard.jsp'">
            <i class="fas fa-tshirt"></i>
            <span>Book Laundry</span>
        </div>
        <div class="quick-action" onclick="location.href='cleaning-dashboard.jsp'">
            <i class="fas fa-broom"></i>
            <span>Request Cleaning</span>
        </div>
        <div class="quick-action" onclick="location.href='payments.jsp'">
            <i class="fas fa-credit-card"></i>
            <span>Pay Rent</span>
        </div>
        <div class="quick-action" onclick="location.href='<%= request.getContextPath() %>/rooms'">
            <i class="fas fa-bed"></i>
            <span>Book Room</span>
        </div>
        <div class="quick-action" onclick="location.href='<%= request.getContextPath() %>/inquiry'">
            <i class="fas fa-envelope-open-text"></i>
            <span>Room Inquiry</span>
        </div>
        <div class="quick-action" onclick="location.href='meal-dashboard.jsp'">
            <i class="fas fa-utensils"></i>
            <span>Order Meals</span>
        </div>
        <div class="quick-action" onclick="location.href='<%= request.getContextPath() %>/dashboard/student/review-dashboard.jsp'">
            <i class="fas fa-star" style="color: #fbbf24;"></i>
            <span>Rate & Review</span>
        </div>
    </div>

    <!-- Dashboard Grid -->
    <div class="dashboard-grid">
        <!-- Today's Schedule -->
        <div class="card">
            <div class="card-header">
                <h3>
                    <i class="fas fa-calendar-alt" style="color: #6366f1;"></i>
                    Today's Schedule
                </h3>
                <a href="#" class="view-all">View All</a>
            </div>
            <div class="schedule-list">
                <div class="schedule-item">
                    <div class="time">08:00 AM</div>
                    <div class="event">
                        <h4>Breakfast</h4>
                        <p>Main Dining Hall</p>
                    </div>
                    <span class="status completed">Completed</span>
                </div>
                <div class="schedule-item">
                    <div class="time">09:00 AM</div>
                    <div class="event">
                        <h4>Room Cleaning</h4>
                        <p>Scheduled</p>
                    </div>
                    <span class="status ongoing">In Progress</span>
                </div>
                <div class="schedule-item">
                    <div class="time">02:00 PM</div>
                    <div class="event">
                        <h4>Study Group</h4>
                        <p>Room 204</p>
                    </div>
                    <span class="status pending">Upcoming</span>
                </div>
                <div class="schedule-item">
                    <div class="time">07:00 PM</div>
                    <div class="event">
                        <h4>Dinner</h4>
                        <p>Main Dining Hall</p>
                    </div>
                    <span class="status pending">Upcoming</span>
                </div>
            </div>
        </div>

        <!-- Notifications -->
        <div class="card">
            <div class="card-header">
                <h3>
                    <i class="fas fa-bell" style="color: #ef4444;"></i>
                    Notifications
                </h3>
                <a href="#" class="view-all">Mark all read</a>
            </div>
            <div class="notification-list">
                <div class="notification-item warning">
                    <div class="notification-icon">📢</div>
                    <div class="notification-content">
                        <h4>Maintenance Notice</h4>
                        <p>Water supply will be off tomorrow 9am-12pm</p>
                        <span class="time">5 min ago</span>
                    </div>
                </div>
                <div class="notification-item">
                    <div class="notification-icon">✅</div>
                    <div class="notification-content">
                        <h4>Payment Received</h4>
                        <p>Your payment of Rs. 15,000 has been confirmed</p>
                        <span class="time">2 hours ago</span>
                    </div>
                </div>
                <div class="notification-item">
                    <div class="notification-icon">🧹</div>
                    <div class="notification-content">
                        <h4>Cleaning Completed</h4>
                        <p>Your room has been cleaned</p>
                        <span class="time">3 hours ago</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Today's Menu -->
    <div class="card" style="margin-top: 25px;">
        <div class="card-header">
            <h3>
                <i class="fas fa-restaurant" style="color: #10b981;"></i>
                Today's Menu
            </h3>
            <button class="btn-action" onclick="location.href='meals.jsp'">
                View Full Menu <i class="fas fa-arrow-right"></i>
            </button>
        </div>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div style="display: flex; gap: 15px; align-items: center;">
                <div style="font-size: 32px;">🍳</div>
                <div>
                    <h4 style="font-size: 16px; font-weight: 600; margin-bottom: 5px;">Breakfast</h4>
                    <p style="font-size: 14px; color: #64748b;">String Hoppers, Dhal, Sambol</p>
                    <span style="font-size: 12px; color: #6366f1;">7:30 AM - 9:30 AM</span>
                </div>
            </div>
            <div style="display: flex; gap: 15px; align-items: center;">
                <div style="font-size: 32px;">🍛</div>
                <div>
                    <h4 style="font-size: 16px; font-weight: 600; margin-bottom: 5px;">Lunch</h4>
                    <p style="font-size: 14px; color: #64748b;">Rice, Chicken Curry, Dhal, Salad</p>
                    <span style="font-size: 12px; color: #6366f1;">12:00 PM - 2:00 PM</span>
                </div>
            </div>
            <div style="display: flex; gap: 15px; align-items: center;">
                <div style="font-size: 32px;">🍲</div>
                <div>
                    <h4 style="font-size: 16px; font-weight: 600; margin-bottom: 5px;">Dinner</h4>
                    <p style="font-size: 14px; color: #64748b;">Rice, Fish Curry, Potato, Sambol</p>
                    <span style="font-size: 12px; color: #6366f1;">7:00 PM - 8:30 PM</span>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function logout() {
        if (confirm('Are you sure you want to logout?')) {
            window.location.href = '<%= request.getContextPath() %>/logout';
        }
    }
</script>
</body>
</html>