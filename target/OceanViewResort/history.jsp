<%-- 
    Document   : history
    Project    : Ocean View Resort - Room Reservation System
--%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || (!role.equals("guest") && !role.equals("admin"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String guestName = (String) session.getAttribute("guest_name");
    if (guestName == null) {
        String email = (String) session.getAttribute("user");
        guestName = (email != null && email.contains("@"))
                    ? email.substring(0, email.indexOf('@')) : "User";
        guestName = Character.toUpperCase(guestName.charAt(0)) + guestName.substring(1);
    }
    boolean isAdmin = "admin".equals(role);
    String pageTitle = isAdmin ? "All Reservations" : "My Reservations";
    String backUrl   = isAdmin ? "/admin.jsp" : "/guest-dashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> — Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Jost:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --sand:        #f5efe6;
            --sand-dark:   #e8ddd0;
            --ocean:       #1a3a4a;
            --ocean-mid:   #2e5f74;
            --ocean-light: #4a8fa8;
            --ocean-pale:  #e8f4f8;
            --gold:        #c9a84c;
            --gold-light:  #e2c47a;
            --gold-pale:   #fdf6e8;
            --text-dark:   #1a2630;
            --text-mid:    #4a5a65;
            --text-light:  #7a8f9a;
            --white:       #ffffff;
            --success:     #2d7d5a;
            --success-pale:#e8f7f1;
            --warn:        #b45309;
            --warn-pale:   #fef3c7;
        }

        body {
            font-family: 'Jost', sans-serif;
            background: var(--sand);
            color: var(--text-dark);
            min-height: 100vh;
        }

        /* ── NAV ── */
        .topnav {
            background: var(--ocean);
            padding: 0 48px;
            height: 64px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
            box-shadow: 0 2px 16px rgba(0,0,0,0.2);
        }
        .nav-brand {
            display: flex; align-items: center; gap: 12px; text-decoration: none;
        }
        .nav-brand-text {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.25rem; font-weight: 400;
            color: var(--white); letter-spacing: 0.05em;
        }
        .nav-brand-text span { color: var(--gold); font-style: italic; }
        .nav-right { display: flex; align-items: center; gap: 16px; }
        .nav-back {
            display: flex; align-items: center; gap: 6px;
            padding: 7px 16px;
            border: 1px solid rgba(255,255,255,0.15); border-radius: 4px;
            color: rgba(255,255,255,0.7);
            font-size: 0.78rem; font-weight: 500;
            letter-spacing: 0.1em; text-transform: uppercase; text-decoration: none;
            transition: border-color 0.2s, color 0.2s;
        }
        .nav-back:hover { border-color: rgba(255,255,255,0.4); color: var(--white); }
        .nav-avatar {
            width: 36px; height: 36px; border-radius: 50%;
            background: linear-gradient(135deg, var(--gold), var(--ocean-light));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Cormorant Garamond', serif;
            font-size: 1rem; color: var(--white);
        }
        .nav-role-badge {
            padding: 3px 10px; border-radius: 20px;
            font-size: 0.65rem; font-weight: 600;
            letter-spacing: 0.15em; text-transform: uppercase;
            background: rgba(201,168,76,0.2); color: var(--gold-light);
        }

        /* ── PAGE HEADER ── */
        .page-header {
            background: linear-gradient(135deg, var(--ocean) 0%, var(--ocean-mid) 100%);
            padding: 40px 48px; position: relative; overflow: hidden;
        }
        .page-header::after {
            content: ''; position: absolute;
            width: 360px; height: 360px; border-radius: 50%;
            border: 1px solid rgba(201,168,76,0.15);
            top: -140px; right: -60px;
        }
        .page-header-inner {
            position: relative; z-index: 2;
            max-width: 1200px; margin: 0 auto;
            display: flex; align-items: flex-end; justify-content: space-between;
            gap: 24px; flex-wrap: wrap;
        }
        .page-eyebrow {
            font-size: 0.68rem; letter-spacing: 0.28em;
            text-transform: uppercase; color: var(--gold-light);
            font-weight: 500; margin-bottom: 8px;
        }
        .page-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 2.2rem; font-weight: 300; color: var(--white);
        }
        .page-title em { font-style: italic; color: var(--gold-light); }
        .page-sub {
            margin-top: 6px; font-size: 0.83rem;
            color: rgba(255,255,255,0.45); font-weight: 300;
        }

        /* Stat chips in header */
        .header-stats { display: flex; gap: 16px; flex-wrap: wrap; }
        .hstat {
            background: rgba(255,255,255,0.07);
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 8px; padding: 12px 20px; text-align: center;
        }
        .hstat-val {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.6rem; font-weight: 400;
            color: var(--gold-light); line-height: 1;
        }
        .hstat-label {
            font-size: 0.68rem; text-transform: uppercase;
            letter-spacing: 0.15em; color: rgba(255,255,255,0.4);
            margin-top: 4px;
        }

        /* ── MAIN ── */
        .main {
            max-width: 1200px;
            margin: 0 auto;
            padding: 36px 32px 64px;
        }

        /* ── TOOLBAR ── */
        .toolbar {
            display: flex; align-items: center; justify-content: space-between;
            gap: 16px; margin-bottom: 24px; flex-wrap: wrap;
            animation: fadeUp 0.4s ease both;
        }
        .search-wrap { position: relative; flex: 1; max-width: 340px; }
        .search-wrap svg {
            position: absolute; left: 12px; top: 50%;
            transform: translateY(-50%);
            width: 15px; height: 15px; color: var(--text-light); pointer-events: none;
        }
        .search-input {
            width: 100%; padding: 10px 14px 10px 36px;
            border: 1.5px solid var(--sand-dark); border-radius: 8px;
            background: var(--white);
            font-family: 'Jost', sans-serif;
            font-size: 0.85rem; color: var(--text-dark);
            outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        }
        .search-input:focus {
            border-color: var(--ocean-light);
            box-shadow: 0 0 0 3px rgba(74,143,168,0.12);
        }
        .search-input::placeholder { color: #b5c0c8; }

        .toolbar-right { display: flex; align-items: center; gap: 12px; }
        .filter-select {
            padding: 10px 32px 10px 14px;
            border: 1.5px solid var(--sand-dark); border-radius: 8px;
            background: var(--white);
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='7' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%234a8fa8' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: right 12px center;
            font-family: 'Jost', sans-serif;
            font-size: 0.82rem; color: var(--text-mid);
            outline: none; cursor: pointer; appearance: none;
            transition: border-color 0.2s;
        }
        .filter-select:focus { border-color: var(--ocean-light); }

        .record-count {
            font-size: 0.78rem; color: var(--text-light);
            white-space: nowrap;
        }
        .record-count strong { color: var(--text-mid); }

        /* ── TABLE CARD ── */
        .table-card {
            background: var(--white);
            border-radius: 14px;
            box-shadow: 0 2px 20px rgba(26,58,74,0.08);
            overflow: hidden;
            animation: fadeUp 0.5s 0.1s ease both;
        }

        .table-wrap { overflow-x: auto; }

        table {
            width: 100%; border-collapse: collapse;
            font-size: 0.85rem;
        }

        thead tr {
            background: var(--ocean);
        }
        thead th {
            padding: 14px 18px;
            text-align: left;
            font-size: 0.65rem; font-weight: 600;
            letter-spacing: 0.2em; text-transform: uppercase;
            color: rgba(255,255,255,0.55);
            white-space: nowrap;
            cursor: pointer;
            user-select: none;
            transition: color 0.15s;
        }
        thead th:hover { color: var(--gold-light); }
        thead th .sort-icon { margin-left: 4px; opacity: 0.4; font-size: 0.7rem; }
        thead th.sorted { color: var(--gold-light); }
        thead th.sorted .sort-icon { opacity: 1; }

        tbody tr {
            border-bottom: 1px solid var(--sand);
            transition: background 0.15s;
        }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #faf7f3; }
        tbody tr.hidden-row { display: none; }

        td {
            padding: 14px 18px;
            color: var(--text-dark);
            vertical-align: middle;
        }

        /* ID cell */
        .id-cell {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1rem; font-weight: 600;
            color: var(--ocean-mid);
        }

        /* Guest avatar + name (admin view) */
        .guest-cell { display: flex; align-items: center; gap: 10px; }
        .guest-mini-avatar {
            width: 32px; height: 32px; border-radius: 50%;
            background: linear-gradient(135deg, var(--ocean-pale), var(--ocean-light));
            display: flex; align-items: center; justify-content: center;
            font-size: 0.78rem; font-weight: 600; color: var(--ocean);
            flex-shrink: 0; text-transform: uppercase;
        }
        .guest-name-text { font-weight: 500; }
        .guest-contact { font-size: 0.73rem; color: var(--text-light); margin-top: 1px; }

        /* Room badge */
        .room-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 600;
            background: var(--ocean-pale); color: var(--ocean-mid);
        }

        /* Date cell */
        .date-cell { white-space: nowrap; }
        .date-main { font-weight: 500; }
        .date-sub { font-size: 0.72rem; color: var(--text-light); margin-top: 1px; }

        /* Nights badge */
        .nights-pill {
            display: inline-block;
            padding: 3px 10px; border-radius: 20px;
            background: var(--gold-pale);
            font-size: 0.72rem; font-weight: 600; color: #7a5c1e;
        }

        /* Total cell */
        .total-cell {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.05rem; font-weight: 600; color: var(--ocean);
        }

        /* Status badge */
        .status-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 4px 10px; border-radius: 20px;
            font-size: 0.7rem; font-weight: 600;
        }
        .status-badge::before {
            content: ''; width: 6px; height: 6px;
            border-radius: 50%; background: currentColor;
            opacity: 0.7;
        }
        .status-upcoming   { background: var(--ocean-pale);   color: var(--ocean-mid); }
        .status-active     { background: var(--success-pale); color: var(--success); }
        .status-completed  { background: var(--sand-dark);    color: var(--text-mid); }
        .status-cancelled  { background: #fdf0f0;             color: #e05555; }

        /* Bill button */
        .btn-bill {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 6px 14px; border-radius: 6px;
            background: var(--ocean); color: var(--white);
            font-family: 'Jost', sans-serif;
            font-size: 0.72rem; font-weight: 500;
            letter-spacing: 0.08em; text-decoration: none;
            transition: background 0.2s, transform 0.1s;
            white-space: nowrap;
        }
        .btn-bill:hover { background: var(--ocean-mid); transform: translateY(-1px); }

        /* Cancel button */
        .btn-cancel {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 6px 14px; border-radius: 6px;
            background: none; color: #e05555;
            border: 1px solid #f5c6c6;
            font-family: 'Jost', sans-serif;
            font-size: 0.72rem; font-weight: 500;
            letter-spacing: 0.08em; cursor: pointer;
            transition: background 0.2s, border-color 0.2s;
            white-space: nowrap;
        }
        .btn-cancel:hover { background: #fdf0f0; border-color: #e05555; }

        /* Alert banners */
        .alert-banner {
            padding: 13px 18px; border-radius: 8px;
            font-size: 0.83rem; margin: 20px 0 0;
            display: flex; align-items: center; gap: 10px;
        }
        .alert-success { background: var(--success-pale); border: 1px solid #a8d5c2; border-left: 3px solid var(--success); color: var(--success); }
        .alert-error   { background: #fdf0f0; border: 1px solid #f5c6c6; border-left: 3px solid #e05555; color: #c0392b; }

        /* Cancel confirmation modal */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.5); z-index: 500;
            align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: var(--white); border-radius: 14px;
            padding: 32px; width: 100%; max-width: 420px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
            animation: modalIn 0.2s ease;
        }
        @keyframes modalIn { from{opacity:0;transform:scale(.95)} to{opacity:1;transform:scale(1)} }
        .modal-icon { width: 48px; height: 48px; border-radius: 50%; background: #fdf0f0; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
        .modal-title { font-family: 'Cormorant Garamond', serif; font-size: 1.4rem; font-weight: 400; color: var(--text-dark); text-align: center; margin-bottom: 8px; }
        .modal-body  { font-size: 0.83rem; color: var(--text-mid); text-align: center; line-height: 1.6; margin-bottom: 24px; }
        .modal-body strong { color: var(--text-dark); }
        .modal-warn  { background: #fdf0f0; border-radius: 8px; padding: 10px 14px; font-size: 0.78rem; color: #c0392b; margin-bottom: 20px; text-align: center; }
        .modal-actions { display: flex; gap: 10px; }
        .modal-btn-confirm { flex: 1; padding: 12px; border-radius: 8px; background: #e05555; color: var(--white); border: none; font-family: 'Jost', sans-serif; font-size: 0.82rem; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .modal-btn-confirm:hover { background: #c0392b; }
        .modal-btn-back { flex: 1; padding: 12px; border-radius: 8px; background: var(--sand); color: var(--text-dark); border: 1px solid var(--sand-dark); font-family: 'Jost', sans-serif; font-size: 0.82rem; font-weight: 500; cursor: pointer; transition: background 0.2s; }
        .modal-btn-back:hover { background: var(--sand-dark); }

        /* ── EMPTY STATE ── */
        .empty-state {
            padding: 64px 32px; text-align: center;
        }
        .empty-icon {
            width: 72px; height: 72px; border-radius: 50%;
            background: var(--ocean-pale);
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px;
        }
        .empty-icon svg { width: 32px; height: 32px; color: var(--ocean-light); }
        .empty-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.4rem; color: var(--text-dark); margin-bottom: 8px;
        }
        .empty-sub {
            font-size: 0.85rem; color: var(--text-light); font-weight: 300;
            margin-bottom: 24px;
        }
        .btn-make-reservation {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 12px 24px; border-radius: 8px;
            background: var(--ocean); color: var(--white);
            font-family: 'Jost', sans-serif;
            font-size: 0.82rem; font-weight: 500;
            letter-spacing: 0.12em; text-transform: uppercase;
            text-decoration: none;
            transition: background 0.2s, transform 0.15s;
        }
        .btn-make-reservation:hover { background: var(--ocean-mid); transform: translateY(-2px); }

        /* No-results row */
        .no-results-row td {
            text-align: center; padding: 40px;
            color: var(--text-light); font-style: italic;
        }

        /* ── TABLE FOOTER ── */
        .table-footer {
            padding: 14px 24px;
            border-top: 1px solid var(--sand);
            display: flex; align-items: center; justify-content: space-between;
            font-size: 0.78rem; color: var(--text-light);
            background: #faf7f2;
        }
        .total-summary {
            font-size: 0.82rem; color: var(--text-mid);
        }
        .total-summary strong {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.1rem; color: var(--ocean); margin-left: 6px;
        }

        /* ── PRINT STYLES ── */
        .btn-print {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 10px 20px; border-radius: 8px;
            border: 1.5px solid var(--sand-dark);
            background: var(--white); color: var(--text-mid);
            font-family: 'Jost', sans-serif;
            font-size: 0.78rem; font-weight: 500;
            cursor: pointer; text-decoration: none;
            transition: border-color 0.2s, color 0.2s;
        }
        .btn-print:hover { border-color: var(--ocean-light); color: var(--ocean); }

        @media print {
            .topnav, .page-header, .toolbar, .table-footer, .btn-bill, .btn-print { display: none !important; }
            body { background: white; }
            .table-card { box-shadow: none; border: 1px solid #ddd; }
        }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── RESPONSIVE ── */
        @media (max-width: 768px) {
            .topnav { padding: 0 20px; }
            .page-header { padding: 28px 20px; }
            .page-header-inner { flex-direction: column; align-items: flex-start; }
            .main { padding: 24px 16px 48px; }
            .toolbar { flex-direction: column; align-items: stretch; }
            .search-wrap { max-width: 100%; }
            .header-stats { display: none; }
        }
    </style>
</head>
<body>

    <!-- ═══ NAV ═══ -->
    <nav class="topnav">
        <a class="nav-brand" href="${pageContext.request.contextPath}<%= backUrl %>">
            <svg width="32" height="32" viewBox="0 0 36 36" fill="none">
                <circle cx="18" cy="18" r="17" stroke="#c9a84c" stroke-width="1"/>
                <path d="M5 22 Q9 16 13 20 Q17 24 21 17 Q25 10 31 14" stroke="#c9a84c" stroke-width="1.2" fill="none" stroke-linecap="round"/>
            </svg>
            <div class="nav-brand-text">Ocean View <span>Resort</span></div>
        </a>
        <div class="nav-right">
            <% if (isAdmin) { %>
                <span class="nav-role-badge">Admin Panel</span>
            <% } %>
            <a href="${pageContext.request.contextPath}<%= backUrl %>" class="nav-back">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                <%= isAdmin ? "Dashboard" : "My Dashboard" %>
            </a>
            <div class="nav-avatar"><%= guestName.charAt(0) %></div>
        </div>
    </nav>

    <!-- ═══ PAGE HEADER ═══ -->
    <div class="page-header">
        <div class="page-header-inner">
            <div>
                <div class="page-eyebrow"><%= isAdmin ? "Admin View" : "Guest Portal" %></div>
                <h1 class="page-title"><%= isAdmin ? "All <em>Reservations</em>" : "My <em>Reservations</em>" %></h1>
                <p class="page-sub">
                    <%= isAdmin ? "Complete overview of all guest bookings at Ocean View Resort."
                                : "Your complete booking history and upcoming stays." %>
                </p>
            </div>

            <!-- Stats computed from reservation list -->
            <div class="header-stats" id="headerStats">
                <div class="hstat">
                    <div class="hstat-val" id="statTotal">—</div>
                    <div class="hstat-label">Total Bookings</div>
                </div>
                <div class="hstat">
                    <div class="hstat-val" id="statNights">—</div>
                    <div class="hstat-label">Total Nights</div>
                </div>
                <div class="hstat">
                    <div class="hstat-val" id="statRevenue">—</div>
                    <div class="hstat-label"><%= isAdmin ? "Total Revenue" : "Total Spent" %></div>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══ MAIN ═══ -->
    <main class="main">
        
        <% if ("1".equals(request.getParameter("success"))) { %>
            <div style="background:#e8f7f1; border:1px solid #a8d5c2;
                        border-left:3px solid #2d7d5a; border-radius:6px;
                        padding:13px 16px; margin-bottom:24px;
                        font-size:0.83rem; color:#2d7d5a;
                        display:flex; align-items:center; gap:8px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polyline points="20 6 9 17 4 12"/>
                </svg>
                Your reservation has been confirmed successfully!
            </div>
        <% } %>

        <%-- ── Success / Error banners from redirect params ── --%>
        <% if ("1".equals(request.getParameter("cancelled"))) { %>
        <div class="alert-banner alert-success">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
            Your reservation has been cancelled successfully.
        </div>
        <% } else if ("too_late".equals(request.getParameter("error"))) { %>
        <div class="alert-banner alert-error">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Cancellation not allowed — check-in is less than 48 hours away.
        </div>
        <% } else if ("already_cancelled".equals(request.getParameter("error"))) { %>
        <div class="alert-banner alert-error">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            This reservation has already been cancelled.
        </div>
        <% } %>

        <!-- TOOLBAR -->
        <div class="toolbar">
            <div class="search-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
                <input type="text" id="searchInput" class="search-input"
                       placeholder="<%= isAdmin ? "Search by guest, room type…" : "Search by room type…" %>"
                       oninput="filterTable()">
            </div>

            <div class="toolbar-right">
                <select class="filter-select" id="statusFilter" onchange="filterTable()">
                    <option value="">All Stays</option>
                    <option value="upcoming">Upcoming</option>
                    <option value="active">Active</option>
                    <option value="completed">Completed</option>
                    <option value="cancelled">Cancelled</option>
                </select>

                <button class="btn-print" onclick="window.print()">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                    Print
                </button>

                <span class="record-count" id="recordCount"></span>
            </div>
        </div>

        <!-- TABLE CARD -->
        <div class="table-card">

            <%-- Check if empty --%>
            <c:choose>
                <c:when test="${empty reservations}">
                    <div class="empty-state">
                        <div class="empty-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <rect x="3" y="4" width="18" height="18" rx="2"/>
                                <line x1="16" y1="2" x2="16" y2="6"/>
                                <line x1="8" y1="2" x2="8" y2="6"/>
                                <line x1="3" y1="10" x2="21" y2="10"/>
                            </svg>
                        </div>
                        <div class="empty-title">No reservations yet</div>
                        <div class="empty-sub">
                            <%= isAdmin ? "No bookings have been made in the system yet."
                                        : "You haven't made any bookings. Ready to plan your stay?" %>
                        </div>
                        <% if (!isAdmin) { %>
                            <a href="${pageContext.request.contextPath}/reservation" class="btn-make-reservation">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                Make a Reservation
                            </a>
                        <% } %>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="table-wrap">
                        <table id="reservationTable">
                            <thead>
                                <tr>
                                    <th onclick="sortTable(0)">Reservation ID <span class="sort-icon">↕</span></th>
                                    <% if (isAdmin) { %>
                                        <th onclick="sortTable(1)">Guest <span class="sort-icon">↕</span></th>
                                    <% } %>
                                    <th onclick="sortTable(<%= isAdmin ? 2 : 1 %>)">Room <span class="sort-icon">↕</span></th>
                                    <th onclick="sortTable(<%= isAdmin ? 3 : 2 %>)">Room Type <span class="sort-icon">↕</span></th>
                                    <th onclick="sortTable(<%= isAdmin ? 4 : 3 %>)">Check-in <span class="sort-icon">↕</span></th>
                                    <th onclick="sortTable(<%= isAdmin ? 5 : 4 %>)">Check-out <span class="sort-icon">↕</span></th>
                                    <th>Nights</th>
                                    <th onclick="sortTable(<%= isAdmin ? 7 : 6 %>)">Total (LKR) <span class="sort-icon">↕</span></th>
                                    <th>Status</th>
                                    <th>Bill</th>
                                    <% if (!isAdmin) { %><th>Cancel</th><% } %>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <c:forEach var="r" items="${reservations}">
                                    <tr data-checkin="${r.checkIn}" data-checkout="${r.checkOut}"
                                        data-nights="${r.nights}" data-total="${r.totalAmount}"
                                        data-resid="${r.id}"
                                        data-dbstatus="${r.status}">

                                        <td class="id-cell">#${r.id}</td>

                                        <% if (isAdmin) { %>
                                        <td>
                                            <div class="guest-cell">
                                                <div class="guest-mini-avatar">${r.firstName.substring(0,1)}</div>
                                                <div>
                                                    <div class="guest-name-text">${r.firstName} ${r.lastName}</div>
                                                    <div class="guest-contact">${r.contactNumber}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <% } %>

                                        <td>
                                            <span class="room-badge">
                                                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                                                ${r.roomNumber}
                                            </span>
                                        </td>

                                        <td>${r.roomType}</td>

                                        <td class="date-cell">
                                            <div class="date-main">${r.checkIn}</div>
                                        </td>

                                        <td class="date-cell">
                                            <div class="date-main">${r.checkOut}</div>
                                        </td>

                                        <td>
                                            <span class="nights-pill">${r.nights}N</span>
                                        </td>

                                        <td class="total-cell">
                                            <fmt:formatNumber value="${r.totalAmount}"
                                              type="number" minFractionDigits="0" maxFractionDigits="0"/>
                                        </td>

                                        <td>
                                            <%-- Status: DB cancelled takes priority, otherwise computed from dates by JS --%>
                                            <c:choose>
                                                <c:when test="${r.status == 'cancelled'}">
                                                    <span class="status-badge status-cancelled">Cancelled</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-upcoming" data-status></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <a href="${pageContext.request.contextPath}/bill?id=${r.id}"
                                               class="btn-bill">
                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                                                View Bill
                                            </a>
                                        </td>

                                        <%-- Cancel button — guests only, hidden for cancelled or past bookings --%>
                                        <% if (!isAdmin) { %>
                                        <td>
                                            <c:if test="${r.status != 'cancelled'}">
                                                <button class="btn-cancel"
                                                        data-id="${r.id}"
                                                        data-room="${r.roomType}"
                                                        data-checkin="${r.checkIn}"
                                                        data-cancancel="true"
                                                        onclick="openCancelModal(this)">
                                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                                    Cancel
                                                </button>
                                            </c:if>
                                        </td>
                                        <% } %>

                                    </tr>
                                </c:forEach>

                                <tr class="no-results-row" id="noResults" style="display:none;">
                                    <td colspan="<%= isAdmin ? 10 : 11 %>">No reservations match your search.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="table-footer">
                        <span id="footerCount"></span>
                        <span class="total-summary">
                            Grand Total: <strong id="footerTotal">LKR 0</strong>
                        </span>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </main>

    <!-- ═══ CANCEL CONFIRMATION MODAL ═══ -->
    <div class="modal-overlay" id="cancelModal">
        <div class="modal">
            <div class="modal-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#e05555" stroke-width="2">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="15" y1="9" x2="9" y2="15"/>
                    <line x1="9"  y1="9" x2="15" y2="15"/>
                </svg>
            </div>
            <div class="modal-title">Cancel Reservation?</div>
            <div class="modal-body">
                You are about to cancel your booking for<br>
                <strong id="modalRoomName">—</strong> on <strong id="modalCheckin">—</strong>.
            </div>
            <div class="modal-warn" id="modalWarn" style="display:none;">
                &#9888; Check-in is within 48 hours — cancellation may not be allowed.
            </div>
            <div class="modal-warn" style="background:var(--ocean-pale);color:var(--ocean-mid);">
                This action cannot be undone. Cancellations must be made at least 48 hours before check-in.
            </div>
            <br>
            <form method="post" action="${pageContext.request.contextPath}/cancel" id="cancelForm">
                <input type="hidden" name="reservation_id" id="cancelResId" value="">
                <div class="modal-actions">
                    <button type="button" class="modal-btn-back" onclick="closeCancelModal()">
                        Go Back
                    </button>
                    <button type="submit" class="modal-btn-confirm">
                        Yes, Cancel Booking
                    </button>
                </div>
            </form>
        </div>
    </div>
                
    <script>            
        const today = new Date();
        today.setHours(0,0,0,0);

        // ── Compute status for each row ──
        function getStatus(checkin, checkout) {
            const ci = new Date(checkin + 'T00:00:00'); // force midnight
            const co = new Date(checkout + 'T00:00:00'); // force midnight

            if (ci > today)  return { cls: 'status-upcoming',  label: 'Upcoming'  };
            if (co > today)  return { cls: 'status-active',    label: 'Active'    };
            return                  { cls: 'status-completed', label: 'Completed' };
        }

        // ── Init: set status badges + header stats ──
        (function init() {
            const rows = document.querySelectorAll('#tableBody tr[data-checkin]');
            let totalNights = 0, totalRevenue = 0;
            
            
            rows.forEach(row => {
                const badge = row.querySelector('[data-status]');

                // If no data-status badge — this row is cancelled, skip it
                if (!badge) {
                    row.dataset.statusLabel = 'cancelled';
                    return;
                }

                const status = getStatus(row.dataset.checkin, row.dataset.checkout);
                badge.className   = 'status-badge ' + status.cls;
                badge.textContent = status.label;
                row.dataset.statusLabel = status.label.toLowerCase();
                
                totalNights  += parseInt(row.dataset.nights)  || 0;
                totalRevenue += parseFloat(row.dataset.total) || 0;
            });

        <%--rows.forEach(row => {
                const status = getStatus(row.dataset.checkin, row.dataset.checkout);
                const badge  = row.querySelector('[data-status]');
                badge.className = 'status-badge ' + status.cls;
                badge.textContent = status.label;
                row.dataset.statusLabel = status.label.toLowerCase();

                totalNights  += parseInt(row.dataset.nights)  || 0;
                totalRevenue += parseFloat(row.dataset.total) || 0;
            });
--%>
            const n = rows.length;
            document.getElementById('statTotal').textContent   = n;
            document.getElementById('statNights').textContent  = totalNights;
            document.getElementById('statRevenue').textContent = 'LKR ' + Math.round(totalRevenue).toLocaleString();
            document.getElementById('recordCount').innerHTML   = '<strong>' + n + '</strong> records';
            document.getElementById('footerCount').textContent = n + ' reservation' + (n !== 1 ? 's' : '');
            document.getElementById('footerTotal').textContent = 'LKR ' + totalRevenue.toLocaleString();
        })();

        // ── Search + filter ──
        function filterTable() {
            const query  = document.getElementById('searchInput').value.toLowerCase();
            const status = document.getElementById('statusFilter').value.toLowerCase();
            const rows   = document.querySelectorAll('#tableBody tr[data-checkin]');
            let visible  = 0;
            let visTotal = 0;

            rows.forEach(row => {
                const text  = row.textContent.toLowerCase();
                const sLbl  = row.dataset.statusLabel || '';
                const matchQ = !query  || text.includes(query);
                const matchS = !status || sLbl.includes(status);

                if (matchQ && matchS) {
                    row.classList.remove('hidden-row');
                    visible++;
                    visTotal += parseFloat(row.dataset.total) || 0;
                } else {
                    row.classList.add('hidden-row');
                }
            });

            document.getElementById('noResults').style.display = visible === 0 ? '' : 'none';
            document.getElementById('recordCount').innerHTML = '<strong>' + visible + '</strong> records';
            document.getElementById('footerCount').textContent = visible + ' reservation' + (visible !== 1 ? 's' : '');
            document.getElementById('footerTotal').textContent = 'LKR ' + visTotal.toLocaleString();
        }

        // ── Sort ──
        let sortDir = {};
        function sortTable(col) {
            const tbody = document.getElementById('tableBody');
            const rows  = Array.from(tbody.querySelectorAll('tr[data-checkin]'));
            const asc   = !sortDir[col];
            sortDir     = {};
            sortDir[col] = asc;

            rows.sort((a, b) => {
                const aVal = a.cells[col]?.textContent.trim() || '';
                const bVal = b.cells[col]?.textContent.trim() || '';
                const n    = parseFloat(aVal) - parseFloat(bVal);
                const res  = isNaN(n) ? aVal.localeCompare(bVal) : n;
                return asc ? res : -res;
            });

            rows.forEach(r => tbody.appendChild(r));

            // Update sort icons
            document.querySelectorAll('thead th').forEach((th, i) => {
                th.classList.toggle('sorted', i === col);
                const ic = th.querySelector('.sort-icon');
                if (ic) ic.textContent = i === col ? (asc ? '↑' : '↓') : '↕';
            });
        }

        // ── Cancel Modal ───────────────────────────────────────────────────────
        function openCancelModal(btn) {
            const resId   = btn.dataset.id;
            const room    = btn.dataset.room  || 'your room';
            const checkin = btn.dataset.checkin || '—';

            // Check if within 48 hours
            const msUntilCheckIn = new Date(checkin).getTime() - Date.now();
            const within48h      = msUntilCheckIn < (48 * 60 * 60 * 1000);

            document.getElementById('cancelResId').value  = resId;
            document.getElementById('modalRoomName').textContent = room;
            document.getElementById('modalCheckin').textContent  = checkin;
            document.getElementById('modalWarn').style.display   = within48h ? 'block' : 'none';

            document.getElementById('cancelModal').classList.add('open');
            document.body.style.overflow = 'hidden';
        }

        function closeCancelModal() {
            document.getElementById('cancelModal').classList.remove('open');
            document.body.style.overflow = '';
        }

        // Close modal on overlay click
        document.getElementById('cancelModal').addEventListener('click', function(e) {
            if (e.target === this) closeCancelModal();
        });

        // Close modal on Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeCancelModal();
        });
    </script>

</body>
</html>
