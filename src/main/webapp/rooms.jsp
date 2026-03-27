<%--
    Document   : rooms
    Project    : Ocean View Resort - Room Reservation System
--%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="
    com.oceanview.oceanviewresort.model.RoomType,
    java.util.List,
    java.time.LocalDate,
    java.time.format.DateTimeFormatter
" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null) {
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

    boolean isAdmin  = "admin".equals(role);
    String  backUrl  = isAdmin ? "/admin.jsp" : "/guest-dashboard";

    List<RoomType> roomTypes     = (List<RoomType>) request.getAttribute("roomTypes");
    int[]          totalCounts   = (int[])          request.getAttribute("totalCounts");
    int[]          availCounts   = (int[])          request.getAttribute("availableCounts");
    boolean        datesProvided = Boolean.TRUE.equals(request.getAttribute("datesProvided"));
    String         checkinVal    = (String)          request.getAttribute("checkinVal");
    String         checkoutVal   = (String)          request.getAttribute("checkoutVal");
    String         dateError     = (String)          request.getAttribute("dateError");

    // Today / tomorrow for date input min values
    String today    = LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE);
    String tomorrow = LocalDate.now().plusDays(1).format(DateTimeFormatter.ISO_LOCAL_DATE);

    // Count available types when dates are filtered
    int availableTypes = 0;
    if (datesProvided && availCounts != null) {
        for (int c : availCounts) if (c > 0) availableTypes++;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Our Rooms — Ocean View Resort</title>
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
            --error:       #e05555;
            --error-pale:  #fdf0f0;
        }

        body { font-family:'Jost',sans-serif; background:var(--sand); color:var(--text-dark); min-height:100vh; }

        /* ── NAV ── */
        .topnav { background:var(--ocean); padding:0 48px; height:64px; display:flex; align-items:center; justify-content:space-between; position:sticky; top:0; z-index:100; box-shadow:0 2px 16px rgba(0,0,0,.2); }
        .nav-brand { display:flex; align-items:center; gap:12px; text-decoration:none; }
        .nav-brand-text { font-family:'Cormorant Garamond',serif; font-size:1.25rem; font-weight:400; color:var(--white); letter-spacing:.05em; }
        .nav-brand-text span { color:var(--gold); font-style:italic; }
        .nav-right { display:flex; align-items:center; gap:16px; }
        .nav-back { display:flex; align-items:center; gap:6px; padding:7px 16px; border:1px solid rgba(255,255,255,.15); border-radius:4px; color:rgba(255,255,255,.7); font-size:.78rem; font-weight:500; letter-spacing:.1em; text-transform:uppercase; text-decoration:none; transition:border-color .2s,color .2s; }
        .nav-back:hover { border-color:rgba(255,255,255,.4); color:var(--white); }
        .nav-avatar { width:36px; height:36px; border-radius:50%; background:linear-gradient(135deg,var(--gold),var(--ocean-light)); display:flex; align-items:center; justify-content:center; font-family:'Cormorant Garamond',serif; font-size:1rem; color:var(--white); }

        /* ── PAGE HEADER ── */
        .page-header { background:linear-gradient(135deg,var(--ocean) 0%,var(--ocean-mid) 100%); padding:48px 48px 56px; position:relative; overflow:hidden; }
        .page-header::before { content:''; position:absolute; width:500px; height:500px; border-radius:50%; border:1px solid rgba(201,168,76,.12); top:-200px; right:-100px; }
        .header-inner { position:relative; z-index:2; max-width:1100px; margin:0 auto; }
        .page-eyebrow { font-size:.68rem; letter-spacing:.28em; text-transform:uppercase; color:var(--gold-light); font-weight:500; margin-bottom:10px; }
        .page-title { font-family:'Cormorant Garamond',serif; font-size:2.8rem; font-weight:300; color:var(--white); line-height:1.1; }
        .page-title em { font-style:italic; color:var(--gold-light); }
        .page-sub { margin-top:10px; font-size:.88rem; color:rgba(255,255,255,.45); font-weight:300; line-height:1.7; max-width:520px; }

        /* ── DATE FILTER CARD ── */
        .filter-card {
            background:rgba(255,255,255,.1);
            border:1px solid rgba(255,255,255,.15);
            border-radius:14px;
            padding:22px 28px;
            margin-top:28px;
            backdrop-filter:blur(4px);
        }
        .filter-label {
            font-size:.65rem; letter-spacing:.2em; text-transform:uppercase;
            color:rgba(255,255,255,.5); font-weight:500; margin-bottom:14px;
            display:flex; align-items:center; gap:8px;
        }
        .filter-label svg { width:13px; height:13px; }
        .filter-form {
            display:flex; align-items:flex-end; gap:14px; flex-wrap:wrap;
        }
        .filter-group { display:flex; flex-direction:column; gap:6px; flex:1; min-width:160px; }
        .filter-group label { font-size:.68rem; letter-spacing:.14em; text-transform:uppercase; color:rgba(255,255,255,.55); font-weight:500; }
        .filter-input {
            padding:11px 14px;
            border:1.5px solid rgba(255,255,255,.2);
            border-radius:8px;
            background:rgba(255,255,255,.1);
            color:var(--white);
            font-family:'Jost',sans-serif; font-size:.88rem;
            outline:none;
            transition:border-color .2s,background .2s;
            color-scheme:dark;
        }
        .filter-input:focus { border-color:var(--gold); background:rgba(255,255,255,.15); }
        .filter-input::-webkit-calendar-picker-indicator { filter:invert(1) opacity(.6); }
        .btn-filter {
            padding:11px 28px; border-radius:8px;
            background:var(--gold); color:var(--ocean);
            font-family:'Jost',sans-serif; font-size:.8rem; font-weight:700;
            letter-spacing:.12em; text-transform:uppercase;
            border:none; cursor:pointer;
            transition:background .2s,transform .15s;
            white-space:nowrap;
        }
        .btn-filter:hover { background:var(--gold-light); transform:translateY(-1px); }
        .btn-clear {
            padding:11px 18px; border-radius:8px;
            background:rgba(255,255,255,.08);
            border:1px solid rgba(255,255,255,.15);
            color:rgba(255,255,255,.6);
            font-family:'Jost',sans-serif; font-size:.78rem; font-weight:500;
            cursor:pointer; text-decoration:none; white-space:nowrap;
            transition:background .2s,color .2s;
        }
        .btn-clear:hover { background:rgba(255,255,255,.12); color:var(--white); }

        /* Date error */
        .date-error { margin-top:10px; font-size:.8rem; color:#f08080; display:flex; align-items:center; gap:6px; }

        /* ── RESULTS BAR ── */
        .results-bar {
            max-width:1100px; margin:0 auto;
            padding:28px 32px 0;
            display:flex; align-items:center; justify-content:space-between;
            flex-wrap:wrap; gap:12px;
            animation:fadeUp .4s ease both;
        }
        .results-text h2 { font-family:'Cormorant Garamond',serif; font-size:1.4rem; font-weight:400; color:var(--text-dark); }
        .results-text p  { font-size:.8rem; color:var(--text-light); margin-top:3px; }

        .results-badge {
            display:inline-flex; align-items:center; gap:6px;
            padding:6px 14px; border-radius:20px;
            font-size:.75rem; font-weight:600;
        }
        .badge-filtered  { background:var(--success-pale); color:var(--success); }
        .badge-unfiltered{ background:var(--ocean-pale);   color:var(--ocean-mid); }
        .badge-none      { background:#fdf0f0;             color:var(--error); }

        /* ── MAIN ── */
        .main { max-width:1100px; margin:0 auto; padding:24px 32px 80px; }

        /* ── ROOM CARDS ── */
        .rooms-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(480px,1fr)); gap:24px; }

        .room-card {
            background:var(--white); border-radius:16px;
            box-shadow:0 2px 16px rgba(26,58,74,.08); overflow:hidden;
            display:flex; flex-direction:column;
            animation:fadeUp .5s ease both;
            transition:transform .2s,box-shadow .2s;
            position:relative;
        }
        .room-card:hover { transform:translateY(-4px); box-shadow:0 12px 36px rgba(26,58,74,.13); }

        /* Booked-out overlay */
        .room-card.fully-booked::after {
            content:'Fully Booked';
            position:absolute; top:14px; left:14px;
            background:var(--error); color:var(--white);
            font-size:.65rem; font-weight:700; letter-spacing:.15em; text-transform:uppercase;
            padding:4px 10px; border-radius:4px; z-index:5;
        }
        .room-card.fully-booked { opacity:.75; }

        /* Illustration */
        .room-illustration { height:180px; position:relative; overflow:hidden; display:flex; align-items:center; justify-content:center; }
        .room-illustration svg { width:100%; height:100%; }
        .rate-badge { position:absolute; top:16px; right:16px; background:var(--ocean); color:var(--white); padding:6px 14px; border-radius:20px; font-family:'Cormorant Garamond',serif; font-size:1rem; font-weight:400; }
        .rate-badge span { font-size:.65rem; font-family:'Jost',sans-serif; opacity:.7; margin-left:2px; }

        /* Body */
        .room-body { padding:24px 28px; flex:1; display:flex; flex-direction:column; gap:16px; }
        .room-title { font-family:'Cormorant Garamond',serif; font-size:1.5rem; font-weight:400; color:var(--text-dark); }
        .room-description { font-size:.85rem; color:var(--text-mid); line-height:1.75; font-weight:300; }

        /* Stats */
        .room-stats { display:flex; border:1px solid var(--sand-dark); border-radius:10px; overflow:hidden; }
        .room-stat { flex:1; padding:12px 16px; text-align:center; border-right:1px solid var(--sand-dark); }
        .room-stat:last-child { border-right:none; }
        .room-stat-val { font-family:'Cormorant Garamond',serif; font-size:1.4rem; font-weight:400; color:var(--ocean); line-height:1; }
        .room-stat-val.avail-yes { color:var(--success); }
        .room-stat-val.avail-no  { color:var(--error); }
        .room-stat-val.avail-na  { color:var(--text-light); font-size:1rem; }
        .room-stat-label { font-size:.62rem; text-transform:uppercase; letter-spacing:.14em; color:var(--text-light); font-weight:500; margin-top:4px; }

        /* Amenities */
        .amenities { display:flex; flex-wrap:wrap; gap:8px; }
        .amenity-tag { display:inline-flex; align-items:center; gap:5px; padding:4px 10px; border-radius:20px; background:var(--ocean-pale); color:var(--ocean-mid); font-size:.7rem; font-weight:500; }
        .amenity-tag svg { width:11px; height:11px; }

        /* Footer */
        .room-footer { padding:18px 28px; border-top:1px solid var(--sand); display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap; }
        .room-footer-price { font-family:'Cormorant Garamond',serif; font-size:1.6rem; font-weight:400; color:var(--ocean); line-height:1; }
        .room-footer-price span { font-family:'Jost',sans-serif; font-size:.72rem; color:var(--text-light); font-weight:400; margin-left:4px; }

        /* Availability pill */
        .avail-pill { display:inline-flex; align-items:center; gap:5px; padding:4px 12px; border-radius:20px; font-size:.72rem; font-weight:600; }
        .avail-pill.has  { background:var(--success-pale); color:var(--success); }
        .avail-pill.zero { background:#fdf0f0; color:var(--error); }
        .avail-pill.none { background:var(--ocean-pale); color:var(--text-mid); font-weight:400; }

        /* Book button */
        .btn-book { display:inline-flex; align-items:center; gap:7px; padding:11px 22px; border-radius:8px; background:var(--ocean); color:var(--white); text-decoration:none; font-size:.78rem; font-weight:600; letter-spacing:.12em; text-transform:uppercase; transition:background .2s,transform .15s; }
        .btn-book:hover { background:var(--ocean-mid); transform:translateY(-1px); }
        .btn-book.disabled { background:var(--text-light); cursor:not-allowed; pointer-events:none; }
        .btn-book svg { width:14px; height:14px; }

        /* Empty / no results */
        .empty { text-align:center; padding:80px 32px; }
        .empty-icon { width:72px; height:72px; border-radius:50%; background:var(--ocean-pale); display:flex; align-items:center; justify-content:center; margin:0 auto 20px; }
        .empty h3 { font-family:'Cormorant Garamond',serif; font-size:1.5rem; color:var(--text-dark); margin-bottom:8px; }
        .empty p  { font-size:.85rem; color:var(--text-light); margin-bottom:20px; }
        .btn-reset { display:inline-flex; align-items:center; gap:6px; padding:10px 20px; border-radius:8px; background:var(--ocean); color:var(--white); text-decoration:none; font-size:.78rem; font-weight:600; letter-spacing:.1em; text-transform:uppercase; transition:background .2s; }
        .btn-reset:hover { background:var(--ocean-mid); }

        @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:translateY(0)} }
        .room-card:nth-child(1){animation-delay:.05s}
        .room-card:nth-child(2){animation-delay:.1s}
        .room-card:nth-child(3){animation-delay:.15s}
        .room-card:nth-child(4){animation-delay:.2s}

        @media(max-width:700px){
            .topnav{padding:0 20px}
            .page-header{padding:36px 20px 44px}
            .filter-form{flex-direction:column}
            .results-bar,.main{padding-left:16px;padding-right:16px}
            .rooms-grid{grid-template-columns:1fr}
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
        <a href="${pageContext.request.contextPath}<%= backUrl %>" class="nav-back">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
            <%= isAdmin ? "Dashboard" : "My Dashboard" %>
        </a>
        <div class="nav-avatar"><%= guestName.charAt(0) %></div>
    </div>
</nav>

<!-- ═══ PAGE HEADER + DATE FILTER ═══ -->
<div class="page-header">
    <div class="header-inner">
        <div class="page-eyebrow">Accommodations</div>
        <h1 class="page-title">Our <em>Rooms</em></h1>
        <p class="page-sub">Pick your dates to see exactly which rooms are available for your stay.</p>

        <!-- Date Filter -->
        <div class="filter-card">
            <div class="filter-label">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                Check availability for your dates
            </div>
            <form class="filter-form" method="get" action="${pageContext.request.contextPath}/rooms" id="filterForm">
                <div class="filter-group">
                    <label for="f_checkin">Check-in Date</label>
                    <input type="date" id="f_checkin" name="checkin" class="filter-input"
                           min="<%= today %>"
                           value="<%= checkinVal %>"
                           required
                           onchange="updateCheckoutMin()">
                </div>
                <div class="filter-group">
                    <label for="f_checkout">Check-out Date</label>
                    <input type="date" id="f_checkout" name="checkout" class="filter-input"
                           min="<%= tomorrow %>"
                           value="<%= checkoutVal %>"
                           required>
                </div>
                <button type="submit" class="btn-filter">
                    Check Availability
                </button>
                <% if (datesProvided) { %>
                <a href="${pageContext.request.contextPath}/rooms" class="btn-clear">Clear</a>
                <% } %>
            </form>
            <% if (dateError != null) { %>
            <div class="date-error">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <%= dateError %>
            </div>
            <% } %>
        </div>
    </div>
</div>

<!-- ═══ RESULTS BAR ═══ -->
<div class="results-bar">
    <div class="results-text">
        <% if (datesProvided) { %>
            <h2><%= availableTypes %> Room Type<%= availableTypes != 1 ? "s" : "" %> Available</h2>
            <p>For <%= checkinVal %> → <%= checkoutVal %></p>
        <% } else { %>
            <h2><%= roomTypes != null ? roomTypes.size() : 0 %> Room Types</h2>
            <p>Select your dates above to see live availability</p>
        <% } %>
    </div>
    <% if (datesProvided) { %>
        <span class="results-badge <%= availableTypes > 0 ? "badge-filtered" : "badge-none" %>">
            <%= availableTypes > 0
                ? "&#10003; " + availableTypes + " available"
                : "&#10007; None available" %>
        </span>
    <% } else { %>
        <span class="results-badge badge-unfiltered">
            Select dates to filter
        </span>
    <% } %>
</div>

<!-- ═══ MAIN ═══ -->
<main class="main">

    <%
        if (roomTypes == null || roomTypes.isEmpty()) {
    %>
    <div class="empty">
        <div class="empty-icon">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="var(--ocean-light)" stroke-width="1.5"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
        </div>
        <h3>No rooms configured</h3>
        <p>Room types have not been set up yet.</p>
    </div>
    <%
        } else {
            // Amenities per room index
            String[][] amenities = {
                {"Ocean View","King Bed","Balcony","Free WiFi","Breakfast"},
                {"Garden View","Queen Bed","En-Suite","Free WiFi","Breakfast"},
                {"Ocean View","2 Bedrooms","Living Area","Kitchenette","Breakfast"},
                {"Panoramic View","Private Pool","Butler","Free WiFi","Breakfast"}
            };
            String[] gradients = {
                "linear-gradient(135deg,#1a3a4a 0%,#2e5f74 100%)",
                "linear-gradient(135deg,#2e5f74 0%,#4a8fa8 100%)",
                "linear-gradient(135deg,#1a3a4a 0%,#4a5a65 100%)",
                "linear-gradient(135deg,#c9a84c 0%,#2e5f74 100%)"
            };
    %>
    <div class="rooms-grid">
        <%
            for (int i = 0; i < roomTypes.size(); i++) {
                RoomType rt    = roomTypes.get(i);
                int total      = totalCounts != null && i < totalCounts.length   ? totalCounts[i]  : 0;
                int avail      = availCounts != null  && i < availCounts.length   ? availCounts[i]  : -1;
                boolean booked = datesProvided && avail == 0;
                String[] tags  = i < amenities.length ? amenities[i] : new String[]{"Free WiFi","Breakfast","En-Suite"};
                String grad    = gradients[i % gradients.length];

                // Build the Book Now URL — pre-fill dates if known
                String bookUrl = request.getContextPath() + "/reservation"
                    + (datesProvided ? "?checkin=" + checkinVal + "&checkout=" + checkoutVal + "&typeId=" + rt.getId() : "");
        %>
        <div class="room-card <%= booked ? "fully-booked" : "" %>">

            <!-- Illustration -->
            <div class="room-illustration" style="background:<%= grad %>;">
                <svg viewBox="0 0 480 180" xmlns="http://www.w3.org/2000/svg">
                    <rect x="0"   y="140" width="480" height="40" fill="rgba(0,0,0,.15)"/>
                    <rect x="140" y="80"  width="200" height="65" rx="6" fill="rgba(255,255,255,.12)"/>
                    <rect x="140" y="60"  width="200" height="30" rx="6" fill="rgba(255,255,255,.18)"/>
                    <rect x="155" y="84"  width="70"  height="35" rx="5" fill="rgba(255,255,255,.22)"/>
                    <rect x="255" y="84"  width="70"  height="35" rx="5" fill="rgba(255,255,255,.22)"/>
                    <rect x="140" y="118" width="200" height="22" rx="3" fill="rgba(201,168,76,.3)"/>
                    <rect x="100" y="100" width="35"  height="45" rx="4" fill="rgba(255,255,255,.1)"/>
                    <rect x="112" y="88"  width="12"  height="14" rx="2" fill="rgba(255,255,255,.2)"/>
                    <polygon points="106,88 118,88 114,78 110,78" fill="rgba(255,215,100,.4)"/>
                    <rect x="345" y="100" width="35"  height="45" rx="4" fill="rgba(255,255,255,.1)"/>
                    <rect x="356" y="88"  width="12"  height="14" rx="2" fill="rgba(255,255,255,.2)"/>
                    <polygon points="350,88 362,88 358,78 354,78" fill="rgba(255,215,100,.4)"/>
                    <rect x="30"  y="30"  width="60"  height="80" rx="4" fill="rgba(135,206,235,.2)" stroke="rgba(255,255,255,.2)" stroke-width="1"/>
                    <line x1="60" y1="30" x2="60" y2="110" stroke="rgba(255,255,255,.15)" stroke-width="1"/>
                    <line x1="30" y1="70" x2="90" y2="70"  stroke="rgba(255,255,255,.15)" stroke-width="1"/>
                    <rect x="31"  y="71"  width="58"  height="38" fill="rgba(74,143,168,.25)"/>
                </svg>
                <div class="rate-badge">
                    LKR <%= String.format("%,.0f", rt.getRatePerNight()) %><span>/ night</span>
                </div>
            </div>

            <!-- Body -->
            <div class="room-body">
                <div class="room-title"><%= rt.getTypeName() %></div>

                <div class="room-description">
                    <%= rt.getDescription() != null && !rt.getDescription().isEmpty()
                        ? rt.getDescription()
                        : "A well-appointed room offering the finest in beachside hospitality at Ocean View Resort." %>
                </div>

                <!-- Stats row: Available / Total / Rate -->
                <div class="room-stats">
                    <div class="room-stat">
                        <%
                            String availClass = "avail-na";
                            String availText  = "—";
                            if (datesProvided) {
                                availClass = avail > 0 ? "avail-yes" : "avail-no";
                                availText  = String.valueOf(avail);
                            }
                        %>
                        <div class="room-stat-val <%= availClass %>"><%= availText %></div>
                        <div class="room-stat-label">Available</div>
                    </div>
                    <div class="room-stat">
                        <div class="room-stat-val"><%= total %></div>
                        <div class="room-stat-label">Total Rooms</div>
                    </div>
                    <div class="room-stat">
                        <div class="room-stat-val">LKR <%= String.format("%,.0f", rt.getRatePerNight()) %></div>
                        <div class="room-stat-label">Per Night</div>
                    </div>
                </div>

                <!-- Amenity tags -->
                <div class="amenities">
                    <% for (String tag : tags) { %>
                    <span class="amenity-tag">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                        <%= tag %>
                    </span>
                    <% } %>
                </div>
            </div>

            <!-- Footer -->
            <div class="room-footer">
                <div>
                    <div class="room-footer-price">
                        LKR <%= String.format("%,.0f", rt.getRatePerNight()) %>
                        <span>per night</span>
                    </div>
                    <div style="margin-top:7px;">
                        <%
                            if (!datesProvided) {
                        %>
                            <span class="avail-pill none">Select dates to check</span>
                        <%
                            } else if (avail > 0) {
                        %>
                            <span class="avail-pill has">&#10003; <%= avail %> room<%= avail > 1 ? "s" : "" %> free</span>
                        <%
                            } else {
                        %>
                            <span class="avail-pill zero">&#10007; Fully booked</span>
                        <%
                            }
                        %>
                    </div>
                </div>

                <% if (!isAdmin) { %>
                <a href="<%= bookUrl %>"
                   class="btn-book <%= booked ? "disabled" : "" %>">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="4" width="18" height="18" rx="2"/>
                        <line x1="16" y1="2" x2="16" y2="6"/>
                        <line x1="8"  y1="2" x2="8"  y2="6"/>
                        <line x1="3"  y1="10" x2="21" y2="10"/>
                        <line x1="12" y1="14" x2="12" y2="18"/>
                        <line x1="10" y1="16" x2="14" y2="16"/>
                    </svg>
                    <%= booked ? "Unavailable" : "Book Now" %>
                </a>
                <% } %>
            </div>
        </div>
        <%
            } // end for
        } // end else
        %>
    </div>

</main>

<script>
    // Keep checkout min = checkin + 1 day
    function updateCheckoutMin() {
        const cin = document.getElementById('f_checkin').value;
        if (!cin) return;
        const next = new Date(cin);
        next.setDate(next.getDate() + 1);
        document.getElementById('f_checkout').min = next.toISOString().split('T')[0];

        // If current checkout is now before new checkin, clear it
        const cout = document.getElementById('f_checkout').value;
        if (cout && cout <= cin) {
            document.getElementById('f_checkout').value = '';
        }
    }

    // Auto-submit when both dates are filled
    document.getElementById('f_checkout').addEventListener('change', function() {
        const cin  = document.getElementById('f_checkin').value;
        const cout = this.value;
        if (cin && cout && cout > cin) {
            document.getElementById('filterForm').submit();
        }
    });
</script>

</body>
</html>
