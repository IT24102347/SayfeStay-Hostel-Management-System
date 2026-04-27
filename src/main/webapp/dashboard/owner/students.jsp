<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*, org.example.dao.*, java.util.*, java.text.*" %>
<%
    // ============ SESSION CHECK ============
    User user = (User) session.getAttribute("user");
    if (user == null || !"Owner".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String view = request.getParameter("view");
    String studentId = request.getParameter("id");
    String studentName = request.getParameter("name");

    if (studentId != null && view == null) {
        view = "profile";
    }

    if (view == null) view = "list";

    // ============ DATABASE ACCESS ============
    StudentDAO studentDAO = new StudentDAO();
    List<Map<String, Object>> studentsList = new ArrayList<Map<String, Object>>();
    Map<String, Object> studentDetails = new HashMap<String, Object>();

    if ("list".equals(view)) {
        // Get all students from database
        studentsList = studentDAO.getAllStudents();
    } else if ("profile".equals(view) && studentId != null) {
        // Get specific student details
        studentDetails = studentDAO.getStudentById(studentId);
    }

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Management - Owner Dashboard</title>
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
            background: #f8fafc;
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: 280px;
            background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
            color: white;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
        }

        .sidebar-header {
            padding: 30px 25px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-header h2 {
            font-size: 28px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .owner-profile {
            padding: 25px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .owner-avatar {
            width: 80px;
            height: 80px;
            background: #4f46e5;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: 700;
            margin: 0 auto 15px;
        }

        .nav-menu {
            padding: 20px 0;
        }

        .nav-item {
            display: flex;
            align-items: center;
            padding: 12px 25px;
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }

        .nav-item:hover, .nav-item.active {
            background: rgba(79, 70, 229, 0.2);
            color: white;
            border-left-color: #4f46e5;
        }

        .nav-item i {
            width: 25px;
            margin-right: 15px;
        }

        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 30px;
        }

        .header {
            background: white;
            border-radius: 20px;
            padding: 25px 30px;
            margin-bottom: 25px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            font-size: 28px;
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
            border: none;
            padding: 12px 25px;
            border-radius: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            text-decoration: none;
        }

        .back-btn:hover {
            background: #e2e8f0;
            transform: translateX(-5px);
        }

        /* Student List View */
        .search-bar {
            background: white;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 25px;
            display: flex;
            gap: 15px;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }

        .search-input {
            flex: 1;
            padding: 15px 20px;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            font-size: 15px;
        }

        .search-input:focus {
            outline: none;
            border-color: #4f46e5;
        }

        .filter-select {
            padding: 15px 25px;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            font-size: 15px;
            background: white;
        }

        .student-table {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            padding: 15px 10px;
            color: #64748b;
            font-weight: 600;
            font-size: 14px;
            border-bottom: 2px solid #f1f5f9;
        }

        td {
            padding: 15px 10px;
            border-bottom: 1px solid #f1f5f9;
        }

        .student-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .student-avatar {
            width: 45px;
            height: 45px;
            background: #eef2ff;
            color: #4f46e5;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
        }

        .student-details h4 {
            font-size: 16px;
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 4px;
        }

        .student-details p {
            font-size: 13px;
            color: #64748b;
        }

        .badge {
            padding: 5px 15px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }

        .badge-active {
            background: #d4edda;
            color: #155724;
        }

        .badge-success {
            background: #d4edda;
            color: #155724;
        }

        .badge-warning {
            background: #fff3cd;
            color: #856404;
        }

        .badge-danger {
            background: #f8d7da;
            color: #721c24;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .action-btn {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
            color: white;
        }

        .btn-view { background: #4f46e5; }
        .btn-edit { background: #10b981; }
        .btn-delete { background: #ef4444; }
        .btn-attendance { background: #f59e0b; }

        .action-btn:hover {
            transform: translateY(-2px);
            opacity: 0.9;
        }

        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 25px;
        }

        .page-btn {
            width: 40px;
            height: 40px;
            border: 1px solid #e2e8f0;
            background: white;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }

        .page-btn.active {
            background: #4f46e5;
            color: white;
            border-color: #4f46e5;
        }

        .add-btn {
            background: #4f46e5;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 20px;
        }

        .add-btn:hover {
            background: #6366f1;
            transform: translateY(-2px);
        }

        /* Profile View */
        .profile-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
        }

        .profile-header {
            display: flex;
            gap: 30px;
            margin-bottom: 30px;
            padding-bottom: 30px;
            border-bottom: 2px solid #f1f5f9;
        }

        .profile-avatar {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: 700;
            color: white;
        }

        .profile-title h2 {
            font-size: 28px;
            color: #0f172a;
            margin-bottom: 10px;
        }

        .profile-title p {
            color: #64748b;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
            margin-bottom: 30px;
        }

        .info-section {
            background: #f8fafc;
            border-radius: 15px;
            padding: 20px;
        }

        .info-section h3 {
            font-size: 18px;
            color: #0f172a;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .info-row {
            display: flex;
            margin-bottom: 12px;
        }

        .info-label {
            width: 120px;
            color: #64748b;
            font-size: 14px;
        }

        .info-value {
            flex: 1;
            color: #0f172a;
            font-weight: 500;
        }

        .action-bar {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            flex-wrap: wrap;
        }

        .profile-btn {
            padding: 12px 25px;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
            font-size: 14px;
        }

        .btn-primary {
            background: #4f46e5;
            color: white;
        }

        .btn-success {
            background: #10b981;
            color: white;
        }

        .btn-warning {
            background: #f59e0b;
            color: white;
        }

        .btn-danger {
            background: #ef4444;
            color: white;
        }

        .btn-info {
            background: #3b82f6;
            color: white;
        }

        .profile-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .no-data {
            text-align: center;
            padding: 50px;
            color: #64748b;
            font-size: 16px;
        }

        .no-data i {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        @media (max-width: 1024px) {
            .sidebar {
                width: 80px;
            }
            .sidebar .nav-item span {
                display: none;
            }
            .main-content {
                margin-left: 80px;
            }
            .info-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            .main-content {
                margin-left: 0;
            }
            .search-bar {
                flex-direction: column;
            }
            .profile-header {
                flex-direction: column;
                text-align: center;
            }
            .action-bar {
                flex-direction: column;
            }
            .profile-btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
<!-- Sidebar -->
<div class="sidebar">
    <div class="sidebar-header">
        <h2>
            <i class="fas fa-hotel"></i>
            <span>SafeStay</span>
        </h2>
    </div>

    <div class="owner-profile">
        <div class="owner-avatar">
            <%= user.getFullName() != null ? user.getFullName().charAt(0) : 'O' %>
        </div>
        <h4 style="margin-bottom: 5px;"><%= user.getFullName() != null ? user.getFullName() : "Owner" %></h4>
        <p style="font-size: 12px;"><%= user.getUserId() %></p>
    </div>

    <div class="nav-menu">
        <a href="<%= request.getContextPath() %>/dashboard/owner" class="nav-item">
            <i class="fas fa-home"></i>
            <span>Dashboard</span>
        </a>
        <a href="<%= request.getContextPath() %>/dashboard/owner/students.jsp" class="nav-item active">
            <i class="fas fa-user-graduate"></i>
            <span>Students</span>
        </a>
        <a href="#" class="nav-item">
            <i class="fas fa-users"></i>
            <span>Staff</span>
        </a>
        <a href="#" class="nav-item">
            <i class="fas fa-door-open"></i>
            <span>Rooms</span>
        </a>
        <a href="#" class="nav-item">
            <i class="fas fa-credit-card"></i>
            <span>Payments</span>
        </a>
        <a href="#" class="nav-item">
            <i class="fas fa-chart-line"></i>
            <span>Reports</span>
        </a>
        <a href="<%= request.getContextPath() %>/logout" class="nav-item" style="margin-top: 50px;">
            <i class="fas fa-sign-out-alt"></i>
            <span>Logout</span>
        </a>
    </div>
</div>

<!-- Main Content -->
<div class="main-content">
    <!-- Header -->
    <div class="header">
        <h1>
            <i class="fas fa-user-graduate"></i>
            <% if ("profile".equals(view)) { %>
            Student Profile
            <% } else if ("add".equals(view)) { %>
            Add New Student
            <% } else { %>
            Student Management
            <% } %>
        </h1>
        <a href="<%= request.getContextPath() %>/dashboard/owner" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>

    <% if ("list".equals(view)) { %>
    <!-- ========== STUDENT LIST VIEW ========== -->

    <!-- Search Bar -->
    <div class="search-bar">
        <input type="text" class="search-input" id="searchInput" placeholder="Search by name, ID, email or phone...">
        <select class="filter-select" id="yearFilter">
            <option value="">All Years</option>
            <option value="1">Year 1</option>
            <option value="2">Year 2</option>
            <option value="3">Year 3</option>
            <option value="4">Year 4</option>
            <option value="5">Year 5</option>
        </select>
        <button class="filter-select" style="background: #4f46e5; color: white; border: none;" onclick="searchStudents()">
            <i class="fas fa-search"></i> Search
        </button>
    </div>

    <!-- Student Table -->
    <div class="student-table">
        <table id="studentTable">
            <thead>
            <tr>
                <th>Student</th>
                <th>Contact</th>
                <th>Year</th>
                <th>Room</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <%
                if (studentsList.isEmpty()) {
            %>
            <tr>
                <td colspan="6" class="no-data">
                    <i class="fas fa-user-graduate"></i>
                    <p>No students found in database</p>
                </td>
            </tr>
            <%
            } else {
                for (Map<String, Object> student : studentsList) {
                    String fullName = (String) student.get("fullName");
                    String stuId = (String) student.get("userId");
                    String email = (String) student.get("email");
                    String phone = (String) student.get("phone");
                    Integer studyYear = (Integer) student.get("studyYear");
                    String roomNumber = (String) student.get("roomNumber") != null ?
                            (String) student.get("roomNumber") : "Not Assigned";
                    String status = (String) student.get("status") != null ?
                            (String) student.get("status") : "Active";
            %>
            <tr>
                <td>
                    <div class="student-info">
                        <div class="student-avatar"><%= fullName != null ? fullName.charAt(0) : '?' %></div>
                        <div class="student-details">
                            <h4><%= fullName != null ? fullName : "Unknown" %></h4>
                            <p><%= stuId != null ? stuId : "" %></p>
                        </div>
                    </div>
                </td>
                <td>
                    <div class="student-details">
                        <p><i class="fas fa-phone"></i> <%= phone != null ? phone : "N/A" %></p>
                        <p><i class="fas fa-envelope"></i> <%= email != null ? email : "N/A" %></p>
                    </div>
                </td>
                <td>Year <%= studyYear != null ? studyYear : "?" %></td>
                <td><%= roomNumber %></td>
                <td><span class="badge badge-active"><%= status %></span></td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn btn-view" onclick="location.href='?view=profile&id=<%= stuId %>&name=<%= fullName %>'" title="View">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="action-btn btn-attendance" onclick="location.href='attendance-history.jsp?studentId=<%= stuId %>&studentName=<%= fullName %>'" title="Attendance">
                            <i class="fas fa-calendar-check"></i>
                        </button>
                        <button class="action-btn btn-edit" onclick="location.href='?view=edit&id=<%= stuId %>'" title="Edit">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="action-btn btn-delete" onclick="deleteStudent('<%= stuId %>')" title="Delete">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
            <%
                    }
                }
            %>
            </tbody>
        </table>

        <!-- Pagination (if needed) -->
        <% if (studentsList.size() > 10) { %>
        <div class="pagination">
            <button class="page-btn"><i class="fas fa-chevron-left"></i></button>
            <button class="page-btn active">1</button>
            <button class="page-btn">2</button>
            <button class="page-btn">3</button>
            <button class="page-btn"><i class="fas fa-chevron-right"></i></button>
        </div>
        <% } %>

        <!-- Add Student Button -->
        <button class="add-btn" onclick="location.href='?view=add'">
            <i class="fas fa-plus"></i> Add New Student
        </button>
    </div>

    <% } else if ("profile".equals(view)) {
        String displayName = (String) studentDetails.get("fullName");
        String displayId = (String) studentDetails.get("userId");
        String email = (String) studentDetails.get("email");
        String phone = (String) studentDetails.get("phone");
        String address = (String) studentDetails.get("address");
        String campus = (String) studentDetails.get("campusName");
        Integer studyYear = (Integer) studentDetails.get("studyYear");
        String guardianName = (String) studentDetails.get("guardianName");
        String guardianPhone = (String) studentDetails.get("guardianPhone");
        String guardianRelation = (String) studentDetails.get("guardianRelationship");
        String emergencyContact = (String) studentDetails.get("emergencyContact");
        java.util.Date regDate = (java.util.Date) studentDetails.get("registrationDate");

        if (displayName == null) displayName = "Student";
        if (displayId == null) displayId = studentId != null ? studentId : "STD001";
    %>
    <!-- ========== STUDENT PROFILE VIEW ========== -->

    <div class="profile-card">
        <!-- Profile Header -->
        <div class="profile-header">
            <div class="profile-avatar">
                <%= displayName.charAt(0) %>
            </div>
            <div class="profile-title">
                <h2><%= displayName %></h2>
                <p><i class="fas fa-id-card"></i> Student ID: <%= displayId %></p>
                <p><i class="fas fa-door-open"></i> Room 101 (Single)</p>
                <p><span class="badge badge-active">Active</span></p>
            </div>
        </div>

        <!-- Info Grid -->
        <div class="info-grid">
            <!-- Personal Information -->
            <div class="info-section">
                <h3><i class="fas fa-user"></i> Personal Information</h3>
                <div class="info-row">
                    <span class="info-label">Full Name</span>
                    <span class="info-value"><%= displayName %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Email</span>
                    <span class="info-value"><%= email != null ? email : "Not provided" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Phone</span>
                    <span class="info-value"><%= phone != null ? phone : "Not provided" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Address</span>
                    <span class="info-value"><%= address != null ? address : "Not provided" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Campus</span>
                    <span class="info-value"><%= campus != null ? campus : "Not provided" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Study Year</span>
                    <span class="info-value">Year <%= studyYear != null ? studyYear : "?" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Joined</span>
                    <span class="info-value"><%= regDate != null ? sdf.format(regDate) : "Not available" %></span>
                </div>
            </div>

            <!-- Guardian Information -->
            <div class="info-section">
                <h3><i class="fas fa-users"></i> Guardian Information</h3>
                <div class="info-row">
                    <span class="info-label">Guardian</span>
                    <span class="info-value"><%= guardianName != null ? guardianName : "Not provided" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Relationship</span>
                    <span class="info-value"><%= guardianRelation != null ? guardianRelation : "Not provided" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Phone</span>
                    <span class="info-value"><%= guardianPhone != null ? guardianPhone : "Not provided" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Emergency</span>
                    <span class="info-value"><%= emergencyContact != null ? emergencyContact : "Not provided" %></span>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="action-bar">
            <button class="profile-btn btn-primary" onclick="location.href='?view=edit&id=<%= displayId %>&name=<%= displayName %>'">
                <i class="fas fa-edit"></i> Edit Profile
            </button>
            <button class="profile-btn btn-warning" onclick="location.href='attendance-history.jsp?studentId=<%= displayId %>&studentName=<%= displayName %>'">
                <i class="fas fa-calendar-check"></i> Attendance
            </button>
            <button class="profile-btn btn-info" onclick="location.href='payments.jsp?studentId=<%= displayId %>'">
                <i class="fas fa-credit-card"></i> Payments
            </button>
            <button class="profile-btn btn-success" onclick="location.href='?view=change-room&id=<%= displayId %>'">
                <i class="fas fa-exchange-alt"></i> Change Room
            </button>
            <button class="profile-btn btn-danger" onclick="deleteStudent('<%= displayId %>')">
                <i class="fas fa-trash"></i> Delete
            </button>
        </div>
    </div>

    <% } else if ("add".equals(view)) { %>
    <!-- ========== ADD STUDENT FORM ========== -->
    <div class="profile-card">
        <h2 style="margin-bottom: 20px;">Add New Student</h2>
        <form action="<%= request.getContextPath() %>/owner/addStudent" method="post">
            <div class="info-grid">
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Full Name *</label>
                    <input type="text" name="fullName" class="search-input" required>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Email *</label>
                    <input type="email" name="email" class="search-input" required>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Phone *</label>
                    <input type="text" name="phone" class="search-input" required>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Address *</label>
                    <input type="text" name="address" class="search-input" required>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Campus *</label>
                    <select name="campus" class="filter-select" style="width: 100%;">
                        <option>University of Colombo</option>
                        <option>University of Peradeniya</option>
                        <option>University of Moratuwa</option>
                        <option>University of Kelaniya</option>
                    </select>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Study Year *</label>
                    <select name="studyYear" class="filter-select" style="width: 100%;">
                        <option value="1">Year 1</option>
                        <option value="2">Year 2</option>
                        <option value="3">Year 3</option>
                        <option value="4">Year 4</option>
                        <option value="5">Year 5</option>
                    </select>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Room *</label>
                    <select name="room" class="filter-select" style="width: 100%;">
                        <option value="101">101 - Single (Rs. 25,000)</option>
                        <option value="102">102 - Double (Rs. 18,000)</option>
                        <option value="103">103 - Double (Rs. 18,000)</option>
                        <option value="201">201 - Triple (Rs. 15,000)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Guardian Name *</label>
                    <input type="text" name="guardianName" class="search-input" required>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Relationship *</label>
                    <select name="relationship" class="filter-select" style="width: 100%;">
                        <option>Father</option>
                        <option>Mother</option>
                        <option>Guardian</option>
                        <option>Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Guardian Phone *</label>
                    <input type="text" name="guardianPhone" class="search-input" required>
                </div>
                <div class="form-group">
                    <label style="display: block; margin-bottom: 8px;">Emergency Contact</label>
                    <input type="text" name="emergencyContact" class="search-input">
                </div>
            </div>

            <div class="action-bar">
                <button type="submit" class="profile-btn btn-primary">
                    <i class="fas fa-save"></i> Save Student
                </button>
                <button type="button" class="profile-btn" style="background: #94a3b8; color: white;" onclick="location.href='?view=list'">
                    <i class="fas fa-times"></i> Cancel
                </button>
            </div>
        </form>
    </div>
    <% } %>
</div>

<script>
    function searchStudents() {
        var input = document.getElementById('searchInput').value.toLowerCase();
        var table = document.getElementById('studentTable');
        var rows = table.getElementsByTagName('tr');

        for (var i = 1; i < rows.length; i++) {
            var row = rows[i];
            var cells = row.getElementsByTagName('td');
            var match = false;

            if (cells.length > 0) {
                var text = cells[0].innerText.toLowerCase() + cells[1].innerText.toLowerCase();
                if (text.indexOf(input) > -1) {
                    match = true;
                }
            }

            if (match) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
    }

    function deleteStudent(studentId) {
        if (confirm('Are you sure you want to delete student ' + studentId + '?')) {
            window.location.href = '<%= request.getContextPath() %>/owner/deleteStudent?id=' + studentId;
        }
    }
</script>
</body>
</html>