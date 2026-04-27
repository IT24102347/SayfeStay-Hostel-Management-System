<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SafeStay - Where Living Becomes an Experience ✨</title>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- AOS Animation -->
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">

    <!-- Swiper Slider -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css" />

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
        }

        /* ========== CUSTOM SCROLLBAR ========== */
        ::-webkit-scrollbar {
            width: 10px;
        }

        ::-webkit-scrollbar-track {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        ::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            border-radius: 10px;
        }

        /* ========== HOSTEL LIFE BACKGROUND IMAGES ========== */
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

        .floating-shapes {
            position: absolute;
            width: 100%;
            height: 100%;
        }

        /* ===== HOSTEL LIFE THEMED FLOATING IMAGES ===== */
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

        .floating-img:hover {
            transform: scale(1.1) rotate(5deg);
            border-color: white;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
            z-index: 100;
        }

        /* Image 1 - Students studying in common room */
        .img1 {
            width: 250px;
            height: 180px;
            top: 15%;
            left: 5%;
            background-image: url('https://images.unsplash.com/photo-1523240795612-9a054b0db644?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            animation-delay: 0s;
        }

        /* Image 2 - Students eating together in dining hall */
        .img2 {
            width: 220px;
            height: 280px;
            top: 60%;
            left: 10%;
            background-image: url('https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            animation-delay: -3s;
        }

        /* Image 3 - Modern hostel room with bed */
        .img3 {
            width: 280px;
            height: 200px;
            bottom: 15%;
            right: 8%;
            background-image: url('https://images.unsplash.com/photo-1555854877-bab0e564b8d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            animation-delay: -6s;
        }

        /* Image 4 - Students doing laundry */
        .img4 {
            width: 200px;
            height: 250px;
            top: 25%;
            right: 12%;
            background-image: url('https://images.unsplash.com/photo-1545173168-9f1947eebb7f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            animation-delay: -9s;
        }

        /* Image 5 - Students playing games in common area */
        .img5 {
            width: 230px;
            height: 230px;
            bottom: 30%;
            left: 20%;
            background-image: url('https://images.unsplash.com/photo-1529156069898-49953e39b3ac?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            border-radius: 50%;
            animation-delay: -12s;
        }

        /* Image 6 - Student with laptop in library */
        .img6 {
            width: 240px;
            height: 180px;
            top: 40%;
            right: 20%;
            background-image: url('https://images.unsplash.com/photo-1522202176988-66273c2fd55f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            animation-delay: -15s;
        }

        /* Image 7 - Hostel building exterior */
        .img7 {
            width: 300px;
            height: 200px;
            bottom: 10%;
            left: 30%;
            background-image: url('https://images.unsplash.com/photo-1555854877-bab0e564b8d5?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            opacity: 0.7;
            animation-delay: -18s;
        }

        /* Image 8 - Students in kitchen */
        .img8 {
            width: 200px;
            height: 200px;
            top: 70%;
            right: 25%;
            background-image: url('https://images.unsplash.com/photo-1556909211-36987daf7b4d?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80');
            background-size: cover;
            background-position: center;
            border-radius: 30% 70% 70% 30% / 30% 30% 70% 70%;
            animation-delay: -21s;
        }

        @keyframes floatAround {
            0%, 100% {
                transform: translate(0, 0) rotate(0deg) scale(1);
            }
            25% {
                transform: translate(30px, 30px) rotate(5deg) scale(1.02);
            }
            50% {
                transform: translate(60px, -20px) rotate(-3deg) scale(1.05);
            }
            75% {
                transform: translate(-20px, 40px) rotate(8deg) scale(1.02);
            }
        }

        /* Add overlay to make text readable over images */
        .hero, .facilities, .stats, .testimonials, .footer {
            position: relative;
            z-index: 10;
        }

        .hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(3px);
            z-index: -1;
        }

        /* ========== NAVBAR ========== */
        .navbar {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            width: 90%;
            max-width: 1200px;
            padding: 15px 30px;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-radius: 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 1000;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            animation: slideDown 0.5s ease;
        }

        @keyframes slideDown {
            from {
                top: -100px;
                opacity: 0;
            }
            to {
                top: 20px;
                opacity: 1;
            }
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo-icon {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            transform: rotate(-5deg);
            transition: all 0.3s;
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        .logo:hover .logo-icon {
            transform: rotate(0deg) scale(1.1);
        }

        .logo-text {
            font-size: 28px;
            font-weight: 800;
            background: linear-gradient(135deg, #fff, #ffeaa7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 1px;
        }

        .nav-links {
            display: flex;
            gap: 30px;
        }

        .nav-link {
            color: white;
            text-decoration: none;
            font-weight: 500;
            font-size: 16px;
            padding: 8px 16px;
            border-radius: 30px;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }

        .nav-link::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }

        .nav-link:hover::before {
            width: 200px;
            height: 200px;
        }

        .nav-link:hover {
            color: #fff;
            text-shadow: 0 0 10px rgba(255,255,255,0.5);
        }

        .nav-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 12px 30px !important;
            border-radius: 30px;
            font-weight: 600;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }

        .nav-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.3);
        }

        /* ========== HERO SECTION ========== */
        .hero {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            padding: 0 20px;
        }

        .hero-content {
            text-align: center;
            color: white;
            z-index: 10;
        }

        .hero-badge {
            display: inline-block;
            padding: 8px 25px;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            border-radius: 50px;
            font-size: 14px;
            font-weight: 600;
            letter-spacing: 2px;
            margin-bottom: 30px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .hero-title {
            font-size: 80px;
            font-weight: 800;
            line-height: 1.1;
            margin-bottom: 20px;
            text-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .gradient-text {
            background: linear-gradient(135deg, #ffeaa7, #ff6b6b, #4ecdc4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-size: 300% 300%;
            animation: gradientFlow 5s ease infinite;
        }

        @keyframes gradientFlow {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .hero-subtitle {
            font-size: 20px;
            margin-bottom: 40px;
            opacity: 0.9;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .hero-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-bottom: 60px;
        }

        .btn-primary {
            padding: 18px 45px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 50px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
            position: relative;
            overflow: hidden;
        }

        .btn-primary::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s;
        }

        .btn-primary:hover::before {
            left: 100%;
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.6);
        }

        .btn-outline {
            padding: 18px 45px;
            background: transparent;
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            backdrop-filter: blur(10px);
        }

        .btn-outline:hover {
            border-color: white;
            background: rgba(255, 255, 255, 0.1);
            transform: translateY(-3px);
        }

        /* ========== FACILITIES CAROUSEL ========== */
        .facilities {
            padding: 100px 50px;
            background: white;
            position: relative;
            overflow: hidden;
        }

        .facilities::before {
            content: '';
            position: absolute;
            top: -100px;
            left: 0;
            width: 100%;
            height: 200px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            transform: skewY(-3deg);
        }

        .section-header {
            text-align: center;
            max-width: 700px;
            margin: 0 auto 60px;
            position: relative;
            z-index: 10;
        }

        .section-badge {
            display: inline-block;
            padding: 8px 25px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 50px;
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 20px;
            letter-spacing: 2px;
            animation: bounce 2s infinite;
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .section-header h2 {
            font-size: 48px;
            font-weight: 800;
            color: #1e293b;
            margin-bottom: 20px;
        }

        .section-header p {
            font-size: 18px;
            color: #64748b;
        }

        /* Swiper Slider */
        .swiper {
            width: 100%;
            padding: 50px 0;
            overflow: visible;
        }

        .swiper-slide {
            background: white;
            border-radius: 30px;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            transition: all 0.3s;
            border: 1px solid rgba(0, 0, 0, 0.05);
        }

        .swiper-slide:hover {
            transform: translateY(-10px) scale(1.05);
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.2);
        }

        .facility-card {
            position: relative;
            height: 400px;
            display: flex;
            flex-direction: column;
        }

        .facility-image {
            height: 200px;
            background-size: cover;
            background-position: center;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }

        .facility-image::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 100px;
            background: linear-gradient(to top, rgba(0,0,0,0.5), transparent);
        }

        .facility-icon {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            z-index: 10;
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
            animation: rotate 10s linear infinite;
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        .facility-content {
            padding: 25px;
            background: white;
            flex: 1;
        }

        .facility-content h3 {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 10px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .facility-content p {
            color: #64748b;
            line-height: 1.6;
            margin-bottom: 15px;
        }

        .facility-tags {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .tag {
            padding: 5px 15px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 30px;
            font-size: 12px;
            font-weight: 600;
            opacity: 0.9;
        }

        /* ========== COLORFUL STATS ========== */
        .stats {
            padding: 80px 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            position: relative;
            overflow: hidden;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 30px;
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
            z-index: 10;
        }

        .stat-item {
            text-align: center;
            color: white;
            padding: 30px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            transition: all 0.3s;
            animation: glow 2s infinite;
        }

        .stat-item:hover {
            transform: translateY(-10px);
            background: rgba(255, 255, 255, 0.2);
        }

        @keyframes glow {
            0%, 100% { box-shadow: 0 0 20px rgba(255,255,255,0.2); }
            50% { box-shadow: 0 0 40px rgba(255,255,255,0.4); }
        }

        .stat-number {
            font-size: 48px;
            font-weight: 800;
            margin-bottom: 10px;
            background: linear-gradient(135deg, #ffeaa7, #ff6b6b);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .stat-label {
            font-size: 16px;
            font-weight: 500;
            opacity: 0.9;
        }

        /* ========== TESTIMONIALS ========== */
        .testimonials {
            padding: 100px 50px;
            background: white;
        }

        .testimonial-slider {
            max-width: 800px;
            margin: 0 auto;
        }

        .testimonial-card {
            background: linear-gradient(135deg, #667eea, #764ba2);
            padding: 40px;
            border-radius: 30px;
            color: white;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .quote-icon {
            font-size: 60px;
            opacity: 0.2;
            position: absolute;
            top: 20px;
            left: 20px;
        }

        .testimonial-text {
            font-size: 18px;
            line-height: 1.8;
            margin-bottom: 30px;
            position: relative;
            z-index: 10;
        }

        .testimonial-author {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }

        .author-avatar {
            width: 60px;
            height: 60px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            font-weight: 700;
            color: #667eea;
        }

        .author-info h4 {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .author-info p {
            font-size: 14px;
            opacity: 0.8;
        }

        /* ========== FOOTER ========== */
        .footer {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            color: white;
            padding: 80px 50px 20px;
            position: relative;
            overflow: hidden;
        }

        .footer::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" opacity="0.1"><circle cx="50" cy="50" r="40" fill="white"/></svg>');
            background-size: 50px 50px;
            animation: moveBackground 20s linear infinite;
        }

        @keyframes moveBackground {
            from { transform: translateX(0) translateY(0); }
            to { transform: translateX(50px) translateY(50px); }
        }

        .footer-content {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 50px;
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
            z-index: 10;
        }

        .footer-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }

        .footer-logo-icon {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }

        .footer-logo-text {
            font-size: 24px;
            font-weight: 800;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .social-links {
            display: flex;
            gap: 15px;
            margin-top: 20px;
        }

        .social-link {
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-decoration: none;
            transition: all 0.3s;
        }

        .social-link:hover {
            background: linear-gradient(135deg, #667eea, #764ba2);
            transform: translateY(-3px) rotate(360deg);
        }

        .footer-col h4 {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 25px;
            color: #ffeaa7;
        }

        .footer-col ul {
            list-style: none;
        }

        .footer-col ul li {
            margin-bottom: 15px;
        }

        .footer-col ul li a {
            color: #94a3b8;
            text-decoration: none;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .footer-col ul li a:hover {
            color: white;
            transform: translateX(5px);
        }

        .footer-bottom {
            text-align: center;
            padding-top: 50px;
            margin-top: 50px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            color: #94a3b8;
            position: relative;
            z-index: 10;
        }

        /* ========== RESPONSIVE ========== */
        @media (max-width: 1200px) {
            .floating-img {
                opacity: 0.3;
            }
        }

        @media (max-width: 1024px) {
            .hero-title {
                font-size: 60px;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .footer-content {
                grid-template-columns: repeat(2, 1fr);
            }

            .floating-img {
                display: none;
            }
        }

        @media (max-width: 768px) {
            .navbar {
                width: 95%;
                padding: 10px 20px;
            }

            .nav-links {
                display: none;
            }

            .hero-title {
                font-size: 40px;
            }

            .hero-buttons {
                flex-direction: column;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .footer-content {
                grid-template-columns: 1fr;
            }

            .floating-img {
                display: none;
            }
        }
    </style>
</head>
<body>
<!-- Animated Background with Hostel Life Images -->
<div class="animated-bg">
    <div class="gradient-bg"></div>
    <div class="floating-shapes">
        <!-- 8 Hostel Life Themed Images -->
        <div class="floating-img img1" title="Students studying in common room"></div>
        <div class="floating-img img2" title="Students eating together"></div>
        <div class="floating-img img3" title="Modern hostel room"></div>
        <div class="floating-img img4" title="Laundry time"></div>
        <div class="floating-img img5" title="Students having fun"></div>
        <div class="floating-img img6" title="Student studying"></div>
        <div class="floating-img img7" title="Hostel building"></div>
        <div class="floating-img img8" title="Kitchen time"></div>
    </div>
</div>

<!-- Navbar -->
<nav class="navbar">
    <div class="logo">
        <div class="logo-icon">
            <i class="fas fa-hotel"></i>
        </div>
        <span class="logo-text">SafeStay</span>
    </div>

    <div class="nav-links">
        <a href="#home" class="nav-link">Home</a>
        <a href="#facilities" class="nav-link">Facilities</a>
        <a href="#about" class="nav-link">About</a>
        <a href="#contact" class="nav-link">Contact</a>
        <a href="login.jsp" class="nav-link nav-btn">Get Started</a>
    </div>
</nav>

<!-- Hero Section -->
<section class="hero" id="home">
    <div class="hero-content" data-aos="fade-up">
        <span class="hero-badge">🌟 WELCOME TO YOUR HOME AWAY FROM HOME</span>
        <h1 class="hero-title">
            Live the<br>
            <span class="gradient-text">Hostel Life</span>
        </h1>
        <p class="hero-subtitle">Experience the perfect blend of study, fun, and community in our vibrant hostel spaces.</p>

        <div class="hero-buttons">
            <a href="register.jsp" class="btn-primary">Start Your Journey</a>
            <a href="#facilities" class="btn-outline">Explore Facilities</a>
        </div>
    </div>
</section>

<!-- Colorful Stats -->
<section class="stats">
    <div class="stats-grid">
        <div class="stat-item" data-aos="fade-up" data-aos-delay="100">
            <div class="stat-number">500+</div>
            <div class="stat-label">Happy Students</div>
        </div>
        <div class="stat-item" data-aos="fade-up" data-aos-delay="200">
            <div class="stat-number">24/7</div>
            <div class="stat-label">Support Available</div>
        </div>
        <div class="stat-item" data-aos="fade-up" data-aos-delay="300">
            <div class="stat-number">100%</div>
            <div class="stat-label">Secure & Safe</div>
        </div>
        <div class="stat-item" data-aos="fade-up" data-aos-delay="400">
            <div class="stat-number">10+</div>
            <div class="stat-label">Facilities</div>
        </div>
    </div>
</section>

<!-- Facilities Carousel -->
<section class="facilities" id="facilities">
    <div class="section-header" data-aos="fade-up">
        <span class="section-badge">🎯 OUR FACILITIES</span>
        <h2>Everything You Need,<br><span class="gradient-text">All in One Place</span></h2>
        <p>From study spaces to laundry, we've got you covered.</p>
    </div>

    <div class="swiper mySwiper" data-aos="fade-up">
        <div class="swiper-wrapper">
            <!-- Slide 1 - QR Attendance -->
            <div class="swiper-slide">
                <div class="facility-card">
                    <div class="facility-image" style="background-image: url('https://images.unsplash.com/photo-1586281380117-5a60ae2050cc?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80')">
                        <div class="facility-icon">
                            <i class="fas fa-qrcode"></i>
                        </div>
                    </div>
                    <div class="facility-content">
                        <h3>QR Attendance</h3>
                        <p>Wave goodbye to registers! Scan and mark attendance in milliseconds.</p>
                        <div class="facility-tags">
                            <span class="tag">✨ Instant</span>
                            <span class="tag">📱 Smart</span>
                            <span class="tag">⚡ Fast</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Slide 2 - Laundry Service -->
            <div class="swiper-slide">
                <div class="facility-card">
                    <div class="facility-image" style="background-image: url('https://images.unsplash.com/photo-1545173168-9f1947eebb7f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80')">
                        <div class="facility-icon">
                            <i class="fas fa-tshirt"></i>
                        </div>
                    </div>
                    <div class="facility-content">
                        <h3>Laundry Service</h3>
                        <p>Schedule pickups and track your laundry in real-time.</p>
                        <div class="facility-tags">
                            <span class="tag">🧺 Wash</span>
                            <span class="tag">👕 Iron</span>
                            <span class="tag">🚀 Express</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Slide 3 - Room Cleaning -->
            <div class="swiper-slide">
                <div class="facility-card">
                    <div class="facility-image" style="background-image: url('https://images.unsplash.com/photo-1581578731548-c64695cc6952?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80')">
                        <div class="facility-icon">
                            <i class="fas fa-broom"></i>
                        </div>
                    </div>
                    <div class="facility-content">
                        <h3>Room Cleaning</h3>
                        <p>Request cleaning with a tap and watch the magic happen.</p>
                        <div class="facility-tags">
                            <span class="tag">✨ Deep Clean</span>
                            <span class="tag">🕒 Flexible</span>
                            <span class="tag">🧹 Professional</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Slide 4 - Kitchen Meals -->
            <div class="swiper-slide">
                <div class="facility-card">
                    <div class="facility-image" style="background-image: url('https://images.unsplash.com/photo-1556909211-36987daf7b4d?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80')">
                        <div class="facility-icon">
                            <i class="fas fa-utensils"></i>
                        </div>
                    </div>
                    <div class="facility-content">
                        <h3>Kitchen Meals</h3>
                        <p>Pre-book your meals and never miss a bite!</p>
                        <div class="facility-tags">
                            <span class="tag">🍛 Local</span>
                            <span class="tag">🍕 International</span>
                            <span class="tag">🥗 Healthy</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Slide 5 - Room Booking -->
            <div class="swiper-slide">
                <div class="facility-card">
                    <div class="facility-image" style="background-image: url('https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80')">
                        <div class="facility-icon">
                            <i class="fas fa-bed"></i>
                        </div>
                    </div>
                    <div class="facility-content">
                        <h3>Room Booking</h3>
                        <p>Choose your perfect space. Single, double, or dorm.</p>
                        <div class="facility-tags">
                            <span class="tag">🛏️ Single</span>
                            <span class="tag">👥 Double</span>
                            <span class="tag">🏘️ Dorm</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Slide 6 - Events -->
            <div class="swiper-slide">
                <div class="facility-card">
                    <div class="facility-image" style="background-image: url('https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80')">
                        <div class="facility-icon">
                            <i class="fas fa-calendar-alt"></i>
                        </div>
                    </div>
                    <div class="facility-content">
                        <h3>Events & Parties</h3>
                        <p>Movie nights, festivals, and more - never miss out!</p>
                        <div class="facility-tags">
                            <span class="tag">🎉 Parties</span>
                            <span class="tag">🎬 Movies</span>
                            <span class="tag">🏏 Sports</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="swiper-pagination"></div>
    </div>
</section>

<!-- Testimonials -->
<section class="testimonials">
    <div class="section-header" data-aos="fade-up">
        <span class="section-badge">💬 STUDENT VOICES</span>
        <h2>What Our <span class="gradient-text">Community</span> Says</h2>
    </div>

    <div class="testimonial-slider swiper testimonialSwiper" data-aos="fade-up">
        <div class="swiper-wrapper">
            <div class="swiper-slide">
                <div class="testimonial-card">
                    <i class="fas fa-quote-right quote-icon"></i>
                    <p class="testimonial-text">"The QR attendance is a game-changer! No more waiting in lines."</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">R</div>
                        <div class="author-info">
                            <h4>Rashmi Perera</h4>
                            <p>Year 2 Student</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="swiper-slide">
                <div class="testimonial-card">
                    <i class="fas fa-quote-right quote-icon"></i>
                    <p class="testimonial-text">"The kitchen meals are amazing! I can pre-book my lunch and dinner."</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">K</div>
                        <div class="author-info">
                            <h4>Kamal Silva</h4>
                            <p>Year 3 Student</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="swiper-slide">
                <div class="testimonial-card">
                    <i class="fas fa-quote-right quote-icon"></i>
                    <p class="testimonial-text">"The room cleaning service is so convenient. Just tap and it's done!"</p>
                    <div class="testimonial-author">
                        <div class="author-avatar">N</div>
                        <div class="author-info">
                            <h4>Nimal Fernando</h4>
                            <p>Year 1 Student</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="swiper-pagination"></div>
    </div>
</section>

<!-- Footer -->
<footer class="footer">
    <div class="footer-content">
        <div class="footer-col">
            <div class="footer-logo">
                <div class="footer-logo-icon">
                    <i class="fas fa-hotel"></i>
                </div>
                <span class="footer-logo-text">SafeStay</span>
            </div>
            <p>Making hostel life better, one feature at a time. Join our vibrant community today!</p>
            <div class="social-links">
                <a href="#" class="social-link"><i class="fab fa-facebook-f"></i></a>
                <a href="#" class="social-link"><i class="fab fa-instagram"></i></a>
                <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                <a href="#" class="social-link"><i class="fab fa-tiktok"></i></a>
            </div>
        </div>

        <div class="footer-col">
            <h4>Quick Links</h4>
            <ul>
                <li><a href="#home"><i class="fas fa-chevron-right"></i> Home</a></li>
                <li><a href="#facilities"><i class="fas fa-chevron-right"></i> Facilities</a></li>
                <li><a href="#about"><i class="fas fa-chevron-right"></i> About Us</a></li>
                <li><a href="#contact"><i class="fas fa-chevron-right"></i> Contact</a></li>
            </ul>
        </div>

        <div class="footer-col">
            <h4>Our Services</h4>
            <ul>
                <li><a href="#"><i class="fas fa-chevron-right"></i> QR Attendance</a></li>
                <li><a href="#"><i class="fas fa-chevron-right"></i> Laundry</a></li>
                <li><a href="#"><i class="fas fa-chevron-right"></i> Room Cleaning</a></li>
                <li><a href="#"><i class="fas fa-chevron-right"></i> Kitchen Meals</a></li>
                <li><a href="#"><i class="fas fa-chevron-right"></i> Room Booking</a></li>
                <li><a href="#"><i class="fas fa-chevron-right"></i> Events</a></li>
            </ul>
        </div>

        <div class="footer-col">
            <h4>Contact Info</h4>
            <ul>
                <li><i class="fas fa-map-marker-alt"></i> Colombo, Sri Lanka</li>
                <li><i class="fas fa-phone"></i> +94 11 234 5678</li>
                <li><i class="fas fa-envelope"></i> hello@safestay.lk</li>
            </ul>
        </div>
    </div>

    <div class="footer-bottom">
        <p>© 2026 SafeStay. Made with <i class="fas fa-heart" style="color: #ff6b6b;"></i> in Sri Lanka</p>
    </div>
</footer>

<!-- Scripts -->
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>
<script>
    // Initialize AOS
    AOS.init({
        duration: 1000,
        once: true,
        offset: 100
    });

    // Initialize Swiper for Facilities
    var swiper = new Swiper(".mySwiper", {
        slidesPerView: 1,
        spaceBetween: 30,
        loop: true,
        autoplay: {
            delay: 2500,
            disableOnInteraction: false,
        },
        pagination: {
            el: ".swiper-pagination",
            clickable: true,
        },
        breakpoints: {
            640: {
                slidesPerView: 2,
            },
            1024: {
                slidesPerView: 3,
            },
        },
    });

    // Initialize Swiper for Testimonials
    var testimonialSwiper = new Swiper(".testimonialSwiper", {
        slidesPerView: 1,
        spaceBetween: 30,
        loop: true,
        autoplay: {
            delay: 3000,
            disableOnInteraction: false,
        },
        pagination: {
            el: ".swiper-pagination",
            clickable: true,
        },
    });

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
</script>
</body>
</html>