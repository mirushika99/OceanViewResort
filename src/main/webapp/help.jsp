<%--
    Document   : help
    Project    : Ocean View Resort - Room Reservation System
--%>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page session="true" %>
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
    boolean isAdmin = "admin".equals(role);
    String backUrl  = isAdmin ? "/admin.jsp" : "/guest-dashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help & Guide — Ocean View Resort</title>
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

        /* ── NAV ── */
        .topnav {
            background: var(--ocean);
            padding: 0 48px; height: 64px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
            box-shadow: 0 2px 16px rgba(0,0,0,0.2);
        }
        .nav-brand { display: flex; align-items: center; gap: 12px; text-decoration: none; }
        .nav-brand-text { font-family: 'Cormorant Garamond', serif; font-size: 1.25rem; font-weight: 400; color: var(--white); letter-spacing: .05em; }
        .nav-brand-text span { color: var(--gold); font-style: italic; }
        .nav-right { display: flex; align-items: center; gap: 16px; }
        .nav-back { display: flex; align-items: center; gap: 6px; padding: 7px 16px; border: 1px solid rgba(255,255,255,.15); border-radius: 4px; color: rgba(255,255,255,.7); font-size: .78rem; font-weight: 500; letter-spacing: .1em; text-transform: uppercase; text-decoration: none; transition: border-color .2s, color .2s; }
        .nav-back:hover { border-color: rgba(255,255,255,.4); color: var(--white); }
        .nav-avatar { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, var(--gold), var(--ocean-light)); display: flex; align-items: center; justify-content: center; font-family: 'Cormorant Garamond', serif; font-size: 1rem; color: var(--white); }

        /* ── PAGE HEADER ── */
        .page-header {
            background: linear-gradient(135deg, var(--ocean) 0%, var(--ocean-mid) 100%);
            padding: 48px 48px 56px; position: relative; overflow: hidden;
        }
        .page-header::before {
            content: ''; position: absolute;
            width: 400px; height: 400px; border-radius: 50%;
            border: 1px solid rgba(201,168,76,.15);
            top: -160px; right: -80px;
        }
        .page-header::after {
            content: ''; position: absolute;
            width: 200px; height: 200px; border-radius: 50%;
            border: 1px solid rgba(201,168,76,.08);
            bottom: -60px; left: 200px;
        }
        .header-inner { position: relative; z-index: 2; max-width: 900px; margin: 0 auto; text-align: center; }
        .page-eyebrow { font-size: .68rem; letter-spacing: .28em; text-transform: uppercase; color: var(--gold-light); font-weight: 500; margin-bottom: 12px; }
        .page-title { font-family: 'Cormorant Garamond', serif; font-size: 2.8rem; font-weight: 300; color: var(--white); line-height: 1.15; }
        .page-title em { font-style: italic; color: var(--gold-light); }
        .page-sub { margin-top: 12px; font-size: .9rem; color: rgba(255,255,255,.5); font-weight: 300; max-width: 520px; margin-left: auto; margin-right: auto; line-height: 1.7; }

        /* Search bar in header */
        .search-wrap {
            margin-top: 28px;
            max-width: 460px; margin-left: auto; margin-right: auto;
            position: relative;
        }
        .search-wrap svg { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); width: 16px; height: 16px; color: var(--text-light); pointer-events: none; }
        .search-input {
            width: 100%; padding: 14px 16px 14px 44px;
            border: none; border-radius: 10px;
            background: rgba(255,255,255,.12);
            backdrop-filter: blur(4px);
            color: var(--white);
            font-family: 'Jost', sans-serif; font-size: .9rem;
            outline: none;
            transition: background .2s;
        }
        .search-input::placeholder { color: rgba(255,255,255,.4); }
        .search-input:focus { background: rgba(255,255,255,.18); }

        /* ── MAIN ── */
        .main {
            max-width: 960px;
            margin: 0 auto;
            padding: 48px 32px 80px;
        }

        /* ── QUICK LINKS ── */
        .quick-links {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 48px;
            animation: fadeUp .5s ease both;
        }
        .ql-card {
            background: var(--white);
            border-radius: 12px;
            padding: 20px 18px;
            text-decoration: none;
            display: flex; flex-direction: column; align-items: center;
            gap: 10px; text-align: center;
            border: 1.5px solid transparent;
            box-shadow: 0 2px 10px rgba(26,58,74,.07);
            transition: transform .2s, border-color .2s, box-shadow .2s;
        }
        .ql-card:hover { transform: translateY(-3px); border-color: var(--ocean-light); box-shadow: 0 8px 24px rgba(26,58,74,.12); }
        .ql-icon { width: 44px; height: 44px; border-radius: 12px; background: var(--ocean-pale); display: flex; align-items: center; justify-content: center; }
        .ql-icon svg { width: 20px; height: 20px; }
        .ql-label { font-size: .78rem; font-weight: 600; color: var(--text-dark); }

        /* ── ACCORDION ── */
        .section-title-bar {
            display: flex; align-items: center; gap: 14px;
            margin-bottom: 18px; margin-top: 40px;
        }
        .section-title-bar:first-of-type { margin-top: 0; }
        .section-icon { width: 36px; height: 36px; border-radius: 10px; background: var(--ocean); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .section-icon svg { width: 16px; height: 16px; color: var(--gold-light); }
        .section-heading { font-family: 'Cormorant Garamond', serif; font-size: 1.4rem; font-weight: 400; color: var(--text-dark); }

        .accordion { display: flex; flex-direction: column; gap: 8px; margin-bottom: 12px; animation: fadeUp .5s ease both; }

        .acc-item {
            background: var(--white);
            border-radius: 10px;
            border: 1.5px solid var(--sand-dark);
            overflow: hidden;
            transition: border-color .2s, box-shadow .2s;
        }
        .acc-item.open { border-color: var(--ocean-light); box-shadow: 0 4px 16px rgba(26,58,74,.08); }
        .acc-item.hidden { display: none; }

        .acc-trigger {
            width: 100%; display: flex; align-items: center; justify-content: space-between;
            padding: 16px 20px; cursor: pointer;
            background: none; border: none; text-align: left;
            font-family: 'Jost', sans-serif;
        }
        .acc-trigger-left { display: flex; align-items: center; gap: 12px; }
        .acc-num { width: 24px; height: 24px; border-radius: 50%; background: var(--ocean-pale); display: flex; align-items: center; justify-content: center; font-size: .68rem; font-weight: 700; color: var(--ocean-mid); flex-shrink: 0; }
        .acc-item.open .acc-num { background: var(--ocean); color: var(--white); }
        .acc-q { font-size: .9rem; font-weight: 500; color: var(--text-dark); }
        .acc-chevron { width: 18px; height: 18px; color: var(--text-light); transition: transform .25s; flex-shrink: 0; }
        .acc-item.open .acc-chevron { transform: rotate(180deg); color: var(--ocean-mid); }

        .acc-body {
            max-height: 0; overflow: hidden;
            transition: max-height .3s ease, padding .2s;
            padding: 0 20px;
        }
        .acc-item.open .acc-body { max-height: 600px; padding: 0 20px 18px; }

        .acc-content { font-size: .85rem; color: var(--text-mid); line-height: 1.75; font-weight: 300; }
        .acc-content p { margin-bottom: 10px; }
        .acc-content p:last-child { margin-bottom: 0; }
        .acc-content strong { font-weight: 600; color: var(--text-dark); }

        /* Step list inside accordion */
        .step-list { margin-top: 10px; display: flex; flex-direction: column; gap: 8px; }
        .step-item { display: flex; gap: 12px; align-items: flex-start; }
        .step-num { width: 22px; height: 22px; border-radius: 50%; background: var(--ocean); color: var(--white); font-size: .68rem; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 1px; }
        .step-text { font-size: .83rem; color: var(--text-mid); line-height: 1.6; }

        /* Info box inside accordion */
        .info-box {
            margin-top: 12px; padding: 12px 14px;
            border-radius: 8px; font-size: .8rem; line-height: 1.6;
            display: flex; gap: 10px; align-items: flex-start;
        }
        .info-box.tip { background: var(--gold-pale); color: #7a5c1e; border-left: 3px solid var(--gold); }
        .info-box.note { background: var(--ocean-pale); color: var(--ocean-mid); border-left: 3px solid var(--ocean-light); }
        .info-box svg { width: 14px; height: 14px; flex-shrink: 0; margin-top: 2px; }

        /* Room type table */
        .room-table { width: 100%; border-collapse: collapse; margin-top: 12px; font-size: .82rem; }
        .room-table th { background: var(--ocean); color: rgba(255,255,255,.7); font-size: .65rem; font-weight: 600; letter-spacing: .15em; text-transform: uppercase; padding: 9px 14px; text-align: left; }
        .room-table td { padding: 10px 14px; border-bottom: 1px solid var(--sand); color: var(--text-mid); }
        .room-table tr:last-child td { border-bottom: none; }
        .room-table tr:hover td { background: #faf7f3; }
        .rate-badge { font-family: 'Cormorant Garamond', serif; font-size: 1rem; font-weight: 600; color: var(--ocean); }

        /* Contact card */
        .contact-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-top: 12px; }
        .contact-card { background: var(--sand); border-radius: 10px; padding: 16px 18px; display: flex; gap: 12px; align-items: flex-start; }
        .contact-icon { width: 36px; height: 36px; border-radius: 9px; background: var(--ocean); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .contact-icon svg { width: 16px; height: 16px; color: var(--gold-light); }
        .contact-label { font-size: .68rem; text-transform: uppercase; letter-spacing: .12em; color: var(--text-light); font-weight: 500; margin-bottom: 3px; }
        .contact-value { font-size: .88rem; font-weight: 500; color: var(--text-dark); }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: translateY(0); } }

        /* ── RESPONSIVE ── */
        @media (max-width: 700px) {
            .topnav { padding: 0 20px; }
            .page-header { padding: 36px 20px 44px; }
            .main { padding: 32px 16px 60px; }
            .quick-links { grid-template-columns: repeat(2, 1fr); }
            .contact-grid { grid-template-columns: 1fr; }
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

    <!-- ═══ PAGE HEADER ═══ -->
    <div class="page-header">
        <div class="header-inner">
            <div class="page-eyebrow">Help Centre</div>
            <h1 class="page-title">How can we <em>help</em> you?</h1>
            <p class="page-sub">Find answers about making reservations, billing, room types, and how to use the system.</p>
            <div class="search-wrap">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" class="search-input" id="helpSearch"
                       placeholder="Search for help… e.g. 'cancel reservation'"
                       oninput="filterHelp(this.value)">
            </div>
        </div>
    </div>

    <!-- ═══ MAIN ═══ -->
    <main class="main">

        <!-- Quick Links -->
        <div class="quick-links">
            <a class="ql-card" href="#getting-started">
                <div class="ql-icon"><svg viewBox="0 0 24 24" fill="none" stroke="var(--ocean-mid)" stroke-width="1.8"><circle cx="12" cy="12" r="10"/><polyline points="12 8 12 12 14 14"/></svg></div>
                <div class="ql-label">Getting Started</div>
            </a>
            <a class="ql-card" href="#reservations">
                <div class="ql-icon"><svg viewBox="0 0 24 24" fill="none" stroke="var(--ocean-mid)" stroke-width="1.8"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
                <div class="ql-label">Reservations</div>
            </a>
            <a class="ql-card" href="#billing">
                <div class="ql-icon"><svg viewBox="0 0 24 24" fill="none" stroke="var(--ocean-mid)" stroke-width="1.8"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg></div>
                <div class="ql-label">Billing</div>
            </a>
            <a class="ql-card" href="#rooms">
                <div class="ql-icon"><svg viewBox="0 0 24 24" fill="none" stroke="var(--ocean-mid)" stroke-width="1.8"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
                <div class="ql-label">Room Types</div>
            </a>
        </div>

        <!-- ══ SECTION 1: Getting Started ══ -->
        <div id="getting-started">
            <div class="section-title-bar">
                <div class="section-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="10"/><polyline points="12 8 12 12 14 14"/></svg></div>
                <h2 class="section-heading">Getting Started</h2>
            </div>
            <div class="accordion">

                <div class="acc-item" data-keywords="register create account new guest sign up">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">1</div>
                            <span class="acc-q">How do I create an account?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p>Click <strong>"Create an account"</strong> on the login page. You will need to provide your personal details to register as a guest.</p>
                            <div class="step-list">
                                <div class="step-item"><div class="step-num">1</div><div class="step-text">Go to the login page and click <strong>Create an account</strong></div></div>
                                <div class="step-item"><div class="step-num">2</div><div class="step-text">Fill in your First Name, Last Name, NIC, Contact Number, District and Address</div></div>
                                <div class="step-item"><div class="step-num">3</div><div class="step-text">Enter your email address — this will be your login username</div></div>
                                <div class="step-item"><div class="step-num">4</div><div class="step-text">Create a strong password (min. 8 characters, uppercase, lowercase, and a number)</div></div>
                                <div class="step-item"><div class="step-num">5</div><div class="step-text">Click <strong>Create Account</strong> — you will be redirected to the login page</div></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="acc-item" data-keywords="login sign in password email access">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">2</div>
                            <span class="acc-q">How do I log in to the system?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p>Go to the main page at <strong>localhost:8081/OceanViewResort</strong> and enter your registered email and password. Click <strong>Sign In</strong>.</p>
                            <div class="info-box note">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                If you enter wrong credentials 3 times, contact the front desk to reset your password.
                            </div>
                        </div>
                    </div>
                </div>

                <div class="acc-item" data-keywords="logout sign out session end">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">3</div>
                            <span class="acc-q">How do I log out?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p>Click the <strong>Logout</strong> button in the top-right corner of any page. Your session will be ended immediately and you will be returned to the login screen.</p>
                            <div class="info-box tip">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                Always log out when using a shared or public computer.
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- ══ SECTION 2: Reservations ══ -->
        <div id="reservations">
            <div class="section-title-bar">
                <div class="section-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
                <h2 class="section-heading">Reservations</h2>
            </div>
            <div class="accordion">

                <div class="acc-item" data-keywords="book reservation make room dates">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">1</div>
                            <span class="acc-q">How do I make a reservation?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <div class="step-list">
                                <div class="step-item"><div class="step-num">1</div><div class="step-text">Log in and click <strong>Make a Reservation</strong> from your dashboard</div></div>
                                <div class="step-item"><div class="step-num">2</div><div class="step-text">Select your <strong>Check-in Date</strong> — must be today or a future date</div></div>
                                <div class="step-item"><div class="step-num">3</div><div class="step-text">Select your <strong>Check-out Date</strong> — must be at least 1 day after check-in</div></div>
                                <div class="step-item"><div class="step-num">4</div><div class="step-text">Choose a <strong>Room Type</strong> from the dropdown. Availability and description will appear automatically</div></div>
                                <div class="step-item"><div class="step-num">5</div><div class="step-text">Review the <strong>Booking Summary</strong> on the right showing your total cost</div></div>
                                <div class="step-item"><div class="step-num">6</div><div class="step-text">Click <strong>Confirm Reservation</strong> to complete the booking</div></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="acc-item" data-keywords="view reservation history my bookings past">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">2</div>
                            <span class="acc-q">How do I view my reservations?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p>From your dashboard, click <strong>My Reservations</strong>. You will see all your past and upcoming bookings in a table with the room details, dates, nights stayed, and total amount.</p>
                            <p>You can <strong>search</strong> by room type and <strong>filter</strong> by status (Upcoming, Active, Completed). Click <strong>View Bill</strong> on any row to see the full invoice.</p>
                        </div>
                    </div>
                </div>

                <div class="acc-item" data-keywords="no rooms available full booked unavailable">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">3</div>
                            <span class="acc-q">What if no rooms are available for my dates?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p>If a room type shows <strong>"Fully Booked"</strong> for your selected dates, try selecting different dates or choosing a different room type. You can also contact the front desk directly — they may be able to assist with waiting lists.</p>
                            <div class="info-box tip">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                Booking at least 2 weeks in advance gives you the best room availability.
                            </div>
                        </div>
                    </div>
                </div>

                <div class="acc-item" data-keywords="checkin checkout time policy">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">4</div>
                            <span class="acc-q">What are the check-in and check-out times?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p><strong>Check-in:</strong> 2:00 PM. Early check-in from 10:00 AM is available on request, subject to room availability.</p>
                            <p><strong>Check-out:</strong> 11:00 AM. Late check-out until 1:00 PM can be arranged with the front desk at no extra charge (subject to availability).</p>
                        </div>
                    </div>
                </div>

                <div class="acc-item" data-keywords="cancel cancellation reservation modify change">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">5</div>
                            <span class="acc-q">Can I cancel or modify a reservation?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p>Cancellations must be made at least <strong>48 hours before check-in</strong> to avoid a cancellation fee. To cancel or modify a booking, please contact the front desk — modifications cannot be done online at this time.</p>
                            <div class="info-box note">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                Cancellations within 48 hours of check-in may be subject to a one-night charge.
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- ══ SECTION 3: Billing ══ -->
        <div id="billing">
            <div class="section-title-bar">
                <div class="section-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg></div>
                <h2 class="section-heading">Billing & Payments</h2>
            </div>
            <div class="accordion">

                <div class="acc-item" data-keywords="bill calculated total cost how price nights">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">1</div>
                            <span class="acc-q">How is my bill calculated?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p>Your bill is calculated as: <strong>Number of Nights × Room Rate per Night</strong>. All rates are in Sri Lankan Rupees (LKR) and include breakfast for two guests.</p>
                            <p>For example: A 3-night stay in a Deluxe Ocean Room at LKR 15,000/night = <strong>LKR 45,000 total</strong>.</p>
                            <div class="info-box tip">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                You can preview the total cost in the Booking Summary panel before confirming your reservation.
                            </div>
                        </div>
                    </div>
                </div>

                <div class="acc-item" data-keywords="view bill invoice print download receipt">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">2</div>
                            <span class="acc-q">How do I view and print my bill?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <div class="step-list">
                                <div class="step-item"><div class="step-num">1</div><div class="step-text">Go to <strong>My Reservations</strong> from your dashboard</div></div>
                                <div class="step-item"><div class="step-num">2</div><div class="step-text">Find the reservation you want and click <strong>View Bill</strong></div></div>
                                <div class="step-item"><div class="step-num">3</div><div class="step-text">Your itemised invoice will open showing all charges</div></div>
                                <div class="step-item"><div class="step-num">4</div><div class="step-text">Use the <strong>Print Bill</strong> button to print or save as PDF</div></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="acc-item" data-keywords="payment method cash card online pay">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">3</div>
                            <span class="acc-q">What payment methods are accepted?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p>Payment is collected at the resort at check-in or check-out. We accept <strong>Cash (LKR)</strong>, <strong>Visa/Mastercard</strong>, and <strong>Bank Transfer</strong>. Online payment through the system is not yet available.</p>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- ══ SECTION 4: Room Types ══ -->
        <div id="rooms">
            <div class="section-title-bar">
                <div class="section-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></div>
                <h2 class="section-heading">Room Types &amp; Rates</h2>
            </div>
            <div class="accordion">

                <div class="acc-item open" data-keywords="room types rates price list deluxe suite standard">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">1</div>
                            <span class="acc-q">What room types are available and what are the rates?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body" style="max-height:600px;padding:0 20px 18px;">
                        <div class="acc-content">
                            <table class="room-table">
                                <thead>
                                    <tr>
                                        <th>Room Type</th>
                                        <th>Description</th>
                                        <th>Rate / Night</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td><strong>Standard Room</strong></td>
                                        <td>Comfortable room with garden view, queen bed, en-suite bathroom</td>
                                        <td class="rate-badge">LKR 8,500</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Deluxe Ocean Room</strong></td>
                                        <td>Spacious room with direct ocean view, king bed, private balcony</td>
                                        <td class="rate-badge">LKR 15,000</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Family Suite</strong></td>
                                        <td>Two-bedroom suite, living area, kitchenette, ocean view</td>
                                        <td class="rate-badge">LKR 22,000</td>
                                    </tr>
                                    <tr>
                                        <td><strong>Presidential Suite</strong></td>
                                        <td>Top-floor luxury suite, panoramic views, private pool, butler service</td>
                                        <td class="rate-badge">LKR 45,000</td>
                                    </tr>
                                </tbody>
                            </table>
                            <div class="info-box note" style="margin-top:14px;">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                All rates include breakfast for two guests. Actual rates in the system may differ — check the reservation page for live pricing.
                            </div>
                        </div>
                    </div>
                </div>

                <div class="acc-item" data-keywords="breakfast included amenities facilities what included">
                    <button class="acc-trigger" onclick="toggle(this)">
                        <div class="acc-trigger-left">
                            <div class="acc-num">2</div>
                            <span class="acc-q">What is included with every room?</span>
                        </div>
                        <svg class="acc-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                    </button>
                    <div class="acc-body">
                        <div class="acc-content">
                            <p>All room types include: <strong>Breakfast for two guests</strong>, complimentary Wi-Fi, air conditioning, flat-screen TV, 24-hour room service, daily housekeeping, and access to the swimming pool and beach.</p>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- ══ CONTACT ══ -->
        <div id="contact" style="margin-top:48px;">
            <div class="section-title-bar">
                <div class="section-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.4 2 2 0 0 1 3.59 1.22h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.77a16 16 0 0 0 6.29 6.29l1.14-1.14a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg></div>
                <h2 class="section-heading">Still need help?</h2>
            </div>
            <div class="contact-grid">
                <div class="contact-card">
                    <div class="contact-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.4 2 2 0 0 1 3.59 1.22h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.77a16 16 0 0 0 6.29 6.29l1.14-1.14a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg></div>
                    <div>
                        <div class="contact-label">Front Desk</div>
                        <div class="contact-value">+94 77 003 0380</div>
                    </div>
                </div>
                <div class="contact-card">
                    <div class="contact-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg></div>
                    <div>
                        <div class="contact-label">Email</div>
                        <div class="contact-value">oceanviewresortapp@gmail.com</div>
                    </div>
                </div>
                <div class="contact-card">
                    <div class="contact-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="10" r="3"/><path d="M12 2a8 8 0 0 0-8 8c0 5.25 8 13 8 13s8-7.75 8-13a8 8 0 0 0-8-8z"/></svg></div>
                    <div>
                        <div class="contact-label">Location</div>
                        <div class="contact-value">439 Matara Rd, Galle, Sri Lanka</div>
                    </div>
                </div>
                <div class="contact-card">
                    <div class="contact-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
                    <div>
                        <div class="contact-label">Front Desk Hours</div>
                        <div class="contact-value">24 hours, 7 days a week</div>
                    </div>
                </div>
            </div>
        </div>

    </main>

    <script>
        // ── Accordion toggle ──────────────────────────────────────────────────
        function toggle(btn) {
            const item = btn.closest('.acc-item');
            item.classList.toggle('open');
        }

        // ── Search / filter ───────────────────────────────────────────────────
        function filterHelp(query) {
            const q = query.toLowerCase().trim();
            document.querySelectorAll('.acc-item').forEach(item => {
                const keywords = (item.dataset.keywords || '').toLowerCase();
                const text     = item.textContent.toLowerCase();
                const match    = !q || keywords.includes(q) || text.includes(q);
                item.classList.toggle('hidden', !match);
            });

            // Hide section headings if all their items are hidden
            document.querySelectorAll('.accordion').forEach(acc => {
                const visible = acc.querySelectorAll('.acc-item:not(.hidden)').length;
                const bar = acc.previousElementSibling;
                if (bar) bar.style.display = visible === 0 ? 'none' : '';
            });
        }

        // ── Smooth scroll for quick links ─────────────────────────────────────
        document.querySelectorAll('a[href^="#"]').forEach(a => {
            a.addEventListener('click', e => {
                e.preventDefault();
                const target = document.querySelector(a.getAttribute('href'));
                if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        });
    </script>

</body>
</html>
