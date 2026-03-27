<%--
    Document   : home
    Project    : Ocean View Resort - Public Landing Page
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
    // If already logged in, redirect to dashboard
    String role = (String) session.getAttribute("role");
    if (role != null) {
        if ("admin".equals(role)) response.sendRedirect(request.getContextPath() + "/admin.jsp");
        else                      response.sendRedirect(request.getContextPath() + "/guest-dashboard");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ocean View Resort — Galle, Sri Lanka</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400;1,600&family=Jost:wght@300;400;500;600&display=swap" rel="stylesheet">
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
        }

        html { scroll-behavior: smooth; }
        body { font-family: 'Jost', sans-serif; background: var(--white); color: var(--text-dark); overflow-x: hidden; }

        /* ── NAV ── */
        .nav {
            position: fixed; top: 0; left: 0; right: 0; z-index: 200;
            padding: 0 56px; height: 72px;
            display: flex; align-items: center; justify-content: space-between;
            transition: background .4s, box-shadow .4s;
        }
        .nav.scrolled {
            background: rgba(26,58,74,.97);
            backdrop-filter: blur(12px);
            box-shadow: 0 2px 24px rgba(0,0,0,.25);
        }
        .nav-brand { display: flex; align-items: center; gap: 14px; text-decoration: none; }
        .nav-brand svg { flex-shrink: 0; }
        .nav-brand-text { font-family: 'Cormorant Garamond', serif; font-size: 1.3rem; font-weight: 400; color: var(--white); letter-spacing: .06em; }
        .nav-brand-text span { color: var(--gold); font-style: italic; }
        .nav-links { display: flex; align-items: center; gap: 36px; }
        .nav-link { color: rgba(255,255,255,.7); font-size: .78rem; font-weight: 500; letter-spacing: .14em; text-transform: uppercase; text-decoration: none; transition: color .2s; }
        .nav-link:hover { color: var(--gold-light); }
        .nav-actions { display: flex; align-items: center; gap: 14px; }
        .btn-signin {
            padding: 9px 22px; border-radius: 4px;
            border: 1px solid rgba(255,255,255,.25);
            color: rgba(255,255,255,.8); font-family: 'Jost', sans-serif;
            font-size: .75rem; font-weight: 600; letter-spacing: .16em; text-transform: uppercase;
            text-decoration: none; transition: border-color .2s, color .2s, background .2s;
        }
        .btn-signin:hover { border-color: var(--gold); color: var(--gold); }
        .btn-book-nav {
            padding: 10px 24px; border-radius: 4px;
            background: var(--gold); color: var(--ocean);
            font-family: 'Jost', sans-serif; font-size: .75rem; font-weight: 700;
            letter-spacing: .16em; text-transform: uppercase; text-decoration: none;
            transition: background .2s, transform .15s;
        }
        .btn-book-nav:hover { background: var(--gold-light); transform: translateY(-1px); }

        /* ── HERO ── */
        .hero {
            position: relative; height: 100vh; min-height: 640px;
            display: flex; align-items: center; justify-content: center;
            overflow: hidden;
            background: var(--ocean);
        }

        /* SVG ocean illustration background */
        .hero-bg {
            position: absolute; inset: 0;
            width: 100%; height: 100%;
        }

        .hero-overlay {
            position: absolute; inset: 0;
            background: linear-gradient(to bottom, rgba(26,58,74,.55) 0%, rgba(26,58,74,.2) 50%, rgba(26,58,74,.75) 100%);
        }

        .hero-content {
            position: relative; z-index: 2;
            text-align: center; padding: 0 24px;
            animation: heroIn 1.2s ease both;
        }
        .hero-eyebrow {
            font-size: .68rem; letter-spacing: .38em; text-transform: uppercase;
            color: var(--gold); font-weight: 500; margin-bottom: 20px;
            animation: heroIn 1s .2s ease both;
        }
        .hero-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: clamp(3rem, 8vw, 6rem);
            font-weight: 300; color: var(--white); line-height: 1.05;
            letter-spacing: .02em;
            animation: heroIn 1s .3s ease both;
        }
        .hero-title em { font-style: italic; color: var(--gold-light); }
        .hero-subtitle {
            margin-top: 20px; font-size: clamp(.9rem, 2vw, 1.05rem);
            color: rgba(255,255,255,.55); font-weight: 300; letter-spacing: .04em;
            line-height: 1.7; max-width: 520px; margin-left: auto; margin-right: auto;
            animation: heroIn 1s .4s ease both;
        }
        .hero-divider {
            width: 60px; height: 1px; background: var(--gold);
            margin: 28px auto; opacity: .7;
            animation: heroIn 1s .5s ease both;
        }
        .hero-actions {
            display: flex; align-items: center; justify-content: center; gap: 16px;
            animation: heroIn 1s .6s ease both;
        }
        .btn-hero-primary {
            padding: 16px 40px; border-radius: 4px;
            background: var(--gold); color: var(--ocean);
            font-family: 'Jost', sans-serif; font-size: .82rem; font-weight: 700;
            letter-spacing: .2em; text-transform: uppercase; text-decoration: none;
            transition: background .2s, transform .15s, box-shadow .2s;
        }
        .btn-hero-primary:hover { background: var(--gold-light); transform: translateY(-2px); box-shadow: 0 12px 32px rgba(201,168,76,.35); }
        .btn-hero-secondary {
            padding: 15px 36px; border-radius: 4px;
            border: 1px solid rgba(255,255,255,.3);
            color: rgba(255,255,255,.8);
            font-family: 'Jost', sans-serif; font-size: .82rem; font-weight: 500;
            letter-spacing: .2em; text-transform: uppercase; text-decoration: none;
            transition: border-color .2s, color .2s;
        }
        .btn-hero-secondary:hover { border-color: rgba(255,255,255,.7); color: var(--white); }

        /* Scroll indicator */
        .scroll-hint {
            position: absolute; bottom: 36px; left: 50%; transform: translateX(-50%);
            display: flex; flex-direction: column; align-items: center; gap: 8px;
            color: rgba(255,255,255,.4); font-size: .65rem; letter-spacing: .2em; text-transform: uppercase;
            animation: bounce 2s 1.5s ease infinite;
            z-index: 2;
        }
        .scroll-hint svg { opacity: .5; }

        /* ── STRIP ── */
        .strip {
            background: var(--ocean);
            padding: 20px 56px;
            display: flex; align-items: center; justify-content: center;
            gap: 48px; flex-wrap: wrap;
        }
        .strip-item {
            display: flex; align-items: center; gap: 10px;
            color: rgba(255,255,255,.55); font-size: .75rem;
            font-weight: 400; letter-spacing: .1em;
        }
        .strip-item svg { color: var(--gold); flex-shrink: 0; }
        .strip-dot { width: 4px; height: 4px; border-radius: 50%; background: rgba(255,255,255,.15); }

        /* ── SECTION BASE ── */
        .section { padding: 100px 56px; }
        .section-inner { max-width: 1100px; margin: 0 auto; }
        .section-eyebrow {
            font-size: .65rem; letter-spacing: .32em; text-transform: uppercase;
            color: var(--gold); font-weight: 500; margin-bottom: 14px;
        }
        .section-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: clamp(2rem, 4vw, 3rem); font-weight: 300;
            color: var(--text-dark); line-height: 1.15;
        }
        .section-title em { font-style: italic; color: var(--ocean-mid); }
        .section-sub {
            margin-top: 14px; font-size: .9rem; color: var(--text-light);
            font-weight: 300; line-height: 1.8; max-width: 560px;
        }
        .section-divider { width: 48px; height: 2px; background: var(--gold); margin-top: 24px; opacity: .6; }

        /* ── FEATURES ── */
        .features-bg { background: var(--sand); }
        .features-grid {
            margin-top: 56px;
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 2px;
        }
        .feature-card {
            background: var(--white);
            padding: 40px 36px;
            position: relative; overflow: hidden;
            transition: transform .25s, box-shadow .25s;
        }
        .feature-card:hover { transform: translateY(-4px); box-shadow: 0 16px 48px rgba(26,58,74,.1); z-index: 2; }
        .feature-card::before {
            content: ''; position: absolute; bottom: 0; left: 0; right: 0;
            height: 3px; background: var(--gold); transform: scaleX(0);
            transform-origin: left; transition: transform .3s;
        }
        .feature-card:hover::before { transform: scaleX(1); }
        .feature-icon {
            width: 52px; height: 52px; border-radius: 12px;
            background: var(--ocean-pale);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 22px;
        }
        .feature-icon svg { color: var(--ocean-mid); }
        .feature-number {
            position: absolute; top: 32px; right: 32px;
            font-family: 'Cormorant Garamond', serif;
            font-size: 3.5rem; font-weight: 300; color: var(--sand-dark);
            line-height: 1; user-select: none;
        }
        .feature-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.35rem; font-weight: 400; color: var(--text-dark);
            margin-bottom: 10px;
        }
        .feature-desc { font-size: .83rem; color: var(--text-light); line-height: 1.75; font-weight: 300; }

        /* ── ABOUT ── */
        .about-grid {
            display: grid; grid-template-columns: 1fr 1fr; gap: 80px;
            align-items: center; margin-top: 60px;
        }
        .about-visual {
            position: relative; height: 480px;
        }
        .about-map-card {
            position: absolute; inset: 0;
            background: var(--ocean);
            border-radius: 4px; overflow: hidden;
        }
        .about-map-card svg { width: 100%; height: 100%; }
        .about-badge {
            position: absolute; bottom: -20px; right: -20px;
            width: 120px; height: 120px; border-radius: 50%;
            background: var(--gold);
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            box-shadow: 0 8px 32px rgba(201,168,76,.4);
        }
        .about-badge-num { font-family: 'Cormorant Garamond', serif; font-size: 2rem; font-weight: 600; color: var(--ocean); line-height: 1; }
        .about-badge-txt { font-size: .6rem; letter-spacing: .12em; text-transform: uppercase; color: var(--ocean); font-weight: 600; margin-top: 2px; text-align: center; }
        .about-text .section-title { font-size: 2.2rem; }
        .about-list { margin-top: 32px; display: flex; flex-direction: column; gap: 16px; }
        .about-item { display: flex; align-items: flex-start; gap: 16px; }
        .about-item-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--gold); flex-shrink: 0; margin-top: 6px; }
        .about-item-text { font-size: .88rem; color: var(--text-mid); line-height: 1.7; }
        .about-item-text strong { color: var(--text-dark); font-weight: 600; }
        .btn-about {
            display: inline-flex; align-items: center; gap: 10px;
            margin-top: 36px; padding: 14px 32px; border-radius: 4px;
            background: var(--ocean); color: var(--white);
            font-family: 'Jost', sans-serif; font-size: .8rem; font-weight: 600;
            letter-spacing: .16em; text-transform: uppercase; text-decoration: none;
            transition: background .2s, transform .15s;
        }
        .btn-about:hover { background: var(--ocean-mid); transform: translateY(-2px); }

        /* ── CONTACT ── */
        .contact-bg { background: var(--ocean); }
        .contact-bg .section-eyebrow { color: var(--gold-light); }
        .contact-bg .section-title { color: var(--white); }
        .contact-bg .section-title em { color: var(--gold-light); }
        .contact-bg .section-sub { color: rgba(255,255,255,.45); }
        .contact-grid {
            display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 2px;
            margin-top: 56px;
        }
        .contact-card {
            background: rgba(255,255,255,.05);
            border: 1px solid rgba(255,255,255,.08);
            padding: 36px 32px;
            transition: background .2s;
        }
        .contact-card:hover { background: rgba(255,255,255,.08); }
        .contact-card-icon {
            width: 44px; height: 44px; border-radius: 10px;
            background: rgba(201,168,76,.15); border: 1px solid rgba(201,168,76,.2);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 20px;
        }
        .contact-card-icon svg { color: var(--gold-light); }
        .contact-card-label { font-size: .62rem; letter-spacing: .22em; text-transform: uppercase; color: rgba(255,255,255,.35); font-weight: 600; margin-bottom: 10px; }
        .contact-card-value { font-size: .95rem; color: var(--white); font-weight: 400; line-height: 1.7; }
        .contact-card-value a { color: var(--gold-light); text-decoration: none; }
        .contact-card-value a:hover { text-decoration: underline; }

        /* ── FOOTER ── */
        .footer {
            background: #0e2330;
            padding: 40px 56px;
            display: flex; align-items: center; justify-content: space-between;
            flex-wrap: wrap; gap: 20px;
        }
        .footer-brand { font-family: 'Cormorant Garamond', serif; font-size: 1.1rem; font-weight: 300; color: rgba(255,255,255,.4); }
        .footer-brand span { color: var(--gold); font-style: italic; }
        .footer-copy { font-size: .72rem; color: rgba(255,255,255,.25); }
        .footer-links { display: flex; gap: 24px; }
        .footer-link { font-size: .72rem; color: rgba(255,255,255,.3); text-decoration: none; letter-spacing: .1em; text-transform: uppercase; transition: color .2s; }
        .footer-link:hover { color: var(--gold-light); }

        /* ── ANIMATIONS ── */
        @keyframes heroIn { from { opacity: 0; transform: translateY(28px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes bounce { 0%,100%{transform:translateX(-50%) translateY(0)} 50%{transform:translateX(-50%) translateY(8px)} }

        .reveal { opacity: 0; transform: translateY(32px); transition: opacity .7s ease, transform .7s ease; }
        .reveal.visible { opacity: 1; transform: translateY(0); }
        .reveal-delay-1 { transition-delay: .1s; }
        .reveal-delay-2 { transition-delay: .2s; }
        .reveal-delay-3 { transition-delay: .3s; }
        .reveal-delay-4 { transition-delay: .4s; }
        .reveal-delay-5 { transition-delay: .5s; }

        @media(max-width:960px){
            .nav { padding: 0 24px; }
            .nav-links { display: none; }
            .section { padding: 72px 24px; }
            .strip { padding: 18px 24px; gap: 24px; }
            .features-grid { grid-template-columns: 1fr 1fr; }
            .about-grid { grid-template-columns: 1fr; gap: 40px; }
            .about-visual { height: 300px; }
            .contact-grid { grid-template-columns: 1fr; gap: 2px; }
            .footer { padding: 32px 24px; flex-direction: column; align-items: flex-start; gap: 16px; }
        }
        @media(max-width:600px){
            .features-grid { grid-template-columns: 1fr; }
            .hero-actions { flex-direction: column; }
            .strip-dot { display: none; }
        }
    </style>
</head>
<body>

<!-- ═══ NAV ═══ -->
<nav class="nav" id="mainNav">
    <a class="nav-brand" href="#">
        <svg width="34" height="34" viewBox="0 0 36 36" fill="none">
            <circle cx="18" cy="18" r="17" stroke="#c9a84c" stroke-width="1"/>
            <path d="M5 22 Q9 16 13 20 Q17 24 21 17 Q25 10 31 14" stroke="#c9a84c" stroke-width="1.2" fill="none" stroke-linecap="round"/>
        </svg>
        <div class="nav-brand-text">Ocean View <span>Resort</span></div>
    </a>
    <div class="nav-links">
        <a class="nav-link" href="#features">Amenities</a>
        <a class="nav-link" href="#about">About</a>
        <a class="nav-link" href="#contact">Contact</a>
    </div>
    <div class="nav-actions">
        <a class="btn-signin" href="${pageContext.request.contextPath}/login.jsp">Sign In</a>
        <a class="btn-book-nav" href="${pageContext.request.contextPath}/register">Book Now</a>
    </div>
</nav>

<!-- ═══ HERO ═══ -->
<section class="hero">
    <!-- Ocean scene SVG illustration -->
    <svg class="hero-bg" viewBox="0 0 1440 900" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">
        <!-- Sky gradient -->
        <defs>
            <linearGradient id="skyGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%"   stop-color="#0d2535"/>
                <stop offset="60%"  stop-color="#1a3a4a"/>
                <stop offset="100%" stop-color="#1e4d63"/>
            </linearGradient>
            <linearGradient id="seaGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%"  stop-color="#1e4d63"/>
                <stop offset="100%" stop-color="#0d2535"/>
            </linearGradient>
            <linearGradient id="sunGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%"  stop-color="#f5c842" stop-opacity=".9"/>
                <stop offset="100%" stop-color="#e8923a" stop-opacity=".6"/>
            </linearGradient>
            <radialGradient id="glowGrad" cx="50%" cy="45%" r="35%">
                <stop offset="0%"  stop-color="#c9a84c" stop-opacity=".3"/>
                <stop offset="100%" stop-color="#c9a84c" stop-opacity="0"/>
            </radialGradient>
        </defs>
        <!-- Sky -->
        <rect width="1440" height="900" fill="url(#skyGrad)"/>
        <!-- Glow -->
        <ellipse cx="720" cy="380" rx="600" ry="300" fill="url(#glowGrad)"/>
        <!-- Stars -->
        <circle cx="120" cy="80"  r="1.2" fill="white" opacity=".6"/>
        <circle cx="280" cy="55"  r=".8"  fill="white" opacity=".5"/>
        <circle cx="450" cy="100" r="1"   fill="white" opacity=".7"/>
        <circle cx="650" cy="60"  r=".9"  fill="white" opacity=".4"/>
        <circle cx="820" cy="90"  r="1.3" fill="white" opacity=".6"/>
        <circle cx="990" cy="50"  r=".8"  fill="white" opacity=".5"/>
        <circle cx="1150" cy="110" r="1.1" fill="white" opacity=".7"/>
        <circle cx="1320" cy="75" r=".9"  fill="white" opacity=".4"/>
        <circle cx="200" cy="140" r=".7"  fill="white" opacity=".3"/>
        <circle cx="550" cy="130" r="1"   fill="white" opacity=".5"/>
        <circle cx="900" cy="140" r=".8"  fill="white" opacity=".4"/>
        <circle cx="1250" cy="130" r="1"  fill="white" opacity=".6"/>
        <!-- Sun/moon -->
        <circle cx="720" cy="360" r="60" fill="url(#sunGrad)" opacity=".7"/>
        <circle cx="720" cy="360" r="50" fill="#f5c842" opacity=".5"/>
        <!-- Sun reflection on sea -->
        <ellipse cx="720" cy="620" rx="80" ry="220" fill="#c9a84c" opacity=".08"/>
        <!-- Horizon line -->
        <line x1="0" y1="530" x2="1440" y2="530" stroke="rgba(201,168,76,.15)" stroke-width="1"/>
        <!-- Sea -->
        <rect x="0" y="530" width="1440" height="370" fill="url(#seaGrad)"/>
        <!-- Wave 1 -->
        <path d="M0 560 Q180 545 360 565 Q540 585 720 560 Q900 535 1080 565 Q1260 585 1440 560 L1440 530 L0 530Z" fill="rgba(255,255,255,.04)"/>
        <!-- Wave 2 -->
        <path d="M0 590 Q180 575 360 595 Q540 615 720 590 Q900 565 1080 590 Q1260 615 1440 590 L1440 560 L0 560Z" fill="rgba(255,255,255,.03)"/>
        <!-- Wave 3 -->
        <path d="M0 620 Q240 605 480 622 Q720 640 960 620 Q1200 600 1440 620 L1440 590 L0 590Z" fill="rgba(255,255,255,.025)"/>
        <!-- Wave ripples -->
        <path d="M100 560 Q200 555 300 562" stroke="rgba(255,255,255,.12)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
        <path d="M500 570 Q620 564 740 572" stroke="rgba(255,255,255,.1)"  stroke-width="1"   fill="none" stroke-linecap="round"/>
        <path d="M900 558 Q1020 553 1140 560" stroke="rgba(255,255,255,.12)" stroke-width="1.5" fill="none" stroke-linecap="round"/>
        <path d="M200 595 Q350 588 500 598" stroke="rgba(255,255,255,.08)"  stroke-width="1"   fill="none" stroke-linecap="round"/>
        <path d="M700 590 Q860 583 1020 592" stroke="rgba(255,255,255,.09)" stroke-width="1"   fill="none" stroke-linecap="round"/>
        <!-- Resort silhouette -->
        <!-- Main building -->
        <rect x="560" y="470" width="320" height="62" fill="#0d2535" opacity=".9"/>
        <!-- Roof line with pitched sections -->
        <polygon points="560,470 620,440 680,470" fill="#0d2535" opacity=".9"/>
        <polygon points="640,470 720,425 800,470" fill="#0d2535" opacity=".9"/>
        <polygon points="760,470 820,445 880,470" fill="#0d2535" opacity=".9"/>
        <!-- Windows lit warm -->
        <rect x="578" y="478" width="20" height="14" rx="2" fill="#c9a84c" opacity=".5"/>
        <rect x="608" y="478" width="20" height="14" rx="2" fill="#e2c47a" opacity=".4"/>
        <rect x="638" y="478" width="20" height="14" rx="2" fill="#c9a84c" opacity=".6"/>
        <rect x="678" y="478" width="20" height="14" rx="2" fill="#e2c47a" opacity=".5"/>
        <rect x="718" y="478" width="20" height="14" rx="2" fill="#c9a84c" opacity=".4"/>
        <rect x="758" y="478" width="20" height="14" rx="2" fill="#e2c47a" opacity=".6"/>
        <rect x="798" y="478" width="20" height="14" rx="2" fill="#c9a84c" opacity=".5"/>
        <rect x="838" y="478" width="20" height="14" rx="2" fill="#e2c47a" opacity=".4"/>
        <!-- Tower left -->
        <rect x="510" y="450" width="55" height="82" fill="#0d2535" opacity=".85"/>
        <polygon points="510,450 537,428 565,450" fill="#0d2535" opacity=".85"/>
        <rect x="522" y="460" width="14" height="12" rx="1" fill="#c9a84c" opacity=".5"/>
        <!-- Tower right -->
        <rect x="880" y="455" width="55" height="77" fill="#0d2535" opacity=".85"/>
        <polygon points="880,455 907,432 935,455" fill="#0d2535" opacity=".85"/>
        <rect x="892" y="462" width="14" height="12" rx="1" fill="#e2c47a" opacity=".5"/>
        <!-- Palm tree left -->
        <line x1="460" y1="532" x2="480" y2="440" stroke="#0a1e2b" stroke-width="5" stroke-linecap="round"/>
        <path d="M480 440 Q440 415 415 428" stroke="#0a1e2b" stroke-width="4" fill="none" stroke-linecap="round"/>
        <path d="M480 440 Q470 408 455 402" stroke="#0a1e2b" stroke-width="4" fill="none" stroke-linecap="round"/>
        <path d="M480 440 Q495 410 490 396" stroke="#0a1e2b" stroke-width="4" fill="none" stroke-linecap="round"/>
        <path d="M480 440 Q508 418 515 424" stroke="#0a1e2b" stroke-width="3" fill="none" stroke-linecap="round"/>
        <!-- Palm tree right -->
        <line x1="980" y1="532" x2="960" y2="448" stroke="#0a1e2b" stroke-width="5" stroke-linecap="round"/>
        <path d="M960 448 Q1000 422 1025 436" stroke="#0a1e2b" stroke-width="4" fill="none" stroke-linecap="round"/>
        <path d="M960 448 Q970 415 986 410" stroke="#0a1e2b" stroke-width="4" fill="none" stroke-linecap="round"/>
        <path d="M960 448 Q945 418 950 403" stroke="#0a1e2b" stroke-width="4" fill="none" stroke-linecap="round"/>
        <path d="M960 448 Q932 424 926 430" stroke="#0a1e2b" stroke-width="3" fill="none" stroke-linecap="round"/>
        <!-- Ground/beach -->
        <path d="M0 530 Q360 520 720 525 Q1080 530 1440 518 L1440 532 L0 532Z" fill="#1a3040" opacity=".8"/>
    </svg>

    <div class="hero-overlay"></div>

    <div class="hero-content">
        <div class="hero-eyebrow">Marine Drive · Galle · Sri Lanka</div>
        <h1 class="hero-title">Where the Sea<br><em>Meets Serenity</em></h1>
        <p class="hero-subtitle">A luxury beachfront retreat on the southern shores of Sri Lanka, where every room faces the Indian Ocean.</p>
        <div class="hero-divider"></div>
        <div class="hero-actions">
            <a href="${pageContext.request.contextPath}/register" class="btn-hero-primary">Reserve a Room</a>
            <a href="#about" class="btn-hero-secondary">Discover More</a>
        </div>
    </div>

    <div class="scroll-hint">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><polyline points="6 9 12 15 18 9"/></svg>
        Scroll
    </div>
</section>

<!-- ═══ STRIP ═══ -->
<div class="strip">
    <div class="strip-item">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/></svg>
        Marine Drive, Galle
    </div>
    <div class="strip-dot"></div>
    <div class="strip-item">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
        Check-in 2:00 PM · Check-out 11:00 AM
    </div>
    <div class="strip-dot"></div>
    <div class="strip-item">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12"/></svg>
        +94 77 003 0380
    </div>
    <div class="strip-dot"></div>
    <div class="strip-item">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
        oceanviewresortapp@gmail.com
    </div>
</div>

<!-- ═══ FEATURES ═══ -->
<section class="section features-bg" id="features">
    <div class="section-inner">
        <div class="reveal">
            <div class="section-eyebrow">Amenities & Services</div>
            <h2 class="section-title">Everything you need for a<br><em>perfect stay</em></h2>
            <p class="section-sub">Every detail at Ocean View Resort is designed to elevate your experience on the southern coast of Sri Lanka.</p>
            <div class="section-divider"></div>
        </div>

        <div class="features-grid">
            <div class="feature-card reveal reveal-delay-1">
                <div class="feature-number">01</div>
                <div class="feature-icon">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                </div>
                <div class="feature-title">Ocean View Rooms</div>
                <div class="feature-desc">Every room is oriented toward the Indian Ocean, with private balconies and panoramic sea views from floor-to-ceiling windows.</div>
            </div>
            <div class="feature-card reveal reveal-delay-2">
                <div class="feature-number">02</div>
                <div class="feature-icon">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>
                </div>
                <div class="feature-title">Beachfront Dining</div>
                <div class="feature-desc">Our open-air restaurant serves Sri Lankan and international cuisine with your feet in the sand and the sound of waves as your backdrop.</div>
            </div>
            <div class="feature-card reveal reveal-delay-3">
                <div class="feature-number">03</div>
                <div class="feature-icon">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                </div>
                <div class="feature-title">Private Pool & Spa</div>
                <div class="feature-desc">Swim in our infinity pool overlooking the ocean, or unwind with traditional Ayurvedic treatments at our dedicated wellness centre.</div>
            </div>
            <div class="feature-card reveal reveal-delay-1">
                <div class="feature-number">04</div>
                <div class="feature-icon">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                </div>
                <div class="feature-title">Free High-Speed Wi-Fi</div>
                <div class="feature-desc">Stay connected with complimentary high-speed Wi-Fi throughout the property, including all rooms, pool areas, and the beach.</div>
            </div>
            <div class="feature-card reveal reveal-delay-2">
                <div class="feature-number">05</div>
                <div class="feature-icon">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M18 8h1a4 4 0 0 1 0 8h-1"/><path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/><line x1="6" y1="1" x2="6" y2="4"/><line x1="10" y1="1" x2="10" y2="4"/><line x1="14" y1="1" x2="14" y2="4"/></svg>
                </div>
                <div class="feature-title">Breakfast Included</div>
                <div class="feature-desc">Wake up to a freshly prepared Sri Lankan breakfast for two, included with every room. Our chefs use locally sourced ingredients daily.</div>
            </div>
            <div class="feature-card reveal reveal-delay-3">
                <div class="feature-number">06</div>
                <div class="feature-icon">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                </div>
                <div class="feature-title">Online Reservations</div>
                <div class="feature-desc">Book directly through our system, check real-time room availability, manage your booking, and receive instant email confirmation.</div>
            </div>
        </div>
    </div>
</section>

<!-- ═══ ABOUT ═══ -->
<section class="section" id="about">
    <div class="section-inner">
        <div class="about-grid">
            <!-- Visual side -->
            <div class="about-visual reveal">
                <div class="about-map-card">
                    <svg viewBox="0 0 480 480" xmlns="http://www.w3.org/2000/svg">
                        <!-- Ocean background -->
                        <rect width="480" height="480" fill="#1a3a4a"/>
                        <!-- Decorative grid lines -->
                        <line x1="0" y1="120" x2="480" y2="120" stroke="rgba(255,255,255,.04)" stroke-width="1"/>
                        <line x1="0" y1="240" x2="480" y2="240" stroke="rgba(255,255,255,.04)" stroke-width="1"/>
                        <line x1="0" y1="360" x2="480" y2="360" stroke="rgba(255,255,255,.04)" stroke-width="1"/>
                        <line x1="120" y1="0" x2="120" y2="480" stroke="rgba(255,255,255,.04)" stroke-width="1"/>
                        <line x1="240" y1="0" x2="240" y2="480" stroke="rgba(255,255,255,.04)" stroke-width="1"/>
                        <line x1="360" y1="0" x2="360" y2="480" stroke="rgba(255,255,255,.04)" stroke-width="1"/>
                        <!-- Sri Lanka island shape (simplified) -->
                        <path d="M240 80 Q270 75 295 90 Q320 105 330 130 Q345 160 340 190 Q335 225 320 255 Q305 285 285 308 Q265 330 245 345 Q225 330 205 308 Q185 285 170 255 Q155 225 150 190 Q145 160 160 130 Q170 105 195 90 Q215 78 240 80Z"
                              fill="rgba(255,255,255,.08)" stroke="rgba(255,255,255,.15)" stroke-width="1.5"/>
                        <!-- Galle location dot -->
                        <circle cx="220" cy="310" r="10" fill="var(--gold)" opacity=".9"/>
                        <circle cx="220" cy="310" r="20" fill="var(--gold)" opacity=".2"/>
                        <circle cx="220" cy="310" r="32" fill="var(--gold)" opacity=".08"/>
                        <!-- Label -->
                        <text x="238" y="308" font-family="Georgia,serif" font-size="12" fill="var(--gold)" opacity=".9">Galle</text>
                        <text x="238" y="322" font-family="sans-serif" font-size="9" fill="rgba(255,255,255,.4)">Ocean View Resort</text>
                        <!-- Compass rose -->
                        <text x="400" y="55" font-family="serif" font-size="11" fill="rgba(255,255,255,.25)" text-anchor="middle">N</text>
                        <line x1="400" y1="60" x2="400" y2="75" stroke="rgba(255,255,255,.2)" stroke-width="1"/>
                        <line x1="393" y1="68" x2="407" y2="68" stroke="rgba(255,255,255,.2)" stroke-width="1"/>
                        <!-- Wave lines at bottom -->
                        <path d="M0 420 Q60 413 120 421 Q180 429 240 420 Q300 411 360 420 Q420 429 480 420" stroke="rgba(201,168,76,.15)" stroke-width="1" fill="none"/>
                        <path d="M0 440 Q60 433 120 441 Q180 449 240 440 Q300 431 360 440 Q420 449 480 440" stroke="rgba(201,168,76,.1)"  stroke-width="1" fill="none"/>
                        <path d="M0 460 Q60 453 120 461 Q180 469 240 460 Q300 451 360 460 Q420 469 480 460" stroke="rgba(201,168,76,.07)" stroke-width="1" fill="none"/>
                        <!-- Title -->
                        <text x="240" y="395" font-family="Georgia,serif" font-size="13" fill="rgba(255,255,255,.3)" text-anchor="middle" font-style="italic">Sri Lanka</text>
                    </svg>
                </div>
                <div class="about-badge">
                    <div class="about-badge-num">★</div>
                    <div class="about-badge-txt">5 Star<br>Resort</div>
                </div>
            </div>

            <!-- Text side -->
            <div class="about-text reveal reveal-delay-2">
                <div class="section-eyebrow">About the Resort</div>
                <h2 class="section-title">A sanctuary on the<br><em>southern shore</em></h2>
                <p class="section-sub">Nestled on the Marine Drive in historic Galle, Ocean View Resort offers an unmatched blend of Sri Lankan hospitality and contemporary luxury.</p>
                <div class="about-list">
                    <div class="about-item">
                        <div class="about-item-dot"></div>
                        <div class="about-item-text"><strong>Prime Location</strong> — Situated directly on the beachfront of Marine Drive, Galle, with panoramic views of the Indian Ocean and just minutes from the UNESCO World Heritage Galle Fort.</div>
                    </div>
                    <div class="about-item">
                        <div class="about-item-dot"></div>
                        <div class="about-item-text"><strong>Authentic Hospitality</strong> — Our team of local staff brings genuine warmth and deep knowledge of the region to create a truly immersive Sri Lankan experience.</div>
                    </div>
                    <div class="about-item">
                        <div class="about-item-dot"></div>
                        <div class="about-item-text"><strong>Easy Booking</strong> — Reserve directly through our online system with instant confirmation, real-time availability, and flexible cancellation up to 48 hours before check-in.</div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/register" class="btn-about">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                    Book Your Stay
                </a>
            </div>
        </div>
    </div>
</section>

<!-- ═══ CONTACT ═══ -->
<section class="section contact-bg" id="contact">
    <div class="section-inner">
        <div class="reveal">
            <div class="section-eyebrow">Get in Touch</div>
            <h2 class="section-title">We'd love to <em>hear from you</em></h2>
            <p class="section-sub">Reach us directly for enquiries, special requests, or group bookings. Our team is available every day.</p>
            <div class="section-divider"></div>
        </div>

        <div class="contact-grid">
            <div class="contact-card reveal reveal-delay-1">
                <div class="contact-card-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                </div>
                <div class="contact-card-label">Address</div>
                <div class="contact-card-value">
                    Marine Drive<br>
                    Galle, Sri Lanka<br>
                    80000
                </div>
            </div>
            <div class="contact-card reveal reveal-delay-2">
                <div class="contact-card-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.4 2 2 0 0 1 3.59 1.22h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.77a16 16 0 0 0 6.29 6.29l1.14-1.14a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                </div>
                <div class="contact-card-label">Phone</div>
                <div class="contact-card-value">
                    <a href="tel:+94770030380">+94 77 003 0380</a><br>
                    <span style="font-size:.8rem;opacity:.5">Daily 7:00 AM – 10:00 PM</span>
                </div>
            </div>
            <div class="contact-card reveal reveal-delay-3">
                <div class="contact-card-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                </div>
                <div class="contact-card-label">Email</div>
                <div class="contact-card-value">
                    <a href="mailto:oceanviewresortapp@gmail.com">oceanviewresortapp@gmail.com</a><br>
                    <span style="font-size:.8rem;opacity:.5">We reply within 24 hours</span>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ═══ FOOTER ═══ -->
<footer class="footer">
    <div class="footer-brand">Ocean View <span>Resort</span> · Galle, Sri Lanka</div>
    <div class="footer-links">
        <a class="footer-link" href="#features">Amenities</a>
        <a class="footer-link" href="#about">About</a>
        <a class="footer-link" href="#contact">Contact</a>
        <a class="footer-link" href="${pageContext.request.contextPath}/index.jsp">Sign In</a>
    </div>
    <div class="footer-copy">&copy; 2026 Ocean View Resort. All rights reserved.</div>
</footer>

<script>
    // Sticky nav
    const nav = document.getElementById('mainNav');
    window.addEventListener('scroll', function() {
        nav.classList.toggle('scrolled', window.scrollY > 60);
    });

    // Scroll reveal
    const reveals = document.querySelectorAll('.reveal');
    const observer = new IntersectionObserver(entries => {
        entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); observer.unobserve(e.target); } });
    }, { threshold: 0.12 });
    reveals.forEach(el => observer.observe(el));
</script>

</body>
</html>
