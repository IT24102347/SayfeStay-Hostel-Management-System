<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - SafeStay Student Housing</title>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- AOS Animation -->
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            overflow-x: hidden;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        /* ========== ANIMATED BACKGROUND ========== */
        .animated-bg {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            overflow: hidden;
        }

        .gradient-bg {
            position: absolute;
            width: 200%;
            height: 200%;
            top: -50%;
            left: -50%;
            background: linear-gradient(
                    45deg,
                    #ff6b6b,
                    #4ecdc4,
                    #45b7d1,
                    #96ceb4,
                    #ffeaa7,
                    #dfe6e9
            );
            animation: gradientShift 15s ease infinite;
            background-size: 400% 400%;
            filter: blur(100px);
            opacity: 0.5;
        }

        @keyframes gradientShift {
            0% { transform: rotate(0deg) scale(1); }
            50% { transform: rotate(180deg) scale(1.5); }
            100% { transform: rotate(360deg) scale(1); }
        }

        /* ===== HOSTEL LIFE THEMED FLOATING IMAGES ===== */
        .floating-shapes {
            position: absolute;
            width: 100%;
            height: 100%;
        }

        .floating-img {
            position: absolute;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            border: 3px solid rgba(255, 255, 255, 0.3);
            backdrop-filter: blur(5px);
            animation: floatAround 20s infinite;
            object-fit: cover;
            transition: all 0.3s;
        }

        .img1 {
            width: 200px;
            height: 150px;
            top: 10%;
            left: 5%;
            background-image: url('https://images.unsplash.com/photo-1523240795612-9a054b0db644?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            animation-delay: 0s;
        }

        .img2 {
            width: 180px;
            height: 220px;
            top: 60%;
            left: 8%;
            background-image: url('https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            animation-delay: -3s;
        }

        .img3 {
            width: 220px;
            height: 160px;
            bottom: 15%;
            right: 5%;
            background-image: url('https://images.unsplash.com/photo-1555854877-bab0e564b8d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            animation-delay: -6s;
        }

        .img4 {
            width: 160px;
            height: 200px;
            top: 20%;
            right: 8%;
            background-image: url('https://images.unsplash.com/photo-1545173168-9f1947eebb7f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            animation-delay: -9s;
        }

        @keyframes floatAround {
            0%, 100% {
                transform: translate(0, 0) rotate(0deg) scale(1);
            }
            25% {
                transform: translate(20px, 20px) rotate(3deg) scale(1.02);
            }
            50% {
                transform: translate(40px, -15px) rotate(-2deg) scale(1.05);
            }
            75% {
                transform: translate(-15px, 25px) rotate(5deg) scale(1.02);
            }
        }

        /* ========== LOGIN CONTAINER ========== */
        .login-container {
            width: 100%;
            max-width: 450px;
            margin: 20px;
            position: relative;
            z-index: 100;
        }

        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-radius: 40px;
            padding: 50px 40px;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.3);
            transform: translateY(0);
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }

        .login-card::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200px;
            height: 200px;
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            border-radius: 50%;
            opacity: 0.1;
            animation: blobMove 15s infinite;
        }

        .login-card::after {
            content: '';
            position: absolute;
            bottom: -50%;
            left: -50%;
            width: 300px;
            height: 300px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 50%;
            opacity: 0.1;
            animation: blobMove 20s infinite reverse;
        }

        @keyframes blobMove {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            33% { transform: translate(30px, -30px) rotate(120deg); }
            66% { transform: translate(-30px, 30px) rotate(240deg); }
        }

        /* ========== HEADER ========== */
        .logo-section {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 25px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            transform: rotate(-5deg);
            transition: transform 0.3s;
            box-shadow: 0 15px 30px rgba(102, 126, 234, 0.4);
        }

        .logo-icon i {
            font-size: 40px;
            color: white;
        }

        .logo-icon:hover {
            transform: rotate(0deg) scale(1.1);
        }

        .logo-text {
            font-size: 36px;
            font-weight: 800;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
            font-family: 'Montserrat', sans-serif;
        }

        .welcome-text {
            color: #64748b;
            font-size: 16px;
        }

        /* ========== LOGIN FORM ========== */
        .login-form {
            margin-top: 30px;
        }

        .input-group {
            margin-bottom: 20px;
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: #667eea;
            font-size: 18px;
            z-index: 10;
        }

        .input-field {
            width: 100%;
            padding: 18px 20px 18px 55px;
            border: 2px solid #e2e8f0;
            border-radius: 20px;
            font-size: 15px;
            font-weight: 500;
            transition: all 0.3s;
            background: white;
            color: #1e293b;
        }

        .input-field:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }

        .input-field::placeholder {
            color: #94a3b8;
            font-weight: 400;
        }

        /* Password visibility toggle */
        .toggle-password {
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            cursor: pointer;
            font-size: 18px;
            transition: color 0.2s;
            z-index: 10;
        }

        .toggle-password:hover {
            color: #667eea;
        }

        /* Remember me & Forgot password */
        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 25px 0 30px;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
        }

        .remember-me input[type="checkbox"] {
            width: 18px;
            height: 18px;
            accent-color: #667eea;
            cursor: pointer;
        }

        .remember-me span {
            color: #475569;
            font-size: 14px;
            font-weight: 500;
        }

        .forgot-link {
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: color 0.2s;
        }

        .forgot-link:hover {
            color: #764ba2;
            text-decoration: underline;
        }

        /* Login Button */
        .login-btn {
            width: 100%;
            padding: 18px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 30px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .login-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s;
        }

        .login-btn:hover::before {
            left: 100%;
        }

        .login-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px rgba(102, 126, 234, 0.4);
        }

        .login-btn i {
            font-size: 18px;
            transition: transform 0.3s;
        }

        .login-btn:hover i {
            transform: translateX(5px);
        }

        /* Social Login */
        .social-login {
            text-align: center;
            margin-top: 20px;
        }

        .divider {
            display: flex;
            align-items: center;
            gap: 15px;
            color: #94a3b8;
            font-size: 13px;
            margin-bottom: 25px;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: linear-gradient(90deg, transparent, #cbd5e1, transparent);
        }

        .social-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
        }

        .social-btn {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: #f1f5f9;
            border: none;
            color: #475569;
            font-size: 20px;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .social-btn:hover {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.2);
        }

        /* Register Link */
        .register-link {
            text-align: center;
            margin-top: 25px;
            padding-top: 25px;
            border-top: 1px solid #e2e8f0;
        }

        .register-link p {
            color: #475569;
            font-size: 15px;
        }

        .register-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 700;
            margin-left: 5px;
            transition: color 0.2s;
        }

        .register-link a:hover {
            color: #764ba2;
            text-decoration: underline;
        }

        /* Error Message */
        .error-message {
            background: #fee2e2;
            color: #dc2626;
            padding: 15px 20px;
            border-radius: 15px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-left: 4px solid #dc2626;
            font-size: 14px;
            font-weight: 500;
            animation: shake 0.5s;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }

        .error-message i {
            font-size: 18px;
        }

        /* Success Message */
        .success-message {
            background: #dcfce7;
            color: #166534;
            padding: 15px 20px;
            border-radius: 15px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-left: 4px solid #22c55e;
            font-size: 14px;
            font-weight: 500;
        }

        .success-message i {
            font-size: 18px;
        }

        /* Back to Home Link */
        .back-home {
            text-align: center;
            margin-top: 20px;
        }

        .back-home a {
            color: white;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 20px;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            border-radius: 50px;
            transition: all 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .back-home a:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }

        .back-home i {
            font-size: 14px;
        }

        /* ========== RESPONSIVE ========== */
        @media (max-width: 768px) {
            .login-card {
                padding: 40px 25px;
            }

            .floating-img {
                opacity: 0.2;
            }

            .logo-icon {
                width: 70px;
                height: 70px;
            }

            .logo-icon i {
                font-size: 32px;
            }

            .logo-text {
                font-size: 30px;
            }
        }

        @media (max-width: 480px) {
            .login-card {
                padding: 30px 20px;
            }

            .form-options {
                flex-direction: column;
                gap: 15px;
                align-items: flex-start;
            }
        }

        /* Loading State */
        .login-btn.loading {
            opacity: 0.7;
            cursor: not-allowed;
        }

        .login-btn.loading i {
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
<!-- Animated Background -->
<div class="animated-bg">
    <div class="gradient-bg"></div>
    <div class="floating-shapes">
        <div class="floating-img img1" title="Students studying"></div>
        <div class="floating-img img2" title="Students eating together"></div>
        <div class="floating-img img3" title="Modern hostel room"></div>
        <div class="floating-img img4" title="Laundry time"></div>
    </div>
</div>

<!-- Login Container -->
<div class="login-container" data-aos="fade-up">
    <div class="login-card">
        <!-- Logo Section -->
        <div class="logo-section">
            <div class="logo-icon">
                <i class="fas fa-hotel"></i>
            </div>
            <h2 class="logo-text">Welcome Back!</h2>
            <p class="welcome-text">Sign in to continue to SafeStay</p>
        </div>

        <!-- Error/Success Messages -->
        <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="error-message">
            <i class="fas fa-exclamation-circle"></i>
            <%= request.getAttribute("errorMessage") %>
        </div>
        <% } %>

        <% if (request.getParameter("registered") != null) { %>
        <div class="success-message">
            <i class="fas fa-check-circle"></i>
            Registration successful! Please login.
        </div>
        <% } %>

        <% if (request.getParameter("logout") != null) { %>
        <div class="success-message">
            <i class="fas fa-check-circle"></i>
            You have been logged out successfully.
        </div>
        <% } %>

        <!-- Login Form -->
        <form class="login-form" action="login" method="post" id="loginForm">
            <div class="input-group">
                <i class="fas fa-id-card input-icon"></i>
                <input type="text"
                       class="input-field"
                       name="userId"
                       placeholder="Student / Staff ID"
                       required
                       autofocus>
            </div>

            <div class="input-group">
                <i class="fas fa-lock input-icon"></i>
                <input type="password"
                       class="input-field"
                       name="password"
                       id="password"
                       placeholder="Password"
                       required>
                <i class="fas fa-eye toggle-password" onclick="togglePassword()"></i>
            </div>

            <div class="form-options">
                <label class="remember-me">
                    <input type="checkbox" name="remember">
                    <span>Remember me</span>
                </label>
                <a href="#" class="forgot-link">Forgot Password?</a>
            </div>

            <button type="submit" class="login-btn" id="loginBtn">
                <span>Sign In</span>
                <i class="fas fa-arrow-right"></i>
            </button>

            <div class="social-login">
                <div class="divider">
                    <span>OR CONTINUE WITH</span>
                </div>
                <div class="social-buttons">
                    <button type="button" class="social-btn" title="Google">
                        <i class="fab fa-google"></i>
                    </button>
                    <button type="button" class="social-btn" title="Facebook">
                        <i class="fab fa-facebook-f"></i>
                    </button>
                    <button type="button" class="social-btn" title="Microsoft">
                        <i class="fab fa-microsoft"></i>
                    </button>
                    <button type="button" class="social-btn" title="Apple">
                        <i class="fab fa-apple"></i>
                    </button>
                </div>
            </div>

            <div class="register-link">
                <p>New to SafeStay?
                    <a href="register.jsp">Create an account</a>
                </p>
            </div>
        </form>
    </div>

    <div class="back-home">
        <a href="index.jsp">
            <i class="fas fa-home"></i>
            Back to Home
        </a>
    </div>
</div>

<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
    AOS.init({
        duration: 800,
        once: true
    });

    function togglePassword() {
        const password = document.getElementById('password');
        const toggleIcon = event.currentTarget;

        if (password.type === 'password') {
            password.type = 'text';
            toggleIcon.classList.remove('fa-eye');
            toggleIcon.classList.add('fa-eye-slash');
        } else {
            password.type = 'password';
            toggleIcon.classList.remove('fa-eye-slash');
            toggleIcon.classList.add('fa-eye');
        }
    }

    document.getElementById('loginForm').addEventListener('submit', function(e) {
        const btn = document.getElementById('loginBtn');
        btn.classList.add('loading');
        btn.innerHTML = '<i class="fas fa-spinner"></i><span>Signing in...</span>';
    });

    setTimeout(function() {
        const messages = document.querySelectorAll('.error-message, .success-message');
        messages.forEach(function(msg) {
            msg.style.transition = 'opacity 0.5s';
            msg.style.opacity = '0';
            setTimeout(function() {
                msg.style.display = 'none';
            }, 500);
        });
    }, 5000);
</script>
</body>
</html>