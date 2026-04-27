<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, org.example.model.User" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    List<Map<String, Object>> approvedReviews =
            (List<Map<String, Object>>) request.getAttribute("approvedReviews");
    if (approvedReviews == null) approvedReviews = new ArrayList<Map<String, Object>>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student Feedback | SafeStay</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #eef2ff;
            min-height: 100vh;
            padding: 30px 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* ── Alerts ── */
        .alert {
            width: 100%; max-width: 900px;
            padding: 13px 18px; border-radius: 10px;
            margin-bottom: 16px; font-size: 14px; font-weight: 500;
            display: flex; align-items: center; gap: 8px;
        }
        .alert-success { background: #dcfce7; color: #166534; }
        .alert-error   { background: #fee2e2; color: #991b1b; }

        /* ══ MAIN CARD ══ */
        .main-card {
            width: 100%; max-width: 900px;
            background: white;
            border-radius: 20px;
            display: flex;
            box-shadow: 0 6px 24px rgba(0,0,0,0.09);
            overflow: hidden;
            margin-bottom: 24px;
        }

        .img-side {
            width: 280px; flex-shrink: 0;
            background: #dde8ff;
            display: flex; align-items: center; justify-content: center;
            padding: 24px;
        }
        .img-side img { width: 100%; border-radius: 14px; }

        .form-side { flex: 1; padding: 32px 36px; }
        .form-title { font-size: 20px; font-weight: 700; color: #1e293b; margin-bottom: 20px; }

        /* ── Category ── */
        .sec-label { font-size: 12px; font-weight: 600; color: #64748b; margin-bottom: 10px; display: block; }
        .cat-row { display: flex; gap: 10px; margin-bottom: 22px; }
        .cat-btn {
            flex: 1; border: 1.5px solid #e2e8f0; border-radius: 12px;
            padding: 10px 6px; background: white; cursor: pointer;
            display: flex; flex-direction: column; align-items: center;
            gap: 5px; font-size: 12px; font-weight: 600; color: #64748b;
            transition: 0.15s;
        }
        .cat-btn i { font-size: 18px; }
        .cat-btn.active, .cat-btn:hover {
            border-color: #3b5cf0; background: #eff4ff; color: #3b5cf0;
        }

        /* ── Stars Grid ── */
        .stars-grid {
            display: grid; grid-template-columns: 1fr 1fr;
            gap: 16px 24px; margin-bottom: 18px;
        }
        .star-block-label { font-size: 12px; font-weight: 600; color: #475569; margin-bottom: 7px; }
        .star-pick {
            display: flex; flex-direction: row-reverse;
            justify-content: flex-end; gap: 3px;
        }
        .star-pick input { display: none; }
        .star-pick label {
            font-size: 26px; color: #d1d5db;
            cursor: pointer; line-height: 1; transition: color 0.12s;
        }
        .star-pick input:checked ~ label,
        .star-pick label:hover,
        .star-pick label:hover ~ label { color: #f59e0b; }

        /* ── Upload ── */
        .upload-area {
            border: 1.5px dashed #cbd5e1; border-radius: 10px;
            padding: 12px 16px; background: #f8fafc;
            margin-bottom: 14px; cursor: pointer;
            display: flex; align-items: center; gap: 10px;
            transition: 0.15s;
        }
        .upload-area:hover { border-color: #3b5cf0; }
        .upload-area i { color: #3b5cf0; font-size: 20px; flex-shrink: 0; }
        .upload-area span { font-size: 13px; color: #64748b; }
        /* Hide the actual file input completely */
        #fileInput { display: none; }

        /* ── Textarea ── */
        .feedback-area {
            width: 100%; border: 1px solid #e2e8f0; border-radius: 10px;
            padding: 12px 14px; font-family: inherit; font-size: 13px;
            color: #334155; resize: vertical; min-height: 80px;
            margin-bottom: 18px;
        }
        .feedback-area:focus { outline: none; border-color: #3b5cf0; }
        .feedback-area::placeholder { color: #94a3b8; }

        /* ── Submit ── */
        .btn-submit {
            width: 100%; background: #3b5cf0; color: white;
            border: none; padding: 14px; border-radius: 10px;
            font-size: 15px; font-weight: 700; cursor: pointer;
        }
        .btn-submit:hover { background: #2f4dd4; }

        /* ══ RECENT FEEDBACK ══ */
        .recent-card {
            width: 100%; max-width: 900px; background: white;
            border-radius: 18px; padding: 26px 28px;
            box-shadow: 0 4px 14px rgba(0,0,0,0.06);
        }
        .recent-title {
            font-size: 15px; font-weight: 700; color: #1e293b;
            margin-bottom: 18px; display: flex; align-items: center; gap: 8px;
        }
        .r-item { border-bottom: 1px solid #f1f5f9; padding: 16px 0; }
        .r-item:last-child { border-bottom: none; }
        .r-top { display: flex; justify-content: space-between; margin-bottom: 6px; }
        .r-name { font-weight: 600; font-size: 14px; color: #1e293b; }
        .r-date { font-size: 11px; color: #94a3b8; margin-top: 3px; }
        .stars-show { display: flex; gap: 2px; }
        .stars-show .on  { color: #f59e0b; font-size: 13px; }
        .stars-show .off { color: #d1d5db; font-size: 13px; }
        .cat-tag {
            display: inline-block; background: #eff4ff; color: #3b5cf0;
            font-size: 11px; font-weight: 700; padding: 2px 9px;
            border-radius: 20px; margin: 5px 0;
        }
        .r-comment { font-size: 13px; color: #64748b; line-height: 1.6; }
        .sub-pills { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px; }
        .sub-pill {
            background: #f8fafc; border: 1px solid #e2e8f0;
            border-radius: 20px; padding: 3px 10px; font-size: 11px; color: #475569;
        }
        .owner-rep {
            background: #f1f5f9; border-left: 3px solid #3b5cf0;
            padding: 9px 13px; border-radius: 0 8px 8px 0;
            font-size: 12px; color: #475569; margin-top: 8px;
        }
        .empty-msg { text-align: center; color: #94a3b8; padding: 30px; font-size: 14px; }

        @media(max-width: 620px) {
            .main-card { flex-direction: column; }
            .img-side { width: 100%; height: 160px; }
            .stars-grid { grid-template-columns: 1fr; }
            .cat-row { flex-wrap: wrap; }
        }
    </style>
</head>
<body>

<%-- Alerts --%>
<% if ("true".equals(request.getParameter("success"))) { %>
<div class="alert alert-success">
    <i class="fas fa-check-circle"></i>
    Review submitted successfully! It will appear after owner approval.
</div>
<% } else if (request.getParameter("error") != null) { %>
<div class="alert alert-error">
    <i class="fas fa-exclamation-circle"></i>
    Something went wrong. Please try again.
</div>
<% } %>

<%-- ══ MAIN CARD ══ --%>
<div class="main-card">

    <div class="img-side">
        <img src="https://static.vecteezy.com/system/resources/previews/011/773/207/original/book-review-template-hand-drawn-cartoon-flat-illustration-with-reader-feedback-for-analysis-rating-satisfaction-and-comments-about-publications-vector.jpg" alt="">
    </div>

    <div class="form-side">
        <div class="form-title">Rate Your Stay! ✨</div>

        <%-- enctype multipart — @MultipartConfig servlet ekata --%>
        <form action="<%= request.getContextPath() %>/student/addReview"
              method="POST" enctype="multipart/form-data">

            <%-- Category --%>
            <span class="sec-label">Choose Category:</span>
            <div class="cat-row">
                <button type="button" class="cat-btn active" onclick="pickCat(this,'Room')">
                    <i class="fas fa-bed"></i> Room
                </button>
                <button type="button" class="cat-btn" onclick="pickCat(this,'Meal')">
                    <i class="fas fa-utensils"></i> Meal
                </button>
                <button type="button" class="cat-btn" onclick="pickCat(this,'Service')">
                    <i class="fas fa-concierge-bell"></i> Service
                </button>
            </div>
            <input type="hidden" id="catVal" name="category" value="Room">

            <%-- 4 Star Grids --%>
            <div class="stars-grid">

                <div>
                    <div class="star-block-label">Overall Experience</div>
                    <div class="star-pick">
                        <input type="radio" id="r5" name="rating" value="5" required>
                        <label for="r5">★</label>
                        <input type="radio" id="r4" name="rating" value="4">
                        <label for="r4">★</label>
                        <input type="radio" id="r3" name="rating" value="3">
                        <label for="r3">★</label>
                        <input type="radio" id="r2" name="rating" value="2">
                        <label for="r2">★</label>
                        <input type="radio" id="r1" name="rating" value="1">
                        <label for="r1">★</label>
                    </div>
                </div>

                <div>
                    <div class="star-block-label">Cleanliness</div>
                    <div class="star-pick">
                        <input type="radio" id="c5" name="cleanlinessRating" value="5">
                        <label for="c5">★</label>
                        <input type="radio" id="c4" name="cleanlinessRating" value="4">
                        <label for="c4">★</label>
                        <input type="radio" id="c3" name="cleanlinessRating" value="3">
                        <label for="c3">★</label>
                        <input type="radio" id="c2" name="cleanlinessRating" value="2">
                        <label for="c2">★</label>
                        <input type="radio" id="c1" name="cleanlinessRating" value="1">
                        <label for="c1">★</label>
                    </div>
                </div>

                <div>
                    <div class="star-block-label">Wifi Internet</div>
                    <div class="star-pick">
                        <input type="radio" id="w5" name="wifiRating" value="5">
                        <label for="w5">★</label>
                        <input type="radio" id="w4" name="wifiRating" value="4">
                        <label for="w4">★</label>
                        <input type="radio" id="w3" name="wifiRating" value="3">
                        <label for="w3">★</label>
                        <input type="radio" id="w2" name="wifiRating" value="2">
                        <label for="w2">★</label>
                        <input type="radio" id="w1" name="wifiRating" value="1">
                        <label for="w1">★</label>
                    </div>
                </div>

                <div>
                    <div class="star-block-label">Staff Service</div>
                    <div class="star-pick">
                        <input type="radio" id="s5" name="staffRating" value="5">
                        <label for="s5">★</label>
                        <input type="radio" id="s4" name="staffRating" value="4">
                        <label for="s4">★</label>
                        <input type="radio" id="s3" name="staffRating" value="3">
                        <label for="s3">★</label>
                        <input type="radio" id="s2" name="staffRating" value="2">
                        <label for="s2">★</label>
                        <input type="radio" id="s1" name="staffRating" value="1">
                        <label for="s1">★</label>
                    </div>
                </div>

            </div>

            <%-- File Upload — hidden input, custom styled div --%>
            <input type="file" id="fileInput" name="photo" accept="image/*"
                   onchange="showFile(this)">
            <div class="upload-area" onclick="document.getElementById('fileInput').click()">
                <i class="fas fa-cloud-upload-alt"></i>
                <span id="fileLabel">Choose File &nbsp;&nbsp; No file chosen</span>
            </div>

            <%-- Comment --%>
            <textarea class="feedback-area" name="comment"
                      placeholder="Write your feedback here..."></textarea>

            <button type="submit" class="btn-submit">Submit My Review</button>

        </form>
    </div>
</div>

<%-- ══ RECENT FEEDBACK ══ --%>
<div class="recent-card">
    <div class="recent-title">
        <i class="fas fa-history" style="color:#3b5cf0;"></i> Recent Feedback
    </div>

    <% if (approvedReviews.isEmpty()) { %>
    <div class="empty-msg">No approved reviews yet.</div>
    <% } else {
        for (Map<String, Object> r : approvedReviews) {
            int stars = r.get("rating") != null ? (int)r.get("rating") : 0;
            int cr = r.get("cleanlinessRating") != null ? (int)r.get("cleanlinessRating") : 0;
            int wr = r.get("wifiRating")        != null ? (int)r.get("wifiRating")        : 0;
            int sr = r.get("staffRating")       != null ? (int)r.get("staffRating")       : 0;
            String cat  = r.get("category") != null ? r.get("category").toString() : "";
            String date = r.get("date")     != null ? r.get("date").toString().substring(0,16) : "";
            String rep  = r.get("ownerReply") != null ? r.get("ownerReply").toString() : "";
    %>
    <div class="r-item">
        <div class="r-top">
            <div>
                <div class="r-name">
                    <i class="fas fa-user-circle" style="color:#cbd5e1;"></i>
                    &nbsp;<%= r.get("name") %>
                </div>
                <div class="r-date"><%= date %></div>
            </div>
            <div class="stars-show">
                <% for (int i=1;i<=5;i++) { %>
                <i class="fas fa-star <%= i<=stars?"on":"off" %>"></i>
                <% } %>
            </div>
        </div>

        <% if (!cat.isEmpty()) { %>
        <span class="cat-tag"><i class="fas fa-tag"></i> <%= cat %></span>
        <% } %>

        <div class="r-comment"><%= r.get("comment") != null ? r.get("comment") : "" %></div>

        <div class="sub-pills">
            <% if (cr>0) { %><span class="sub-pill">🧹 Clean: <%= cr %>/5</span><% } %>
            <% if (wr>0) { %><span class="sub-pill">📶 WiFi: <%= wr %>/5</span><% } %>
            <% if (sr>0) { %><span class="sub-pill">👥 Staff: <%= sr %>/5</span><% } %>
        </div>

        <% if (!rep.isEmpty()) { %>
        <div class="owner-rep">
            <strong><i class="fas fa-reply"></i> Owner's Reply:</strong><br><%= rep %>
        </div>
        <% } %>
    </div>
    <% } } %>
</div>

<script>
    function pickCat(btn, val) {
        document.querySelectorAll('.cat-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        document.getElementById('catVal').value = val;
    }

    function showFile(input) {
        const label = document.getElementById('fileLabel');
        label.textContent = input.files.length > 0
            ? input.files[0].name
            : 'Choose File   No file chosen';
    }
</script>
</body>
</html>
