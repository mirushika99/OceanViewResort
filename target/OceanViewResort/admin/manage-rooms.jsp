<%--
    Document   : manage-rooms
    Project    : Ocean View Resort - Room Reservation System
--%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="
    com.oceanview.oceanviewresort.model.RoomType,
    com.oceanview.oceanviewresort.model.Room,
    java.util.List
" %>
<%
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<RoomType> roomTypes   = (List<RoomType>) request.getAttribute("roomTypes");
    List<Room>     rooms       = (List<Room>)     request.getAttribute("rooms");
    int[]          totalCounts = (int[])           request.getAttribute("totalCounts");

    // Banner messages from redirect params
    String success = request.getParameter("success");
    String error   = request.getParameter("error");

    String successMsg = "";
    String errorMsg   = "";

    if      ("type_added".equals(success))    successMsg = "Room type added successfully.";
    else if ("type_updated".equals(success))  successMsg = "Room type updated successfully.";
    else if ("room_added".equals(success))    successMsg = "Room added successfully.";
    else if ("room_deleted".equals(success))  successMsg = "Room deleted successfully.";
    else if ("missing_fields".equals(error))  errorMsg   = "Please fill in all required fields.";
    else if ("invalid_rate".equals(error))    errorMsg   = "Rate must be a valid positive number.";
    else if ("has_reservations".equals(error))errorMsg   = "Cannot delete — this room has existing reservations.";
    else if ("failed".equals(error))          errorMsg   = "Operation failed. Please try again.";
    else if ("invalid_type".equals(error))    errorMsg   = "Invalid room type selected.";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Rooms — Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Jost:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --sand:#f5efe6; --sand-dark:#e8ddd0;
            --ocean:#1a3a4a; --ocean-mid:#2e5f74; --ocean-light:#4a8fa8; --ocean-pale:#e8f4f8;
            --gold:#c9a84c; --gold-light:#e2c47a; --gold-pale:#fdf6e8;
            --text-dark:#1a2630; --text-mid:#4a5a65; --text-light:#7a8f9a; --white:#ffffff;
            --success:#2d7d5a; --success-pale:#e8f7f1;
            --error:#e05555; --error-pale:#fdf0f0;
        }
        body { font-family:'Jost',sans-serif; background:var(--sand); color:var(--text-dark); min-height:100vh; display:flex; }

        /* ── SIDEBAR (same as admin.jsp) ── */
        .sidebar { width:240px; flex-shrink:0; background:var(--ocean); min-height:100vh; display:flex; flex-direction:column; position:fixed; top:0; left:0; bottom:0; }
        .sidebar-brand { padding:28px 24px 20px; border-bottom:1px solid rgba(255,255,255,.08); }
        .sidebar-brand-name { font-family:'Cormorant Garamond',serif; font-size:1.3rem; font-weight:400; color:var(--white); letter-spacing:.04em; line-height:1.2; }
        .sidebar-brand-name span { color:var(--gold); font-style:italic; }
        .sidebar-brand-sub { font-size:.65rem; letter-spacing:.2em; text-transform:uppercase; color:rgba(255,255,255,.3); margin-top:4px; }
        .sidebar-nav { flex:1; padding-bottom:20px; }
        .sidebar-section-label { font-size:.6rem; letter-spacing:.22em; text-transform:uppercase; color:rgba(255,255,255,.25); font-weight:600; padding:20px 24px 8px; }
        .nav-item { display:flex; align-items:center; gap:12px; padding:11px 24px; color:rgba(255,255,255,.55); text-decoration:none; font-size:.85rem; transition:background .15s,color .15s; position:relative; }
        .nav-item:hover { background:rgba(255,255,255,.06); color:rgba(255,255,255,.85); }
        .nav-item.active { background:rgba(201,168,76,.12); color:var(--gold-light); }
        .nav-item.active::before { content:''; position:absolute; left:0; top:0; bottom:0; width:3px; background:var(--gold); border-radius:0 2px 2px 0; }
        .nav-item svg { width:16px; height:16px; flex-shrink:0; opacity:.8; }
        .sidebar-footer { padding:16px 24px 24px; border-top:1px solid rgba(255,255,255,.08); }
        .btn-logout { display:flex; align-items:center; gap:8px; width:100%; padding:9px 14px; background:rgba(255,255,255,.05); border:1px solid rgba(255,255,255,.1); border-radius:6px; color:rgba(255,255,255,.55); font-family:'Jost',sans-serif; font-size:.75rem; font-weight:500; letter-spacing:.1em; text-transform:uppercase; text-decoration:none; transition:background .2s,color .2s; }
        .btn-logout:hover { background:rgba(224,85,85,.12); border-color:rgba(224,85,85,.3); color:#f08080; }

        /* ── MAIN ── */
        .main-wrap { margin-left:240px; flex:1; display:flex; flex-direction:column; }
        .topbar { background:var(--white); border-bottom:1px solid var(--sand-dark); padding:0 36px; height:64px; display:flex; align-items:center; justify-content:space-between; position:sticky; top:0; z-index:100; }
        .topbar h1 { font-family:'Cormorant Garamond',serif; font-size:1.4rem; font-weight:400; }
        .topbar p  { font-size:.75rem; color:var(--text-light); margin-top:1px; }
        .page-body { padding:32px 36px 64px; }

        /* ── ALERTS ── */
        .alert { padding:13px 18px; border-radius:8px; font-size:.83rem; margin-bottom:24px; display:flex; align-items:center; gap:10px; }
        .alert-success { background:var(--success-pale); border:1px solid #a8d5c2; border-left:3px solid var(--success); color:var(--success); }
        .alert-error   { background:var(--error-pale);   border:1px solid #f5c6c6; border-left:3px solid var(--error);   color:#c0392b; }

        /* ── TWO COLUMN LAYOUT ── */
        .layout { display:grid; grid-template-columns:1fr 1fr; gap:28px; align-items:start; }

        /* ── CARDS ── */
        .card { background:var(--white); border-radius:14px; box-shadow:0 2px 16px rgba(26,58,74,.08); overflow:hidden; margin-bottom:24px; }
        .card-header { padding:18px 24px; border-bottom:1px solid var(--sand); display:flex; align-items:center; justify-content:space-between; }
        .card-title { font-size:.95rem; font-weight:600; color:var(--text-dark); }
        .card-sub   { font-size:.75rem; color:var(--text-light); margin-top:2px; }
        .card-body  { padding:24px; }

        /* ── FORM ELEMENTS ── */
        .form-group { margin-bottom:18px; }
        .form-group:last-child { margin-bottom:0; }
        .form-label { display:block; font-size:.68rem; letter-spacing:.16em; text-transform:uppercase; color:var(--text-mid); font-weight:500; margin-bottom:7px; }
        .form-label .req { color:var(--error); margin-left:2px; }
        .input-wrap { position:relative; }
        .input-wrap svg { position:absolute; left:13px; top:50%; transform:translateY(-50%); width:14px; height:14px; color:var(--ocean-light); pointer-events:none; }
        .form-control { width:100%; padding:11px 14px 11px 36px; border:1.5px solid var(--sand-dark); border-radius:8px; background:var(--white); font-family:'Jost',sans-serif; font-size:.88rem; color:var(--text-dark); outline:none; transition:border-color .2s,box-shadow .2s; appearance:none; }
        .form-control:focus { border-color:var(--ocean-light); box-shadow:0 0 0 3px rgba(74,143,168,.12); }
        .form-control.no-icon { padding-left:14px; }
        textarea.form-control { padding-left:14px; resize:vertical; min-height:80px; line-height:1.5; }
        select.form-control { background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='7' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%234a8fa8' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E"); background-repeat:no-repeat; background-position:right 14px center; padding-right:36px; cursor:pointer; }

        /* ── SUBMIT BUTTON ── */
        .btn-submit { width:100%; padding:12px; background:linear-gradient(135deg,var(--ocean),var(--ocean-mid)); color:var(--white); border:none; border-radius:8px; font-family:'Jost',sans-serif; font-size:.8rem; font-weight:600; letter-spacing:.15em; text-transform:uppercase; cursor:pointer; display:flex; align-items:center; justify-content:center; gap:8px; transition:transform .15s,box-shadow .2s; margin-top:20px; }
        .btn-submit:hover { transform:translateY(-1px); box-shadow:0 6px 20px rgba(26,58,74,.25); }

        /* ── ROOM TYPES TABLE ── */
        table { width:100%; border-collapse:collapse; font-size:.83rem; }
        thead tr { background:var(--ocean); }
        thead th { padding:11px 16px; text-align:left; font-size:.62rem; font-weight:600; letter-spacing:.18em; text-transform:uppercase; color:rgba(255,255,255,.55); white-space:nowrap; }
        tbody tr { border-bottom:1px solid var(--sand); transition:background .12s; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:#faf7f3; }
        td { padding:12px 16px; vertical-align:middle; color:var(--text-dark); }

        .type-name { font-weight:600; font-size:.88rem; }
        .type-desc { font-size:.75rem; color:var(--text-light); margin-top:2px; font-weight:300; }
        .rate-val  { font-family:'Cormorant Garamond',serif; font-size:1rem; font-weight:600; color:var(--ocean); }
        .count-pill { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; background:var(--ocean-pale); color:var(--ocean-mid); font-size:.72rem; font-weight:600; }
        .room-pill  { display:inline-flex; align-items:center; gap:4px; padding:3px 9px; border-radius:20px; background:var(--gold-pale); color:#7a5c1e; font-size:.7rem; font-weight:600; margin:2px; }

        /* Edit / Delete buttons */
        .btn-edit { display:inline-flex; align-items:center; gap:4px; padding:5px 12px; border-radius:6px; background:var(--ocean-pale); color:var(--ocean-mid); border:none; font-family:'Jost',sans-serif; font-size:.7rem; font-weight:600; cursor:pointer; transition:background .2s; }
        .btn-edit:hover { background:var(--ocean-light); color:var(--white); }
        .btn-del  { display:inline-flex; align-items:center; gap:4px; padding:5px 12px; border-radius:6px; background:var(--error-pale); color:var(--error); border:1px solid #f5c6c6; font-family:'Jost',sans-serif; font-size:.7rem; font-weight:600; cursor:pointer; transition:background .2s; }
        .btn-del:hover { background:var(--error); color:var(--white); }

        /* Edit inline form */
        .edit-row { display:none; background:#f8fcfe; }
        .edit-row.open { display:table-row; }
        .edit-form { padding:16px; display:grid; grid-template-columns:1fr 1fr 2fr auto; gap:12px; align-items:end; }
        .edit-form .form-group { margin-bottom:0; }
        .btn-save { padding:10px 18px; border-radius:7px; background:var(--success); color:var(--white); border:none; font-family:'Jost',sans-serif; font-size:.75rem; font-weight:600; cursor:pointer; white-space:nowrap; }
        .btn-cancel-edit { padding:10px 14px; border-radius:7px; background:var(--sand-dark); color:var(--text-mid); border:none; font-family:'Jost',sans-serif; font-size:.75rem; font-weight:500; cursor:pointer; }

        /* ── MODAL ── */
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(0,0,0,.5); z-index:500; align-items:center; justify-content:center; }
        .modal-overlay.open { display:flex; }
        .modal { background:var(--white); border-radius:14px; padding:32px; width:100%; max-width:400px; box-shadow:0 20px 60px rgba(0,0,0,.25); animation:mIn .2s ease; }
        @keyframes mIn { from{opacity:0;transform:scale(.95)} to{opacity:1;transform:scale(1)} }
        .modal-icon { width:48px; height:48px; border-radius:50%; background:var(--error-pale); display:flex; align-items:center; justify-content:center; margin:0 auto 16px; }
        .modal-title { font-family:'Cormorant Garamond',serif; font-size:1.4rem; text-align:center; margin-bottom:8px; }
        .modal-body  { font-size:.83rem; color:var(--text-mid); text-align:center; line-height:1.6; margin-bottom:24px; }
        .modal-actions { display:flex; gap:10px; }
        .modal-btn-confirm { flex:1; padding:12px; border-radius:8px; background:var(--error); color:var(--white); border:none; font-family:'Jost',sans-serif; font-size:.82rem; font-weight:600; cursor:pointer; }
        .modal-btn-back    { flex:1; padding:12px; border-radius:8px; background:var(--sand); color:var(--text-dark); border:1px solid var(--sand-dark); font-family:'Jost',sans-serif; font-size:.82rem; cursor:pointer; }

        @media(max-width:1024px) { .layout{grid-template-columns:1fr} }
        @media(max-width:768px)  { .sidebar{transform:translateX(-100%)} .main-wrap{margin-left:0} .page-body{padding:24px 16px} }
    </style>
</head>
<body>

<!-- ═══ SIDEBAR ═══ -->
<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="sidebar-brand-name">Ocean View <span>Resort</span></div>
        <div class="sidebar-brand-sub">Admin Panel</div>
    </div>
    <nav class="sidebar-nav">
        <div class="sidebar-section-label">Main</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/admin.jsp">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>Dashboard
        </a>
        <a class="nav-item" href="${pageContext.request.contextPath}/history">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>All Reservations
        </a>
        <a class="nav-item active" href="${pageContext.request.contextPath}/manage-rooms">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>Manage Rooms
        </a>
        <a class="nav-item" href="${pageContext.request.contextPath}/help">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>Help
        </a>
    </nav>
    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>Sign Out
        </a>
    </div>
</aside>

<!-- ═══ MAIN ═══ -->
<div class="main-wrap">

    <div class="topbar">
        <div>
            <h1>Manage Rooms</h1>
            <p>Add, edit and remove room types and individual rooms</p>
        </div>
    </div>

    <div class="page-body">

        <!-- Banners -->
        <% if (!successMsg.isEmpty()) { %>
        <div class="alert alert-success">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
            <%= successMsg %>
        </div>
        <% } else if (!errorMsg.isEmpty()) { %>
        <div class="alert alert-error">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <%= errorMsg %>
        </div>
        <% } %>

        <div class="layout">

            <!-- ══ LEFT: Room Types ══ -->
            <div>
                <!-- Add new room type -->
                <div class="card">
                    <div class="card-header">
                        <div>
                            <div class="card-title">Add New Room Type</div>
                            <div class="card-sub">e.g. Deluxe Ocean Room, Family Suite</div>
                        </div>
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/manage-rooms">
                            <input type="hidden" name="action" value="add_type">
                            <div class="form-group">
                                <label class="form-label">Type Name <span class="req">*</span></label>
                                <div class="input-wrap">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                                    <input type="text" name="type_name" class="form-control" placeholder="e.g. Deluxe Ocean Room" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Rate per Night (LKR) <span class="req">*</span></label>
                                <div class="input-wrap">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                                    <input type="number" name="rate" class="form-control" placeholder="e.g. 15000" min="1" step="0.01" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Description</label>
                                <textarea name="description" class="form-control no-icon" placeholder="Describe the room features..."></textarea>
                            </div>
                            <button type="submit" class="btn-submit">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                Add Room Type
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Existing room types table -->
                <div class="card">
                    <div class="card-header">
                        <div>
                            <div class="card-title">Existing Room Types</div>
                            <div class="card-sub"><%= roomTypes != null ? roomTypes.size() : 0 %> types configured</div>
                        </div>
                    </div>
                    <div style="overflow-x:auto;">
                        <table id="typesTable">
                            <thead>
                                <tr>
                                    <th>Type</th>
                                    <th>Rate / Night</th>
                                    <th>Rooms</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (roomTypes != null) {
                                        for (int i = 0; i < roomTypes.size(); i++) {
                                            RoomType rt = roomTypes.get(i);
                                            int cnt = totalCounts != null && i < totalCounts.length ? totalCounts[i] : 0;
                                %>
                                <tr id="type-row-<%= rt.getId() %>">
                                    <td>
                                        <div class="type-name"><%= rt.getTypeName() %></div>
                                        <div class="type-desc"><%= rt.getDescription() != null ? rt.getDescription() : "—" %></div>
                                    </td>
                                    <td><span class="rate-val">LKR <%= String.format("%,.0f", rt.getRatePerNight()) %></span></td>
                                    <td><span class="count-pill"><%= cnt %> rooms</span></td>
                                    <td style="white-space:nowrap;">
                                        <button class="btn-edit" onclick="openEditType(<%= rt.getId() %>, '<%= rt.getTypeName().replace("'","\\'") %>', <%= rt.getRatePerNight() %>, '<%= rt.getDescription() != null ? rt.getDescription().replace("'","\\'").replace("\n"," ") : "" %>')">
                                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                            Edit
                                        </button>
                                    </td>
                                </tr>
                                <!-- Inline edit row -->
                                <tr class="edit-row" id="edit-row-<%= rt.getId() %>">
                                    <td colspan="4">
                                        <form class="edit-form" method="post" action="${pageContext.request.contextPath}/manage-rooms">
                                            <input type="hidden" name="action"  value="update_type">
                                            <input type="hidden" name="type_id" value="<%= rt.getId() %>">
                                            <div class="form-group">
                                                <label class="form-label">Name</label>
                                                <input type="text" name="type_name" id="edit-name-<%= rt.getId() %>" class="form-control no-icon" required>
                                            </div>
                                            <div class="form-group">
                                                <label class="form-label">Rate (LKR)</label>
                                                <input type="number" name="rate" id="edit-rate-<%= rt.getId() %>" class="form-control no-icon" min="1" step="0.01" required>
                                            </div>
                                            <div class="form-group">
                                                <label class="form-label">Description</label>
                                                <input type="text" name="description" id="edit-desc-<%= rt.getId() %>" class="form-control no-icon">
                                            </div>
                                            <div style="display:flex;gap:6px;padding-top:22px;">
                                                <button type="submit" class="btn-save">Save</button>
                                                <button type="button" class="btn-cancel-edit" onclick="closeEditType(<%= rt.getId() %>)">Cancel</button>
                                            </div>
                                        </form>
                                    </td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ══ RIGHT: Individual Rooms ══ -->
            <div>
                <!-- Add new room -->
                <div class="card">
                    <div class="card-header">
                        <div>
                            <div class="card-title">Add New Room</div>
                            <div class="card-sub">Assign a room number to a room type</div>
                        </div>
                    </div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/manage-rooms">
                            <input type="hidden" name="action" value="add_room">
                            <div class="form-group">
                                <label class="form-label">Room Number <span class="req">*</span></label>
                                <div class="input-wrap">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                                    <input type="text" name="room_number" class="form-control" placeholder="e.g. 201" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Room Type <span class="req">*</span></label>
                                <div class="input-wrap">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                                    <select name="type_id" class="form-control" required>
                                        <option value="">— Select type —</option>
                                        <% if (roomTypes != null) { for (RoomType rt : roomTypes) { %>
                                        <option value="<%= rt.getId() %>"><%= rt.getTypeName() %> — LKR <%= String.format("%,.0f", rt.getRatePerNight()) %></option>
                                        <% } } %>
                                    </select>
                                </div>
                            </div>
                            <button type="submit" class="btn-submit">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                Add Room
                            </button>
                        </form>
                    </div>
                </div>

                <!-- All rooms list grouped by type -->
                <div class="card">
                    <div class="card-header">
                        <div>
                            <div class="card-title">All Rooms</div>
                            <div class="card-sub"><%= rooms != null ? rooms.size() : 0 %> rooms total</div>
                        </div>
                    </div>
                    <div style="overflow-x:auto;">
                        <table>
                            <thead>
                                <tr>
                                    <th>Room No.</th>
                                    <th>Type</th>
                                    <th>Delete</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (rooms != null) {
                                        for (Room rm : rooms) {
                                %>
                                <tr>
                                    <td><span class="room-pill"><%= rm.getRoomNumber() %></span></td>
                                    <td style="font-size:.83rem;color:var(--text-mid);"><%= rm.getTypeName() %></td>
                                    <td>
                                        <button class="btn-del"
                                                onclick="openDeleteModal(<%= rm.getId() %>, '<%= rm.getRoomNumber() %>')">
                                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                                            Delete
                                        </button>
                                    </td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ═══ DELETE CONFIRMATION MODAL ═══ -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <div class="modal-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#e05555" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/></svg>
        </div>
        <div class="modal-title">Delete Room?</div>
        <div class="modal-body">
            Are you sure you want to delete room <strong id="delRoomNumber">—</strong>?
            This cannot be undone. Rooms with existing reservations cannot be deleted.
        </div>
        <form method="post" action="${pageContext.request.contextPath}/manage-rooms">
            <input type="hidden" name="action"  value="delete_room">
            <input type="hidden" name="room_id" id="delRoomId" value="">
            <div class="modal-actions">
                <button type="button" class="modal-btn-back"    onclick="closeDeleteModal()">Cancel</button>
                <button type="submit" class="modal-btn-confirm">Yes, Delete</button>
            </div>
        </form>
    </div>
</div>

<script>
    // ── Inline edit for room types ────────────────────────────────────────────
    function openEditType(id, name, rate, desc) {
        // Close any open edit rows first
        document.querySelectorAll('.edit-row.open').forEach(r => r.classList.remove('open'));

        document.getElementById('edit-name-' + id).value = name;
        document.getElementById('edit-rate-' + id).value = rate;
        document.getElementById('edit-desc-' + id).value = desc;
        document.getElementById('edit-row-' + id).classList.add('open');

        // Scroll into view
        document.getElementById('edit-row-' + id).scrollIntoView({ behavior: 'smooth', block: 'center' });
    }

    function closeEditType(id) {
        document.getElementById('edit-row-' + id).classList.remove('open');
    }

    // ── Delete modal ──────────────────────────────────────────────────────────
    function openDeleteModal(roomId, roomNumber) {
        document.getElementById('delRoomId').value     = roomId;
        document.getElementById('delRoomNumber').textContent = roomNumber;
        document.getElementById('deleteModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeDeleteModal() {
        document.getElementById('deleteModal').classList.remove('open');
        document.body.style.overflow = '';
    }

    document.getElementById('deleteModal').addEventListener('click', function(e) {
        if (e.target === this) closeDeleteModal();
    });

    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') closeDeleteModal();
    });
</script>

</body>
</html>
