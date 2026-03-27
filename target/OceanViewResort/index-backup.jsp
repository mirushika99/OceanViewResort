<%-- 
    Document   : index (Login Page)
    Project    : Ocean View Resort - Room Reservation System
    Author     : Student
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
    // If already logged in, redirect appropriately
    String role = (String) session.getAttribute("role");
    if (role != null) {
        if (role.equals("admin")) {
            response.sendRedirect(request.getContextPath() + "/admin.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/guest-dashboard");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ocean View Resort — Login</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Jost:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        :root {
            --sand:      #f5efe6;
            --sand-dark: #e8ddd0;
            --ocean:     #1a3a4a;
            --ocean-mid: #2e5f74;
            --ocean-light: #4a8fa8;
            --gold:      #c9a84c;
            --gold-light:#e2c47a;
            --text-dark: #1a2630;
            --text-mid:  #4a5a65;
            --white:     #ffffff;
        }

        body {
            min-height: 100vh;
            font-family: 'Jost', sans-serif;
            background-color: var(--ocean);
            display: flex;
            overflow: hidden;
        }

        /* ── Left Panel ── */
        .panel-left {
            flex: 1.1;
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 48px 56px;
            background: linear-gradient(160deg, #0d2433 0%, #1a3a4a 45%, #2e5f74 100%);
            overflow: hidden;
        }

        /* Decorative circles */
        .panel-left::before {
            content: '';
            position: absolute;
            width: 500px;
            height: 500px;
            border-radius: 50%;
            border: 1px solid rgba(201,168,76,0.15);
            top: -120px;
            left: -120px;
            pointer-events: none;
        }
        .panel-left::after {
            content: '';
            position: absolute;
            width: 320px;
            height: 320px;
            border-radius: 50%;
            border: 1px solid rgba(201,168,76,0.1);
            bottom: 80px;
            right: -80px;
            pointer-events: none;
        }

        .wave-art {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            opacity: 0.06;
            pointer-events: none;
        }

        .brand {
            position: relative;
            z-index: 2;
            animation: fadeSlideDown 0.8s ease both;
        }

        .brand-icon {
            width: 48px;
            height: 48px;
            margin-bottom: 20px;
        }

        .brand-name {
            font-family: 'Cormorant Garamond', serif;
            font-size: 2rem;
            font-weight: 300;
            color: var(--white);
            letter-spacing: 0.08em;
            line-height: 1.2;
        }

        .brand-name span {
            display: block;
            color: var(--gold);
            font-style: italic;
        }

        .brand-tagline {
            margin-top: 10px;
            font-size: 0.72rem;
            letter-spacing: 0.25em;
            text-transform: uppercase;
            color: rgba(255,255,255,0.4);
        }

        .hero-text {
            position: relative;
            z-index: 2;
            animation: fadeSlideUp 0.9s 0.2s ease both;
        }

        .hero-text h1 {
            font-family: 'Cormorant Garamond', serif;
            font-size: clamp(2.4rem, 4vw, 3.6rem);
            font-weight: 300;
            color: var(--white);
            line-height: 1.15;
        }

        .hero-text h1 em {
            font-style: italic;
            color: var(--gold-light);
        }

        .hero-text p {
            margin-top: 18px;
            font-size: 0.88rem;
            color: rgba(255,255,255,0.5);
            line-height: 1.7;
            max-width: 340px;
            font-weight: 300;
        }

        .divider-gold {
            width: 48px;
            height: 1px;
            background: var(--gold);
            margin: 22px 0;
            opacity: 0.6;
        }

        .stats-row {
            display: flex;
            gap: 40px;
        }

        .stat {
            color: rgba(255,255,255,0.6);
            font-size: 0.78rem;
        }

        .stat strong {
            display: block;
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.6rem;
            font-weight: 400;
            color: var(--gold-light);
            line-height: 1;
            margin-bottom: 4px;
        }

        /* ── Right Panel ── */
        .panel-right {
            flex: 0.9;
            background: var(--sand);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px 56px;
            position: relative;
        }

        .panel-right::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--gold), var(--ocean-light));
        }

        .login-box {
            width: 100%;
            max-width: 380px;
            animation: fadeIn 0.8s 0.3s ease both;
        }

        .login-header {
            margin-bottom: 36px;
        }

        .login-header .eyebrow {
            font-size: 0.68rem;
            letter-spacing: 0.3em;
            text-transform: uppercase;
            color: var(--gold);
            font-weight: 500;
            margin-bottom: 10px;
        }

        .login-header h2 {
            font-family: 'Cormorant Garamond', serif;
            font-size: 2.2rem;
            font-weight: 400;
            color: var(--text-dark);
            line-height: 1.15;
        }

        .login-header p {
            margin-top: 8px;
            font-size: 0.83rem;
            color: var(--text-mid);
            font-weight: 300;
        }

        /* Form */
        .form-group {
            margin-bottom: 22px;
        }

        .form-group label {
            display: block;
            font-size: 0.72rem;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            color: var(--text-mid);
            font-weight: 500;
            margin-bottom: 8px;
        }

        .input-wrap {
            position: relative;
        }

        .input-wrap svg {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            width: 16px;
            height: 16px;
            color: var(--ocean-light);
            pointer-events: none;
        }

        .form-group input {
            width: 100%;
            padding: 13px 14px 13px 40px;
            border: 1.5px solid var(--sand-dark);
            border-radius: 6px;
            background: var(--white);
            font-family: 'Jost', sans-serif;
            font-size: 0.92rem;
            color: var(--text-dark);
            transition: border-color 0.2s, box-shadow 0.2s;
            outline: none;
        }

        .form-group input:focus {
            border-color: var(--ocean-light);
            box-shadow: 0 0 0 3px rgba(74,143,168,0.12);
        }

        .form-group input::placeholder {
            color: #b0b8be;
            font-weight: 300;
        }

        .form-row-inline {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 26px;
            margin-top: -8px;
        }

        .checkbox-label {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.8rem;
            color: var(--text-mid);
            cursor: pointer;
        }

        .checkbox-label input[type="checkbox"] {
            width: 15px;
            height: 15px;
            accent-color: var(--ocean-mid);
        }

        .forgot-link {
            font-size: 0.8rem;
            color: var(--ocean-light);
            text-decoration: none;
            transition: color 0.2s;
        }
        .forgot-link:hover { color: var(--ocean); }

        /* Error message */
        .error-msg {
            background: #fdf0f0;
            border: 1px solid #f5c6c6;
            border-left: 3px solid #e05555;
            border-radius: 6px;
            padding: 12px 14px;
            font-size: 0.82rem;
            color: #c0392b;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Button */
        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, var(--ocean) 0%, var(--ocean-mid) 100%);
            color: var(--white);
            border: none;
            border-radius: 6px;
            font-family: 'Jost', sans-serif;
            font-size: 0.82rem;
            font-weight: 500;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            cursor: pointer;
            transition: transform 0.15s, box-shadow 0.2s, opacity 0.2s;
            position: relative;
            overflow: hidden;
        }

        .btn-login::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, var(--gold) 0%, var(--ocean-mid) 100%);
            opacity: 0;
            transition: opacity 0.3s;
        }

        .btn-login:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 24px rgba(26,58,74,0.3);
        }

        .btn-login:hover::after { opacity: 0.25; }
        .btn-login:active { transform: translateY(0); }

        .btn-login span { position: relative; z-index: 1; }

        .register-row {
            margin-top: 24px;
            text-align: center;
            font-size: 0.82rem;
            color: var(--text-mid);
        }

        .register-row a {
            color: var(--ocean-mid);
            font-weight: 500;
            text-decoration: none;
            transition: color 0.2s;
        }
        .register-row a:hover { color: var(--gold); }

        /* Animations */
        @keyframes fadeSlideDown {
            from { opacity: 0; transform: translateY(-20px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeSlideUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateX(16px); }
            to   { opacity: 1; transform: translateX(0); }
        }

        /* Responsive */
        @media (max-width: 768px) {
            body { flex-direction: column; }
            .panel-left { flex: none; padding: 36px 28px; min-height: 260px; }
            .hero-text h1 { font-size: 2rem; }
            .stats-row { display: none; }
            .panel-right { flex: 1; padding: 36px 24px; }
        }
    </style>
</head>
<body>

    <!-- ═══ LEFT PANEL ═══ -->
    <div class="panel-left">

        <!-- Brand -->
        <div class="brand">
            <svg class="brand-icon" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="24" cy="24" r="23" stroke="#c9a84c" stroke-width="1"/>
                <path d="M8 30 Q14 22 20 28 Q26 34 32 24 Q38 14 42 20" stroke="#c9a84c" stroke-width="1.5" fill="none" stroke-linecap="round"/>
                <path d="M6 35 Q14 27 22 33 Q30 39 40 28" stroke="rgba(201,168,76,0.4)" stroke-width="1" fill="none" stroke-linecap="round"/>
                <circle cx="24" cy="18" r="5" stroke="rgba(255,255,255,0.6)" stroke-width="1" fill="none"/>
                <line x1="24" y1="14" x2="24" y2="10" stroke="rgba(255,255,255,0.4)" stroke-width="1"/>
            </svg>
            <div class="brand-name">
                Ocean View
                <span>Resort</span>
            </div>
            <div class="brand-tagline">Galle · Sri Lanka · Est. 1998</div>
        </div>

        <!-- Hero Text -->
        <div class="hero-text">
            <h1>Where the sea<br>meets <em>serenity</em></h1>
            <div class="divider-gold"></div>
            <p>Manage reservations, guest experiences, and hospitality operations — all from one elegant system.</p>
            <div class="stats-row" style="margin-top:28px;">
                <div class="stat"><strong>120+</strong>Rooms</div>
                <div class="stat"><strong>5★</strong>Rating</div>
                <div class="stat"><strong>25yr</strong>Excellence</div>
            </div>
        </div>

        <!-- Decorative wave SVG -->
        <svg class="wave-art" viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg">
            <path d="M0,80 C80,10 160,150 240,80 C320,10 400,150 480,80 C560,10 640,150 720,80 C780,20 800,60 800,80 L800,200 L0,200 Z" fill="white"/>
        </svg>
    </div>

    <!-- ═══ RIGHT PANEL ═══ -->
    <div class="panel-right">
        <div class="login-box">

            <div class="login-header">
                <div class="eyebrow">Staff Portal</div>
                <h2>Welcome back</h2>
                <p>Sign in to access the reservation management system.</p>
            </div>
            
            <%-- Add this block just above your <form> tag --%>
            <% if ("true".equals(request.getParameter("registered"))) { %>
                <div style="background:#e8f7f1; border:1px solid #a8d5c2; border-left:3px solid #2d7d5a;
                            border-radius:6px; padding:12px 16px; margin-bottom:20px;
                            font-size:0.83rem; color:#2d7d5a; display:flex; align-items:center; gap:8px;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    Account created successfully! Please sign in.
                </div>
            <% } %>


            <!-- Error message (shown when redirected from error) -->
            <%
                String loginError = request.getParameter("error");
                if ("true".equals(loginError)) {
            %>
            <div class="error-msg">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                Invalid email or password. Please try again.
            </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login" method="post" id="loginForm" novalidate>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <div class="input-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        <input
                            type="email"
                            id="email"
                            name="email"
                            placeholder="you@oceanviewresort.lk"
                            required
                            autocomplete="email"
                        >
                        
                        
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="••••••••"
                            required
                            autocomplete="current-password"
                        >
                        
                        <!-- 👁 Show/Hide Icon -->
                        <span id="togglePassword" style="
                            position:absolute;
                            right:12px;
                            top:50%;
                            transform:translateY(-50%);
                            cursor:pointer;
                            font-size:14px;
                            color:#4a5a65;
                        ">👁</span>
                    </div>
                </div>

                <div class="form-row-inline">
                    <label class="checkbox-label">
                        <input type="checkbox" name="remember"> Remember me
                    </label>
                    <a href="#" class="forgot-link">Forgot password?</a>
                </div>

                <button type="submit" class="btn-login">
                    <span>Sign In</span>
                </button>

            </form>

            <div class="register-row">
                New guest? <a href="${pageContext.request.contextPath}/register">Create an account</a>
            </div>

        </div>
    </div>

    <script>
        // Client-side validation before submit
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            const email    = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value.trim();
            const emailRx  = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

            if (!email || !emailRx.test(email)) {
                e.preventDefault();
                document.getElementById('email').focus();
                showInlineError('email', 'Please enter a valid email address.');
                return;
            }
            if (!password || password.length < 4) {
                e.preventDefault();
                document.getElementById('password').focus();
                showInlineError('password', 'Password must be at least 4 characters.');
                return;
            }
        });

        function showInlineError(fieldId, msg) {
            // Remove old error if any
            const old = document.getElementById('err-' + fieldId);
            if (old) old.remove();

            const field = document.getElementById(fieldId);
            field.style.borderColor = '#e05555';

            const err = document.createElement('p');
            err.id = 'err-' + fieldId;
            err.style.cssText = 'color:#e05555;font-size:0.76rem;margin-top:5px;';
            err.textContent = msg;
            field.parentElement.parentElement.appendChild(err);

            field.addEventListener('input', function() {
                field.style.borderColor = '';
                const e = document.getElementById('err-' + fieldId);
                if (e) e.remove();
            }, { once: true });
        }
        
        
        const togglePassword = document.getElementById("togglePassword");
        const passwordField = document.getElementById("password");

        togglePassword.addEventListener("click", function () {
            const type = passwordField.getAttribute("type") === "password" ? "text" : "password";
            passwordField.setAttribute("type", type);

            // Change icon
            this.textContent = type === "password" ? "👁" : "👁";
        });
    </script>

</body>
</html>
