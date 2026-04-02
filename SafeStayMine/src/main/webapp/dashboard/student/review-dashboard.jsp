<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, org.example.dao.OwnerDAO" %>
<%
  OwnerDAO ownerDAO = new OwnerDAO();
  List<Map<String, Object>> reviews = ownerDAO.getAllReviews(); // මෙතනට ඔයාගේ DAO එකෙන් Approved ඒවා විතරක් ගන්න
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Student Feedback - SafeStay</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    :root { --primary: #4f46e5; --accent: #fbbf24; }
    body { font-family: 'Poppins', sans-serif; background-color: #f1f5f9; padding: 20px; }
    .container { max-width: 1000px; margin: auto; }
    .main-card { background: white; border-radius: 20px; display: flex; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.1); margin-bottom: 30px; }
    .image-section { flex: 1; background: #eef2ff; padding: 20px; display: flex; align-items: center; }
    .form-section { flex: 1.2; padding: 40px; }

    /* Stars UI */
    .star-rating { display: flex; flex-direction: row-reverse; justify-content: flex-end; gap: 10px; margin: 15px 0; }
    .star-rating input { display: none; }
    .star-rating label { font-size: 30px; color: #cbd5e1; cursor: pointer; transition: 0.2s; }
    .star-rating input:checked ~ label, .star-rating label:hover, .star-rating label:hover ~ label { color: var(--accent); }

    /* Review List UI */
    .review-list-section { background: white; border-radius: 20px; padding: 30px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
    .review-item { border-bottom: 1px solid #f1f5f9; padding: 20px 0; }
    .review-header { display: flex; justify-content: space-between; align-items: center; }
    .student-name { font-weight: 600; color: #1e293b; }
    .rating-stars { color: var(--accent); font-size: 14px; }
    .comment-text { color: #64748b; margin-top: 8px; font-size: 14px; }
    .owner-reply { background: #f8fafc; border-left: 4px solid var(--primary); padding: 15px; margin-top: 15px; border-radius: 8px; font-size: 13px; }
  </style>
</head>
<body>
<div class="container">
  <div class="main-card">
    <div class="image-section">
      <img src="https://static.vecteezy.com/system/resources/previews/011/773/207/original/book-review-template-hand-drawn-cartoon-flat-illustration-with-reader-feedback-for-analysis-rating-satisfaction-and-comments-about-publications-vector.jpg" style="width:100%; border-radius:15px;">
    </div>
    <div class="form-section">
      <h2>Rate Your Stay! ✨</h2>
      <form action="<%= request.getContextPath() %>/student/addReview" method="POST">
        <div class="star-rating">
          <input type="radio" id="s5" name="rating" value="5" required/><label for="s5">★</label>
          <input type="radio" id="s4" name="rating" value="4"/><label for="s4">★</label>
          <input type="radio" id="s3" name="rating" value="3"/><label for="s3">★</label>
          <input type="radio" id="s2" name="rating" value="2"/><label for="s2">★</label>
          <input type="radio" id="s1" name="rating" value="1"/><label for="s1">★</label>
        </div>
        <textarea name="comment" rows="4" placeholder="How was your experience?" required style="width:100%; padding:15px; border-radius:10px; border:1px solid #ddd;"></textarea>
        <button type="submit" style="width:100%; background:var(--primary); color:white; border:none; padding:15px; border-radius:10px; margin-top:15px; cursor:pointer; font-weight:600;">Submit Review</button>
      </form>
    </div>
  </div>

  <div class="review-list-section">
    <h3>Recent Student Feedback</h3>
    <% for(Map<String, Object> r : reviews) {
      if("Approved".equals(r.get("status"))) { %>
    <div class="review-item">
      <div class="review-header">
        <span class="student-name"><%= r.get("name") %></span>
        <div class="rating-stars">
          <% int stars = (int)r.get("rating");
            for(int i=1; i<=5; i++) { %>
          <i class="<%= i<=stars ? "fas" : "far" %> fa-star"></i>
          <% } %>
        </div>
      </div>
      <p class="comment-text"><%= r.get("comment") %></p>

      <% if(r.get("ownerReply") != null) { %>
      <div class="owner-reply">
        <strong>Hostel Owner's Reply:</strong><br>
        <%= r.get("ownerReply") %>
      </div>
      <% } %>
    </div>
    <% } } %>
  </div>
</div>
</body>
</html>