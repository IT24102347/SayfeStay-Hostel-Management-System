<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() == null || !user.getRole().toLowerCase().contains("kitchen")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Kitchen Staff</title>
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
            --primary-soft:#edf0ff;

            --blue-btn-1:#6e83ee;
            --blue-btn-2:#7b5fd1;

            --gold-btn-1:#e3bc6f;
            --gold-btn-2:#c89b43;

            --red-btn-1:#eb7f8a;
            --red-btn-2:#d1606d;

            --dark-btn-1:#a9b7cf;
            --dark-btn-2:#8b98b0;

            --shadow-sm:0 10px 22px rgba(45,75,120,.10);
            --shadow-md:0 18px 38px rgba(40,66,108,.14);
            --shadow-lg:0 28px 60px rgba(27,48,82,.18);

            --radius-xl:30px;
            --radius-lg:24px;
            --radius-md:18px;
            --radius-sm:14px;
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

        .logout-btn,.reset-btn{
            color:#fff;
            text-decoration:none;
            padding:12px 18px;
            border-radius:16px;
            font-weight:700;
            border:none;
            cursor:pointer;
            box-shadow:0 12px 22px rgba(55,78,123,.18);
            transition:.22s ease;
        }

        .logout-btn:hover,.reset-btn:hover,.btn:hover,.close-btn:hover,.stat-card:hover{
            transform:translateY(-2px);
        }

        .logout-btn{
            background:linear-gradient(135deg, var(--red-btn-1), var(--red-btn-2));
        }

        .reset-btn{
            background:linear-gradient(135deg, var(--dark-btn-1), var(--dark-btn-2));
            margin-right:10px;
        }

        .stats{
            background:rgba(248,249,252,.82);
            backdrop-filter:blur(10px);
            -webkit-backdrop-filter:blur(10px);
            border:1px solid rgba(255,255,255,.52);
            border-radius:28px;
            padding:18px;
            display:grid;
            grid-template-columns:repeat(4,1fr);
            gap:16px;
            margin-bottom:28px;
            box-shadow:var(--shadow-lg);
        }

        .stat-card{
            border:1px solid #dde4f0;
            border-radius:22px;
            background:linear-gradient(180deg, rgba(255,255,255,.96) 0%, rgba(240,243,249,.96) 100%);
            text-align:center;
            padding:20px 14px;
            cursor:pointer;
            transition:.22s ease;
            box-shadow:var(--shadow-sm);
        }

        .stat-card:nth-child(1){ background:linear-gradient(135deg, #eef1ff 0%, #e3e8ff 100%); }
        .stat-card:nth-child(2){ background:linear-gradient(135deg, #f4eeff 0%, #eae1ff 100%); }
        .stat-card:nth-child(3){ background:linear-gradient(135deg, #eef7ff 0%, #dfefff 100%); }
        .stat-card:nth-child(4){ background:linear-gradient(135deg, #fff4ec 0%, #ffe8d6 100%); }

        .stat-card:hover{
            box-shadow:0 18px 34px rgba(56,84,126,.16);
            border-color:#cdd6e6;
        }

        .stat-title{
            font-size:13px;
            color:var(--text-2);
            font-weight:800;
            margin-bottom:10px;
            letter-spacing:.05em;
            text-transform:uppercase;
        }

        .stat-value{
            font-size:33px;
            font-weight:800;
            color:var(--text);
        }

        .notification-panel{
            background:rgba(248,249,252,.88);
            backdrop-filter:blur(10px);
            -webkit-backdrop-filter:blur(10px);
            border:1px solid rgba(255,255,255,.52);
            border-radius:30px;
            padding:22px;
            margin-bottom:30px;
            box-shadow:var(--shadow-lg);
        }

        .panel-title{
            margin:0 0 14px;
            font-size:16px;
            font-weight:800;
            color:#6773df;
        }

        .notification-form{
            display:grid;
            grid-template-columns:1fr auto auto;
            gap:12px;
            align-items:start;
            margin-bottom:18px;
        }

        .notification-form textarea{
            width:100%;
            min-height:96px;
            resize:vertical;
            padding:14px;
            border:1px solid #d5dceb;
            border-radius:16px;
            background:linear-gradient(180deg, #ffffff 0%, #f0f3f8 100%);
            color:var(--text);
            font-size:14px;
            outline:none;
        }

        .notification-actions{
            display:flex;
            gap:10px;
            flex-wrap:wrap;
            align-items:center;
        }

        .helper-text{
            font-size:13px;
            font-weight:700;
            color:var(--muted);
            margin-bottom:12px;
        }

        .meal-section{
            margin-bottom:34px;
        }

        .meal-head{
            display:flex;
            justify-content:space-between;
            align-items:center;
            flex-wrap:wrap;
            gap:12px;
            margin-bottom:14px;
        }

        .meal-title{
            font-size:27px;
            font-weight:800;
            text-transform:capitalize;
            color:#f8fbff;
            letter-spacing:.2px;
            text-shadow:0 6px 18px rgba(39,58,94,.18);
            padding-left:6px;
        }

        .meal-tools{
            display:flex;
            align-items:center;
            gap:10px;
            flex-wrap:wrap;
            background:rgba(247,248,252,.88);
            border:1px solid rgba(255,255,255,.5);
            border-radius:18px;
            padding:12px 14px;
            box-shadow:var(--shadow-sm);
        }

        .meal-tools label{
            font-size:14px;
            font-weight:800;
            color:var(--text);
        }

        .meal-tools input{
            padding:11px 13px;
            border:1px solid #d5dceb;
            border-radius:14px;
            background:linear-gradient(180deg, #ffffff 0%, #f0f3f8 100%);
            color:var(--text);
            box-shadow:inset 0 1px 2px rgba(255,255,255,.85);
            outline:none;
        }

        .btn{
            border:none;
            border-radius:14px;
            padding:11px 15px;
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

        .btn-yellow{
            background:linear-gradient(135deg, var(--gold-btn-1), var(--gold-btn-2));
            color:#fff;
        }

        .btn-red{
            background:linear-gradient(135deg, var(--red-btn-1), var(--red-btn-2));
            color:#fff;
        }

        .btn-gray{
            background:linear-gradient(135deg, #b6c1d6, #97a4bd);
            color:#fff;
        }

        .btn-sm{
            padding:7px 10px;
            font-size:12px;
        }

        .meal-panel{
            background:rgba(248,249,252,.88);
            backdrop-filter:blur(10px);
            -webkit-backdrop-filter:blur(10px);
            border:1px solid rgba(255,255,255,.52);
            border-radius:30px;
            padding:18px;
            display:flex;
            gap:16px;
            align-items:flex-start;
            box-shadow:var(--shadow-lg);
        }

        .columns-wrap{
            flex:1;
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

        .form-message{
            margin:10px 0 0;
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

        .column-card{
            width:260px;
            background:linear-gradient(180deg, #ffffff 0%, #eef2f8 100%);
            border:1px solid #d7deea;
            border-radius:30px;
            overflow:hidden;
            box-shadow:0 18px 30px rgba(44,57,80,.13);
        }

        .column-top{
            min-height:126px;
            border-bottom:1px solid #dce3ee;
            background:linear-gradient(180deg, #fafcff 0%, #edf2f8 100%);
            padding:12px;
        }

        .column-bottom{
            padding:12px 14px 14px;
            text-align:center;
            background:linear-gradient(180deg, rgba(255,255,255,.42), rgba(230,236,246,.6));
        }

        .split-layout{
            display:grid;
            grid-template-columns:repeat(2,1fr);
            gap:10px;
            align-content:start;
        }

        .part-box{
            border:1px solid #d8dfeb;
            border-radius:16px;
            padding:8px;
            background:linear-gradient(180deg, #ffffff 0%, #f1f4f9 100%);
            box-shadow:0 8px 16px rgba(50,61,83,.07);
        }

        .part-box input[type="text"],
        .part-box input[type="number"],
        .normal-item-inputs input[type="text"],
        .normal-item-inputs input[type="number"]{
            width:100%;
            padding:9px 10px;
            border:1px solid #d5dceb;
            border-radius:12px;
            font-size:11px;
            margin-top:6px;
            background:linear-gradient(180deg, #ffffff 0%, #eef2f7 100%);
            color:var(--text);
            outline:none;
        }

        .part-actions{
            display:flex;
            gap:6px;
            justify-content:flex-end;
            margin-top:8px;
            grid-column:1 / -1;
        }

        .normal-item-inputs{
            display:flex;
            flex-direction:column;
            align-items:center;
            justify-content:flex-start;
            gap:8px;
            padding:0;
            width:100%;
        }

        .meta-date{
            margin-top:6px;
            font-size:11px;
            color:var(--muted);
            text-align:center;
            word-break:break-word;
            font-weight:700;
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
            margin:0 auto;
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

        .normal-column .column-top{
            display:flex;
            align-items:center;
            justify-content:center;
        }

        .normal-column .img-preview{
            max-width:155px;
        }

        .file-label{
            display:inline-block;
            width:100%;
            text-align:center;
            background:linear-gradient(135deg, #d2d9e8, #afb9ce);
            color:#fff;
            border-radius:12px;
            padding:8px 8px;
            font-size:11px;
            font-weight:700;
            cursor:pointer;
            margin-top:6px;
            box-shadow:0 8px 14px rgba(53,67,92,.10);
        }

        .file-input{display:none}

        .side-actions{
            width:118px;
            display:flex;
            flex-direction:column;
            gap:10px;
        }

        .modal{
            position:fixed;
            inset:0;
            background:rgba(35,46,66,.28);
            backdrop-filter:blur(6px);
            display:none;
            align-items:center;
            justify-content:center;
            z-index:999;
            padding:20px;
        }

        .modal-card{
            width:100%;
            max-width:920px;
            max-height:85vh;
            overflow:auto;
            background:linear-gradient(180deg, #f9fbff 0%, #eef2f8 100%);
            border:1px solid rgba(255,255,255,.65);
            border-radius:28px;
            padding:22px;
            box-shadow:0 30px 65px rgba(21,31,48,.22);
        }

        .modal-head{
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:16px;
        }

        .modal-head h3{
            color:#6875df;
            font-size:25px;
        }

        .close-btn{
            background:linear-gradient(135deg, #bbc5d6, #98a4b8);
            color:#fff;
            border:none;
            border-radius:14px;
            padding:10px 15px;
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

        .locked-badge{
            display:inline-block;
            padding:6px 10px;
            border-radius:999px;
            background:#ffe7eb;
            color:#b34d61;
            font-size:12px;
            font-weight:800;
        }

        .open-badge{
            display:inline-block;
            padding:6px 10px;
            border-radius:999px;
            background:#e9f7ef;
            color:#2f7850;
            font-size:12px;
            font-weight:800;
        }

        @media (max-width:1000px){
            .stats{grid-template-columns:repeat(2,1fr)}
            .meal-panel{flex-direction:column}
            .side-actions{width:100%;flex-direction:row;flex-wrap:wrap}
            .notification-form{grid-template-columns:1fr}
        }

        @media (max-width:700px){
            .stats{grid-template-columns:1fr}
            .topbar{flex-direction:column;align-items:flex-start}
            .column-card{width:100%}
            .meal-tools{width:100%}
        }
    </style>
</head>
<body>
<div class="container">
    <div class="topbar">
        <div>
            <h2>Kitchen Staff </h2>
            <div class="top-meta">Kitchen ID: <strong><%= user.getUserId() %></strong> | Name: <strong><%= user.getFullName() != null ? user.getFullName() : user.getUsername() %></strong></div>
        </div>
        <div>
            <button class="reset-btn" type="button" onclick="resetDashboard()">Reset</button>
            <a class="logout-btn" href="<%=request.getContextPath()%>/logout">Logout</a>
        </div>
    </div>



    <div class="stats">
        <div class="stat-card" onclick="openOrdersModal('Breakfast')"><div class="stat-title">Breakfast Count</div><div class="stat-value" id="count_Breakfast">0</div></div>
        <div class="stat-card" onclick="openOrdersModal('Lunch')"><div class="stat-title">Lunch Count</div><div class="stat-value" id="count_Lunch">0</div></div>
        <div class="stat-card" onclick="openOrdersModal('Dinner')"><div class="stat-title">Dinner Count</div><div class="stat-value" id="count_Dinner">0</div></div>
        <div class="stat-card" onclick="openOrdersModal('Tea')"><div class="stat-title">Tea Count</div><div class="stat-value" id="count_Tea">0</div></div>
    </div>

    <div class="notification-panel">
        <h3 class="panel-title">Meal Notifications</h3>
        <div class="helper-text">Notices</div>

        <div class="notification-form">
            <textarea id="notificationMessage" placeholder="Type notification message here..."></textarea>
            <div class="notification-actions">
                <button class="btn btn-blue" type="button" onclick="saveNotification()">Send</button>
                <button class="btn btn-gray" type="button" onclick="clearNotificationForm()">Clear</button>
            </div>
            <div class="notification-actions">
                <input type="hidden" id="editingNotificationId" value="">
                <div id="notificationFormInfo" class="helper-text"></div>
            </div>
        </div>

        <div class="form-message" id="notificationFormMessage"></div>

        <table>
            <thead>
            <tr>
                <th style="width:42%;">Message</th>
                <th>Time</th>
                <th>Viewed Count</th>
                <th>Status</th>
                <th style="width:200px;">Actions</th>
            </tr>
            </thead>
            <tbody id="notificationTableBody">
            <tr><td colspan="5" style="text-align:center;color:#7a8599;">No notifications yet.</td></tr>
            </tbody>
        </table>
    </div>

    <% String[] mealTypes = {"Breakfast","Lunch","Dinner","Tea"}; for (String mealType : mealTypes) { %>
    <div class="meal-section" id="meal_section_<%= mealType %>">
        <div class="meal-head">
            <div class="meal-title"><%= mealType %></div>
            <div class="meal-tools">
                <label>Order Before</label>
                <input type="datetime-local" id="orderBefore_<%= mealType %>">
                <button class="btn btn-gray" type="button" onclick="addColumn('<%= mealType %>')">Add Item</button>
            </div>
        </div>
        <div class="meal-panel">
            <div class="form-message" id="message_<%= mealType %>"></div>
            <div class="columns-wrap" id="columns_<%= mealType %>"><div class="empty-text">No items added for <%= mealType.toLowerCase() %></div></div>
            <div class="side-actions">
                <button class="btn btn-blue" type="button" onclick="saveLayout('<%= mealType %>')">Save</button>
                <button class="btn btn-yellow" type="button" onclick="toggleEditMode('<%= mealType %>')">Edit</button>
                <button class="btn btn-red" type="button" onclick="clearCategory('<%= mealType %>')">Delete</button>
            </div>
        </div>
    </div>
    <% } %>
</div>

<div class="modal" id="ordersModal">
    <div class="modal-card">
        <div class="modal-head">
            <h3 id="modalTitle" style="margin:0;">Orders</h3>
            <button class="close-btn" type="button" onclick="closeOrdersModal()">Close</button>
        </div>
        <table>
            <thead><tr><th>Student ID</th><th>Meal Detail</th><th>Ordered Time</th></tr></thead>
            <tbody id="modalOrdersBody"><tr><td colspan="3" style="text-align:center;color:#7a8599;">No orders found.</td></tr></tbody>
        </table>
    </div>
</div>

<script>
    var layouts={Breakfast:{columns:[],editMode:true},Lunch:{columns:[],editMode:true},Dinner:{columns:[],editMode:true},Tea:{columns:[],editMode:true}};
    var notifications=[];
    var notificationEditingId=null;

    function showFormMessage(mealType,message,type){
        var el=document.getElementById('message_'+mealType);
        if(!el)return;
        el.className='form-message '+(type||'error');
        el.textContent=message||'';
        el.style.display=message?'block':'none';
    }

    function clearFormMessage(mealType){
        showFormMessage(mealType,'','error');
    }

    function showNotificationFormMessage(message,type){
        var el=document.getElementById('notificationFormMessage');
        if(!el)return;
        el.className='form-message '+(type||'error');
        el.textContent=message||'';
        el.style.display=message?'block':'none';
    }

    function clearNotificationFormMessage(){
        showNotificationFormMessage('','error');
    }

    function validateLayout(mealType){
        var orderBeforeValue=document.getElementById('orderBefore_'+mealType).value;
        if(!orderBeforeValue){
            return 'Please select Order Before date and time for '+mealType+'.';
        }

        var selectedDate=new Date(orderBeforeValue);
        if(isNaN(selectedDate.getTime())){
            return 'Please enter a valid Order Before date and time for '+mealType+'.';
        }
        if(selectedDate.getTime()<Date.now()){
            return 'Order Before cannot be in the past for '+mealType+'.';
        }

        if(layouts[mealType].columns.length===0){
            return 'Please add at least one item for '+mealType+'.';
        }

        for(var i=0;i<layouts[mealType].columns.length;i++){
            var col=layouts[mealType].columns[i];
            var columnNo=i+1;
            var price=parseFloat(col.price);

            if(!(price>0)){
                return 'Price must be greater than 0 in column '+columnNo+'.';
            }

            if(col.type==='split'){
                if(!col.parts||!col.parts.length){
                    return 'Add at least one item name in column '+columnNo+'.';
                }
                for(var j=0;j<col.parts.length;j++){
                    var part=col.parts[j];
                    if(!part.name||!part.name.trim()){
                        return 'Item name cannot be empty in column '+columnNo+'.';
                    }
                }
            }else{
                if(!col.name||!col.name.trim()){
                    return 'Item name cannot be empty in column '+columnNo+'.';
                }
            }
        }
        return '';
    }

    function setInputsDisabled(mealType, disabled){
        var wrap=document.getElementById('columns_'+mealType);
        if(!wrap)return;

        wrap.querySelectorAll('input').forEach(function(el){
            if(el.type!=='file')el.disabled=disabled;
        });

        wrap.querySelectorAll('label.file-label').forEach(function(el){
            el.style.pointerEvents=disabled?'none':'auto';
            el.style.opacity=disabled?'0.6':'1';
        });
    }

    function toggleEditMode(mealType){
        layouts[mealType].editMode=!layouts[mealType].editMode;
        renderCategory(mealType);
        if(layouts[mealType].editMode)scrollToMealCategory(mealType);
    }

    function clearCategory(mealType){
        if(confirm('Delete all items in '+mealType+'?')){
            layouts[mealType].columns=[];
            renderCategory(mealType);
        }
    }

    function addColumn(mealType){
        if(!layouts[mealType].editMode){
            alert('Click Edit first.');
            return;
        }

        var state=layouts[mealType],isTea=mealType==='Tea';
        if(state.columns.length===0&&!isTea){
            state.columns.push({type:'split',price:'',savedDate:'',parts:[{name:'',imageData:''}]});
        }else{
            state.columns.push({type:'normal',name:'',imageData:'',price:'',savedDate:''});
        }
        renderCategory(mealType);
    }

    function addPart(mealType,colIndex){
        if(!layouts[mealType].editMode)return;
        var col=layouts[mealType].columns[colIndex];
        if(col&&col.type==='split'){
            col.parts.push({name:'',imageData:''});
            renderCategory(mealType);
        }
    }

    function removePart(mealType,colIndex){
        if(!layouts[mealType].editMode)return;
        var col=layouts[mealType].columns[colIndex];
        if(col&&col.type==='split'&&col.parts.length>1){
            col.parts.pop();
            renderCategory(mealType);
        }
    }

    function removeColumn(mealType,colIndex){
        if(!layouts[mealType].editMode)return;
        layouts[mealType].columns.splice(colIndex,1);
        renderCategory(mealType);
    }

    function updateSplitPart(mealType,colIndex,partIndex,field,value){
        layouts[mealType].columns[colIndex].parts[partIndex][field]=value;
    }

    function updateSplitPrice(mealType,colIndex,value){
        layouts[mealType].columns[colIndex].price=value;
    }

    function updateNormal(mealType,colIndex,field,value){
        layouts[mealType].columns[colIndex][field]=value;
    }

    function handleSplitFile(mealType,colIndex,partIndex,input){
        if(!layouts[mealType].editMode)return;
        var file=input.files&&input.files[0];
        if(!file)return;

        var reader=new FileReader();
        reader.onload=function(e){
            layouts[mealType].columns[colIndex].parts[partIndex].imageData=e.target.result;
            renderCategory(mealType);
        };
        reader.readAsDataURL(file);
    }

    function handleNormalFile(mealType,colIndex,input){
        if(!layouts[mealType].editMode)return;
        var file=input.files&&input.files[0];
        if(!file)return;

        var reader=new FileReader();
        reader.onload=function(e){
            layouts[mealType].columns[colIndex].imageData=e.target.result;
            renderCategory(mealType);
        };
        reader.readAsDataURL(file);
    }

    function saveLayout(mealType){
        clearFormMessage(mealType);
        var orderBeforeValue=document.getElementById('orderBefore_'+mealType).value;
        var validationMessage=validateLayout(mealType);

        if(validationMessage){
            showFormMessage(mealType,validationMessage,'error');
            return;
        }

        var payload={
            mealType:mealType,
            orderBefore:orderBeforeValue,
            columns:layouts[mealType].columns
        };

        fetch('<%=request.getContextPath()%>/kitchen/advanced-meal/save-layout',{
            method:'POST',
            headers:{'Content-Type':'application/json'},
            body:JSON.stringify(payload)
        })
            .then(function(r){return r.json()})
            .then(function(data){
                if(data.success){
                    alert(mealType+' saved successfully.');
                    layouts[mealType].editMode=false;
                    loadAll();
                }else{
                    alert('Failed to save '+mealType+(data.message?'\n'+data.message:'.'));
                }
            })
            .catch(function(error){
                console.error(error);
                showFormMessage(mealType,'Error while saving '+mealType+'.','error');
            });
    }

    function resetDashboard(){
        if(!confirm('Reset all added items, all order counts, and all notification messages?')) return;

        fetch('<%=request.getContextPath()%>/kitchen/advanced-meal/reset',{method:'POST'})
            .then(function(r){ return r.json(); })
            .then(function(data){
                if(data.success){
                    alert('Dashboard reset successfully. Meal history remains unchanged.');

                    layouts = {
                        Breakfast:{columns:[],editMode:true},
                        Lunch:{columns:[],editMode:true},
                        Dinner:{columns:[],editMode:true},
                        Tea:{columns:[],editMode:true}
                    };

                    ['Breakfast','Lunch','Dinner','Tea'].forEach(function(m){
                        document.getElementById('orderBefore_'+m).value = '';
                        renderCategory(m);
                    });

                    clearNotificationForm();
                    notifications = [];
                    renderNotificationTable();

                    loadCounts();
                    loadNotifications();
                }else{
                    alert(data.message || 'Reset failed.');
                }
            })
            .catch(function(e){
                console.error(e);
                alert('Reset failed.');
            });
    }

    function renderCategory(mealType){
        var state=layouts[mealType],wrap=document.getElementById('columns_'+mealType);

        if(state.columns.length===0){
            wrap.innerHTML='<div class="empty-text">No items added for '+mealType.toLowerCase()+'</div>';
            return;
        }

        var html='';

        for(var colIndex=0;colIndex<state.columns.length;colIndex++){
            var col=state.columns[colIndex];
            var savedDate=formatDisplayDate(col.savedDate);

            if(col.type==='split'){
                html+='<div class="column-card"><div class="column-top split-layout">';

                for(var partIndex=0;partIndex<col.parts.length;partIndex++){
                    var part=col.parts[partIndex];

                    html+='<div class="part-box">';
                    html+='<div class="img-preview">'+(part.imageData?'<img src="'+part.imageData+'" alt="preview">':'No picture')+'</div>';

                    if(state.editMode){
                        html+='<label class="file-label" for="splitFile_'+mealType+'_'+colIndex+'_'+partIndex+'">Select Picture</label>';
                    }

                    html+='<input class="file-input" id="splitFile_'+mealType+'_'+colIndex+'_'+partIndex+'" type="file" accept="image/*" onchange="handleSplitFile(\''+mealType+'\','+colIndex+','+partIndex+',this)">';
                    html+='<input type="text" placeholder="Type name" value="'+escapeAttr(part.name||'')+'" oninput="updateSplitPart(\''+mealType+'\','+colIndex+','+partIndex+',\'name\',this.value)">';
                    html+=(savedDate?'<div class="meta-date">'+escapeHtml(savedDate)+'</div>':'');
                    html+='</div>';
                }

                if(state.editMode){
                    html+='<div class="part-actions"><button class="btn btn-gray btn-sm" type="button" onclick="addPart(\''+mealType+'\','+colIndex+')">+</button><button class="btn btn-gray btn-sm" type="button" onclick="removePart(\''+mealType+'\','+colIndex+')">-</button></div>';
                }

                html+='</div><div class="column-bottom">';
                html+='<input type="number" min="0" step="0.01" placeholder="Price" value="'+escapeAttr(col.price||'')+'" oninput="updateSplitPrice(\''+mealType+'\','+colIndex+',this.value)" style="width:100%;padding:10px 11px;border:1px solid #d5dceb;border-radius:12px;font-size:12px;margin-top:6px;background:linear-gradient(180deg,#ffffff 0%,#eef2f7 100%);color:#35476a;outline:none;">';
                html+=(state.editMode?'<div style="margin-top:8px;"><button class="btn btn-red btn-sm" type="button" onclick="removeColumn(\''+mealType+'\','+colIndex+')">Delete</button></div>':'');
                html+='</div></div>';
            }else{
                html+='<div class="column-card normal-column">';
                html+='<div class="column-top">';
                html+='<div class="normal-item-inputs">';
                html+='<div class="img-preview">'+(col.imageData?'<img src="'+col.imageData+'" alt="preview">':'No picture')+'</div>';

                if(state.editMode){
                    html+='<label class="file-label" for="normalFile_'+mealType+'_'+colIndex+'">Select Picture</label>';
                }

                html+='<input class="file-input" id="normalFile_'+mealType+'_'+colIndex+'" type="file" accept="image/*" onchange="handleNormalFile(\''+mealType+'\','+colIndex+',this)">';
                html+='<input type="text" placeholder="Type here" value="'+escapeAttr(col.name||'')+'" oninput="updateNormal(\''+mealType+'\','+colIndex+',\'name\',this.value)">';
                html+=(savedDate?'<div class="meta-date">'+escapeHtml(savedDate)+'</div>':'');
                html+='</div></div>';
                html+='<div class="column-bottom">';
                html+='<input type="number" min="0" step="0.01" placeholder="Price" value="'+escapeAttr(col.price||'')+'" oninput="updateNormal(\''+mealType+'\','+colIndex+',\'price\',this.value)" style="width:100%;padding:10px 11px;border:1px solid #d5dceb;border-radius:12px;font-size:12px;background:linear-gradient(180deg,#ffffff 0%,#eef2f7 100%);color:#35476a;outline:none;">';
                html+=(state.editMode?'<div style="margin-top:8px;"><button class="btn btn-red btn-sm" type="button" onclick="removeColumn(\''+mealType+'\','+colIndex+')">Delete</button></div>':'');
                html+='</div></div>';
            }
        }

        wrap.innerHTML=html;
        setInputsDisabled(mealType,!state.editMode);
    }

    function loadSavedLayouts(){
        fetch('<%=request.getContextPath()%>/kitchen/advanced-meal/today')
            .then(function(r){return r.json()})
            .then(function(data){
                ['Breakfast','Lunch','Dinner','Tea'].forEach(function(mealType){
                    var section=data[mealType];
                    layouts[mealType]={columns:[],editMode:true};

                    if(section){
                        var cols=[];
                        (section.columns||[]).forEach(function(c){
                            var rawType=(c.type||c.columnType||'').toString().toLowerCase();
                            var savedDate=c.updatedAt||c.createdAt||section.updatedAt||section.createdAt||section.mealDate||'';

                            if(rawType==='split'){
                                cols.push({
                                    type:'split',
                                    price:c.price||'',
                                    savedDate:savedDate,
                                    parts:(c.parts||[]).map(function(p){
                                        return {
                                            name:p.partName||p.name||'',
                                            imageData:p.imagePath||p.imageData||''
                                        };
                                    })
                                });
                            }else{
                                cols.push({
                                    type:'normal',
                                    name:c.itemName||c.name||'',
                                    imageData:c.imagePath||c.imageData||'',
                                    price:c.price||'',
                                    savedDate:savedDate
                                });
                            }
                        });

                        layouts[mealType]={columns:cols,editMode:false};
                        document.getElementById('orderBefore_'+mealType).value=formatInputDate(section.orderBefore);
                    }else{
                        document.getElementById('orderBefore_'+mealType).value='';
                    }

                    renderCategory(mealType);
                });
            })
            .catch(function(e){
                console.error(e);
                ['Breakfast','Lunch','Dinner','Tea'].forEach(renderCategory);
            });
    }

    function loadNotifications(){
        fetch('<%=request.getContextPath()%>/kitchen/advanced-meal/notifications')
            .then(function(r){return r.json()})
            .then(function(data){
                notifications=data||[];
                renderNotificationTable();
            })
            .catch(function(e){
                console.error(e);
                document.getElementById('notificationTableBody').innerHTML='<tr><td colspan="5" style="text-align:center;color:#b85252;">Failed to load notifications.</td></tr>';
            });
    }

    function renderNotificationTable(){
        var body=document.getElementById('notificationTableBody');
        if(!notifications.length){
            body.innerHTML='<tr><td colspan="5" style="text-align:center;color:#7a8599;">No notifications yet.</td></tr>';
            return;
        }

        var html='';
        for(var i=0;i<notifications.length;i++){
            var n=notifications[i];
            var locked=(n.viewedCount||0)>0;
            html+='<tr>';
            html+='<td>'+escapeHtml(n.message||'')+'</td>';
            html+='<td>'+escapeHtml(formatOrderDateTime(n.createdAt))+'</td>';
            html+='<td>'+escapeHtml(String(n.viewedCount||0))+'</td>';
            html+='<td>'+(locked?'<span class="locked-badge">Locked</span>':'<span class="open-badge">Editable</span>')+'</td>';
            html+='<td>';
            html+='<button class="btn btn-yellow btn-sm" type="button" onclick="editNotification('+n.id+')">Edit</button> ';
            html+='<button class="btn btn-red btn-sm" type="button" onclick="deleteNotification('+n.id+')">Delete</button>';
            html+='</td>';
            html+='</tr>';
        }
        body.innerHTML=html;
    }

    function clearNotificationForm(){
        notificationEditingId=null;
        document.getElementById('editingNotificationId').value='';
        document.getElementById('notificationMessage').value='';
        document.getElementById('notificationFormInfo').innerHTML='';
        clearNotificationFormMessage();
    }

    function editNotification(id){
        var n=notifications.find(function(item){ return item.id===id; });
        if(!n)return;
        if((n.viewedCount||0)>0){
            showNotificationFormMessage('This notification has already been viewed by at least one student. It cannot be edited.','error');
            return;
        }
        notificationEditingId=id;
        document.getElementById('editingNotificationId').value=id;
        document.getElementById('notificationMessage').value=n.message||'';
        document.getElementById('notificationFormInfo').innerHTML='Editing notification ID: <strong>'+id+'</strong>';
        clearNotificationFormMessage();
        document.getElementById('notificationMessage').focus();
    }

    function saveNotification(){
        clearNotificationFormMessage();
        var message=document.getElementById('notificationMessage').value.trim();
        if(!message){
            showNotificationFormMessage('Notification message cannot be empty.','error');
            return;
        }

        var payload={
            id: notificationEditingId || 0,
            message: message
        };

        fetch('<%=request.getContextPath()%>/kitchen/advanced-meal/notification/save',{
            method:'POST',
            headers:{'Content-Type':'application/json'},
            body:JSON.stringify(payload)
        })
            .then(function(r){ return r.json(); })
            .then(function(data){
                if(data.success){
                    showNotificationFormMessage(notificationEditingId?'Notification updated successfully.':'Notification sent successfully.','success');
                    clearNotificationForm();
                    loadNotifications();
                }else{
                    showNotificationFormMessage(data.message||'Could not save notification.','error');
                }
            })
            .catch(function(e){
                console.error(e);
                showNotificationFormMessage('Error while saving notification.','error');
            });
    }

    function deleteNotification(id){
        var n=notifications.find(function(item){ return item.id===id; });
        if(!n)return;
        if((n.viewedCount||0)>0){
            showNotificationFormMessage('This notification has already been viewed by at least one student. It cannot be deleted.','error');
            return;
        }
        if(!confirm('Delete this notification?'))return;

        fetch('<%=request.getContextPath()%>/kitchen/advanced-meal/notification/delete?id='+encodeURIComponent(id),{
            method:'POST'
        })
            .then(function(r){ return r.json(); })
            .then(function(data){
                if(data.success){
                    if(notificationEditingId===id)clearNotificationForm();
                    loadNotifications();
                }else{
                    showNotificationFormMessage(data.message||'Could not delete notification.','error');
                }
            })
            .catch(function(e){
                console.error(e);
                showNotificationFormMessage('Error while deleting notification.','error');
            });
    }

    function formatInputDate(v){
        if(!v)return '';
        var d=new Date(v);
        if(isNaN(d.getTime()))return '';
        var p=function(n){return String(n).padStart(2,'0')};
        return d.getFullYear()+'-'+p(d.getMonth()+1)+'-'+p(d.getDate())+'T'+p(d.getHours())+':'+p(d.getMinutes());
    }

    function formatDisplayDate(v){
        if(!v)return '';
        var d=new Date(v);
        return isNaN(d.getTime())?'':('Saved: '+d.toLocaleDateString()+' '+d.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}));
    }

    function scrollToMealCategory(mealType){
        var el=document.getElementById('meal_section_'+mealType);
        if(el)el.scrollIntoView({behavior:'smooth',block:'start'});
    }

    function openOrdersModal(mealType){
        document.getElementById('ordersModal').style.display='flex';
        document.getElementById('modalTitle').innerText=mealType+' Orders';

        fetch('<%=request.getContextPath()%>/kitchen/advanced-meal/orders?mealType='+encodeURIComponent(mealType))
            .then(function(r){return r.json()})
            .then(function(data){
                var body=document.getElementById('modalOrdersBody');
                if(!data||data.length===0){
                    body.innerHTML='<tr><td colspan="3" style="text-align:center;color:#7a8599;">No orders found.</td></tr>';
                    return;
                }

                var html='';
                for(var i=0;i<data.length;i++){
                    var order=data[i];
                    html+='<tr><td>'+escapeHtml(order.studentId||'')+'</td><td>'+escapeHtml(order.selectedSummary||'')+'</td><td>'+escapeHtml(formatOrderDateTime(order.orderedAt))+'</td></tr>';
                }
                body.innerHTML=html;
            })
            .catch(function(error){
                console.error(error);
                document.getElementById('modalOrdersBody').innerHTML='<tr><td colspan="3" style="text-align:center;color:#b85252;">Failed to load orders.</td></tr>';
            });
    }

    function formatOrderDateTime(v){
        if(!v)return 'Not available';
        var d=new Date(v);
        return isNaN(d.getTime())?String(v):d.toLocaleString();
    }

    function closeOrdersModal(){
        document.getElementById('ordersModal').style.display='none';
    }

    function loadCounts(){
        ['Breakfast','Lunch','Dinner','Tea'].forEach(function(mealType){
            fetch('<%=request.getContextPath()%>/kitchen/advanced-meal/orders?mealType='+encodeURIComponent(mealType))
                .then(function(r){return r.json()})
                .then(function(data){
                    var el=document.getElementById('count_'+mealType);
                    if(el)el.innerHTML=data?data.length:0;
                })
                .catch(function(){
                    var el=document.getElementById('count_'+mealType);
                    if(el)el.innerHTML=0;
                });
        });
    }

    function loadAll(){
        loadSavedLayouts();
        loadCounts();
        loadNotifications();
    }

    function escapeHtml(text){
        text=String(text||'');
        return text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#039;');
    }

    function escapeAttr(text){
        return escapeHtml(text);
    }

    window.onclick=function(e){
        var modal=document.getElementById('ordersModal');
        if(e.target===modal)closeOrdersModal();
    };

    loadAll();
</script>
</body>
</html>