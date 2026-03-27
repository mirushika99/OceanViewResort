<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter, java.util.Locale" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"guest".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Guest name from session
    String guestEmail = (String) session.getAttribute("user");
    String guestName  = (String) session.getAttribute("guest_name"); // set this in LoginServlet
    System.out.println(guestName);
    if (guestName == null || guestName.isEmpty()) {
        // fallback: use part before @ in email
        guestName = (guestEmail != null && guestEmail.contains("@"))
                    ? guestEmail.substring(0, guestEmail.indexOf('@')) : "Guest";
        // Capitalize first letter
        guestName = Character.toUpperCase(guestName.charAt(0)) + guestName.substring(1);
    }

    // Server-side time
    LocalDateTime now       = LocalDateTime.now();
    String dateFormatted    = now.format(DateTimeFormatter.ofPattern("EEEE, d MMMM yyyy", Locale.ENGLISH));
    String timeFormatted    = now.format(DateTimeFormatter.ofPattern("hh:mm a", Locale.ENGLISH));
    int hour                = now.getHour();
    String greeting         = hour < 12 ? "Good Morning" : hour < 17 ? "Good Afternoon" : "Good Evening";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Dashboard — Ocean View Resort</title>
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
        }

        body {
            font-family: 'Jost', sans-serif;
            background: var(--sand);
            color: var(--text-dark);
            min-height: 100vh;
        }

        /* ── TOP NAV ── */
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
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }

        .nav-brand-icon {
            width: 36px;
            height: 36px;
        }

        .nav-brand-text {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.25rem;
            font-weight: 400;
            color: var(--white);
            letter-spacing: 0.05em;
        }
        .nav-brand-text span { color: var(--gold); font-style: italic; }

        .nav-right {
            display: flex;
            align-items: center;
            gap: 24px;
        }

        .nav-time {
            text-align: right;
        }
        .nav-time .time-val {
            font-size: 1rem;
            font-weight: 500;
            color: var(--white);
            letter-spacing: 0.05em;
            font-variant-numeric: tabular-nums;
        }
        .nav-time .date-val {
            font-size: 0.7rem;
            color: rgba(255,255,255,0.45);
            letter-spacing: 0.1em;
        }

        .nav-divider {
            width: 1px;
            height: 28px;
            background: rgba(255,255,255,0.15);
        }

        .nav-avatar {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--gold) 0%, var(--ocean-light) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--white);
            flex-shrink: 0;
        }

        .nav-guest-info {
            text-align: right;
        }
        .nav-guest-name {
            font-size: 0.82rem;
            font-weight: 500;
            color: var(--white);
        }
        .nav-guest-role {
            font-size: 0.68rem;
            color: var(--gold-light);
            text-transform: uppercase;
            letter-spacing: 0.15em;
        }

        .btn-logout {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 7px 16px;
            border: 1px solid rgba(201,168,76,0.4);
            border-radius: 4px;
            color: var(--gold-light);
            font-family: 'Jost', sans-serif;
            font-size: 0.75rem;
            font-weight: 500;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            text-decoration: none;
            transition: background 0.2s, border-color 0.2s;
        }
        .btn-logout:hover {
            background: rgba(201,168,76,0.1);
            border-color: var(--gold);
        }

        /* ── MAIN ── */
        .main {
            max-width: 1100px;
            margin: 0 auto;
            padding: 48px 32px 64px;
        }

        /* ── HERO GREETING ── */
        .hero {
            background: linear-gradient(135deg, var(--ocean) 0%, var(--ocean-mid) 60%, #3a7a95 100%);
            border-radius: 16px;
            padding: 48px 52px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 40px;
            position: relative;
            overflow: hidden;
            animation: fadeUp 0.6s ease both;
        }

        .hero::before {
            content: '';
            position: absolute;
            width: 400px; height: 400px;
            border-radius: 50%;
            border: 1px solid rgba(201,168,76,0.2);
            top: -150px; right: -100px;
            pointer-events: none;
        }
        .hero::after {
            content: '';
            position: absolute;
            width: 220px; height: 220px;
            border-radius: 50%;
            border: 1px solid rgba(201,168,76,0.12);
            bottom: -80px; right: 120px;
            pointer-events: none;
        }

        .hero-wave {
            position: absolute;
            bottom: 0; left: 0;
            width: 100%;
            opacity: 0.05;
            pointer-events: none;
        }

        .hero-left { position: relative; z-index: 2; }

        .hero-greeting {
            font-size: 0.72rem;
            letter-spacing: 0.28em;
            text-transform: uppercase;
            color: var(--gold-light);
            font-weight: 500;
            margin-bottom: 10px;
        }

        .hero-name {
            font-family: 'Cormorant Garamond', serif;
            font-size: clamp(2rem, 4vw, 3rem);
            font-weight: 300;
            color: var(--white);
            line-height: 1.15;
        }
        .hero-name em { font-style: italic; color: var(--gold-light); }

        .hero-sub {
            margin-top: 10px;
            font-size: 0.85rem;
            color: rgba(255,255,255,0.5);
            font-weight: 300;
        }

        .hero-right {
            position: relative;
            z-index: 2;
            text-align: right;
        }

        .live-clock {
            font-family: 'Cormorant Garamond', serif;
            font-size: 3rem;
            font-weight: 300;
            color: var(--white);
            letter-spacing: 0.05em;
            line-height: 1;
            font-variant-numeric: tabular-nums;
        }

        .live-date {
            margin-top: 6px;
            font-size: 0.78rem;
            color: rgba(255,255,255,0.45);
            letter-spacing: 0.12em;
        }

        /* ── SECTION TITLE ── */
        .section-label {
            font-size: 0.68rem;
            letter-spacing: 0.25em;
            text-transform: uppercase;
            color: var(--text-light);
            font-weight: 500;
            margin-bottom: 18px;
        }

        /* ── ACTION CARDS ── */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
            animation: fadeUp 0.6s 0.15s ease both;
        }

        .action-card {
            background: var(--white);
            border-radius: 12px;
            padding: 28px 28px 24px;
            text-decoration: none;
            display: block;
            border: 1.5px solid transparent;
            box-shadow: 0 2px 12px rgba(26,58,74,0.07);
            transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
            position: relative;
            overflow: hidden;
        }

        .action-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 32px rgba(26,58,74,0.14);
            border-color: var(--ocean-light);
        }

        .action-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: var(--card-accent, var(--ocean-mid));
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.3s;
        }
        .action-card:hover::before { transform: scaleX(1); }

        .card-icon {
            width: 48px; height: 48px;
            border-radius: 12px;
            background: var(--card-icon-bg, var(--ocean-pale));
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 18px;
        }
        .card-icon svg { width: 22px; height: 22px; }

        .card-title {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 6px;
        }

        .card-desc {
            font-size: 0.8rem;
            color: var(--text-mid);
            line-height: 1.6;
            font-weight: 300;
        }

        .card-arrow {
            position: absolute;
            bottom: 22px; right: 22px;
            width: 28px; height: 28px;
            border-radius: 50%;
            background: var(--sand);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s;
        }
        .action-card:hover .card-arrow { background: var(--ocean-pale); }

        /* Card color variants */
        .card-reserve  { --card-accent: var(--ocean-mid);  --card-icon-bg: var(--ocean-pale); }
        .card-history  { --card-accent: var(--gold);       --card-icon-bg: var(--gold-pale); }
        .card-help     { --card-accent: var(--success);    --card-icon-bg: var(--success-pale); }

        /* ── INFO STRIP ── */
        .info-strip {
            background: var(--white);
            border-radius: 12px;
            padding: 24px 32px;
            display: flex;
            align-items: center;
            gap: 32px;
            box-shadow: 0 2px 12px rgba(26,58,74,0.06);
            animation: fadeUp 0.6s 0.25s ease both;
        }

        .info-item {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .info-icon {
            width: 40px; height: 40px;
            border-radius: 10px;
            background: var(--ocean-pale);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .info-icon svg { width: 18px; height: 18px; color: var(--ocean-mid); }

        .info-label {
            font-size: 0.68rem;
            text-transform: uppercase;
            letter-spacing: 0.15em;
            color: var(--text-light);
            font-weight: 500;
        }
        .info-value {
            font-size: 0.9rem;
            font-weight: 500;
            color: var(--text-dark);
            margin-top: 2px;
        }

        .info-sep { flex: 1; }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(18px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── RESPONSIVE ── */
        @media (max-width: 680px) {
            .topnav { padding: 0 20px; }
            .main   { padding: 28px 16px 48px; }
            .hero   { flex-direction: column; gap: 28px; padding: 32px 28px; }
            .hero-right { text-align: left; }
            .info-strip { flex-direction: column; align-items: flex-start; gap: 20px; }
            .nav-time, .nav-guest-info { display: none; }
        }
    </style>
</head>
<body>

    <!-- ═══ TOP NAV ═══ -->
    <nav class="topnav">
        <a class="nav-brand" href="#">
            <svg class="nav-brand-icon" viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="18" cy="18" r="17" stroke="#c9a84c" stroke-width="1"/>
                <path d="M5 22 Q9 16 13 20 Q17 24 21 17 Q25 10 31 14" stroke="#c9a84c" stroke-width="1.2" fill="none" stroke-linecap="round"/>
                <path d="M4 26 Q10 20 16 24 Q22 28 30 21" stroke="rgba(201,168,76,0.35)" stroke-width="0.8" fill="none" stroke-linecap="round"/>
            </svg>
            <div class="nav-brand-text">Ocean View <span>Resort</span></div>
        </a>

        <div class="nav-right">
            <div class="nav-time">
                <div class="time-val" id="navClock"><%= timeFormatted %></div>
                <div class="date-val"><%= dateFormatted %></div>
            </div>

            <div class="nav-divider"></div>

            <div class="nav-guest-info">
                <div class="nav-guest-name"><%= guestName %></div>
                <div class="nav-guest-role">Guest</div>
            </div>

            <div class="nav-avatar"><%= guestName.charAt(0) %></div>

            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                Logout
            </a>
        </div>
    </nav>

    <!-- ═══ MAIN ═══ -->
    <main class="main">

        <!-- HERO GREETING -->
        <div class="hero">
            <div class="hero-left">
                <div class="hero-greeting"><%= greeting %></div>
                <h1 class="hero-name"><em><%= guestName %></em>,<br>welcome back.</h1>
                <p class="hero-sub">What would you like to do today?</p>
            </div>

            <div class="hero-right">
                <div class="live-clock" id="heroClock"><%= timeFormatted %></div>
                <div class="live-date"><%= dateFormatted %></div>
            </div>

            <!-- decorative wave -->
            <svg class="hero-wave" viewBox="0 0 900 180" xmlns="http://www.w3.org/2000/svg">
                <path d="M0,60 C100,10 200,120 300,60 C400,0 500,120 600,60 C700,0 800,100 900,60 L900,180 L0,180 Z" fill="white"/>
            </svg>
        </div>

        <!-- ACTION CARDS -->
        <div class="section-label">Quick Actions</div>
        <div class="cards-grid">

            <a class="action-card card-reserve" href="${pageContext.request.contextPath}/rooms">
                <div class="card-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="#2e5f74" stroke-width="1.8">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                        <line x1="16" y1="2" x2="16" y2="6"/>
                        <line x1="8"  y1="2" x2="8"  y2="6"/>
                        <line x1="3"  y1="10" x2="21" y2="10"/>
                        <line x1="12" y1="14" x2="12" y2="18"/>
                        <line x1="10" y1="16" x2="14" y2="16"/>
                    </svg>
                </div>
                <div class="card-title">Make a Reservation</div>
                <div class="card-desc">Book a room for your upcoming stay. Choose dates, room type, and confirm instantly.</div>
                <div class="card-arrow">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#2e5f74" stroke-width="2.5"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </a>
                


            <a class="action-card card-history" href="${pageContext.request.contextPath}/history">
                <div class="card-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="#c9a84c" stroke-width="1.8">
                        <polyline points="12 8 12 12 14 14"/>
                        <path d="M3.05 11a9 9 0 1 0 .5-4H1"/>
                        <polyline points="1 3 1 7 5 7"/>
                    </svg>
                </div>
                <div class="card-title">My Reservations</div>
                <div class="card-desc">View your booking history, check-in details, and total bills for past and upcoming stays.</div>
                <div class="card-arrow">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#c9a84c" stroke-width="2.5"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </a>

            <a class="action-card card-help" href="${pageContext.request.contextPath}/help">
                <div class="card-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="#2d7d5a" stroke-width="1.8">
                        <circle cx="12" cy="12" r="10"/>
                        <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>
                        <line x1="12" y1="17" x2="12.01" y2="17"/>
                    </svg>
                </div>
                <div class="card-title">Help & Guide</div>
                <div class="card-desc">New here? Learn how to use the reservation system and get answers to common questions.</div>
                <div class="card-arrow">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#2d7d5a" stroke-width="2.5"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </a>

        </div>

        <!-- INFO STRIP -->
        <div class="info-strip">
            <div class="info-item">
                <div class="info-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                </div>
                <div>
                    <div class="info-label">Logged in as</div>
                    <div class="info-value"><%= guestEmail %></div>
                </div>
            </div>

            <div class="info-item">
                <div class="info-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                </div>
                <div>
                    <div class="info-label">Property</div>
                    <div class="info-value">Ocean View Resort, Galle</div>
                </div>
            </div>

            <div class="info-sep"></div>

            <div class="info-item">
                <div class="info-icon" style="background:var(--success-pale);">
                    <svg viewBox="0 0 24 24" fill="none" stroke="#2d7d5a" stroke-width="1.8"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.4 2 2 0 0 1 3.59 1.22h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.77a16 16 0 0 0 6.29 6.29l1.14-1.14a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                </div>
                <div>
                    <div class="info-label">Need Help?</div>
                    <div class="info-value">+94 77 003 0380</div>
                </div>
            </div>
        </div>

    </main>

    <script>
        // Live ticking clock
        function updateClock() {
            const now  = new Date();
            let h      = now.getHours();
            let m      = now.getMinutes().toString().padStart(2, '0');
            let s      = now.getSeconds().toString().padStart(2, '0');
            const ampm = h >= 12 ? 'PM' : 'AM';
            h = h % 12 || 12;
            const str = h + ':' + m + ':' + s + ' ' + ampm;

            const nav  = document.getElementById('navClock');
            const hero = document.getElementById('heroClock');
            if (nav)  nav.textContent  = str;
            if (hero) hero.textContent = str;
        }
        setInterval(updateClock, 1000);
        updateClock();
    </script>

</body>
</html>
