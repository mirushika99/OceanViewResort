<%-- 
    Document   : reservation
    Project    : Ocean View Resort - Room Reservation System
--%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("guest")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String guestName = (String) session.getAttribute("guest_name");
    if (guestName == null) {
        String email = (String) session.getAttribute("user");
        guestName = (email != null && email.contains("@"))
                    ? email.substring(0, email.indexOf('@')) : "Guest";
        guestName = Character.toUpperCase(guestName.charAt(0)) + guestName.substring(1);
    }
    // Min date = today, formatted for HTML date input
    String today = LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE);
    String tomorrow = LocalDate.now().plusDays(1).format(DateTimeFormatter.ISO_LOCAL_DATE);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Make a Reservation — Ocean View Resort</title>
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
            --error:       #e05555;
            --error-pale:  #fdf0f0;
            --success:     #2d7d5a;
            --success-pale:#e8f7f1;
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
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
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
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 4px;
            color: rgba(255,255,255,0.7);
            font-size: 0.78rem; font-weight: 500;
            letter-spacing: 0.1em; text-transform: uppercase;
            text-decoration: none;
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

        /* ── PAGE HEADER ── */
        .page-header {
            background: linear-gradient(135deg, var(--ocean) 0%, var(--ocean-mid) 100%);
            padding: 40px 48px;
            position: relative;
            overflow: hidden;
        }
        .page-header::after {
            content: '';
            position: absolute;
            width: 360px; height: 360px;
            border-radius: 50%;
            border: 1px solid rgba(201,168,76,0.15);
            top: -140px; right: -60px;
        }
        .page-header-inner { position: relative; z-index: 2; max-width: 1100px; margin: 0 auto; }
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

        /* ── MAIN LAYOUT ── */
        .main {
            max-width: 1100px;
            margin: 0 auto;
            padding: 40px 32px 64px;
            display: grid;
            grid-template-columns: 1fr 380px;
            gap: 28px;
            align-items: start;
        }

        /* ── FORM CARD ── */
        .form-card {
            background: var(--white);
            border-radius: 14px;
            box-shadow: 0 2px 20px rgba(26,58,74,0.08);
            overflow: hidden;
            animation: fadeUp 0.5s ease both;
        }

        .form-card-header {
            padding: 24px 32px;
            border-bottom: 1px solid var(--sand-dark);
            display: flex; align-items: center; gap: 14px;
        }
        .form-card-header-icon {
            width: 40px; height: 40px; border-radius: 10px;
            background: var(--ocean-pale);
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .form-card-header h2 {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.35rem; font-weight: 400; color: var(--text-dark);
        }
        .form-card-header p {
            font-size: 0.78rem; color: var(--text-light); font-weight: 300;
        }

        .form-body { padding: 32px; }

        /* Steps indicator */
        .steps {
            display: flex; align-items: center;
            margin-bottom: 32px; gap: 0;
        }
        .step {
            display: flex; align-items: center; gap: 8px;
            font-size: 0.72rem; font-weight: 500;
            letter-spacing: 0.1em; text-transform: uppercase;
            color: var(--text-light);
        }
        .step.active { color: var(--ocean-mid); }
        .step-num {
            width: 24px; height: 24px; border-radius: 50%;
            background: var(--sand-dark);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.7rem; font-weight: 600; color: var(--text-mid);
            flex-shrink: 0;
        }
        .step.active .step-num {
            background: var(--ocean-mid); color: var(--white);
        }
        .step-line {
            flex: 1; height: 1px; background: var(--sand-dark);
            margin: 0 12px; min-width: 24px;
        }

        /* Form groups */
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 24px;
        }
        .form-group { margin-bottom: 0; }
        .form-group.full { grid-column: 1 / -1; }

        .form-label {
            display: block;
            font-size: 0.7rem; letter-spacing: 0.18em;
            text-transform: uppercase; color: var(--text-mid);
            font-weight: 500; margin-bottom: 8px;
        }

        .input-wrap { position: relative; }
        .input-wrap svg.input-icon {
            position: absolute; left: 13px; top: 50%;
            transform: translateY(-50%);
            width: 15px; height: 15px;
            color: var(--ocean-light); pointer-events: none;
        }

        .form-control {
            width: 100%;
            padding: 12px 14px 12px 38px;
            border: 1.5px solid var(--sand-dark);
            border-radius: 8px;
            background: var(--white);
            font-family: 'Jost', sans-serif;
            font-size: 0.9rem; color: var(--text-dark);
            transition: border-color 0.2s, box-shadow 0.2s;
            outline: none;
            appearance: none;
        }
        .form-control:focus {
            border-color: var(--ocean-light);
            box-shadow: 0 0 0 3px rgba(74,143,168,0.12);
        }
        .form-control.error {
            border-color: var(--error);
            box-shadow: 0 0 0 3px rgba(224,85,85,0.1);
        }
        .form-control::placeholder { color: #b5c0c8; font-weight: 300; }

        select.form-control {
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%234a8fa8' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 14px center;
            padding-right: 36px;
            cursor: pointer;
        }

        .field-hint {
            margin-top: 5px;
            font-size: 0.73rem;
            color: var(--text-light);
            font-weight: 300;
        }
        .field-error {
            margin-top: 5px;
            font-size: 0.73rem;
            color: var(--error);
            display: none;
        }

        /* Room info panel */
        .room-info-panel {
            margin-top: 8px;
            border: 1.5px solid var(--ocean-pale);
            border-radius: 8px;
            padding: 16px 18px;
            background: var(--ocean-pale);
            display: none;
            animation: fadeIn 0.3s ease;
        }
        .room-info-panel.visible { display: block; }
        .room-info-row {
            display: flex; justify-content: space-between;
            align-items: center; margin-bottom: 8px;
        }
        .room-info-row:last-child { margin-bottom: 0; }
        .room-info-label { font-size: 0.75rem; color: var(--text-mid); font-weight: 500; }
        .room-info-value { font-size: 0.85rem; color: var(--ocean); font-weight: 600; }
        .room-avail-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 3px 10px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 600;
        }
        .room-avail-badge.ok  { background: var(--success-pale); color: var(--success); }
        .room-avail-badge.no  { background: #fdf0f0; color: var(--error); }

        /* Alert */
        .alert {
            padding: 13px 16px;
            border-radius: 8px;
            font-size: 0.83rem;
            margin-bottom: 24px;
            display: flex; align-items: flex-start; gap: 10px;
        }
        .alert-error {
            background: var(--error-pale);
            border: 1px solid #f5c6c6;
            border-left: 3px solid var(--error);
            color: #c0392b;
        }

        /* Night counter */
        .nights-badge {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 8px 16px; border-radius: 8px;
            background: var(--gold-pale);
            border: 1px solid rgba(201,168,76,0.3);
            font-size: 0.82rem; color: #7a5c1e;
            margin-top: 10px;
        }
        .nights-badge strong { font-weight: 600; }

        /* Submit button */
        .btn-submit {
            width: 100%;
            margin-top: 32px;
            padding: 15px;
            background: linear-gradient(135deg, var(--ocean) 0%, var(--ocean-mid) 100%);
            color: var(--white);
            border: none; border-radius: 8px;
            font-family: 'Jost', sans-serif;
            font-size: 0.82rem; font-weight: 600;
            letter-spacing: 0.2em; text-transform: uppercase;
            cursor: pointer;
            transition: transform 0.15s, box-shadow 0.2s;
            display: flex; align-items: center; justify-content: center; gap: 10px;
        }
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 28px rgba(26,58,74,0.28);
        }
        .btn-submit:active { transform: translateY(0); }
        .btn-submit:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

        /* ── SUMMARY SIDEBAR ── */
        .sidebar { display: flex; flex-direction: column; gap: 20px; }

        .summary-card {
            background: var(--white);
            border-radius: 14px;
            box-shadow: 0 2px 20px rgba(26,58,74,0.08);
            overflow: hidden;
            animation: fadeUp 0.5s 0.1s ease both;
        }
        .summary-header {
            background: linear-gradient(135deg, var(--ocean) 0%, var(--ocean-mid) 100%);
            padding: 18px 24px;
        }
        .summary-header h3 {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.1rem; font-weight: 400; color: var(--white);
        }
        .summary-header p {
            font-size: 0.72rem; color: rgba(255,255,255,0.5);
            margin-top: 2px;
        }
        .summary-body { padding: 20px 24px; }

        .summary-row {
            display: flex; justify-content: space-between;
            align-items: flex-start;
            padding: 10px 0;
            border-bottom: 1px solid var(--sand);
        }
        .summary-row:last-child { border-bottom: none; }
        .summary-key {
            font-size: 0.75rem; color: var(--text-light);
            font-weight: 500; text-transform: uppercase;
            letter-spacing: 0.1em;
        }
        .summary-val {
            font-size: 0.88rem; color: var(--text-dark);
            font-weight: 500; text-align: right;
        }
        .summary-val.total {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.3rem; color: var(--ocean);
        }
        .summary-placeholder {
            text-align: center; padding: 20px 0;
            color: var(--text-light); font-size: 0.8rem;
            font-weight: 300; font-style: italic;
        }

        /* Tips card */
        .tips-card {
            background: var(--ocean);
            border-radius: 14px;
            padding: 24px;
            animation: fadeUp 0.5s 0.2s ease both;
        }
        .tips-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1rem; font-weight: 400;
            color: var(--gold-light); margin-bottom: 14px;
            display: flex; align-items: center; gap: 8px;
        }
        .tip-item {
            display: flex; align-items: flex-start; gap: 10px;
            margin-bottom: 10px; font-size: 0.78rem;
            color: rgba(255,255,255,0.55); font-weight: 300;
            line-height: 1.5;
        }
        .tip-item:last-child { margin-bottom: 0; }
        .tip-dot {
            width: 5px; height: 5px; border-radius: 50%;
            background: var(--gold); flex-shrink: 0; margin-top: 6px;
        }

        /* Animations */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeIn {
            from { opacity: 0; } to { opacity: 1; }
        }

        /* Responsive */
        @media (max-width: 860px) {
            .main { grid-template-columns: 1fr; }
            .sidebar { order: -1; }
            .form-row { grid-template-columns: 1fr; }
        }
        @media (max-width: 600px) {
            .topnav { padding: 0 20px; }
            .page-header { padding: 28px 20px; }
            .main { padding: 24px 16px 48px; }
            .form-body { padding: 20px; }
        }
    </style>
