<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.*, org.example.dao.*, java.util.*, java.text.*" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null || !user.getRole().equalsIgnoreCase("Student")) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

  BookingDAO bookingDAO = new BookingDAO();
  RoomDAO roomDAO = new RoomDAO();

  List<RoomBooking> myBookings = bookingDAO.getStudentBookings(user.getUserId());
  RoomAssignment currentAssignment = bookingDAO.getStudentAssignment(user.getUserId());
  List<Room> availableRooms = roomDAO.getAvailableRooms();

  SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Room Booking - SafeStay</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
    body { background: #f8fafc; padding: 30px; }
    .container { max-width: 1200px; margin: 0 auto; }

    .header {
      background: white;
      border-radius: 15px;
      padding: 25px;
      margin-bottom: 25px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    h2 { color: #1e293b; margin-bottom: 20px; }
    h3 { color: #4f46e5; margin-bottom: 15px; }

    .current-room {
      background: linear-gradient(135deg, #6366f1, #8b5cf6);
      color: white;
      padding: 25px;
      border-radius: 15px;
      margin-bottom: 25px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .current-room h3 { font-size: 18px; opacity: 0.9; color: white; }
    .current-room h2 { font-size: 28px; color: white; margin: 5px 0; }
    .current-room .price { font-size: 20px; background: rgba(255,255,255,0.2); padding: 8px 20px; border-radius: 30px; }

    .booking-form {
      background: white;
      padding: 25px;
      border-radius: 15px;
      margin-bottom: 25px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }

    .form-row {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
      margin-bottom: 20px;
    }

    .form-group { margin-bottom: 15px; }
    label {
      display: block;
      font-weight: 600;
      margin-bottom: 5px;
      color: #1e293b;
    }

    select, input {
      width: 100%;
      padding: 12px;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      font-size: 15px;
    }

    .price-display {
      background: #f1f5f9;
      padding: 20px;
      border-radius: 10px;
      margin: 20px 0;
      text-align: center;
      border: 2px dashed #6366f1;
    }

    .estimated-price {
      font-size: 36px;
      font-weight: 700;
      color: #10b981;
    }

    .price-label {
      font-size: 14px;
      color: #64748b;
      margin-top: 5px;
    }

    .btn {
      background: #6366f1;
      color: white;
      border: none;
      padding: 14px 30px;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      width: 100%;
      font-size: 16px;
    }
    .btn:hover { background: #4f46e5; }

    /* Price Cards for Available Rooms */
    .price-cards {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 20px;
      margin-bottom: 30px;
    }

    .price-card {
      background: white;
      border-radius: 12px;
      padding: 20px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      border-left: 4px solid #6366f1;
    }

    .room-badge {
      display: inline-block;
      padding: 4px 12px;
      background: #eef2ff;
      color: #4f46e5;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
      margin-bottom: 10px;
    }

    .room-detail-price {
      font-size: 24px;
      font-weight: 700;
      color: #0f172a;
      margin: 10px 0;
    }

    .facility-icons {
      display: flex;
      gap: 10px;
      margin: 10px 0;
    }

    .facility-icon {
      background: #f1f5f9;
      padding: 5px 10px;
      border-radius: 20px;
      font-size: 12px;
    }

    .rooms-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 20px;
      margin: 20px 0;
    }

    .room-card {
      background: white;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }

    .room-header {
      background: linear-gradient(135deg, #6366f1, #8b5cf6);
      color: white;
      padding: 15px;
    }

    .room-body {
      padding: 15px;
    }

    .room-price {
      font-size: 22px;
      font-weight: 700;
      color: #10b981;
      margin: 10px 0;
    }

    table {
      width: 100%;
      background: white;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }

    th {
      background: #f1f5f9;
      padding: 12px;
      text-align: left;
    }

    td {
      padding: 12px;
      border-bottom: 1px solid #e2e8f0;
    }

    .badge {
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
    }
    .badge-pending { background: #fff3cd; color: #856404; }
    .badge-approved { background: #d4edda; color: #155724; }

    @media (max-width: 768px) {
      .price-cards, .rooms-grid { grid-template-columns: 1fr; }
      .form-row { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
<div class="container">
  <div class="header">
    <h1><i class="fas fa-bed"></i> Room Booking</h1>
    <a href="index.jsp" style="color: #6366f1; text-decoration: none;">← Back to Dashboard</a>
  </div>

  <% if (currentAssignment != null) { %>
  <div class="current-room">
    <div>
      <h3>Your Current Room</h3>
      <h2><i class="fas fa-door-open"></i> Room <%= currentAssignment.getRoomNumber() %></h2>
    </div>
    <div class="price">Rs. <%= String.format("%,.0f", currentAssignment.getRentAmount()) %>/month</div>
  </div>
  <% } %>

  <!-- Price Guide Cards -->
  <h2><i class="fas fa-tags"></i> Room Prices</h2>
  <div class="price-cards">
    <div class="price-card">
      <span class="room-badge">Single Room</span>
      <div class="room-detail-price">Rs. 40,000 <span style="font-size:14px; color:#64748b;">with AC</span></div>
      <div class="room-detail-price">Rs. 30,000 <span style="font-size:14px; color:#64748b;">with Fan</span></div>
      <div class="facility-icons">
        <span class="facility-icon"><i class="fas fa-wind"></i> AC</span>
        <span class="facility-icon"><i class="fas fa-fan"></i> Fan</span>
        <span class="facility-icon"><i class="fas fa-shower"></i> Attached Bath</span>
      </div>
    </div>

    <div class="price-card">
      <span class="room-badge">Double Room</span>
      <div class="room-detail-price">Rs. 20,000 <span style="font-size:14px; color:#64748b;">with AC</span></div>
      <div class="room-detail-price">Rs. 15,000 <span style="font-size:14px; color:#64748b;">with Fan</span></div>
      <div class="facility-icons">
        <span class="facility-icon"><i class="fas fa-wind"></i> AC</span>
        <span class="facility-icon"><i class="fas fa-fan"></i> Fan</span>
        <span class="facility-icon"><i class="fas fa-shower"></i> Attached Bath</span>
      </div>
    </div>

    <div class="price-card">
      <span class="room-badge">Triple Room</span>
      <div class="room-detail-price">Rs. 13,000 <span style="font-size:14px; color:#64748b;">with AC</span></div>
      <div class="room-detail-price">Rs. 10,000 <span style="font-size:14px; color:#64748b;">with Fan</span></div>
      <div class="facility-icons">
        <span class="facility-icon"><i class="fas fa-wind"></i> AC</span>
        <span class="facility-icon"><i class="fas fa-fan"></i> Fan</span>
        <span class="facility-icon"><i class="fas fa-shower"></i> Common Bath</span>
      </div>
    </div>
  </div>

  <!-- Booking Form with Smart Price -->
  <div class="booking-form">
    <h2>Request New Room</h2>
    <form id="bookingForm" action="<%= request.getContextPath() %>/booking/create" method="post">
      <input type="hidden" name="action" value="create">

      <div class="form-row">
        <div class="form-group">
          <label>Room Type</label>
          <select name="roomType" id="roomType" onchange="calculatePrice()">
            <option value="Single">Single Room</option>
            <option value="Double">Double Room</option>
            <option value="Triple">Triple Room</option>
          </select>
        </div>

        <div class="form-group">
          <label>Floor</label>
          <select name="floor">
            <option value="0">Any Floor</option>
            <option value="1">1st Floor</option>
            <option value="2">2nd Floor</option>
            <option value="3">3rd Floor</option>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>AC Required?</label>
          <select name="needAc" id="needAc" onchange="calculatePrice()">
            <option value="No">No AC (Cheaper)</option>
            <option value="Yes">Yes, need AC</option>
          </select>
        </div>

        <div class="form-group">
          <label>Fan Required?</label>
          <select name="needFan" id="needFan" onchange="calculatePrice()">
            <option value="Yes">Yes, need Fan</option>
            <option value="No">No Fan (Not Recommended)</option>
          </select>
        </div>
      </div>

      <!-- Smart Price Display -->
      <div class="price-display">
        <div class="estimated-price" id="estimatedPrice">Rs. 30,000</div>
        <div class="price-label">Estimated monthly rent based on your selection</div>
      </div>

      <button type="submit" class="btn">Submit Request</button>
    </form>
  </div>

  <!-- Available Rooms -->
  <h2>Available Rooms (<%= availableRooms.size() %>)</h2>
  <div class="rooms-grid">
    <% for (Room room : availableRooms) { %>
    <div class="room-card">
      <div class="room-header">
        <h3>Room <%= room.getRoomNumber() %></h3>
        <p><%= room.getRoomType() %> • Floor <%= room.getFloor() %></p>
      </div>
      <div class="room-body">
        <div style="margin: 10px 0;">
          <% if ("Yes".equals(room.getHasAc())) { %>
          <span class="facility-icon"><i class="fas fa-wind"></i> AC</span>
          <% } %>
          <% if ("Yes".equals(room.getHasFan())) { %>
          <span class="facility-icon"><i class="fas fa-fan"></i> Fan</span>
          <% } %>
          <% if ("Yes".equals(room.getHasAttachedBathroom())) { %>
          <span class="facility-icon"><i class="fas fa-shower"></i> Attached Bath</span>
          <% } %>
        </div>
        <div class="room-price">Rs. <%= String.format("%,.0f", room.getPriceMonthly()) %> <span style="font-size:14px;">/month</span></div>
        <button onclick="selectRoom(<%= room.getId() %>, '<%= room.getRoomType() %>', '<%= room.getHasAc() %>', '<%= room.getHasFan() %>')"
                style="width:100%; padding:10px; background:#6366f1; color:white; border:none; border-radius:8px; cursor:pointer;">
          Select This Room
        </button>
      </div>
    </div>
    <% } %>
  </div>

  <!-- My Booking Requests -->
  <h2>My Booking Requests</h2>
  <table>
    <thead>
    <tr>
      <th>Booking No.</th>
      <th>Date</th>
      <th>Type</th>
      <th>AC/Fan</th>
      <th>Floor</th>
      <th>Status</th>
      <th>Action</th>
    </tr>
    </thead>
    <tbody>
    <% for (RoomBooking booking : myBookings) { %>
    <tr>
      <td><%= booking.getBookingNo() %></td>
      <td><%= sdf.format(booking.getCreatedAt()) %></td>
      <td><%= booking.getRoomType() %></td>
      <td>
        <% if ("Yes".equals(booking.getNeedAc())) { %>AC <% } %>
        <% if ("Yes".equals(booking.getNeedFan())) { %>Fan <% } %>
      </td>
      <td><%= booking.getFloor() > 0 ? "Floor "+booking.getFloor() : "Any" %></td>
      <td><span class="badge badge-<%= booking.getStatus().toLowerCase() %>"><%= booking.getStatus() %></span></td>
      <td>
        <% if ("Pending".equals(booking.getStatus())) { %>
        <button onclick="cancelBooking(<%= booking.getId() %>)"
                style="padding:5px 10px; background:#ef4444; color:white; border:none; border-radius:5px;">
          Cancel
        </button>
        <% } %>
      </td>
    </tr>
    <% } %>
    </tbody>
  </table>
</div>

<script>
  // Price calculation based on room type and AC selection
  function calculatePrice() {
    const roomType = document.getElementById('roomType').value;
    const needAc = document.getElementById('needAc').value;
    const priceElement = document.getElementById('estimatedPrice');

    let price = 0;

    if (roomType === 'Single') {
      price = (needAc === 'Yes') ? 40000 : 30000;
    } else if (roomType === 'Double') {
      price = (needAc === 'Yes') ? 20000 : 15000;
    } else if (roomType === 'Triple') {
      price = (needAc === 'Yes') ? 13000 : 10000;
    }

    priceElement.textContent = 'Rs. ' + price.toLocaleString();
  }

  // Set form values when selecting a specific room
  function selectRoom(roomId, roomType, hasAc, hasFan) {
    document.getElementById('roomType').value = roomType;
    document.getElementById('needAc').value = hasAc;
    document.getElementById('needFan').value = hasFan;
    calculatePrice();

    // Also could submit directly
    if (confirm('Request this room?')) {
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '<%= request.getContextPath() %>/booking/create';

      const inputs = [
        { name: 'action', value: 'create' },
        { name: 'roomType', value: roomType },
        { name: 'floor', value: '0' },
        { name: 'needAc', value: hasAc },
        { name: 'needFan', value: hasFan }
      ];

      inputs.forEach(i => {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = i.name;
        input.value = i.value;
        form.appendChild(input);
      });

      document.body.appendChild(form);
      form.submit();
    }
  }

  function cancelBooking(id) {
    if (confirm('Cancel this request?')) {
      location.href = '<%= request.getContextPath() %>/booking/cancel?bookingId=' + id;
    }
  }

  // Initialize price on page load
  window.onload = calculatePrice;
</script>
</body>
</html>