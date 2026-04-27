<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.User" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null || user.getRole() == null || !"Student".equalsIgnoreCase(user.getRole())) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Student Meal </title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    :root{
      --page-bg-1:#6fa4dd;
      --page-bg-2:#5f95d0;
      --page-bg-3:#79ade4;

      --glass:#f7f8fb;
      --glass-2:#eef1f7;
      --glass-3:#ffffff;
      --card:#f8f9fc;
      --card-2:#eef2f8;

      --line:#d7deea;
      --line-soft:#e4e9f2;

      --text:#35476a;
      --text-2:#6d7f9e;
      --muted:#8e9db7;

      --primary:#6a78e6;
      --primary-2:#7d5ac9;

      --blue-btn-1:#6e83ee;
      --blue-btn-2:#7b5fd1;
      --red-btn-1:#eb7f8a;
      --red-btn-2:#d1606d;
      --gray-btn-1:#b6c1d6;
      --gray-btn-2:#97a4bd;

      --shadow-sm:0 10px 22px rgba(45,75,120,.10);
      --shadow-md:0 18px 38px rgba(40,66,108,.14);
      --shadow-lg:0 28px 60px rgba(27,48,82,.18);
    }

    *{box-sizing:border-box}

    html,body{
      margin:0;
      padding:0;
      min-height:100vh;
      font-family:Arial,sans-serif;
      color:var(--text);
      background:
              radial-gradient(circle at 15% 18%, rgba(255,255,255,.18), transparent 18%),
              radial-gradient(circle at 85% 22%, rgba(255,255,255,.14), transparent 16%),
              radial-gradient(circle at 22% 82%, rgba(255,255,255,.12), transparent 18%),
              linear-gradient(135deg, var(--page-bg-1) 0%, var(--page-bg-2) 55%, var(--page-bg-3) 100%);
    }

    body{
      padding:28px 0 40px;
    }

    .container{
      width:92%;
      max-width:1320px;
      margin:0 auto;
    }

    .topbar{
      background:rgba(248,249,252,.88);
      backdrop-filter:blur(10px);
      -webkit-backdrop-filter:blur(10px);
      border:1px solid rgba(255,255,255,.55);
      border-radius:30px;
      padding:24px 26px;
      display:flex;
      justify-content:space-between;
      align-items:center;
      gap:18px;
      margin-bottom:20px;
      box-shadow:var(--shadow-lg);
    }

    .topbar h2{
      margin:0;
      font-size:31px;
      font-weight:800;
      color:#6773df;
      letter-spacing:.2px;
    }

    .top-meta{
      color:var(--text-2);
      font-size:14px;
      margin-top:8px;
      font-weight:600;
    }

    .logout-btn{
      background:linear-gradient(135deg, var(--red-btn-1), var(--red-btn-2));
      color:#fff;
      text-decoration:none;
      padding:12px 18px;
      border-radius:16px;
      font-weight:700;
      box-shadow:0 12px 22px rgba(55,78,123,.18);
      transition:.22s ease;
    }

    .logout-btn:hover,.btn:hover,.stat-card:hover,.modal-close:hover{
      transform:translateY(-2px);
    }

    .notifications-card{
      background:linear-gradient(180deg, #eef3f9 0%, #e6edf6 100%);
      backdrop-filter:blur(10px);
      -webkit-backdrop-filter:blur(10px);
      border:1px solid #d7deea;
      border-radius:30px;
      padding:22px;
      box-shadow
      :var(--shadow-lg);
      margin-bottom:24px;
    }

    .notifications-card h3{
      margin:0 0 14px;
      font-size:31px;
      font-weight:800;
      color:#6773df;
      letter-spacing:.2px;
    }
    .notifications-card h3{
       margin:0 0 14px;
       font-size:16px;
       font-weight:800;
       color:#6773df;
       letter-spacing:.2px;
      text-shadow:0 6px 18px rgba(39,58,94,.18);
      padding-left:6px;
    }

    .notification-item{
      border:1px solid #32cd32;
      border-radius:18px;
      background:linear-gradient(180deg, #eaffea 0%, #d6f7d6 100%);
      padding:16px;
      margin-bottom:12px;
      box-shadow:var(--shadow-sm);
    }

    .notification-item:last-child{
      margin-bottom:0;
    }

    .notification-time{
      font-size:14px;
      font-weight:700;
      color:#35476A;
      margin-bottom:8px;
    }

    .notification-text{
      font-size:20px;
      line-height:1.55;
      font-weight:700;
      color:#35476A;
      white-space:pre-wrap;
      word-break:break-word;
    }

    .empty-note{
      text-align:center;
      color:#b57c86;
      font-weight:700;
      padding:18px 12px;
    }

    .stats-row{
      display:flex;
      gap:16px;
      flex-wrap:wrap;
      margin-bottom:24px;
    }

    .stat-card{
      flex:1 1 280px;
      border-radius:26px;
      padding:22px 24px;
      box-shadow:var(--shadow-lg);
      cursor:pointer;
      transition:.22s ease;
      border:1px solid rgba(255,255,255,.55);
      backdrop-filter:blur(10px);
      -webkit-backdrop-filter:blur(10px);
    }

    #weekTotalCard{
      background:linear-gradient(135deg, rgba(247,248,252,.92) 0%, rgba(236,238,255,.92) 100%);
    }

    #historyStatCard{
      background:linear-gradient(135deg, rgba(247,248,252,.92) 0%, rgba(239,244,251,.92) 100%);
    }

    .stat-card:hover{
      box-shadow:0 22px 40px rgba(61,90,133,.16);
    }

    .stat-label{
      font-size:13px;
      font-weight:800;
      letter-spacing:.08em;
      text-transform:uppercase;
      color:#6a78e2;
      margin-bottom:8px;
    }

    .stat-value{
      font-size:34px;
      font-weight:800;
      color:var(--text);
      line-height:1.15;
    }

    .stat-subtext{
      margin-top:8px;
      font-size:13px;
      color:var(--muted);
      font-weight:700;
    }

    .meal-section{
      margin-bottom:30px;
    }

    .meal-section.active-edit{
      scroll-margin-top:24px;
    }

    .meal-section.active-edit .meal-panel{
      border:1px solid rgba(123,95,209,.45);
      box-shadow:0 0 0 5px rgba(123,95,209,.10), var(--shadow-lg);
    }

    .form-message{
      margin:0 0 12px;
      padding:12px 14px;
      border-radius:14px;
      font-size:13px;
      font-weight:700;
      display:none;
      border:1px solid transparent;
    }

    .form-message.error{
      display:block;
      background:linear-gradient(180deg, #fff0f2 0%, #ffe2e7 100%);
      border-color:#f0b8c2;
      color:#b34d61;
    }

    .form-message.success{
      display:block;
      background:linear-gradient(180deg, #effaf1 0%, #ddf2e2 100%);
      border-color:#b9dcc0;
      color:#2f7850;
    }

    .meal-head{
      display:flex;
      justify-content:space-between;
      align-items:center;
      flex-wrap:wrap;
      gap:12px;
      margin-bottom:12px;
    }

    .meal-title{
      font-size:27px;
      font-weight:800;
      text-transform:capitalize;
      color:#f8fbff;
      text-shadow:0 6px 18px rgba(39,58,94,.18);
      padding-left:6px;
    }

    .deadline{
      font-size:14px;
      color:#ffffff;
      font-weight:800;
      background:rgba(77,110,166,.22);
      border:1px solid rgba(255,255,255,.22);
      padding:10px 14px;
      border-radius:16px;
      box-shadow:var(--shadow-sm);
    }

    .deadline.expired{
      background:rgba(201,83,102,.22);
      color:#fff7f8;
    }

    .meal-panel{
      background:rgba(248,249,252,.88);
      backdrop-filter:blur(10px);
      -webkit-backdrop-filter:blur(10px);
      border:1px solid rgba(255,255,255,.52);
      border-radius:30px;
      padding:18px;
      box-shadow:var(--shadow-lg);
    }

    .columns-wrap{
      min-height:200px;
      border:1px dashed #c6d2e4;
      border-radius:24px;
      padding:16px;
      display:flex;
      gap:16px;
      flex-wrap:wrap;
      align-items:flex-start;
      background:linear-gradient(180deg, rgba(255,255,255,.88) 0%, rgba(239,243,249,.88) 100%);
    }

    .empty-text{
      width:100%;
      min-height:150px;
      display:flex;
      align-items:center;
      justify-content:center;
      color:var(--muted);
      font-size:16px;
      font-weight:700;
    }

    .column-card{
      width:220px;
      background:linear-gradient(180deg, #ffffff 0%, #eef2f8 100%);
      border:1px solid #d7deea;
      border-radius:30px;
      overflow:hidden;
      cursor:pointer;
      transition:.18s ease;
      user-select:none;
      box-shadow:0 18px 30px rgba(44,57,80,.13);
    }

    .column-card:hover{
      transform:translateY(-2px);
      box-shadow:0 22px 36px rgba(44,57,80,.16);
    }

    .column-card.selected{
      border-color:#7b5fd1;
      box-shadow:0 0 0 5px rgba(123,95,209,.12), 0 22px 36px rgba(44,57,80,.16);
      background:linear-gradient(180deg, #f5f2ff 0%, #ebe6ff 100%);
    }

    .column-card.disabled{
      opacity:.6;
      cursor:not-allowed;
    }

    .column-top{
      min-height:132px;
      border-bottom:1px solid #dce3ee;
      background:linear-gradient(180deg, #fafcff 0%, #edf2f8 100%);
      padding:12px;
    }

    .column-bottom{
      padding:12px;
      text-align:center;
      background:linear-gradient(180deg, rgba(255,255,255,.42), rgba(230,236,246,.6));
    }

    .split-grid{
      display:grid;
      grid-template-columns:repeat(2,1fr);
      gap:10px;
    }

    .split-part{
      border:1px solid #d8dfeb;
      border-radius:16px;
      padding:8px;
      background:linear-gradient(180deg, #ffffff 0%, #f1f4f9 100%);
      box-shadow:0 8px 16px rgba(50,61,83,.07);
    }

    .img-preview{
      width:100%;
      height:74px;
      border:1px dashed #c8d2e2;
      border-radius:14px;
      background:linear-gradient(180deg, #ffffff 0%, #edf2f8 100%);
      display:flex;
      align-items:center;
      justify-content:center;
      overflow:hidden;
      font-size:11px;
      color:var(--muted);
      text-align:center;
      box-shadow:inset 0 1px 2px rgba(255,255,255,.9);
    }

    .img-preview img{
      max-width:100%;
      max-height:100%;
      width:auto;
      height:auto;
      display:block;
      margin:0 auto;
      object-fit:contain;
    }

    .part-name,.item-name{
      margin-top:8px;
      font-size:12px;
      font-weight:800;
      text-align:center;
      word-break:break-word;
      color:var(--text);
    }

    .item-price{
      font-size:13px;
      font-weight:800;
      color:var(--text);
      margin-top:6px;
    }

    .meal-actions{
      margin-top:16px;
      display:flex;
      justify-content:space-between;
      align-items:center;
      flex-wrap:wrap;
      gap:12px;
    }

    .live-total{
      font-size:20px;
      font-weight:800;
      color:var(--text);
    }

    .btn{
      border:none;
      border-radius:14px;
      padding:11px 17px;
      font-size:13px;
      font-weight:700;
      cursor:pointer;
      transition:.22s ease;
      box-shadow:0 10px 18px rgba(55,70,98,.14);
    }

    .btn-blue{
      background:linear-gradient(135deg, var(--blue-btn-1), var(--blue-btn-2));
      color:#fff;
    }

    .btn-red{
      background:linear-gradient(135deg, var(--red-btn-1), var(--red-btn-2));
      color:#fff;
    }

    .btn-gray{
      background:linear-gradient(135deg, var(--gray-btn-1), var(--gray-btn-2));
      color:#fff;
    }

    .btn:disabled{
      opacity:.6;
      cursor:not-allowed;
      box-shadow:none;
    }

    .history-card{
      background:rgba(248,249,252,.88);
      backdrop-filter:blur(10px);
      -webkit-backdrop-filter:blur(10px);
      border:1px solid rgba(255,255,255,.52);
      border-radius:30px;
      padding:22px;
      box-shadow:var(--shadow-lg);
      margin-top:34px;
    }

    .history-card h3{
      margin-top:0;
      margin-bottom:16px;
      font-size:26px;
      color:#6773df;
    }

    .modal-backdrop{
      position:fixed;
      inset:0;
      background:rgba(35,46,66,.28);
      backdrop-filter:blur(6px);
      display:none;
      align-items:center;
      justify-content:center;
      padding:20px;
      z-index:1000;
    }

    .modal-backdrop.show{
      display:flex;
    }

    .modal-card{
      width:min(880px,100%);
      max-height:85vh;
      overflow:auto;
      background:linear-gradient(180deg, #f9fbff 0%, #eef2f8 100%);
      border:1px solid rgba(255,255,255,.65);
      border-radius:28px;
      box-shadow:0 30px 65px rgba(21,31,48,.22);
      padding:22px;
    }

    .modal-header{
      display:flex;
      justify-content:space-between;
      align-items:flex-start;
      gap:12px;
      margin-bottom:14px;
    }

    .modal-title{
      margin:0;
      font-size:25px;
      color:#6875df;
    }

    .modal-subtitle{
      margin-top:6px;
      color:var(--muted);
      font-size:14px;
      font-weight:700;
    }

    .modal-close{
      background:linear-gradient(135deg, #bbc5d6, #98a4b8);
      color:#fff;
      border:none;
      border-radius:14px;
      padding:10px 14px;
      font-weight:700;
      cursor:pointer;
      transition:.2s ease;
      box-shadow:0 8px 16px rgba(53,67,92,.12);
    }

    table{
      width:100%;
      border-collapse:collapse;
      background:#f9fbff;
      border-radius:18px;
      overflow:hidden;
    }

    th,td{
      padding:14px 12px;
      border-bottom:1px solid #dde5ef;
      text-align:left;
      vertical-align:top;
      font-size:14px;
    }

    th{
      background:#e8edf6;
      color:var(--text);
    }

    tr:hover td{
      background:#f1f5fb;
    }

    @media (max-width:700px){
      .topbar{flex-direction:column;align-items:flex-start}
      .column-card{width:100%}
      .deadline{width:100%}
    }
  </style>
</head>
<body>
<div class="container">
  <div class="topbar">
    <div>
      <h2>Student Meal </h2>
      <div class="top-meta">Student ID: <strong><%= user.getUserId() %></strong> | Name: <strong><%= user.getFullName() != null ? user.getFullName() : user.getUsername() %></strong></div>
    </div>
    <a class="logout-btn" href="<%=request.getContextPath()%>/logout">Logout</a>
  </div>

  <div class="notifications-card">
    <h3>Meal Notifications</h3>
    <div id="studentNotificationsWrap">
      <div class="empty-note">No notifications yet.</div>
    </div>
  </div>

  <div class="stats-row">
    <div class="stat-card" id="weekTotalCard" onclick="scrollToCurrentWeekHistory()">
      <div class="stat-label">Week Total</div>
      <div class="stat-value">Rs. <span id="weekTotalValue">0.00</span></div>
      <div class="stat-subtext" id="weekTotalRange">This week</div>
    </div>
    <div class="stat-card" id="historyStatCard" onclick="openWeeklyHistoryModal()">
      <div class="stat-label">History</div>
      <div class="stat-value"><span id="historyWeekCount">0</span> Weeks</div>
      <div class="stat-subtext">View week start date, end date and week total</div>
    </div>
  </div>

  <div id="mealSections"></div>

  <div class="history-card">
    <h3>Meal History</h3>
    <table>
      <thead><tr><th>Meal Category</th><th>Ordered Items</th><th>Total Price</th><th>Ordered At</th><th>Order Before</th><th>Actions</th></tr></thead>
      <tbody id="historyTableBody"><tr><td colspan="6" style="text-align:center;color:#7a8599;">No orders yet.</td></tr></tbody>
    </table>
  </div>
</div>

<div class="modal-backdrop" id="weeklyHistoryModal" onclick="handleWeeklyHistoryBackdrop(event)">
  <div class="modal-card">
    <div class="modal-header">
      <div>
        <h3 class="modal-title">Weekly Meal History</h3>
        <div class="modal-subtitle">Week start date, week end date and total amount</div>
      </div>
      <button type="button" class="modal-close" onclick="closeWeeklyHistoryModal()">Close</button>
    </div>
    <table>
      <thead><tr><th>Week Start Date</th><th>Week End Date</th><th>Week Total</th></tr></thead>
      <tbody id="weeklyHistoryTableBody"><tr><td colspan="3" style="text-align:center;color:#7a8599;">No weekly history yet.</td></tr></tbody>
    </table>
  </div>
</div>

<script>
  var mealTypes=["Breakfast","Lunch","Dinner","Tea"];
  var mealLayouts={Breakfast:{sectionId:0,orderBefore:"",columns:[]},Lunch:{sectionId:0,orderBefore:"",columns:[]},Dinner:{sectionId:0,orderBefore:"",columns:[]},Tea:{sectionId:0,orderBefore:"",columns:[]}};
  var studentOrders=[];
  var weeklyOrderSummary=[];
  var selections={Breakfast:[],Lunch:[],Dinner:[],Tea:[]};
  var editingOrderId=null;
  var editingMealType="";
  var studentNotifications=[];

  function showSectionMessage(mealType,message,type){
    var el=document.getElementById('message_'+mealType);
    if(!el)return;
    el.className='form-message '+(type||'error');
    el.textContent=message||'';
    el.style.display=message?'block':'none';
  }

  function clearSectionMessage(mealType){
    showSectionMessage(mealType,'','error');
  }

  function formatDateTime(dt){
    if(!dt)return "No deadline";
    var d=new Date(dt);
    return isNaN(d.getTime())?dt:d.toLocaleString();
  }

  function escapeHtml(text){
    text=String(text||"");
    return text.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/\"/g,"&quot;").replace(/'/g,"&#039;");
  }

  function isExpired(deadline){
    if(!deadline)return false;
    var d=new Date(deadline);
    return !isNaN(d.getTime())&&new Date().getTime()>d.getTime();
  }

  function formatMoney(v){
    return parseFloat(v||0).toFixed(2);
  }

  function getWeekStart(date){
    var d=new Date(date);
    d.setHours(0,0,0,0);
    var day=d.getDay();
    var diff=(day+6)%7;
    d.setDate(d.getDate()-diff);
    return d;
  }

  function getWeekEnd(date){
    var end=getWeekStart(date);
    end.setDate(end.getDate()+6);
    end.setHours(23,59,59,999);
    return end;
  }

  function formatDateOnly(dt){
    if(!dt)return "";
    var d=new Date(dt);
    if(isNaN(d.getTime()))return dt;
    return d.getFullYear()+"-"+String(d.getMonth()+1).padStart(2,'0')+"-"+String(d.getDate()).padStart(2,'0');
  }

  function buildWeeklyOrderSummary(){
    var grouped={};
    for(var i=0;i<studentOrders.length;i++){
      var order=studentOrders[i];
      var baseDate=order.orderedAt||order.mealDate||order.orderBefore;
      var parsed=new Date(baseDate);
      if(isNaN(parsed.getTime()))continue;
      var weekStart=getWeekStart(parsed);
      var weekEnd=getWeekEnd(parsed);
      var key=formatDateOnly(weekStart);
      if(!grouped[key]){
        grouped[key]={weekStart:new Date(weekStart),weekEnd:new Date(weekEnd),total:0};
      }
      grouped[key].total+=parseFloat(order.totalPrice||0);
    }

    weeklyOrderSummary=Object.keys(grouped).map(function(key){ return grouped[key]; })
            .sort(function(a,b){ return b.weekStart.getTime()-a.weekStart.getTime(); });
  }

  function updateWeeklyCards(){
    buildWeeklyOrderSummary();

    var now=new Date();
    var currentStart=getWeekStart(now);
    var currentEnd=getWeekEnd(now);
    var currentKey=formatDateOnly(currentStart);
    var currentWeek=weeklyOrderSummary.find(function(item){ return formatDateOnly(item.weekStart)===currentKey; });
    var totalEl=document.getElementById('weekTotalValue');
    var rangeEl=document.getElementById('weekTotalRange');
    var countEl=document.getElementById('historyWeekCount');

    if(totalEl)totalEl.innerHTML=formatMoney(currentWeek?currentWeek.total:0);
    if(rangeEl)rangeEl.innerHTML=formatDateOnly(currentStart)+' to '+formatDateOnly(currentEnd);
    if(countEl)countEl.innerHTML=weeklyOrderSummary.length;
  }

  function renderWeeklyHistoryTable(){
    var body=document.getElementById('weeklyHistoryTableBody');
    if(!body)return;
    if(!weeklyOrderSummary.length){
      body.innerHTML='<tr><td colspan="3" style="text-align:center;color:#7a8599;">No weekly history yet.</td></tr>';
      return;
    }

    var html='';
    for(var i=0;i<weeklyOrderSummary.length;i++){
      var row=weeklyOrderSummary[i];
      html+='<tr>';
      html+='<td>'+escapeHtml(formatDateOnly(row.weekStart))+'</td>';
      html+='<td>'+escapeHtml(formatDateOnly(row.weekEnd))+'</td>';
      html+='<td>Rs. '+formatMoney(row.total)+'</td>';
      html+='</tr>';
    }
    body.innerHTML=html;
  }

  function openWeeklyHistoryModal(){
    renderWeeklyHistoryTable();
    var modal=document.getElementById('weeklyHistoryModal');
    if(modal)modal.classList.add('show');
  }

  function closeWeeklyHistoryModal(){
    var modal=document.getElementById('weeklyHistoryModal');
    if(modal)modal.classList.remove('show');
  }

  function handleWeeklyHistoryBackdrop(event){
    if(event.target&&event.target.id==='weeklyHistoryModal')closeWeeklyHistoryModal();
  }

  function scrollToCurrentWeekHistory(){
    var historyCard=document.querySelector('.history-card');
    if(historyCard)historyCard.scrollIntoView({behavior:'smooth',block:'start'});
  }

  function loadNotifications(){
    fetch('<%=request.getContextPath()%>/student/meal/notifications')
            .then(function(r){ return r.json(); })
            .then(function(data){
              studentNotifications=data||[];
              renderNotifications();
            })
            .catch(function(error){
              console.error(error);
              document.getElementById('studentNotificationsWrap').innerHTML='<div class="empty-note" style="color:#b85252;">Failed to load notifications.</div>';
            });
  }

  function renderNotifications(){
    var wrap=document.getElementById('studentNotificationsWrap');
    if(!studentNotifications.length){
      wrap.innerHTML='<div class="empty-note">No notifications yet.</div>';
      return;
    }

    var html='';
    for(var i=0;i<studentNotifications.length;i++){
      var n=studentNotifications[i];
      html+='<div class="notification-item">';
      html+='<div class="notification-time">'+escapeHtml(formatDateTime(n.createdAt))+'</div>';
      html+='<div class="notification-text">'+escapeHtml(n.message||'')+'</div>';
      html+='</div>';
    }
    wrap.innerHTML=html;
  }

  function renderMealSections(){
    var wrap=document.getElementById("mealSections"),html="";
    for(var i=0;i<mealTypes.length;i++){
      var mealType=mealTypes[i],
              layout=mealLayouts[mealType]||{sectionId:0,orderBefore:"",columns:[]},
              deadline=layout.orderBefore||"",
              expired=isExpired(deadline),
              columns=layout.columns||[],
              isEditingThis=editingOrderId&&editingMealType===mealType;

      html+='<div class="meal-section'+(isEditingThis?' active-edit':'')+'" id="meal_section_'+mealType+'">';
      html+='<div class="meal-head">';
      html+='<div class="meal-title">'+mealType+'</div>';
      html+='<div class="deadline'+(expired?' expired':'')+'">Order Before: '+escapeHtml(formatDateTime(deadline))+'</div>';
      html+='</div>';
      html+='<div class="meal-panel">';
      html+='<div class="form-message" id="message_'+mealType+'"></div>';
      html+='<div class="columns-wrap">';

      if(columns.length===0){
        html+='<div class="empty-text">No items added for '+mealType.toLowerCase()+'</div>';
      }else{
        html+=renderColumns(mealType,columns,expired);
      }

      html+='</div>';
      html+='<div class="meal-actions">';
      html+='<div class="live-total">Total: Rs. <span id="total_'+mealType+'">0.00</span></div>';
      html+='<button class="btn btn-blue" '+(expired?'disabled':'')+' onclick="placeOrder(\''+mealType+'\')">'+(isEditingThis?'Save Changes':'Order')+'</button>';
      html+='</div></div></div>';
    }
    wrap.innerHTML=html;
    updateAllTotals();
  }

  function renderColumns(mealType,columns,expired){
    var html="";
    for(var i=0;i<columns.length;i++){
      var col=columns[i],
              selected=selections[mealType].indexOf(col.id)>-1,
              cardClass="column-card"+(selected?" selected":"")+(expired?" disabled":"");

      html+='<div class="'+cardClass+'" '+(!expired?'onclick="toggleColumn(\''+mealType+'\','+col.id+')"':'')+'>';

      if(col.type==="split"){
        html+='<div class="column-top"><div class="split-grid">';
        var parts=col.parts||[];
        for(var p=0;p<parts.length;p++){
          var part=parts[p];
          html+='<div class="split-part">';
          html+='<div class="img-preview">'+(part.imageData?'<img src="'+part.imageData+'" alt="preview">':'No picture')+'</div>';
          html+='<div class="part-name">'+escapeHtml(part.name||"")+'</div>';
          html+='</div>';
        }
        html+='</div></div>';
        html+='<div class="column-bottom"><div class="item-price">Rs. '+formatMoney(col.price)+'</div></div>';
      }else{
        html+='<div class="column-top">';
        html+='<div class="img-preview">'+(col.imageData?'<img src="'+col.imageData+'" alt="preview">':'No picture')+'</div>';
        html+='<div class="item-name">'+escapeHtml(col.name||"")+'</div>';
        html+='</div>';
        html+='<div class="column-bottom"><div class="item-price">Rs. '+formatMoney(col.price)+'</div></div>';
      }

      html+='</div>';
    }
    return html;
  }

  function toggleColumn(mealType,columnId){
    var layout=mealLayouts[mealType]||{columns:[]};
    if(isExpired(layout.orderBefore)){
      alert("Deadline passed. Cannot order now.");
      return;
    }
    var index=selections[mealType].indexOf(columnId);
    if(index>-1){
      selections[mealType].splice(index,1);
    }else{
      selections[mealType].push(columnId);
    }
    renderMealSections();
  }

  function updateAllTotals(){
    for(var i=0;i<mealTypes.length;i++)updateLiveTotal(mealTypes[i]);
  }

  function updateLiveTotal(mealType){
    var layout=mealLayouts[mealType]||{columns:[]},total=0;
    for(var i=0;i<layout.columns.length;i++){
      var col=layout.columns[i];
      if(selections[mealType].indexOf(col.id)>-1)total+=parseFloat(col.price||0);
    }
    var totalEl=document.getElementById("total_"+mealType);
    if(totalEl)totalEl.innerHTML=total.toFixed(2);
  }

  function placeOrder(mealType){
    clearSectionMessage(mealType);
    var layout=mealLayouts[mealType]||{sectionId:0,orderBefore:"",columns:[]};
    if(!layout.sectionId){
      showSectionMessage(mealType,"No saved meal layout for "+mealType+".","error");
      return;
    }
    if(isExpired(layout.orderBefore)){
      showSectionMessage(mealType,"Deadline passed. Cannot place order.","error");
      return;
    }
    var selectedColumnIds=selections[mealType];
    if(!selectedColumnIds.length){
      showSectionMessage(mealType,"Select at least one column.","error");
      return;
    }

    var params=new URLSearchParams();
    var isEdit=editingOrderId&&editingMealType===mealType;

    if(isEdit){
      params.append("action","edit");
      params.append("orderId",editingOrderId);
    }else{
      params.append("action","place");
      params.append("sectionId",layout.sectionId);
    }

    params.append("selectedColumnIds",selectedColumnIds.join(","));

    fetch('<%=request.getContextPath()%>/student/meal/dashboard',{
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:params.toString()
    })
            .then(function(r){return r.json()})
            .then(function(data){
              if(data.success){
                showSectionMessage(mealType,isEdit?"Order updated successfully.":"Meal order placed successfully.","success");
                cancelEditMode(false);
                selections[mealType]=[];
                loadOrders();
              }else{
                showSectionMessage(mealType,data.message||(isEdit?"Could not update order.":"Could not place the order."),"error");
              }
            })
            .catch(function(error){
              console.error(error);
              showSectionMessage(mealType,isEdit?"Error while updating order.":"Error while placing order.","error");
            });
  }

  function renderHistoryTable(){
    var body=document.getElementById("historyTableBody");
    if(!studentOrders.length){
      body.innerHTML='<tr><td colspan="6" style="text-align:center;color:#7a8599;">No orders yet.</td></tr>';
      updateWeeklyCards();
      renderWeeklyHistoryTable();
      return;
    }

    var html="";
    for(var i=0;i<studentOrders.length;i++){
      var order=studentOrders[i],expired=isExpired(order.orderBefore),disabled=expired;
      html+='<tr>';
      html+='<td>'+escapeHtml(order.mealType)+'</td>';
      html+='<td>'+escapeHtml(order.orderedItems)+'</td>';
      html+='<td>Rs. '+formatMoney(order.totalPrice)+'</td>';
      html+='<td>'+escapeHtml(formatDateTime(order.orderedAt))+'</td>';
      html+='<td>'+escapeHtml(formatDateTime(order.orderBefore))+'</td>';
      html+='<td><button class="btn btn-gray" '+(disabled?'disabled':'')+' onclick="editOrder('+order.id+')">Edit</button> <button class="btn btn-red" '+(disabled?'disabled':'')+' onclick="deleteOrder('+order.id+')">Delete</button></td>';
      html+='</tr>';
    }
    body.innerHTML=html;
    updateWeeklyCards();
    renderWeeklyHistoryTable();
  }

  function editOrder(orderId){
    var order=studentOrders.find(function(o){return o.id===orderId});
    if(!order)return;
    if(isExpired(order.orderBefore)){
      showSectionMessage(order.mealType,"Deadline passed. Cannot edit.","error");
      return;
    }

    mealTypes.forEach(function(m){selections[m]=[]});
    editingOrderId=order.id;
    editingMealType=order.mealType;
    selections[order.mealType]=(order.selectedColumnIds||[]).slice();

    renderMealSections();

    var section=document.getElementById('meal_section_'+order.mealType);
    if(section)section.scrollIntoView({behavior:'smooth',block:'start'});
  }

  function cancelEditMode(showMessage){
    editingOrderId=null;
    editingMealType="";
    mealTypes.forEach(function(m){selections[m]=[]});
    renderMealSections();
    if(showMessage!==false)alert("Edit mode cancelled.");
  }

  function deleteOrder(orderId){
    var order=studentOrders.find(function(o){return o.id===orderId});
    if(!order)return;
    if(isExpired(order.orderBefore)){
      alert("Deadline passed. Cannot delete.");
      return;
    }
    if(!confirm("Delete this order?"))return;

    var params=new URLSearchParams();
    params.append("action","delete");
    params.append("orderId",orderId);

    fetch('<%=request.getContextPath()%>/student/meal/dashboard',{
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:params.toString()
    })
            .then(function(r){return r.json()})
            .then(function(data){
              if(data.success){
                if(editingOrderId===orderId)cancelEditMode(false);
                studentOrders=studentOrders.filter(function(o){return o.id!==orderId});
                renderHistoryTable();
                loadLayout();
              }else{
                alert(data.message||"Could not delete order.");
              }
            })
            .catch(function(error){
              console.error(error);
              alert("Error while deleting order.");
            });
  }

  function loadLayout(){
    fetch('<%=request.getContextPath()%>/student/meal/layout')
            .then(function(r){return r.json()})
            .then(function(data){
              mealTypes.forEach(function(mealType){
                mealLayouts[mealType]=data&&data[mealType]?data[mealType]:{sectionId:0,orderBefore:"",columns:[]};
              });
              renderMealSections();
            })
            .catch(function(error){
              console.error(error);
              renderMealSections();
            });
  }

  function loadOrders(){
    fetch('<%=request.getContextPath()%>/student/meal/orders')
            .then(function(r){return r.json()})
            .then(function(data){
              studentOrders=data||[];
              renderHistoryTable();
              loadLayout();
            })
            .catch(function(error){
              console.error(error);
              renderHistoryTable();
            });
  }

  document.addEventListener('keydown',function(event){
    if(event.key==='Escape')closeWeeklyHistoryModal();
  });

  loadNotifications();
  loadLayout();
  loadOrders();
</script>
</body>
</html>