</head>
<body>

    <!-- ═══ NAV ═══ -->
    <nav class="topnav">
        <a class="nav-brand" href="${pageContext.request.contextPath}/guest-dashboard">
            <svg width="32" height="32" viewBox="0 0 36 36" fill="none">
                <circle cx="18" cy="18" r="17" stroke="#c9a84c" stroke-width="1"/>
                <path d="M5 22 Q9 16 13 20 Q17 24 21 17 Q25 10 31 14" stroke="#c9a84c" stroke-width="1.2" fill="none" stroke-linecap="round"/>
            </svg>
            <div class="nav-brand-text">Ocean View <span>Resort</span></div>
        </a>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/guest-dashboard" class="nav-back">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                Dashboard
            </a>
            <div class="nav-avatar"><%= guestName.charAt(0) %></div>
        </div>
    </nav>

    <!-- ═══ PAGE HEADER ═══ -->
    <div class="page-header">
        <div class="page-header-inner">
            <div class="page-eyebrow">Reservations</div>
            <h1 class="page-title">Book a <em>Room</em></h1>
            <p class="page-sub">Choose your dates and preferred room type to check availability instantly.</p>
        </div>
    </div>

    <!-- ═══ MAIN ═══ -->
    <div class="main">

        <!-- FORM CARD -->
        <div class="form-card">

            <div class="form-card-header">
                <div class="form-card-header-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#2e5f74" stroke-width="1.8">
                        <rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/>
                        <line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>
                    </svg>
                </div>
                <div>
                    <h2>Reservation Details</h2>
                    <p>All fields are required. Rates are shown in Sri Lankan Rupees (LKR).</p>
                </div>
            </div>

            <div class="form-body">

                <!-- Steps -->
                <div class="steps">
                    <div class="step active"><div class="step-num">1</div> Dates</div>
                    <div class="step-line"></div>
                    <div class="step active"><div class="step-num">2</div> Room</div>
                    <div class="step-line"></div>
                    <div class="step"><div class="step-num">3</div> Confirm</div>
                </div>

                <!-- Server-side error -->
                <c:if test="${not empty error}">
                    <div class="alert alert-error">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                        ${error}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/reservation" method="post" id="reservationForm" novalidate>

                    <!-- Dates row -->
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="checkin_date">Check-in Date</label>
                            <div class="input-wrap">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                <input type="date" id="checkin_date" name="checkin_date"
                                       class="form-control" min="<%= today %>" required
                                       value="${param.checkin}"
                                       onchange="onDateChange()">
                            </div>
                            <div class="field-error" id="err-checkin">Please select a check-in date.</div>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="checkout_date">Check-out Date</label>
                            <div class="input-wrap">
                                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                <input type="date" id="checkout_date" name="checkout_date"
                                       class="form-control" min="<%= tomorrow %>" required
                                       value="${param.checkout}"
                                       onchange="onDateChange()">
                            </div>
                            <div class="field-error" id="err-checkout">Check-out must be after check-in.</div>
                        </div>
                    </div>

                    <!-- Nights badge -->
                    <div id="nightsBadge" class="nights-badge" style="display:none;">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#c9a84c" stroke-width="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                        <span id="nightsText">—</span>
                    </div>

                    <div style="margin-top:24px; margin-bottom:4px;">
                        <label class="form-label" for="roomType">Room Type</label>
                        <div class="input-wrap">
                            <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                            <select id="roomType" name="room_type" class="form-control"
                                    onchange="loadRoomDetails()" required>
                                <option value="">— Select a room type —</option>
                                <c:forEach var="rt" items="${rooms}">
                                    <option value="${rt.id}"
                                            data-rate="${rt.ratePerNight}"
                                            data-name="${rt.typeName}"
                                            <%= request.getParameter("typeId") != null && 
                                                request.getParameter("typeId").equals(String.valueOf(pageContext.getAttribute("rt") != null ? 
                                                ((com.oceanview.oceanviewresort.model.RoomType)pageContext.findAttribute("rt")).getId() : 0)) 
                                                ? "selected" : "" %>>
                                        ${rt.typeName} &nbsp;|&nbsp; LKR ${rt.ratePerNight} / night
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="field-error" id="err-room">Please select a room type.</div>

                        <!-- Dynamic room info panel -->
                        <div class="room-info-panel" id="roomInfoPanel">
                            <div class="room-info-row">
                                <span class="room-info-label">Availability</span>
                                <span class="room-info-value" id="riAvail">—</span>
                            </div>
                            <div class="room-info-row">
                                <span class="room-info-label">Rate per Night</span>
                                <span class="room-info-value" id="riRate">—</span>
                            </div>
                            <div class="room-info-row">
                                <span class="room-info-label">Description</span>
                                <span class="room-info-value" id="riDesc" style="font-weight:400;font-size:0.8rem;max-width:60%;text-align:right;">—</span>
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn-submit" id="submitBtn">
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                        Confirm Reservation
                    </button>

                </form>
            </div>
        </div>

        <!-- ─── SIDEBAR ─── -->
        <div class="sidebar">

            <!-- Live Summary -->
