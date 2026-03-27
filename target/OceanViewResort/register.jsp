<%--
    Document   : register
    Project    : Ocean View Resort - Room Reservation System
    Two-step:
      Step 1 → email only + "Send Code" button  (action=send_otp)
      Step 2 → full form + OTP field             (action=create_account)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
    String role = (String) session.getAttribute("role");
    if (role != null) {
        response.sendRedirect(request.getContextPath() +
            ("admin".equals(role) ? "/admin.jsp" : "/guest-dashboard"));
        return;
    }

    // Step detection
    String step       = request.getParameter("step");
    String emailParam = request.getParameter("email");
    if (emailParam == null) emailParam = "";
    boolean showFull  = "otp".equals(step) && !emailParam.isEmpty();

    // Error messages
    String errorMsg = request.getParameter("error");
    String errorText = "";
    if      ("invalid_email".equals(errorMsg))    errorText = "Please enter a valid email address.";
    else if ("email_exists".equals(errorMsg))     errorText = "This email is already registered. Please log in instead.";
    else if ("invalid_otp".equals(errorMsg))      errorText = "Incorrect or expired verification code. Please try again.";
    else if ("missing_fields".equals(errorMsg))   errorText = "Please fill in all required fields.";
    else if ("password_mismatch".equals(errorMsg))errorText = "Passwords do not match.";
    else if ("weak_password".equals(errorMsg))    errorText = "Password must be at least 8 characters with uppercase, lowercase and a number.";
    else if ("invalid_nic".equals(errorMsg))      errorText = "Invalid NIC. Use 12 digits or 9 digits + V/X.";
    else if ("invalid_contact".equals(errorMsg))  errorText = "Contact must start with 0 and be 10 digits.";
    else if ("nic_exists".equals(errorMsg))       errorText = "This NIC is already registered.";
    else if ("contact_exists".equals(errorMsg))   errorText = "This contact number is already registered.";
    else if ("server_error".equals(errorMsg))     errorText = "A server error occurred. Please try again.";
    // Legacy error codes from old servlet
    else if ("weakpassword".equals(errorMsg))     errorText = "Password must be at least 8 characters with uppercase, lowercase, and a number.";
    else if ("mismatch".equals(errorMsg))         errorText = "Passwords do not match. Please try again.";
    else if ("emailtaken".equals(errorMsg))       errorText = "This email is already registered. Please log in instead.";
    else if ("failed".equals(errorMsg))           errorText = "Registration failed. Please try again.";
    else if ("invalid".equals(errorMsg))          errorText = "Please fill in all required fields correctly.";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account — Ocean View Resort</title>
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
            --text-dark:   #1a2630;
            --text-mid:    #4a5a65;
            --text-light:  #7a8f9a;
            --white:       #ffffff;
            --error:       #e05555;
            --error-pale:  #fdf0f0;
            --success:     #2d7d5a;
            --success-pale:#e8f7f1;
        }

        body { font-family:'Jost',sans-serif; background:var(--sand); color:var(--text-dark); min-height:100vh; display:flex; flex-direction:column; }

        /* NAV */
        .topnav { background:var(--ocean); padding:0 48px; height:60px; display:flex; align-items:center; justify-content:space-between; }
        .nav-brand { display:flex; align-items:center; gap:12px; text-decoration:none; }
        .nav-brand-text { font-family:'Cormorant Garamond',serif; font-size:1.2rem; font-weight:400; color:var(--white); letter-spacing:.05em; }
        .nav-brand-text span { color:var(--gold); font-style:italic; }
        .nav-login { display:flex; align-items:center; gap:8px; font-size:.78rem; color:rgba(255,255,255,.6); text-decoration:none; transition:color .2s; }
        .nav-login:hover { color:var(--gold-light); }

        /* LAYOUT */
        .page-wrap { flex:1; display:flex; align-items:flex-start; justify-content:center; padding:40px 24px 64px; }
        .register-box { width:100%; max-width:780px; animation:fadeUp .5s ease both; }

        /* HEADER */
        .reg-header { text-align:center; margin-bottom:32px; }
        .reg-eyebrow { font-size:.68rem; letter-spacing:.28em; text-transform:uppercase; color:var(--gold); font-weight:500; margin-bottom:10px; }
        .reg-title { font-family:'Cormorant Garamond',serif; font-size:2.4rem; font-weight:300; color:var(--text-dark); line-height:1.15; }
        .reg-title em { font-style:italic; color:var(--ocean-mid); }
        .reg-sub { margin-top:8px; font-size:.85rem; color:var(--text-light); font-weight:300; }

        /* STEP INDICATOR */
        .steps-bar { display:flex; align-items:center; justify-content:center; margin-bottom:28px; gap:0; }
        .step-item { display:flex; align-items:center; gap:8px; font-size:.72rem; font-weight:500; letter-spacing:.1em; text-transform:uppercase; color:var(--text-light); }
        .step-item.done  { color:var(--success); }
        .step-item.active{ color:var(--ocean-mid); }
        .step-circle { width:26px; height:26px; border-radius:50%; border:2px solid var(--sand-dark); background:var(--white); display:flex; align-items:center; justify-content:center; font-size:.7rem; font-weight:700; color:var(--text-light); flex-shrink:0; transition:.2s; }
        .step-item.done  .step-circle { background:var(--success); border-color:var(--success); color:var(--white); }
        .step-item.active .step-circle { background:var(--ocean-mid); border-color:var(--ocean-mid); color:var(--white); }
        .step-line { width:60px; height:2px; background:var(--sand-dark); margin:0 12px; }
        .step-line.done { background:var(--success); }

        /* OTP SENT BOX */
        .otp-sent-box { display:flex; align-items:center; gap:14px; padding:14px 20px; background:var(--success-pale); border:1px solid #a8d5c2; border-left:3px solid var(--success); border-radius:8px; margin:0 36px 4px; }
        .otp-sent-icon { width:34px; height:34px; border-radius:50%; background:var(--success); display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .otp-sent-text { font-size:.83rem; color:var(--success); line-height:1.5; }
        .otp-sent-email { font-weight:600; }

        /* OTP INPUT */
        .otp-wrap { padding:20px 36px 0; }
        .otp-input { font-size:1.6rem; font-weight:700; letter-spacing:10px; text-align:center; padding:14px; border:2px solid var(--ocean-light); border-radius:10px; background:var(--ocean-pale); color:var(--ocean); font-family:'Jost',sans-serif; width:100%; outline:none; transition:box-shadow .2s; }
        .otp-input:focus { box-shadow:0 0 0 3px rgba(74,143,168,.2); }
        .otp-hint { margin-top:8px; font-size:.75rem; color:var(--text-light); display:flex; align-items:center; justify-content:space-between; }
        .btn-resend { background:none; border:none; color:var(--ocean-light); font-family:'Jost',sans-serif; font-size:.75rem; cursor:pointer; text-decoration:underline; padding:0; }
        .btn-resend:hover { color:var(--ocean); }

        /* CARD */
        .form-card { background:var(--white); border-radius:16px; box-shadow:0 2px 24px rgba(26,58,74,.09); overflow:hidden; }
        .form-section { padding:28px 36px; border-bottom:1px solid var(--sand); }
        .form-section:last-of-type { border-bottom:none; }
        .section-label { font-size:.65rem; letter-spacing:.22em; text-transform:uppercase; color:var(--text-light); font-weight:600; margin-bottom:20px; display:flex; align-items:center; gap:10px; }
        .section-label::after { content:''; flex:1; height:1px; background:var(--sand-dark); }

        /* EMAIL-ONLY STEP */
        .email-step-section { padding:36px; }
        .email-step-desc { font-size:.85rem; color:var(--text-mid); line-height:1.6; margin-bottom:24px; }

        /* GRID */
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:18px; margin-bottom:18px; }
        .form-row:last-child { margin-bottom:0; }
        .form-row.single { grid-template-columns:1fr; }
        .form-row.triple { grid-template-columns:1fr 1fr 1fr; }
        .form-group { display:flex; flex-direction:column; }

        /* LABELS & INPUTS */
        .form-label { font-size:.68rem; letter-spacing:.16em; text-transform:uppercase; color:var(--text-mid); font-weight:500; margin-bottom:7px; }
        .form-label .req { color:var(--error); margin-left:2px; }
        .input-wrap { position:relative; }
        .input-wrap svg.iico { position:absolute; left:13px; top:50%; transform:translateY(-50%); width:15px; height:15px; color:var(--ocean-light); pointer-events:none; }
        .input-wrap svg.eye  { position:absolute; right:13px; top:50%; transform:translateY(-50%); width:16px; height:16px; color:var(--text-light); cursor:pointer; transition:color .2s; }
        .input-wrap svg.eye:hover { color:var(--ocean-mid); }
        .form-control { width:100%; padding:12px 14px 12px 38px; border:1.5px solid var(--sand-dark); border-radius:8px; background:var(--white); font-family:'Jost',sans-serif; font-size:.9rem; color:var(--text-dark); transition:border-color .2s,box-shadow .2s; outline:none; appearance:none; }
        .form-control:focus { border-color:var(--ocean-light); box-shadow:0 0 0 3px rgba(74,143,168,.12); }
        .form-control.has-eye { padding-right:40px; }
        .form-control.ok  { border-color:var(--success); }
        .form-control.bad { border-color:var(--error); box-shadow:0 0 0 3px rgba(224,85,85,.1); }
        .form-control[readonly] { background:var(--ocean-pale); color:var(--ocean-mid); font-weight:500; cursor:default; }
        .form-control::placeholder { color:#b5c0c8; font-weight:300; }
        select.form-control { background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='7' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%234a8fa8' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E"); background-repeat:no-repeat; background-position:right 14px center; padding-right:36px; cursor:pointer; }
        .fhint { font-size:.7rem; color:var(--text-light); margin-top:5px; font-weight:300; }
        .ferr  { font-size:.7rem; color:var(--error); margin-top:5px; display:none; }

        /* PASSWORD STRENGTH */
        .pw-strength { margin-top:8px; display:none; }
        .pw-bars { display:flex; gap:4px; margin-bottom:5px; }
        .pw-bar  { flex:1; height:4px; border-radius:2px; background:var(--sand-dark); transition:background .3s; }
        .pw-bar.weak   { background:var(--error); }
        .pw-bar.med    { background:var(--gold); }
        .pw-bar.strong { background:var(--success); }
        .pw-lbl  { font-size:.7rem; }
        .pw-rules { margin-top:8px; display:flex; flex-wrap:wrap; gap:6px 16px; }
        .pw-rule { display:flex; align-items:center; gap:5px; font-size:.7rem; color:var(--text-light); transition:color .2s; }
        .pw-rule.met { color:var(--success); }
        .pw-rule svg { width:12px; height:12px; flex-shrink:0; }

        /* ALERT */
        .alert-err { display:flex; align-items:flex-start; gap:10px; padding:13px 16px; background:var(--error-pale); border:1px solid #f5c6c6; border-left:3px solid var(--error); border-radius:8px; font-size:.83rem; color:#c0392b; margin:24px 36px 0; }

        /* FOOTER */
        .form-footer { padding:24px 36px; background:#faf7f2; border-top:1px solid var(--sand-dark); display:flex; align-items:center; justify-content:space-between; gap:16px; flex-wrap:wrap; }
        .login-hint { font-size:.82rem; color:var(--text-mid); }
        .login-hint a { color:var(--ocean-mid); font-weight:500; text-decoration:none; transition:color .2s; }
        .login-hint a:hover { color:var(--gold); }
        .btn-reg { padding:13px 36px; background:linear-gradient(135deg,var(--ocean),var(--ocean-mid)); color:var(--white); border:none; border-radius:8px; font-family:'Jost',sans-serif; font-size:.82rem; font-weight:600; letter-spacing:.18em; text-transform:uppercase; cursor:pointer; display:flex; align-items:center; gap:10px; transition:transform .15s,box-shadow .2s; }
        .btn-reg:hover { transform:translateY(-2px); box-shadow:0 8px 28px rgba(26,58,74,.28); }

        @keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }

        @media(max-width:640px){
            .topnav{padding:0 20px}
            .form-section,.email-step-section,.otp-wrap{padding-left:20px;padding-right:20px}
            .otp-sent-box{margin-left:20px;margin-right:20px}
            .form-row,.form-row.triple{grid-template-columns:1fr}
            .form-footer{flex-direction:column;align-items:stretch}
            .btn-reg{justify-content:center}
            .alert-err{margin:20px 20px 0}
        }
    </style>
</head>
<body>

<nav class="topnav">
    <a class="nav-brand" href="${pageContext.request.contextPath}/login.jsp">
        <svg width="30" height="30" viewBox="0 0 36 36" fill="none">
            <circle cx="18" cy="18" r="17" stroke="#c9a84c" stroke-width="1"/>
            <path d="M5 22 Q9 16 13 20 Q17 24 21 17 Q25 10 31 14" stroke="#c9a84c" stroke-width="1.2" fill="none" stroke-linecap="round"/>
        </svg>
        <div class="nav-brand-text">Ocean View <span>Resort</span></div>
    </a>
    <a class="nav-login" href="${pageContext.request.contextPath}/login.jsp">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/>
            <polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/>
        </svg>
        Already have an account? Sign in
    </a>
</nav>

<div class="page-wrap">
  <div class="register-box">

    <div class="reg-header">
        <div class="reg-eyebrow">Guest Registration</div>
        <h1 class="reg-title">Create your <em>account</em></h1>
        <p class="reg-sub">Verify your email first, then complete your details.</p>
    </div>

    <!-- Step indicator -->
    <div class="steps-bar">
        <div class="step-item <%= showFull ? "done" : "active" %>">
            <div class="step-circle"><%= showFull ? "&#10003;" : "1" %></div>
            &nbsp;Verify Email
        </div>
        <div class="step-line <%= showFull ? "done" : "" %>"></div>
        <div class="step-item <%= showFull ? "active" : "" %>">
            <div class="step-circle">2</div>
            &nbsp;Your Details
        </div>
    </div>

    <div class="form-card">

        <!-- Error banner -->
        <% if (!errorText.isEmpty()) { %>
        <div class="alert-err">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <%= errorText %>
        </div>
        <% } %>

        <!-- ════════════════════════════════════════════════════════════════
             STEP 1 — Email only
             ════════════════════════════════════════════════════════════════ -->
        <% if (!showFull) { %>
        <form action="${pageContext.request.contextPath}/register" method="post" id="otpRequestForm">
            <input type="hidden" name="action" value="send_otp">
            <div class="email-step-section">
                <p class="email-step-desc">
                    Enter your email address and we'll send you a 6-digit verification code.
                    Once verified, you can complete your registration.
                </p>
                <div class="form-row single">
                    <div class="form-group">
                        <label class="form-label" for="email">Email Address <span class="req">*</span></label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            <input type="email" id="email" name="email" class="form-control"
                                   placeholder="mirushika@gmail.com" required autocomplete="email"
                                   value="<%= emailParam %>">
                        </div>
                        <div class="ferr" id="err-email">Enter a valid email address.</div>
                    </div>
                </div>
            </div>
            <div class="form-footer">
                <div class="login-hint">
                    Already have an account?
                    <a href="${pageContext.request.contextPath}/login.jsp">Sign in here</a>
                </div>
                <button type="submit" class="btn-reg">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                    Send Verification Code
                </button>
            </div>
        </form>

        <!-- ════════════════════════════════════════════════════════════════
             STEP 2 — OTP + Full form
             ════════════════════════════════════════════════════════════════ -->
        <% } else { %>

        <!-- OTP sent confirmation banner -->
        <div class="otp-sent-box" style="margin-top:24px;">
            <div class="otp-sent-icon">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
            <div class="otp-sent-text">
                Code sent to <span class="otp-sent-email"><%= emailParam %></span><br>
                <span style="font-size:.75rem;opacity:.85">Check your inbox — expires in 10 minutes.</span>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/register" method="post" id="regForm" novalidate>
            <input type="hidden" name="action" value="create_account">
            <input type="hidden" name="email"  value="<%= emailParam %>">

            <!-- OTP entry -->
            <div class="otp-wrap">
                <label class="form-label" for="otp" style="display:block;margin-bottom:8px;">Verification Code <span class="req">*</span></label>
                <input type="text" id="otp" name="otp" class="otp-input"
                       maxlength="6" placeholder="· · · · · ·"
                       autocomplete="one-time-code" required
                       oninput="this.value=this.value.replace(/[^0-9]/g,'')">
                <div class="otp-hint">
                    <span>Enter the 6-digit code from your email</span>
                    <button type="button" class="btn-resend" onclick="resendCode()">Resend code</button>
                </div>
            </div>

            <!-- ── PERSONAL INFO ── -->
            <div class="form-section" style="margin-top:8px;">
                <div class="section-label">Personal Information</div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="firstName">First Name <span class="req">*</span></label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            <input type="text" id="firstName" name="first_name" class="form-control"
                                   placeholder="e.g. Mirushika" required autocomplete="given-name">
                        </div>
                        <div class="ferr" id="err-firstName">First name is required.</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="lastName">Last Name <span class="req">*</span></label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            <input type="text" id="lastName" name="last_name" class="form-control"
                                   placeholder="e.g. Chandrapala" required autocomplete="family-name">
                        </div>
                        <div class="ferr" id="err-lastName">Last name is required.</div>
                    </div>
                </div>

                <div class="form-row triple">
                    <div class="form-group">
                        <label class="form-label" for="nic">NIC <span class="req">*</span></label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
                            <input type="text" id="nic" name="nic" class="form-control"
                                   placeholder="123456789V" maxlength="12" required
                                   oninput="this.value=this.value.toUpperCase()">
                        </div>
                        <div class="fhint">9 digits + V/X  or  12 digits</div>
                        <div class="ferr" id="err-nic">Enter a valid Sri Lankan NIC.</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="contact">Contact No. <span class="req">*</span></label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.4 2 2 0 0 1 3.59 1.22h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.77a16 16 0 0 0 6.29 6.29l1.14-1.14a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                            <input type="tel" id="contact" name="contact_number" class="form-control"
                                   placeholder="0771234567" maxlength="10" required>
                        </div>
                        <div class="fhint">10-digit Sri Lankan number</div>
                        <div class="ferr" id="err-contact">Enter a valid 10-digit number.</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="district">District <span class="req">*</span></label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                            <select id="district" name="district" class="form-control" required>
                                <option value="">Select district</option>
                                <option>Colombo</option><option>Gampaha</option><option>Kalutara</option>
                                <option>Kandy</option><option>Matale</option><option>Nuwara Eliya</option>
                                <option>Galle</option><option>Matara</option><option>Hambantota</option>
                                <option>Jaffna</option><option>Kilinochchi</option><option>Mannar</option>
                                <option>Vavuniya</option><option>Mullaitivu</option><option>Batticaloa</option>
                                <option>Ampara</option><option>Trincomalee</option><option>Kurunegala</option>
                                <option>Puttalam</option><option>Anuradhapura</option><option>Polonnaruwa</option>
                                <option>Badulla</option><option>Moneragala</option><option>Ratnapura</option>
                                <option>Kegalle</option>
                            </select>
                        </div>
                        <div class="ferr" id="err-district">Please select your district.</div>
                    </div>
                </div>

                <div class="form-row single">
                    <div class="form-group">
                        <label class="form-label" for="address">Address</label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                            <input type="text" id="address" name="address" class="form-control"
                                   placeholder="No. 12, Sea View Lane, Galle" autocomplete="street-address">
                        </div>
                    </div>
                </div>
            </div>

            <!-- ── ACCOUNT CREDENTIALS ── -->
            <div class="form-section">
                <div class="section-label">Account Credentials</div>

                <!-- Email readonly -->
                <div class="form-row single" style="margin-bottom:18px;">
                    <div class="form-group">
                        <label class="form-label" for="emailDisplay">Email Address</label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            <input type="email" id="emailDisplay" name="emailDisplay"
                                   class="form-control" value="<%= emailParam %>" readonly>
                        </div>
                        <div class="fhint">&#10003; Verified</div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="password">Password <span class="req">*</span></label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            <input type="password" id="password" name="password"
                                   class="form-control has-eye" placeholder="Min. 8 characters"
                                   required autocomplete="new-password"
                                   oninput="checkStrength(this.value)">
                            <svg class="eye" id="eye1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" onclick="togglePw('password','eye1')">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                            </svg>
                        </div>
                        <div class="pw-strength" id="pwStr">
                            <div class="pw-bars">
                                <div class="pw-bar" id="b1"></div><div class="pw-bar" id="b2"></div>
                                <div class="pw-bar" id="b3"></div><div class="pw-bar" id="b4"></div>
                            </div>
                            <div class="pw-lbl" id="pwLbl"></div>
                            <div class="pw-rules">
                                <div class="pw-rule" id="rl"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>8+ chars</div>
                                <div class="pw-rule" id="ru"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>Uppercase</div>
                                <div class="pw-rule" id="rlo"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>Lowercase</div>
                                <div class="pw-rule" id="rn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>Number</div>
                            </div>
                        </div>
                        <div class="ferr" id="err-password">Password does not meet requirements.</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="confirmPassword">Confirm Password <span class="req">*</span></label>
                        <div class="input-wrap">
                            <svg class="iico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            <input type="password" id="confirmPassword" name="confirm_password"
                                   class="form-control has-eye" placeholder="Re-enter password"
                                   required autocomplete="new-password">
                            <svg class="eye" id="eye2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" onclick="togglePw('confirmPassword','eye2')">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                            </svg>
                        </div>
                        <div class="ferr" id="err-confirm">Passwords do not match.</div>
                    </div>
                </div>
            </div>

            <!-- FOOTER -->
            <div class="form-footer">
                <div class="login-hint">
                    Already have an account?
                    <a href="${pageContext.request.contextPath}/login.jsp">Sign in here</a>
                </div>
                <button type="submit" class="btn-reg">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                    Create Account
                </button>
            </div>

        </form>
        <% } %>

    </div><!-- /form-card -->
  </div>
</div>

<script>
    function togglePw(fid, eid) {
        const f = document.getElementById(fid);
        f.type = f.type === 'password' ? 'text' : 'password';
        document.getElementById(eid).innerHTML = f.type === 'text'
            ? '<line x1="1" y1="1" x2="23" y2="23"/><path d="M9.88 9.88A3 3 0 0 0 12 15a3 3 0 0 0 2.12-.88M10.73 5.08A10.05 10.05 0 0 1 12 5c7 0 11 8 11 8a18.07 18.07 0 0 1-2.62 3.44M6.61 6.61A13.92 13.92 0 0 0 1 12s4 8 11 8a9.95 9.95 0 0 0 5.39-1.61"/>'
            : '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
    }

    function resendCode() {
        const form = document.createElement('form');
        form.method = 'post';
        form.action = '${pageContext.request.contextPath}/register';

        const a = document.createElement('input');
        a.type = 'hidden'; a.name = 'action'; a.value = 'send_otp';

        const e = document.createElement('input');
        e.type = 'hidden'; e.name = 'email'; e.value = '<%= emailParam %>';

        form.appendChild(a);
        form.appendChild(e);
        document.body.appendChild(form);
        form.submit();
    }

    function checkStrength(v) {
        const meter = document.getElementById('pwStr');
        if (!v) { meter.style.display = 'none'; return; }
        meter.style.display = 'block';
        const L = v.length >= 8, U = /[A-Z]/.test(v), Lo = /[a-z]/.test(v), N = /\d/.test(v), S = /[^a-zA-Z0-9]/.test(v);
        document.getElementById('rl').classList.toggle('met', L);
        document.getElementById('ru').classList.toggle('met', U);
        document.getElementById('rlo').classList.toggle('met', Lo);
        document.getElementById('rn').classList.toggle('met', N);
        const score = [L,U,Lo,N,S].filter(Boolean).length;
        const bars = ['b1','b2','b3','b4'].map(id => document.getElementById(id));
        bars.forEach(b => b.className = 'pw-bar');
        const lbl = document.getElementById('pwLbl');
        if      (score <= 2) { bars[0].classList.add('weak');   lbl.textContent='Weak';   lbl.style.color='var(--error)'; }
        else if (score === 3) { [0,1].forEach(i=>bars[i].classList.add('med')); lbl.textContent='Fair'; lbl.style.color='var(--gold)'; }
        else if (score === 4) { [0,1,2].forEach(i=>bars[i].classList.add('strong')); lbl.textContent='Good'; lbl.style.color='var(--success)'; }
        else                  { bars.forEach(b=>b.classList.add('strong')); lbl.textContent='Strong'; lbl.style.color='var(--success)'; }
    }

    function mark(el, ok) { el.classList.toggle('ok', ok); el.classList.toggle('bad', !ok); }
    function showErr(id, show) { const el = document.getElementById(id); if(el) el.style.display = show ? 'block' : 'none'; }

    // Live validation — step 2 only
    <% if (showFull) { %>
    document.getElementById('firstName').addEventListener('blur', function() { const ok = this.value.trim().length >= 2; mark(this, ok); showErr('err-firstName', !ok); });
    document.getElementById('lastName').addEventListener('blur',  function() { const ok = this.value.trim().length >= 2; mark(this, ok); showErr('err-lastName', !ok); });
    document.getElementById('nic').addEventListener('blur', function() {
        const v = this.value.trim();
        const ok = /^[0-9]{9}[VvXx]$/.test(v) || /^[0-9]{12}$/.test(v);
        mark(this, ok); showErr('err-nic', !ok);
    });
    document.getElementById('contact').addEventListener('blur', function() { const ok = /^0[0-9]{9}$/.test(this.value.trim()); mark(this, ok); showErr('err-contact', !ok); });
    document.getElementById('district').addEventListener('change', function() { const ok = this.value !== ''; mark(this, ok); showErr('err-district', !ok); });
    document.getElementById('password').addEventListener('blur', function() {
        const v = this.value;
        const ok = v.length>=8 && /[A-Z]/.test(v) && /[a-z]/.test(v) && /\d/.test(v);
        mark(this, ok); showErr('err-password', !ok);
    });
    document.getElementById('confirmPassword').addEventListener('blur', function() {
        const ok = this.value === document.getElementById('password').value && this.value.length > 0;
        mark(this, ok); showErr('err-confirm', !ok);
    });

    // Full form submit validation
    document.getElementById('regForm').addEventListener('submit', function(e) {
        let allOk = true;

        const otp = document.getElementById('otp');
        const pw  = document.getElementById('password');
        const cp  = document.getElementById('confirmPassword');
        const pwV = pw ? pw.value : '';

        // OTP check
        if (!otp || otp.value.trim().length !== 6) {
            if (otp) otp.style.borderColor = 'var(--error)';
            allOk = false;
        }

        // First name
        const fn = document.getElementById('firstName');
        if (fn && fn.value.trim().length < 2) { mark(fn, false); showErr('err-firstName', true); allOk = false; }
        else if (fn) mark(fn, true);

        // Last name
        const ln = document.getElementById('lastName');
        if (ln && ln.value.trim().length < 2) { mark(ln, false); showErr('err-lastName', true); allOk = false; }
        else if (ln) mark(ln, true);

        // NIC
        const nic = document.getElementById('nic');
        if (nic) {
            const v = nic.value.trim();
            const ok = /^[0-9]{9}[VvXx]$/.test(v) || /^[0-9]{12}$/.test(v);
            mark(nic, ok); showErr('err-nic', !ok);
            if (!ok) allOk = false;
        }

        // Contact
        const con = document.getElementById('contact');
        if (con) {
            const ok = /^0[0-9]{9}$/.test(con.value.trim());
            mark(con, ok); showErr('err-contact', !ok);
            if (!ok) allOk = false;
        }

        // District
        const dis = document.getElementById('district');
        if (dis && dis.value === '') { mark(dis, false); showErr('err-district', true); allOk = false; }
        else if (dis) mark(dis, true);

        // Password
        if (pw) {
            const ok = pwV.length>=8 && /[A-Z]/.test(pwV) && /[a-z]/.test(pwV) && /\d/.test(pwV);
            mark(pw, ok); showErr('err-password', !ok);
            if (!ok) allOk = false;
        }

        // Confirm password
        if (cp) {
            const ok = cp.value === pwV && cp.value.length > 0;
            mark(cp, ok); showErr('err-confirm', !ok);
            if (!ok) allOk = false;
        }

        if (!allOk) {
            e.preventDefault();
            document.querySelector('.bad')?.scrollIntoView({ behavior:'smooth', block:'center' });
        }
    });

    // Auto-focus OTP
    window.addEventListener('load', function() {
        const otp = document.getElementById('otp');
        if (otp) { otp.focus(); }
    });
    <% } else { %>
    // Step 1 email validation
    document.getElementById('otpRequestForm').addEventListener('submit', function(e) {
        const em = document.getElementById('email');
        const ok = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(em.value.trim());
        mark(em, ok); showErr('err-email', !ok);
        if (!ok) e.preventDefault();
    });
    <% } %>
    
    
</script>

</body>
</html>
