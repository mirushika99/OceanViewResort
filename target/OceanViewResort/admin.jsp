<%--
    Document   : admin
    Project    : Ocean View Resort - Room Reservation System
--%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="
    com.oceanview.oceanviewresort.dao.ReservationDAO,
    com.oceanview.oceanviewresort.model.Reservation,
    java.util.List,
    java.time.LocalDate,
    java.time.LocalDateTime,
    java.time.format.DateTimeFormatter,
    java.util.Locale
" %>
<%
    // ── Auth guard ────────────────────────────────────────────────────────────
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("admin")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // ── Load all reservations for stats ───────────────────────────────────────
    ReservationDAO dao = new ReservationDAO();
    List<Reservation> allReservations = dao.getReservations(null);

    // ── Compute dashboard stats ───────────────────────────────────────────────
    int    totalBookings  = allReservations.size();
    double totalRevenue   = 0;
    int    totalNights    = 0;
    int    activeToday    = 0;
    int    upcomingCount  = 0;

    LocalDate today = LocalDate.now();

    for (Reservation r : allReservations) {
        totalRevenue += r.getTotalAmount();
        totalNights  += r.getNights();

        if (r.getCheckIn() != null && r.getCheckOut() != null) {
            LocalDate ci = r.getCheckIn().toLocalDate();
            LocalDate co = r.getCheckOut().toLocalDate();
            if (!ci.isAfter(today) && !co.isBefore(today)) activeToday++;
            if (ci.isAfter(today)) upcomingCount++;
        }
    }

    // Most recent 5 reservations for activity feed
    List<Reservation> recent = allReservations.size() > 5
        ? allReservations.subList(allReservations.size() - 5, allReservations.size())
        : allReservations;

    // Date / time for header
    String dateStr = LocalDateTime.now()
        .format(DateTimeFormatter.ofPattern("EEEE, d MMMM yyyy", Locale.ENGLISH));
    String timeStr = LocalDateTime.now()
        .format(DateTimeFormatter.ofPattern("hh:mm a", Locale.ENGLISH));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Ocean View Resort</title>
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
            --purple:      #6d4ea0;
            --purple-pale: #f0ebfa;
        }

        body {
            font-family: 'Jost', sans-serif;
            background: var(--sand);
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
        }

        /* ══════════════════════════════════════════
           SIDEBAR
        ══════════════════════════════════════════ */
        .sidebar {
            width: 240px;
            flex-shrink: 0;
            background: var(--ocean);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0; left: 0; bottom: 0;
            z-index: 200;
            transition: transform 0.3s;
        }

        .sidebar-brand {
            padding: 28px 24px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .sidebar-brand-name {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.3rem; font-weight: 400;
            color: var(--white); letter-spacing: 0.04em; line-height: 1.2;
        }
        .sidebar-brand-name span { color: var(--gold); font-style: italic; }
        .sidebar-brand-sub {
            font-size: 0.65rem; letter-spacing: 0.2em;
            text-transform: uppercase; color: rgba(255,255,255,0.3);
            margin-top: 4px;
        }

        .sidebar-section-label {
            font-size: 0.6rem; letter-spacing: 0.22em;
            text-transform: uppercase; color: rgba(255,255,255,0.25);
            font-weight: 600; padding: 20px 24px 8px;
        }

        .sidebar-nav { flex: 1; padding-bottom: 20px; }

        .nav-item {
            display: flex; align-items: center; gap: 12px;
            padding: 11px 24px;
            color: rgba(255,255,255,0.55);
            text-decoration: none;
            font-size: 0.85rem; font-weight: 400;
            transition: background 0.15s, color 0.15s;
            position: relative;
            border-radius: 0;
        }
        .nav-item:hover {
            background: rgba(255,255,255,0.06);
            color: rgba(255,255,255,0.85);
        }
        .nav-item.active {
            background: rgba(201,168,76,0.12);
            color: var(--gold-light);
        }
        .nav-item.active::before {
            content: '';
            position: absolute; left: 0; top: 0; bottom: 0;
            width: 3px; background: var(--gold);
            border-radius: 0 2px 2px 0;
        }
        .nav-item svg { width: 16px; height: 16px; flex-shrink: 0; opacity: 0.8; }
        .nav-item.active svg { opacity: 1; }

        .sidebar-footer {
            padding: 16px 24px 24px;
            border-top: 1px solid rgba(255,255,255,0.08);
        }
        .admin-chip {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 14px;
        }
        .admin-avatar {
            width: 34px; height: 34px; border-radius: 50%;
            background: linear-gradient(135deg, var(--gold), var(--ocean-light));
            display: flex; align-items: center; justify-content: center;
            font-family: 'Cormorant Garamond', serif;
            font-size: 1rem; color: var(--white); flex-shrink: 0;
        }
        .admin-info-name { font-size: 0.82rem; font-weight: 500; color: var(--white); }
        .admin-info-role {
            font-size: 0.65rem; text-transform: uppercase;
            letter-spacing: 0.15em; color: var(--gold-light);
        }
        .btn-logout {
            display: flex; align-items: center; gap: 8px;
            width: 100%; padding: 9px 14px;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 6px;
            color: rgba(255,255,255,0.55);
            font-family: 'Jost', sans-serif;
            font-size: 0.75rem; font-weight: 500;
            letter-spacing: 0.1em; text-transform: uppercase;
            text-decoration: none;
            transition: background 0.2s, color 0.2s;
            cursor: pointer;
        }
        .btn-logout:hover {
            background: rgba(224,85,85,0.12);
            border-color: rgba(224,85,85,0.3);
            color: #f08080;
        }

        /* ══════════════════════════════════════════
           MAIN CONTENT
        ══════════════════════════════════════════ */
        .main-wrap {
            margin-left: 240px;
            flex: 1;
            display: flex; flex-direction: column;
            min-height: 100vh;
        }

        /* Top bar */
        .topbar {
            background: var(--white);
            border-bottom: 1px solid var(--sand-dark);
            padding: 0 36px;
            height: 64px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
        }
        .topbar-left h1 {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.4rem; font-weight: 400; color: var(--text-dark);
        }
        .topbar-left p {
            font-size: 0.75rem; color: var(--text-light); margin-top: 1px;
        }
        .topbar-right { display: flex; align-items: center; gap: 20px; }
        .topbar-time {
            text-align: right;
            font-size: 0.78rem; color: var(--text-light);
        }
        .topbar-time strong {
            display: block; font-size: 1rem;
            color: var(--text-dark); font-weight: 500;
            font-variant-numeric: tabular-nums;
        }

        /* Page body */
        .page-body {
            padding: 32px 36px 64px;
            flex: 1;
        }

        /* ══════════════════════════════════════════
           STAT CARDS
        ══════════════════════════════════════════ */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 32px;
            animation: fadeUp 0.5s ease both;
        }

        .stat-card {
            background: var(--white);
            border-radius: 14px;
            padding: 22px 24px;
            box-shadow: 0 1px 12px rgba(26,58,74,0.07);
            display: flex; align-items: flex-start; gap: 16px;
            position: relative; overflow: hidden;
        }
        .stat-card::after {
            content: '';
            position: absolute; bottom: 0; left: 0; right: 0;
            height: 3px;
            background: var(--stat-color, var(--ocean-mid));
        }

        .stat-icon {
            width: 44px; height: 44px; border-radius: 12px;
            background: var(--stat-pale, var(--ocean-pale));
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .stat-icon svg { width: 20px; height: 20px; }

        .stat-label {
            font-size: 0.68rem; font-weight: 500;
            letter-spacing: 0.15em; text-transform: uppercase;
            color: var(--text-light); margin-bottom: 6px;
        }
        .stat-value {
            font-family: 'Cormorant Garamond', serif;
            font-size: 2rem; font-weight: 400;
            color: var(--text-dark); line-height: 1;
        }
        .stat-sub {
            font-size: 0.72rem; color: var(--text-light);
            margin-top: 4px; font-weight: 300;
        }

        /* Color variants */
        .stat-ocean  { --stat-color: var(--ocean-mid);  --stat-pale: var(--ocean-pale); }
        .stat-gold   { --stat-color: var(--gold);       --stat-pale: var(--gold-pale); }
        .stat-green  { --stat-color: var(--success);    --stat-pale: var(--success-pale); }
        .stat-purple { --stat-color: var(--purple);     --stat-pale: var(--purple-pale); }

        /* ══════════════════════════════════════════
           TWO-COLUMN LAYOUT
        ══════════════════════════════════════════ */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 24px;
            animation: fadeUp 0.5s 0.1s ease both;
        }

        /* ── Card shell ── */
        .card {
            background: var(--white);
            border-radius: 14px;
            box-shadow: 0 1px 12px rgba(26,58,74,0.07);
            overflow: hidden;
        }
        .card-header {
            padding: 18px 24px;
            border-bottom: 1px solid var(--sand);
            display: flex; align-items: center; justify-content: space-between;
        }
        .card-title {
            font-size: 0.95rem; font-weight: 600; color: var(--text-dark);
        }
        .card-sub {
            font-size: 0.75rem; color: var(--text-light); margin-top: 2px;
        }
        .card-link {
            font-size: 0.75rem; color: var(--ocean-light);
            text-decoration: none; font-weight: 500;
            transition: color 0.2s;
        }
        .card-link:hover { color: var(--ocean); }

        /* ── Reservations table ── */
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; font-size: 0.83rem; }
        thead tr { background: var(--sand); }
        thead th {
            padding: 11px 16px; text-align: left;
            font-size: 0.63rem; font-weight: 600;
            letter-spacing: 0.18em; text-transform: uppercase;
            color: var(--text-light); white-space: nowrap;
        }
        tbody tr { border-bottom: 1px solid var(--sand); transition: background 0.12s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #faf7f3; }
        td { padding: 12px 16px; vertical-align: middle; }

        .guest-cell { display: flex; align-items: center; gap: 9px; }
        .mini-avatar {
            width: 30px; height: 30px; border-radius: 50%;
            background: linear-gradient(135deg, var(--ocean-pale), var(--ocean-light));
            display: flex; align-items: center; justify-content: center;
            font-size: 0.72rem; font-weight: 600; color: var(--ocean);
            flex-shrink: 0; text-transform: uppercase;
        }
        .guest-name { font-weight: 500; font-size: 0.83rem; }
        .guest-contact { font-size: 0.7rem; color: var(--text-light); }

        .room-pill {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 3px 9px; border-radius: 20px;
            background: var(--ocean-pale); color: var(--ocean-mid);
            font-size: 0.7rem; font-weight: 600;
        }
        .nights-pill {
            display: inline-block; padding: 2px 8px; border-radius: 20px;
            background: var(--gold-pale); color: #7a5c1e;
            font-size: 0.7rem; font-weight: 600;
        }
        .status-badge {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 3px 9px; border-radius: 20px;
            font-size: 0.68rem; font-weight: 600;
        }
        .status-active    { background: var(--success-pale); color: var(--success); }
        .status-upcoming  { background: var(--ocean-pale);   color: var(--ocean-mid); }
        .status-completed { background: var(--sand-dark);    color: var(--text-mid); }
        .amount-cell {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1rem; font-weight: 600; color: var(--ocean);
        }

        .btn-sm {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 5px 12px; border-radius: 6px;
            font-family: 'Jost', sans-serif;
            font-size: 0.7rem; font-weight: 500;
            text-decoration: none; transition: background 0.2s;
        }
        .btn-view {
            background: var(--ocean);
            color: var(--white);
        }
        .btn-view:hover { background: var(--ocean-mid); }

        /* ── Quick actions sidebar ── */
        .quick-actions { display: flex; flex-direction: column; gap: 16px; }

        .action-item {
            display: flex; align-items: center; gap: 14px;
            padding: 16px 18px;
            border-radius: 10px; text-decoration: none;
            border: 1.5px solid var(--sand-dark);
            transition: border-color 0.2s, transform 0.15s, box-shadow 0.2s;
            background: var(--white);
        }
        .action-item:hover {
            border-color: var(--action-color, var(--ocean-light));
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(26,58,74,0.1);
        }
        .action-icon {
            width: 42px; height: 42px; border-radius: 10px;
            background: var(--action-pale, var(--ocean-pale));
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .action-icon svg { width: 18px; height: 18px; }
        .action-title { font-size: 0.88rem; font-weight: 600; color: var(--text-dark); }
        .action-desc  { font-size: 0.72rem; color: var(--text-light); margin-top: 2px; }

        /* ── Room type summary ── */
        .room-type-list { padding: 8px 0; }
        .room-type-row {
            display: flex; align-items: center; justify-content: space-between;
            padding: 10px 24px;
            border-bottom: 1px solid var(--sand);
        }
        .room-type-row:last-child { border-bottom: none; }
        .rt-name { font-size: 0.85rem; font-weight: 500; }
        .rt-rate { font-size: 0.75rem; color: var(--text-light); margin-top: 1px; }
        .rt-bar-wrap { flex: 1; margin: 0 16px; height: 6px; background: var(--sand-dark); border-radius: 3px; overflow: hidden; }
        .rt-bar { height: 100%; border-radius: 3px; background: var(--ocean-mid); transition: width 1s ease; }

        /* ── Empty state ── */
        .empty-row td { text-align: center; padding: 40px; color: var(--text-light); font-style: italic; }

        /* ══════════════════════════════════════════
           ANIMATIONS
        ══════════════════════════════════════════ */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes countUp {
            from { opacity: 0; transform: translateY(8px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .stat-value { animation: countUp 0.6s ease both; }

        /* ══════════════════════════════════════════
           RESPONSIVE
        ══════════════════════════════════════════ */
        @media (max-width: 1100px) {
            .stats-grid { grid-template-columns: repeat(2,1fr); }
            .dashboard-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-wrap { margin-left: 0; }
            .stats-grid { grid-template-columns: 1fr 1fr; }
        }
    </style>
</head>
<body>

    <!-- ═══════════════════════════════════════
         SIDEBAR
    ═══════════════════════════════════════ -->
    <aside class="sidebar">

        <div class="sidebar-brand">
            <div class="sidebar-brand-name">Ocean View <span>Resort</span></div>
            <div class="sidebar-brand-sub">Admin Panel</div>
        </div>

        <nav class="sidebar-nav">
            <div class="sidebar-section-label">Main</div>

            <a class="nav-item active" href="${pageContext.request.contextPath}/admin.jsp">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
                    <rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/>
                </svg>
                Dashboard
            </a>
                
            <a class="nav-item" href="${pageContext.request.contextPath}/rooms">Rooms</a>

            <a class="nav-item" href="${pageContext.request.contextPath}/history">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                    <line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>
                </svg>
                All Reservations
            </a>
                
            <a class="nav-item" href="${pageContext.request.contextPath}/manage-rooms">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                    <polyline points="9 22 9 12 15 12 15 22"/>
                </svg>
                Manage Rooms
            </a>

<!--            <a class="nav-item" href="${pageContext.request.contextPath}/reservation">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <rect x="3" y="4" width="18" height="18" rx="2"/>
                    <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
                    <line x1="3" y1="10" x2="21" y2="10"/>
                    <line x1="12" y1="14" x2="12" y2="18"/><line x1="10" y1="16" x2="14" y2="16"/>
                </svg>
                New Reservation
            </a>-->

            <div class="sidebar-section-label">Reports</div>

            <a class="nav-item" href="${pageContext.request.contextPath}/history">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/>
                    <line x1="6" y1="20" x2="6" y2="14"/>
                </svg>
                Revenue Report
            </a>

            <a class="nav-item" href="${pageContext.request.contextPath}/help">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                    <circle cx="12" cy="12" r="10"/>
                    <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>
                    <line x1="12" y1="17" x2="12.01" y2="17"/>
                </svg>
                Help
            </a>
        </nav>

        <div class="sidebar-footer">
            <div class="admin-chip">
                <div class="admin-avatar">A</div>
                <div>
                    <div class="admin-info-name">Administrator</div>
                    <div class="admin-info-role">System Admin</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                    <polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
                </svg>
                Sign Out
            </a>
        </div>
    </aside>

    <!-- ═══════════════════════════════════════
         MAIN
    ═══════════════════════════════════════ -->
    <div class="main-wrap">

        <!-- Top bar -->
        <div class="topbar">
            <div class="topbar-left">
                <h1>Dashboard</h1>
                <p><%= dateStr %></p>
            </div>
            <div class="topbar-right">
                <div class="topbar-time">
                    <strong id="liveClock"><%= timeStr %></strong>
                    Ocean View Resort, Galle
                </div>
            </div>
        </div>

        <!-- Page body -->
        <div class="page-body">

            <!-- ── STAT CARDS ── -->
            <div class="stats-grid">

                <div class="stat-card stat-ocean">
                    <div class="stat-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="var(--ocean-mid)" stroke-width="1.8">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                            <polyline points="14 2 14 8 20 8"/>
                        </svg>
                    </div>
                    <div>
                        <div class="stat-label">Total Bookings</div>
                        <div class="stat-value" id="sv-bookings">0</div>
                        <div class="stat-sub">All time reservations</div>
                    </div>
                </div>

                <div class="stat-card stat-gold">
                    <div class="stat-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="var(--gold)" stroke-width="1.8">
                            <line x1="12" y1="1" x2="12" y2="23"/>
                            <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
                        </svg>
                    </div>
                    <div>
                        <div class="stat-label">Total Revenue</div>
                        <div class="stat-value" id="sv-revenue">0</div>
                        <div class="stat-sub">LKR earned overall</div>
                    </div>
                </div>

                <div class="stat-card stat-green">
                    <div class="stat-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="var(--success)" stroke-width="1.8">
                            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                            <polyline points="9 22 9 12 15 12 15 22"/>
                        </svg>
                    </div>
                    <div>
                        <div class="stat-label">Active Today</div>
                        <div class="stat-value" id="sv-active">0</div>
                        <div class="stat-sub">Guests currently staying</div>
                    </div>
                </div>

                <div class="stat-card stat-purple">
                    <div class="stat-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="var(--purple)" stroke-width="1.8">
                            <rect x="3" y="4" width="18" height="18" rx="2"/>
                            <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
                            <line x1="3" y1="10" x2="21" y2="10"/>
                        </svg>
                    </div>
                    <div>
                        <div class="stat-label">Upcoming</div>
                        <div class="stat-value" id="sv-upcoming">0</div>
                        <div class="stat-sub">Future reservations</div>
                    </div>
                </div>

            </div>

            <!-- ── MAIN GRID ── -->
            <div class="dashboard-grid">

                <!-- Recent Reservations Table -->
                <div class="card">
                    <div class="card-header">
                        <div>
                            <div class="card-title">Recent Reservations</div>
                            <div class="card-sub">Latest <%= recent.size() %> of <%= totalBookings %> total</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/history" class="card-link">View all →</a>
                    </div>
                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Guest</th>
                                    <th>Room</th>
                                    <th>Check-in</th>
                                    <th>Nights</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                    <th>Bill</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (recent.isEmpty()) {
                                %>
                                    <tr class="empty-row"><td colspan="7">No reservations yet.</td></tr>
                                <%
                                    } else {
                                        java.time.LocalDate tod = LocalDate.now();
                                        for (int i = recent.size()-1; i >= 0; i--) {
                                            Reservation r = recent.get(i);
                                            String statusCls = "status-upcoming";
                                            String statusLbl = "Upcoming";
                                            if (r.getCheckIn() != null && r.getCheckOut() != null) {
                                                LocalDate ci = r.getCheckIn().toLocalDate();
                                                LocalDate co = r.getCheckOut().toLocalDate();
                                                if (!ci.isAfter(tod) && !co.isBefore(tod)) { statusCls = "status-active"; statusLbl = "Active"; }
                                                else if (co.isBefore(tod))                  { statusCls = "status-completed"; statusLbl = "Completed"; }
                                            }
                                            String initials = "";
                                            if (r.getFirstName() != null && !r.getFirstName().isEmpty()) initials += r.getFirstName().charAt(0);
                                            if (r.getLastName()  != null && !r.getLastName().isEmpty())  initials += r.getLastName().charAt(0);
                                %>
                                <tr>
                                    <td>
                                        <div class="guest-cell">
                                            <div class="mini-avatar"><%= initials %></div>
                                            <div>
                                                <div class="guest-name"><%= r.getFirstName() %> <%= r.getLastName() %></div>
                                                <div class="guest-contact"><%= r.getContactNumber() %></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="room-pill"><%= r.getRoomNumber() %></span></td>
                                    <td style="font-size:0.82rem;white-space:nowrap"><%= r.getCheckIn() %></td>
                                    <td><span class="nights-pill"><%= r.getNights() %>N</span></td>
                                    <td class="amount-cell">LKR <%= String.format("%,.0f", r.getTotalAmount()) %></td>
                                    <td><span class="status-badge <%= statusCls %>"><%= statusLbl %></span></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/bill?id=<%= r.getId() %>"
                                           class="btn-sm btn-view">
                                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                            Bill
                                        </a>
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

                <!-- Right sidebar -->
                <div style="display:flex;flex-direction:column;gap:20px;">

                    <!-- Quick Actions -->
                    <div class="card">
                        <div class="card-header">
                            <div class="card-title">Quick Actions</div>
                        </div>
                        <div style="padding:16px;" class="quick-actions">

                            <a class="action-item" href="${pageContext.request.contextPath}/history"
                               style="--action-color:var(--ocean-mid);--action-pale:var(--ocean-pale)">
                                <div class="action-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="var(--ocean-mid)" stroke-width="1.8">
                                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                                        <polyline points="14 2 14 8 20 8"/>
                                    </svg>
                                </div>
                                <div>
                                    <div class="action-title">All Reservations</div>
                                    <div class="action-desc">Full list with search & filter</div>
                                </div>
                            </a>

<!--                            <a class="action-item" href="${pageContext.request.contextPath}/reservation"
                               style="--action-color:var(--success);--action-pale:var(--success-pale)">
                                <div class="action-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="var(--success)" stroke-width="1.8">
                                        <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                                    </svg>
                                </div>
                                <div>
                                    <div class="action-title">New Reservation</div>
                                    <div class="action-desc">Book a room for a guest</div>
                                </div>
                            </a>-->

                            <a class="action-item" href="${pageContext.request.contextPath}/help"
                               style="--action-color:var(--gold);--action-pale:var(--gold-pale)">
                                <div class="action-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="var(--gold)" stroke-width="1.8">
                                        <circle cx="12" cy="12" r="10"/>
                                        <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>
                                        <line x1="12" y1="17" x2="12.01" y2="17"/>
                                    </svg>
                                </div>
                                <div>
                                    <div class="action-title">Help & Guide</div>
                                    <div class="action-desc">System usage documentation</div>
                                </div>
                            </a>

                        </div>
                    </div>

                    <!-- Revenue summary -->
                    <div class="card">
                        <div class="card-header">
                            <div class="card-title">Summary</div>
                        </div>
                        <div style="padding:0">
                            <div class="room-type-row">
                                <div>
                                    <div class="rt-name">Total Nights Reserved</div>
                                    <div class="rt-rate">Across all reservations</div>
                                </div>
                                <div style="font-family:'Cormorant Garamond',serif;font-size:1.2rem;color:var(--ocean);font-weight:600">
                                    <%= totalNights %>
                                </div>
                            </div>
                            <div class="room-type-row">
                                <div>
                                    <div class="rt-name">Avg. Stay Length</div>
                                    <div class="rt-rate">Nights per booking</div>
                                </div>
                                <div style="font-family:'Cormorant Garamond',serif;font-size:1.2rem;color:var(--ocean);font-weight:600">
                                    <%= totalBookings > 0 ? String.format("%.1f", (double)totalNights/totalBookings) : "—" %>
                                </div>
                            </div>
                            <div class="room-type-row">
                                <div>
                                    <div class="rt-name">Avg. Revenue</div>
                                    <div class="rt-rate">Per reservation</div>
                                </div>
                                <div style="font-family:'Cormorant Garamond',serif;font-size:1.2rem;color:var(--ocean);font-weight:600">
                                    LKR <%= totalBookings > 0 ? String.format("%,.0f", totalRevenue/totalBookings) : "—" %>
                                </div>
                            </div>
                            <div class="room-type-row" style="border-bottom:none;">
                                <div>
                                    <div class="rt-name">Total Revenue</div>
                                    <div class="rt-rate">All bookings combined</div>
                                </div>
                                <div style="font-family:'Cormorant Garamond',serif;font-size:1.2rem;color:var(--gold);font-weight:600">
                                    LKR <%= String.format("%,.0f", totalRevenue) %>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <script>
        // Animated counter for stat cards
        function animateCount(id, target, prefix, suffix, decimals) {
            const el    = document.getElementById(id);
            const dur   = 1200;
            const steps = 60;
            const inc   = target / steps;
            let cur     = 0;
            let count   = 0;
            const timer = setInterval(() => {
                cur += inc;
                count++;
                const display = decimals
                    ? Math.round(cur).toLocaleString()
                    : Math.round(cur).toLocaleString();
                el.textContent = (prefix || '') + display + (suffix || '');
                if (count >= steps) {
                    el.textContent = (prefix || '') + target.toLocaleString() + (suffix || '');
                    clearInterval(timer);
                }
            }, dur / steps);
        }

        // Run counters on load
        window.addEventListener('load', () => {
            animateCount('sv-bookings', <%= totalBookings %>,  '',    '', false);
            animateCount('sv-revenue',  <%= (int)totalRevenue %>, '', '', false);
            animateCount('sv-active',   <%= activeToday %>,   '',    '', false);
            animateCount('sv-upcoming', <%= upcomingCount %>, '',    '', false);
        });

        // Live clock
        function tick() {
            const now  = new Date();
            let h      = now.getHours();
            const m    = now.getMinutes().toString().padStart(2,'0');
            const s    = now.getSeconds().toString().padStart(2,'0');
            const ampm = h >= 12 ? 'PM' : 'AM';
            h = h % 12 || 12;
            document.getElementById('liveClock').textContent = h + ':' + m + ':' + s + ' ' + ampm;
        }
        setInterval(tick, 1000);
        tick();
    </script>

</body>
</html>
