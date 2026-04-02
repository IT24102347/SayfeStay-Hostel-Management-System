<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.User" %>
<%
    String userId = (String) session.getAttribute("registeredUserId");
    String role = (String) session.getAttribute("registeredRole");
    String fullName = (String) session.getAttribute("registeredName");

    if (userId == null) {
        response.sendRedirect("register.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registration Success - SafeStay</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .success-container {
            max-width: 600px;
            width: 100%;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            overflow: hidden;
            animation: fadeIn 0.6s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .success-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px 30px;
            text-align: center;
            color: white;
        }

        .success-icon {
            font-size: 80px;
            margin-bottom: 20px;
            animation: scaleIn 0.5s ease-out 0.3s both;
        }

        @keyframes scaleIn {
            from {
                transform: scale(0);
            }
            to {
                transform: scale(1);
            }
        }

        .success-header h1 {
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .success-header p {
            font-size: 1.1rem;
            opacity: 0.95;
        }

        .success-body {
            padding: 40px;
        }

        .welcome-message {
            text-align: center;
            margin-bottom: 30px;
        }

        .welcome-message h2 {
            color: #2c3e50;
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .welcome-message p {
            color: #64748b;
            font-size: 1rem;
        }

        .user-details-card {
            background: #f8fafc;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            border: 1px solid #e2e8f0;
        }

        .detail-row {
            display: flex;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #e2e8f0;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            width: 120px;
            font-weight: 600;
            color: #4a5568;
        }

        .detail-value {
            flex: 1;
            color: #2c3e50;
            font-weight: 500;
        }

        .detail-value.highlight {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-weight: 700;
        }

        .role-badge {
            display: inline-block;
            padding: 8px 20px;
            border-radius: 30px;
            font-size: 0.9rem;
            font-weight: 600;
            color: white;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .info-box {
            background: #e6f7ff;
            border-left: 4px solid #1890ff;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
        }

        .info-box h4 {
            color: #0050b3;
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .info-box ul {
            list-style: none;
            padding-left: 0;
        }

        .info-box li {
            color: #0050b3;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.95rem;
        }

        .info-box li i {
            color: #1890ff;
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 20px;
        }

        .btn {
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1rem;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s;
            border: none;
            cursor: pointer;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }

        .btn-outline {
            background: transparent;
            border: 2px solid #667eea;
            color: #667eea;
        }

        .btn-outline:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: #e2e8f0;
            color: #4a5568;
        }

        .btn-secondary:hover {
            background: #cbd5e0;
            transform: translateY(-2px);
        }

        .alert {
            background: #d4edda;
            color: #155724;
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-left: 4px solid #28a745;
        }

        .alert i {
            font-size: 1.2rem;
        }

        @media (max-width: 768px) {
            .success-container {
                margin: 20px;
            }

            .success-header {
                padding: 30px 20px;
            }

            .success-header h1 {
                font-size: 1.8rem;
            }

            .success-body {
                padding: 25px;
            }

            .detail-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 5px;
            }

            .detail-label {
                width: 100%;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn {
                width: 100%;
            }
        }

        @media (max-width: 480px) {
            .success-header h1 {
                font-size: 1.5rem;
            }

            .success-icon {
                font-size: 60px;
            }

            .welcome-message h2 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
<div class="success-container">
    <div class="success-header">
        <div class="success-icon">
            <i class="fas fa-check-circle"></i>
        </div>
        <h1>Registration Successful!</h1>
        <p>Your account has been created successfully</p>
    </div>

    <div class="success-body">
        <div class="alert">
            <i class="fas fa-info-circle"></i>
            <strong>Welcome to SafeStay!</strong> Your registration is complete.
        </div>

        <div class="welcome-message">
            <h2>Hello, <%= fullName != null ? fullName.split(" ")[0] : "User" %>! 👋</h2>
            <p>Thank you for joining SafeStay Hostel Management System</p>
        </div>

        <div class="user-details-card">
            <div style="text-align: center; margin-bottom: 20px;">
                    <span class="role-badge">
                        <i class="fas <%=
                            role != null && role.equalsIgnoreCase("Student") ? "fa-user-graduate" :
                            role != null && role.equalsIgnoreCase("Owner") ? "fa-hotel" :
                            role != null && role.contains("Staff") ? "fa-user-tie" : "fa-user"
                        %>"></i>
                        <%= role != null ? role.replace("_", " ") : "Member" %>
                    </span>
            </div>

            <div class="detail-row">
                    <span class="detail-label">
                        <i class="fas fa-id-card" style="color: #667eea; margin-right: 8px;"></i>
                        User ID
                    </span>
                <span class="detail-value highlight"><strong><%= userId %></strong></span>
            </div>

            <div class="detail-row">
                    <span class="detail-label">
                        <i class="fas fa-user" style="color: #667eea; margin-right: 8px;"></i>
                        Full Name
                    </span>
                <span class="detail-value"><%= fullName != null ? fullName : "Not Provided" %></span>
            </div>

            <div class="detail-row">
                    <span class="detail-label">
                        <i class="fas fa-tag" style="color: #667eea; margin-right: 8px;"></i>
                        Role
                    </span>
                <span class="detail-value"><%= role != null ? role.replace("_", " ") : "Member" %></span>
            </div>

            <div class="detail-row">
                    <span class="detail-label">
                        <i class="fas fa-calendar" style="color: #667eea; margin-right: 8px;"></i>
                        Registered On
                    </span>
                <span class="detail-value">
                        <%= new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(new java.util.Date()) %>
                    </span>
            </div>
        </div>

        <% if (role != null && role.equalsIgnoreCase("Student")) { %>
        <div class="info-box">
            <h4>
                <i class="fas fa-graduation-cap"></i>
                Student Information
            </h4>
            <ul>
                <li><i class="fas fa-check-circle"></i> Your Student ID: <strong><%= userId %></strong></li>
                <li><i class="fas fa-check-circle"></i> Use this ID to login and access your dashboard</li>
                <li><i class="fas fa-check-circle"></i> You can book rooms, request services, and track attendance</li>
                <li><i class="fas fa-check-circle"></i> Complete your profile for better experience</li>
            </ul>
        </div>
        <% } else if (role != null && role.equalsIgnoreCase("Owner")) { %>
        <div class="info-box">
            <h4>
                <i class="fas fa-hotel"></i>
                Owner Information
            </h4>
            <ul>
                <li><i class="fas fa-check-circle"></i> Your Owner ID: <strong><%= userId %></strong></li>
                <li><i class="fas fa-check-circle"></i> Use this ID to login and manage your hostel</li>
                <li><i class="fas fa-check-circle"></i> You can manage students, staff, rooms and payments</li>
                <li><i class="fas fa-check-circle"></i> Set up your hostel details in settings</li>
            </ul>
        </div>
        <% } else { %>
        <div class="info-box">
            <h4>
                <i class="fas fa-briefcase"></i>
                Staff Information
            </h4>
            <ul>
                <li><i class="fas fa-check-circle"></i> Your Staff ID: <strong><%= userId %></strong></li>
                <li><i class="fas fa-check-circle"></i> Use this ID to login and manage your tasks</li>
                <li><i class="fas fa-check-circle"></i> Check your schedule and assigned duties</li>
                <li><i class="fas fa-check-circle"></i> Contact admin for any issues</li>
            </ul>
        </div>
        <% } %>

        <div style="text-align: center; margin: 30px 0 20px;">
            <p style="color: #64748b; margin-bottom: 20px;">
                <i class="fas fa-envelope"></i>
                A confirmation email has been sent to your registered email address.
            </p>
        </div>

        <div class="action-buttons">
            <a href="login.jsp" class="btn btn-primary">
                <i class="fas fa-sign-in-alt"></i> Login Now
            </a>
            <a href="dashboard" class="btn btn-outline">
                <i class="fas fa-tachometer-alt"></i> Go to Dashboard
            </a>
        </div>

        <div style="text-align: center; margin-top: 25px; padding-top: 20px; border-top: 1px solid #e2e8f0;">
            <p style="color: #64748b; font-size: 0.9rem;">
                <i class="fas fa-shield-alt"></i>
                Your account is protected with industry-standard security
            </p>
            <p style="color: #a0aec0; font-size: 0.8rem; margin-top: 10px;">
                © 2024 SafeStay Hostel Management. All rights reserved.
            </p>
        </div>
    </div>
</div>

<script>
    // Clear session data after showing
    window.onload = function() {
        // Auto redirect to login after 10 seconds
        setTimeout(function() {
            window.location.href = 'login.jsp';
        }, 10000);
    };

    // Copy User ID to clipboard
    function copyUserId() {
        const userId = '<%= userId %>';
        navigator.clipboard.writeText(userId);
        alert('User ID copied to clipboard!');
    }
</script>
</body>
</html>