<!--            <div class="summary-card">
                <div class="summary-header">
                    <h3>Booking Summary</h3>
                    <p>Updates as you fill the form</p>
                </div>
                <div class="summary-body" id="summaryBody">
                    <div class="summary-placeholder">Fill in the details to see your booking summary.</div>
                </div>
            </div>-->

            <!-- Tips -->
            <div class="tips-card">
                <div class="tips-title">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#e2c47a" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    Booking Tips
                </div>
                <div class="tip-item"><div class="tip-dot"></div>Check-in time is 2:00 PM. Early check-in subject to availability.</div>
                <div class="tip-item"><div class="tip-dot"></div>Check-out time is 11:00 AM. Late check-out can be arranged.</div>
                <div class="tip-item"><div class="tip-dot"></div>Cancellations must be made 48 hours before check-in.</div>
                <div class="tip-item"><div class="tip-dot"></div>All rates include breakfast for two guests.</div>
            </div>

        </div>
    </div>

    <script>
        const ctx = '${pageContext.request.contextPath}';

        function onDateChange() {
            const cin  = document.getElementById('checkin_date').value;
            const cout = document.getElementById('checkout_date').value;
            const badge = document.getElementById('nightsBadge');

            // Keep checkout min = checkin + 1
            if (cin) {
                const next = new Date(cin);
                next.setDate(next.getDate() + 1);
                document.getElementById('checkout_date').min = next.toISOString().split('T')[0];
            }

            if (cin && cout && cout > cin) {
                const diff  = (new Date(cout) - new Date(cin)) / 86400000;
                const txt   = diff === 1 ? '1 night' : diff + ' nights';
                document.getElementById('nightsText').textContent = txt;
                badge.style.display = 'inline-flex';
                document.getElementById('err-checkout').style.display = 'none';
            } else if (cin && cout && cout <= cin) {
                badge.style.display = 'none';
                document.getElementById('err-checkout').style.display = 'block';
            } else {
                badge.style.display = 'none';
            }
            updateSummary();
        }

        function loadRoomDetails() {
            const sel    = document.getElementById('roomType');
            const typeId = sel.value;
            const panel  = document.getElementById('roomInfoPanel');

            if (!typeId) { panel.classList.remove('visible'); updateSummary(); return; }

            fetch(ctx + '/room-details?typeId=' + typeId)
                .then(r => r.json())
                .then(data => {
                    const avail = data.available > 0;
                    document.getElementById('riAvail').innerHTML =
                        '<span class="room-avail-badge ' + (avail ? 'ok' : 'no') + '">' +
                        (avail ? '✓ ' + data.available + ' available' : '✗ Fully Booked') +
                        '</span>';
                    const opt = sel.options[sel.selectedIndex];
                    document.getElementById('riRate').textContent =
                        'LKR ' + Number(opt.dataset.rate).toLocaleString() + ' / night';
                    document.getElementById('riDesc').textContent = data.description || '—';
                    panel.classList.add('visible');
                    document.getElementById('err-room').style.display = 'none';
                    updateSummary(data.available > 0);
                })
                .catch(() => panel.classList.remove('visible'));
        }

        function updateSummary(roomAvail) {
            
            const descText = document.getElementById('riDesc') 
                ? document.getElementById('riDesc').textContent 
                : '—';

            const availHtml = document.getElementById('riAvail') 
                ? document.getElementById('riAvail').innerHTML 
                : '—';
            const cin    = document.getElementById('checkin_date').value;
            const cout   = document.getElementById('checkout_date').value;
            const sel    = document.getElementById('roomType');
            const typeId = sel.value;
            const body   = document.getElementById('summaryBody');

            if (!cin || !cout || !typeId || cout <= cin) {
                body.innerHTML = '<div class="summary-placeholder">Fill in the details to see your booking summary.</div>';
                return;
            }

            const diff  = (new Date(cout) - new Date(cin)) / 86400000;
            const opt   = sel.options[sel.selectedIndex];
            const rate  = parseFloat(opt.dataset.rate) || 0;
            const total = diff * rate;

            const fmtDate = d => new Date(d + 'T00:00').toLocaleDateString('en-GB', { day:'numeric', month:'short', year:'numeric' });
            
            body.innerHTML =
                '<div class="summary-row"><span class="summary-key">Room Type</span>' +
                    '<span class="summary-val" style="font-weight:600">' + opt.dataset.name + '</span></div>' +
                '<div class="summary-row" style="flex-direction:column;align-items:flex-start;gap:4px;">' +
                    '<span class="summary-key">Description</span>' +
                    '<span style="font-size:0.8rem;color:var(--text-mid);font-weight:300;line-height:1.5">' + descText + '</span></div>' +
                '<div class="summary-row"><span class="summary-key">Availability</span>' +
                    '<span class="summary-val">' + availHtml + '</span></div>' +
                '<div class="summary-row"><span class="summary-key">Check-in</span>' +
                    '<span class="summary-val">' + fmtDate(cin) + '</span></div>' +
                '<div class="summary-row"><span class="summary-key">Check-out</span>' +
                    '<span class="summary-val">' + fmtDate(cout) + '</span></div>' +
                '<div class="summary-row"><span class="summary-key">Duration</span>' +
                    '<span class="summary-val">' + diff + ' night' + (diff > 1 ? 's' : '') + '</span></div>' +
                '<div class="summary-row"><span class="summary-key">Rate / night</span>' +
                    '<span class="summary-val">LKR ' + rate.toLocaleString() + '</span></div>' +
                '<div class="summary-row" style="border-bottom:none;"><span class="summary-key">Total</span>' +
                    '<span class="summary-val total">LKR ' + total.toLocaleString() + '</span></div>';

//            body.innerHTML = `
//                <div class="summary-row">
//                    <span class="summary-key">Room</span>
//                    <span class="summary-val">${opt.dataset.name}</span>
//                </div>
//                <div class="summary-row">
//                    <span class="summary-key">Check-in</span>
//                    <span class="summary-val">${fmtDate(cin)}</span>
//                </div>
//                <div class="summary-row">
//                    <span class="summary-key">Check-out</span>
//                    <span class="summary-val">${fmtDate(cout)}</span>
//                </div>
//                <div class="summary-row">
//                    <span class="summary-key">Duration</span>
//                    <span class="summary-val">${diff} night${diff > 1 ? 's' : ''}</span>
//                </div>
//                <div class="summary-row">
//                    <span class="summary-key">Rate / night</span>
//                    <span class="summary-val">LKR ${rate.toLocaleString()}</span>
//                </div>
//                <div class="summary-row">
//                    <span class="summary-key">Total</span>
//                    <span class="summary-val total">LKR ${total.toLocaleString()}</span>
//                </div>
//            `;
        }

        // Form validation before submit
        document.getElementById('reservationForm').addEventListener('submit', function(e) {
            let valid = true;
            const cin    = document.getElementById('checkin_date').value;
            const cout   = document.getElementById('checkout_date').value;
            const room   = document.getElementById('roomType').value;

            if (!cin) {
                document.getElementById('err-checkin').style.display = 'block';
                document.getElementById('checkin_date').classList.add('error');
                valid = false;
            }
            if (!cout || cout <= cin) {
                document.getElementById('err-checkout').style.display = 'block';
                document.getElementById('checkout_date').classList.add('error');
                valid = false;
            }
            if (!room) {
                document.getElementById('err-room').style.display = 'block';
                document.getElementById('roomType').classList.add('error');
                valid = false;
            }
            if (!valid) e.preventDefault();
        });

        // Clear errors on input
        ['checkin_date','checkout_date','roomType'].forEach(id => {
            document.getElementById(id).addEventListener('change', function() {
                this.classList.remove('error');
            });
        });

        // ── Auto-trigger when page loads with pre-filled URL params ───────────
        // Happens when guest arrives from rooms.jsp "Book Now" button
        // which passes ?checkin=...&checkout=...&typeId=...
        window.addEventListener('load', function() {
            const cin  = document.getElementById('checkin_date').value;
            const cout = document.getElementById('checkout_date').value;
            const room = document.getElementById('roomType').value;

            if (cin && cout && cout > cin) {
                // Show the nights badge
                const diff = (new Date(cout) - new Date(cin)) / 86400000;
                document.getElementById('nightsText').textContent =
                    diff === 1 ? '1 night' : diff + ' nights';
                document.getElementById('nightsBadge').style.display = 'inline-flex';
                // Update checkout min
                const next = new Date(cin);
                next.setDate(next.getDate() + 1);
                document.getElementById('checkout_date').min = next.toISOString().split('T')[0];
            }

            if (room) {
                // Fetch description + availability and populate the summary
                loadRoomDetails();
            }
        });
    </script>

</body>
</html>
