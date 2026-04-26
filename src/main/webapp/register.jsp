<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - SafeStay Hostel Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        /* All your existing CSS code remains the same */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            background: linear-gradient(rgba(0,0,0,0.7), rgba(0,0,0,0.7)),
            url('images/1737.jpg') no-repeat center center fixed;
            background-size: cover;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .register-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.3);
            width: 100%;
            max-width: 700px;
            padding: 40px;
            margin: 20px;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .header h2 {
            color: #4e73df;
            font-size: 2rem;
            margin-bottom: 5px;
        }

        .header p {
            color: #666;
            font-size: 0.9rem;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
            font-size: 0.9rem;
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s;
        }

        .form-control:focus {
            border-color: #4e73df;
            outline: none;
            box-shadow: 0 0 0 3px rgba(78, 115, 223, 0.1);
        }

        select.form-control {
            height: 46px;
        }

        .row {
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
        }

        .row .form-group {
            flex: 1;
        }

        .btn-register {
            background: linear-gradient(45deg, #e74a3b, #c53030);
            color: white;
            border: none;
            padding: 15px 30px;
            width: 100%;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 20px;
        }

        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(231, 74, 59, 0.3);
        }

        .login-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 0.9rem;
        }

        .login-link a {
            color: #4e73df;
            text-decoration: none;
            font-weight: 600;
        }

        .alert {
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 0.9rem;
        }

        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .role-options {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin-bottom: 20px;
        }

        .role-option {
            text-align: center;
            padding: 15px 10px;
            border: 2px solid #ddd;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .role-option:hover {
            border-color: #4e73df;
            background-color: #f8f9fe;
            transform: translateY(-2px);
        }

        .role-option.selected {
            border-color: #4e73df;
            background-color: #4e73df;
            color: white;
            box-shadow: 0 5px 15px rgba(78, 115, 223, 0.3);
        }

        .role-icon {
            font-size: 28px;
            margin-bottom: 8px;
            display: block;
        }

        .role-field {
            display: none;
        }

        .role-field.active {
            display: block;
            animation: fadeIn 0.5s;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .section-title {
            color: #2c3e50;
            margin: 25px 0 15px 0;
            padding-bottom: 8px;
            border-bottom: 2px solid #eee;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title:before {
            content: "📋";
        }

        .required-field:after {
            content: " *";
            color: #e74a3b;
        }

        .info-box {
            background: #f0f8ff;
            padding: 15px;
            border-radius: 10px;
            margin: 15px 0;
            border-left: 4px solid #4e73df;
        }

        .info-box p {
            margin: 5px 0;
            color: #555;
            font-size: 0.9rem;
        }

        @media (max-width: 768px) {
            .role-options {
                grid-template-columns: repeat(2, 1fr);
            }

            .row {
                flex-direction: column;
                gap: 10px;
            }

            .register-container {
                padding: 25px;
                margin: 10px;
            }
        }

        /* Hidden Rules Modal Styles (Add at the end of existing CSS) */
        .rules-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.85);
            z-index: 9999;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .rules-content {
            background: white;
            border-radius: 20px;
            width: 95%;
            max-width: 900px;
            max-height: 90vh;
            overflow: hidden;
            box-shadow: 0 25px 50px rgba(0,0,0,0.5);
        }

        .rules-header {
            background: linear-gradient(45deg, #e74a3b, #c53030);
            color: white;
            padding: 25px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .rules-header h3 {
            margin: 0;
            font-size: 1.8rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .close-rules {
            background: none;
            border: none;
            color: white;
            font-size: 35px;
            cursor: pointer;
            padding: 5px 15px;
            border-radius: 50%;
            transition: background 0.3s;
            line-height: 1;
        }

        .close-rules:hover {
            background: rgba(255,255,255,0.2);
        }

        .rules-body {
            padding: 30px;
            max-height: 65vh;
            overflow-y: auto;
            background: #f8f9fa;
        }

        .rules-section {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.05);
            border-left: 4px solid #4e73df;
        }

        .rules-section h4 {
            color: #2c3e50;
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 2px solid #eee;
            font-size: 1.1rem;
        }

        .rules-section ul, .rules-section ol {
            margin-left: 25px;
            margin-bottom: 15px;
        }

        .rules-section li {
            margin-bottom: 10px;
            line-height: 1.6;
            color: #444;
        }

        .rules-footer {
            padding: 25px 30px;
            background: white;
            border-top: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .rules-agree {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .rules-agree input[type="checkbox"] {
            width: 22px;
            height: 22px;
            cursor: pointer;
        }

        .rules-agree label {
            font-weight: 600;
            color: #2c3e50;
            margin: 0;
            cursor: pointer;
        }

        .rules-buttons {
            display: flex;
            gap: 15px;
        }

        .btn-rules {
            padding: 12px 30px;
            border-radius: 10px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 1rem;
        }

        .btn-accept {
            background: linear-gradient(45deg, #28a745, #1e7e34);
            color: white;
        }

        .btn-accept:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3);
        }

        .btn-cancel {
            background: #6c757d;
            color: white;
        }

        .btn-cancel:hover {
            background: #5a6268;
        }

        .highlight {
            background: #fff3cd;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            border-left: 4px solid #ffc107;
        }

        .important-note {
            background: #f8d7da;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            border-left: 4px solid #dc3545;
        }

        .important-note strong {
            color: #721c24;
        }

        @media (max-width: 768px) {
            .rules-footer {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }

            .rules-buttons {
                width: 100%;
                flex-direction: column;
            }

            .btn-rules {
                width: 100%;
            }

            .rules-header h3 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
<div class="register-container">
    <div class="header">
        <h2>SafeStay Hostel Management</h2>
        <p>Create your account as a member</p>
    </div>

    <%-- Success/Error Messages --%>
    <% if (request.getParameter("status") != null && request.getParameter("status").equals("success")) { %>
    <div class="alert alert-success">
        Registration successful! You can now <a href="login.jsp" style="color: #155724; font-weight: bold;">login here</a>.
    </div>
    <% } %>

    <% if (request.getAttribute("error") != null) { %>
    <div class="alert alert-error">
        <strong>Error:</strong> <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <%-- Hidden input for rules agreement --%>
    <input type="hidden" id="rulesAgreed" name="rulesAgreed" value="false">

    <form action="register" method="post" id="registerForm">
        <%-- ============ ROLE SELECTION ============ --%>
        <div class="form-group">
            <label class="required-field">I am registering as:</label>
            <div class="role-options">
                <div class="role-option selected" data-role="Student" onclick="selectRole(this)">
                    <span class="role-icon">👨‍🎓</span>
                    <strong>Student</strong>
                </div>
                <div class="role-option" data-role="Owner" onclick="selectRole(this)">
                    <span class="role-icon">🏨</span>
                    <strong>Hostel Owner</strong>
                </div>
                <div class="role-option" data-role="Cleaning_Staff" onclick="selectRole(this)">
                    <span class="role-icon">🧹</span>
                    <strong>Cleaning Staff</strong>
                </div>
                <div class="role-option" data-role="Laundry_Staff" onclick="selectRole(this)">
                    <span class="role-icon">👕</span>
                    <strong>Laundry Staff</strong>
                </div>
                <div class="role-option" data-role="Kitchen_Staff" onclick="selectRole(this)">
                    <span class="role-icon">👨‍🍳</span>
                    <strong>Kitchen Staff</strong>
                </div>
                <div class="role-option" data-role="IT_Supporter" onclick="selectRole(this)">
                    <span class="role-icon">💻</span>
                    <strong>IT Support</strong>
                </div>
            </div>
            <input type="hidden" name="role" id="selectedRole" value="Student" required>
        </div>

        <div class="info-box">
            <p><strong>Note:</strong> Based on your selected role, different information will be required.</p>
            <p>• Students need guardian details and campus information</p>
            <p>• Staff members need employment details</p>
        </div>

        <%-- ============ BASIC INFORMATION (All Roles) ============ --%>
        <div class="section-title">Basic Information</div>

        <div class="row">
            <div class="form-group">
                <label class="required-field">Username</label>
                <input type="text" name="username" class="form-control"
                       placeholder="Choose a username" required minlength="3" maxlength="50">
            </div>
            <div class="form-group">
                <label class="required-field">Password</label>
                <input type="password" name="password" class="form-control"
                       placeholder="Create a strong password" required minlength="6">
            </div>
        </div>

        <div class="form-group">
            <label class="required-field">Full Name</label>
            <input type="text" name="fullName" class="form-control"
                   placeholder="Enter your full name" required>
        </div>

        <div class="row">
            <div class="form-group">
                <label class="required-field">Email Address</label>
                <input type="email" name="email" class="form-control"
                       placeholder="example@email.com" required>
            </div>
            <div class="form-group">
                <label class="required-field">Phone Number</label>
                <input type="tel" name="phone" class="form-control"
                       placeholder="07XXXXXXXX" pattern="[0-9]{10}" required>
                <small style="color: #666; font-size: 12px;">10 digits without spaces</small>
            </div>
        </div>

        <div class="form-group">
            <label class="required-field">Address</label>
            <textarea name="address" class="form-control"
                      placeholder="Your complete address" rows="2" required></textarea>
        </div>

        <%-- ============ STUDENT SPECIFIC FIELDS ============ --%>
        <div class="role-field active" id="studentFields">
            <div class="section-title">Student Details</div>

            <div class="row">
                <div class="form-group">
                    <label class="required-field">Study Year</label>
                    <select name="studyYear" class="form-control" required>
                        <option value="">Select Year</option>
                        <option value="1">Year 1</option>
                        <option value="2">Year 2</option>
                        <option value="3">Year 3</option>
                        <option value="4">Year 4</option>
                        <option value="5">Year 5</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="required-field">Campus Name</label>
                    <input type="text" name="campusName" class="form-control"
                           placeholder="e.g., Colombo Main Campus" required>
                </div>
            </div>

            <div class="section-title">Guardian/Emergency Contact Details</div>

            <div class="row">
                <div class="form-group">
                    <label class="required-field">Guardian Name</label>
                    <input type="text" name="guardianName" class="form-control"
                           placeholder="Guardian's full name" required>
                </div>
                <div class="form-group">
                    <label class="required-field">Relationship</label>
                    <select name="guardianRelationship" class="form-control" required>
                        <option value="Parent">Parent</option>
                        <option value="Guardian">Legal Guardian</option>
                        <option value="Sibling">Sibling</option>
                        <option value="Relative">Relative</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
            </div>

            <div class="row">
                <div class="form-group">
                    <label class="required-field">Guardian Phone</label>
                    <input type="tel" name="guardianPhone" class="form-control"
                           placeholder="Guardian's phone number" pattern="[0-9]{10}" required>
                </div>
                <div class="form-group">
                    <label>Emergency Contact</label>
                    <input type="tel" name="emergencyContact" class="form-control"
                           placeholder="Additional emergency contact (optional)">
                </div>
            </div>
        </div>

        <%-- ============ STAFF SPECIFIC FIELDS (for all staff roles) ============ --%>
        <div class="role-field" id="staffFields">
            <div class="section-title">Employment Details</div>

            <div class="row">
                <div class="form-group">
                    <label>Company/Organization</label>
                    <input type="text" name="companyName" class="form-control"
                           placeholder="Company name (if applicable)">
                </div>
                <div class="form-group">
                    <label>Department</label>
                    <input type="text" name="department" class="form-control"
                           placeholder="Your department">
                </div>
            </div>

            <div class="row">
                <div class="form-group">
                    <label>Work Shift</label>
                    <select name="workShift" class="form-control">
                        <option value="">Select Shift</option>
                        <option value="Day Shift">Day Shift</option>
                        <option value="Night Shift">Night Shift</option>
                        <option value="Morning Shift">Morning Shift</option>
                        <option value="Evening Shift">Evening Shift</option>
                        <option value="Full Time">Full Time</option>
                        <option value="Part Time">Part Time</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Employee ID (Optional)</label>
                    <input type="text" name="employeeId" class="form-control"
                           placeholder="Your employee ID if any">
                </div>
            </div>

            <div class="info-box">
                <p><strong>Note for Staff:</strong> Your User ID will be generated as follows:</p>
                <p>• Owner: OWN001, OWN002, ...</p>
                <p>• Cleaning Staff: CLN001, CLN002, ...</p>
                <p>• Laundry Staff: LND001, LND002, ...</p>
                <p>• Kitchen Staff: KIT001, KIT002, ...</p>
                <p>• IT Support: SUP001, SUP002, ...</p>
            </div>
        </div>

        <%-- ============ TERMS AND CONDITIONS ============ --%>
        <div class="form-group" style="margin-top: 25px;">
            <label>
                <input type="checkbox" name="terms" required style="margin-right: 8px;">
                I agree to the <a href="#" style="color: #4e73df;">Terms and Conditions</a> and
                <a href="#" style="color: #4e73df;">Privacy Policy</a>
            </label>
        </div>

        <button type="button" class="btn-register" onclick="validateAndShowRules()">
            <span style="font-size: 1.1rem;">✓</span> Register Now
        </button>
    </form>

    <div class="login-link">
        <p>Already have an account? <a href="login.jsp">Login here</a></p>
        <p style="margin-top: 10px; font-size: 0.8rem; color: #888;">
            Need help? <a href="contact.jsp" style="color: #4e73df;">Contact Support</a>
        </p>
    </div>
</div>

<%-- RULES MODAL (Add this at the end, before </body>) --%>
<div class="rules-modal" id="rulesModal">
    <div class="rules-content">
        <div class="rules-header">
            <h3><span style="font-size: 1.5rem;">🏠</span> SafeStay Hostel Rules & Regulations</h3>
            <button class="close-rules" onclick="closeRules()">×</button>
        </div>

        <div class="rules-body">
            <div class="important-note">
                <strong>⚠️ IMPORTANT:</strong> All residents and staff must strictly follow these rules.
                Violations may result in penalties, fines, or expulsion.
            </div>

            <div class="rules-section">
                <h4>📋 General Rules</h4>
                <ol>
                    <li><strong>Check-in/Check-out:</strong> Check-in: 2:00 PM | Check-out: 11:00 AM sharp</li>
                    <li><strong>Visitor Policy:</strong> No visitors after 10:00 PM. Day visitors must register</li>
                    <li><strong>Quiet Hours:</strong> Complete silence from 10:00 PM to 7:00 AM</li>
                    <li><strong>Cleanliness:</strong> Keep rooms and common areas clean. Weekly inspections</li>
                    <li><strong>Cooking:</strong> No cooking in rooms. Use kitchen areas only</li>
                    <li><strong>Prohibited Items:</strong> No alcohol, drugs, weapons, or pets</li>
                    <li><strong>Smoking:</strong> Only in designated outdoor areas</li>
                    <li><strong>Electrical Appliances:</strong> Only approved low-wattage devices</li>
                    <li><strong>Room Changes:</strong> Require 7 days notice and warden approval</li>
                    <li><strong>Guest Policy:</strong> No overnight guests without written permission</li>
                </ol>
            </div>

            <div class="rules-section">
                <h4>💰 Payment Rules</h4>
                <ul>
                    <li>Monthly rent due before 5th of each month</li>
                    <li>Late payment penalty: <strong>Rs. 500 per day</strong> after due date</li>
                    <li>Security deposit: <strong>Rs. 15,000</strong> (refundable)</li>
                    <li>No refunds for early departure</li>
                    <li>Damage charges: Replacement cost + 20% service fee</li>
                    <li>Lost key/access card replacement: <strong>Rs. 1,000</strong></li>
                </ul>
            </div>

            <div class="rules-section">
                <h4>🚨 Safety & Security</h4>
                <ul>
                    <li>Always lock your room when leaving</li>
                    <li>Never share keys or access cards</li>
                    <li>Keep fire exits and corridors clear</li>
                    <li>Report maintenance issues immediately</li>
                    <li>Follow emergency evacuation procedures</li>
                    <li><strong>Emergency Contacts:</strong>
                        <br>• Warden: 011-2345678 (24/7)
                        <br>• Security: 011-2345679
                        <br>• Fire/Ambulance: 011-2345680
                    </li>
                </ul>
            </div>

            <div class="rules-section">
                <h4>⚖️ Disciplinary Actions</h4>
                <div class="highlight">
                    <strong>Three-Strike Policy:</strong>
                    <ol>
                        <li><strong>First Violation:</strong> Written warning + Rs. 1,000 fine</li>
                        <li><strong>Second Violation:</strong> Rs. 5,000 fine + management meeting</li>
                        <li><strong>Third Violation:</strong> Immediate expulsion (no refund)</li>
                    </ol>
                </div>
                <p><strong>Serious violations</strong> (drugs, violence, theft) result in immediate expulsion.</p>
            </div>

            <div class="rules-section">
                <h4>🏢 Common Area Rules</h4>
                <ul>
                    <li>TV lounge: First come, first served (max 2 hours during peak)</li>
                    <li>Study room: Absolute silence required</li>
                    <li>Laundry room: Schedule and clean after use</li>
                    <li>Kitchen: Clean all utensils immediately after use</li>
                    <li>Parking: Assigned spots only</li>
                </ul>
            </div>

            <div class="rules-section">
                <h4>🎓 Student-Specific Rules</h4>
                <ul>
                    <li>Maintain minimum 75% attendance</li>
                    <li>Academic progress reports may be requested</li>
                    <li>Night out permission required after 10:00 PM</li>
                    <li>Parent/Guardian consent required</li>
                </ul>
            </div>

            <div class="rules-section">
                <h4>👨‍💼 Staff-Specific Rules</h4>
                <ul>
                    <li>Wear ID badges at all times</li>
                    <li>Respect resident privacy</li>
                    <li>Report suspicious activities</li>
                    <li>Maintain professional conduct</li>
                </ul>
            </div>

            <div class="important-note">
                <strong>📝 Agreement:</strong> By accepting, you confirm:
                <ol>
                    <li>You have read and understood ALL rules</li>
                    <li>You agree to abide by these rules</li>
                    <li>You accept penalties for violations</li>
                    <li>You authorize management to take action</li>
                </ol>
            </div>
        </div>

        <div class="rules-footer">
            <div class="rules-agree">
                <input type="checkbox" id="agreeRulesInModal">
                <label for="agreeRulesInModal">I have read, understood, and agree to ALL rules</label>
            </div>
            <div class="rules-buttons">
                <button class="btn-rules btn-cancel" onclick="closeRules()">Cancel</button>
                <button class="btn-rules btn-accept" onclick="acceptRules()">Accept & Continue Registration</button>
            </div>
        </div>
    </div>
</div>

<script>
    // Current selected role
    let currentRole = 'Student';

    // Role selection function
    function selectRole(element) {
        // Remove selected class from all roles
        document.querySelectorAll('.role-option').forEach(option => {
            option.classList.remove('selected');
        });

        // Add selected class to clicked role
        element.classList.add('selected');

        // Get selected role value
        currentRole = element.getAttribute('data-role');
        document.getElementById('selectedRole').value = currentRole;

        // Update form fields based on role
        updateFormFields(currentRole);
    }

    // Update form fields based on selected role
    function updateFormFields(role) {
        const studentFields = document.getElementById('studentFields');
        const staffFields = document.getElementById('staffFields');

        // Hide all role-specific fields
        studentFields.classList.remove('active');
        staffFields.classList.remove('active');

        // Show relevant fields
        if (role === 'Student') {
            studentFields.classList.add('active');
            setStudentFieldsRequired(true);
            setStaffFieldsRequired(false);
        } else {
            staffFields.classList.add('active');
            setStudentFieldsRequired(false);
            setStaffFieldsRequired(false);

            // Auto-fill department based on role
            if (role === 'Owner') {
                document.querySelector('[name="department"]').value = 'Management';
                document.querySelector('[name="workShift"]').value = 'Full Time';
            } else if (role === 'Cleaning_Staff') {
                document.querySelector('[name="department"]').value = 'Housekeeping';
            } else if (role === 'Laundry_Staff') {
                document.querySelector('[name="department"]').value = 'Laundry';
            } else if (role === 'Kitchen_Staff') {
                document.querySelector('[name="department"]').value = 'Kitchen';
            } else if (role === 'IT_Supporter') {
                document.querySelector('[name="department"]').value = 'IT Department';
            }
        }
    }

    // Set student fields as required/not required
    function setStudentFieldsRequired(required) {
        const studentFields = [
            'studyYear', 'campusName', 'guardianName',
            'guardianPhone', 'guardianRelationship'
        ];

        studentFields.forEach(fieldName => {
            const field = document.querySelector(`[name="${fieldName}"]`);
            if (field) {
                field.required = required;
            }
        });
    }

    // Set staff fields as required/not required
    function setStaffFieldsRequired(required) {
        const staffFields = ['companyName', 'department', 'workShift'];
        staffFields.forEach(fieldName => {
            const field = document.querySelector(`[name="${fieldName}"]`);
            if (field) {
                field.required = required;
            }
        });
    }

    // MAIN FUNCTION: Validate form and show rules
    function validateAndShowRules(event) {
        // First validate the form
        if (!validateForm()) {
            return false;
        }

        // Check if terms are agreed
        const terms = document.querySelector('[name="terms"]').checked;
        if (!terms) {
            alert('You must agree to the Terms and Conditions');
            return false;
        }

        // Show rules modal
        showHostelRules();
        return false;
    }

    // Basic form validation
    function validateForm() {
        const role = document.getElementById('selectedRole').value;
        const username = document.querySelector('[name="username"]').value;
        const password = document.querySelector('[name="password"]').value;
        const fullName = document.querySelector('[name="fullName"]').value;
        const email = document.querySelector('[name="email"]').value;
        const phone = document.querySelector('[name="phone"]').value;
        const address = document.querySelector('[name="address"]').value;

        // Basic validations
        if (!username || username.length < 3) {
            alert('Username must be at least 3 characters long');
            return false;
        }

        if (!password || password.length < 6) {
            alert('Password must be at least 6 characters long');
            return false;
        }

        if (!fullName || fullName.trim().length < 2) {
            alert('Please enter a valid full name');
            return false;
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            alert('Please enter a valid email address');
            return false;
        }

        if (!/^[0-9]{10}$/.test(phone)) {
            alert('Phone number must be exactly 10 digits');
            return false;
        }

        if (!address || address.trim().length < 5) {
            alert('Please enter a valid address');
            return false;
        }

        // Role-specific validations
        if (role === 'Student') {
            const studyYear = document.querySelector('[name="studyYear"]').value;
            const campusName = document.querySelector('[name="campusName"]').value;
            const guardianName = document.querySelector('[name="guardianName"]').value;
            const guardianPhone = document.querySelector('[name="guardianPhone"]').value;

            if (!studyYear) {
                alert('Please select your study year');
                return false;
            }

            if (!campusName || campusName.trim().length < 2) {
                alert('Please enter your campus name');
                return false;
            }

            if (!guardianName || guardianName.trim().length < 2) {
                alert('Please enter guardian name');
                return false;
            }

            if (!/^[0-9]{10}$/.test(guardianPhone)) {
                alert('Guardian phone must be exactly 10 digits');
                return false;
            }
        }

        return true;
    }

    // Show hostel rules modal
    function showHostelRules() {
        document.getElementById('rulesModal').style.display = 'flex';
        // Reset modal checkbox
        document.getElementById('agreeRulesInModal').checked = false;
        // Scroll to top of rules
        document.querySelector('.rules-body').scrollTop = 0;
    }

    // Close rules modal
    function closeRules() {
        document.getElementById('rulesModal').style.display = 'none';
    }

    // Accept rules from modal
    function acceptRules() {
        const agreeInModal = document.getElementById('agreeRulesInModal').checked;

        if (!agreeInModal) {
            alert('Please check the agreement box to accept the rules');
            return;
        }

        // Set rules agreed flag
        document.getElementById('rulesAgreed').value = 'true';

        // Close modal
        closeRules();

        // Submit the form
        document.getElementById('registerForm').submit();
    }

    // Close modal when clicking outside
    document.getElementById('rulesModal').addEventListener('click', function(e) {
        if (e.target.id === 'rulesModal') {
            closeRules();
        }
    });

    // Auto-fill emergency contact with guardian phone
    document.querySelector('[name="guardianPhone"]')?.addEventListener('change', function() {
        const emergencyContact = document.querySelector('[name="emergencyContact"]');
        if (emergencyContact && !emergencyContact.value) {
            emergencyContact.value = this.value;
        }
    });

    // Initialize form
    document.addEventListener('DOMContentLoaded', function() {
        updateFormFields('Student');
    });
</script>
</body>
</html>