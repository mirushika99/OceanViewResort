<%--
    Document   : bill
    Project    : Ocean View Resort - Room Reservation System
--%>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ page import="com.oceanview.oceanviewresort.model.Reservation" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Reservation r      = (Reservation) request.getAttribute("reservation");
    String      errMsg = (String)      request.getAttribute("error");
    String      backUrl = "admin".equals(role) ? "/history" : "/history";

    // Calculate rate per night from total / nights (since model may not have it)
    double ratePerNight = 0;
    if (r != null && r.getNights() > 0) {
        ratePerNight = r.getTotalAmount() / r.getNights();
    }

    // Generate a bill number from reservation ID
    String billNo = r != null ? String.format("OVR-%06d", r.getId()) : "—";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice <%= billNo %> — Ocean View Resort</title>
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
        }

        /* ── SCREEN STYLES ── */
        body {
            font-family: 'Jost', sans-serif;
            background: var(--sand);
            color: var(--text-dark);
            min-height: 100vh;
        }

        /* Top action bar — hidden on print */
        .action-bar {
            background: var(--ocean);
            padding: 0 48px; height: 64px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
            box-shadow: 0 2px 16px rgba(0,0,0,.2);
        }
        .nav-brand { display:flex; align-items:center; gap:12px; text-decoration:none; }
        .nav-brand-text { font-family:'Cormorant Garamond',serif; font-size:1.2rem; font-weight:400; color:var(--white); letter-spacing:.05em; }
        .nav-brand-text span { color:var(--gold); font-style:italic; }

        .bar-actions { display:flex; align-items:center; gap:12px; }
        .btn-back {
            display:flex; align-items:center; gap:6px;
            padding:8px 16px; border-radius:6px;
            border:1px solid rgba(255,255,255,.2);
            color:rgba(255,255,255,.7);
            font-size:.78rem; font-weight:500; letter-spacing:.1em; text-transform:uppercase;
            text-decoration:none; transition:border-color .2s, color .2s;
        }
        .btn-back:hover { border-color:rgba(255,255,255,.5); color:var(--white); }
        .btn-print {
            display:flex; align-items:center; gap:8px;
            padding:10px 22px; border-radius:6px;
            background:var(--gold); color:var(--ocean);
            font-family:'Jost',sans-serif;
            font-size:.78rem; font-weight:700; letter-spacing:.12em; text-transform:uppercase;
            border:none; cursor:pointer;
            transition:background .2s, transform .15s;
        }
        .btn-print:hover { background:var(--gold-light); transform:translateY(-1px); }
        
        .btn-email {
            display:flex; align-items:center; gap:8px;
            padding:10px 22px; border-radius:6px;
            background:var(--ocean-light); color:var(--white);
            font-family:'Jost',sans-serif;
            font-size:.78rem; font-weight:700; letter-spacing:.12em; text-transform:uppercase;
            border:none; cursor:pointer;
            transition:background .2s, transform .15s;
        }
        .btn-email:hover { background:var(--ocean-mid); transform:translateY(-1px); }

        /* Page wrapper */
        .page-wrap {
            max-width: 820px;
            margin: 40px auto 80px;
            padding: 0 24px;
        }

        /* ── INVOICE CARD ── */
        .invoice {
            background: var(--white);
            border-radius: 16px;
            box-shadow: 0 4px 40px rgba(26,58,74,.12);
            overflow: hidden;
        }

        /* Invoice header */
        .inv-header {
            background: linear-gradient(135deg, var(--ocean) 0%, var(--ocean-mid) 100%);
            padding: 40px 48px;
            display: flex; justify-content: space-between; align-items: flex-start;
            position: relative; overflow: hidden;
        }
        .inv-header::before {
            content: '';
            position: absolute; width: 360px; height: 360px; border-radius: 50%;
            border: 1px solid rgba(201,168,76,.15);
            top: -160px; right: -80px;
        }

        .inv-brand { position: relative; z-index: 2; }
        .inv-brand-name {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.6rem; font-weight: 300; color: var(--white);
            letter-spacing: .04em; line-height: 1.2;
        }
        .inv-brand-name span { color: var(--gold); font-style: italic; }
        .inv-brand-address {
            margin-top: 8px; font-size: .75rem;
            color: rgba(255,255,255,.45); font-weight: 300; line-height: 1.7;
        }

        .inv-meta { position: relative; z-index: 2; text-align: right; }
        .inv-title {
            font-family: 'Cormorant Garamond', serif;
            font-size: 2rem; font-weight: 300; color: var(--gold-light);
            letter-spacing: .08em; text-transform: uppercase;
        }
        .inv-number {
            margin-top: 6px; font-size: .78rem; font-weight: 600;
            color: rgba(255,255,255,.5); letter-spacing: .15em;
        }
        .inv-date {
            margin-top: 4px; font-size: .78rem;
            color: rgba(255,255,255,.4); font-weight: 300;
        }

        /* Divider band */
        .inv-band {
            background: var(--gold);
            height: 4px;
        }

        /* Invoice body */
        .inv-body { padding: 40px 48px; }

        /* Guest & stay section */
        .inv-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 32px;
            margin-bottom: 36px;
            padding-bottom: 36px;
            border-bottom: 1px solid var(--sand-dark);
        }

        .inv-section-title {
            font-size: .62rem; letter-spacing: .22em; text-transform: uppercase;
            color: var(--text-light); font-weight: 600; margin-bottom: 14px;
        }

        .inv-field { margin-bottom: 10px; }
        .inv-field-label {
            font-size: .68rem; text-transform: uppercase; letter-spacing: .12em;
            color: var(--text-light); font-weight: 500; margin-bottom: 2px;
        }
        .inv-field-value {
            font-size: .9rem; color: var(--text-dark); font-weight: 400;
        }
        .inv-field-value.large {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.15rem; font-weight: 400;
        }

        /* Itemised charges table */
        .inv-table-title {
            font-size: .62rem; letter-spacing: .22em; text-transform: uppercase;
            color: var(--text-light); font-weight: 600; margin-bottom: 14px;
        }

        .inv-table {
            width: 100%; border-collapse: collapse;
            font-size: .85rem; margin-bottom: 0;
        }
        .inv-table thead tr {
            background: var(--ocean);
        }
        .inv-table thead th {
            padding: 11px 16px;
            text-align: left;
            font-size: .62rem; font-weight: 600;
            letter-spacing: .18em; text-transform: uppercase;
            color: rgba(255,255,255,.6);
        }
        .inv-table thead th:last-child { text-align: right; }
        .inv-table tbody tr {
            border-bottom: 1px solid var(--sand);
        }
        .inv-table tbody tr:last-child { border-bottom: none; }
        .inv-table tbody td {
            padding: 14px 16px;
            color: var(--text-mid); vertical-align: top;
        }
        .inv-table tbody td:last-child { text-align: right; }
        .inv-table tfoot tr { border-top: 2px solid var(--sand-dark); }
        .inv-table tfoot td {
            padding: 12px 16px;
            font-weight: 600; color: var(--text-dark);
        }
        .inv-table tfoot td:last-child { text-align: right; }

        .charge-name { font-weight: 500; color: var(--text-dark); }
        .charge-detail { font-size: .75rem; color: var(--text-light); margin-top: 2px; font-weight: 300; }

        /* Total box */
        .inv-total-box {
            margin-top: 24px;
            background: var(--ocean);
            border-radius: 10px;
            padding: 20px 24px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .inv-total-label {
            font-size: .72rem; letter-spacing: .18em; text-transform: uppercase;
            color: rgba(255,255,255,.5); font-weight: 600;
        }
        .inv-total-amount {
            font-family: 'Cormorant Garamond', serif;
            font-size: 2rem; font-weight: 400; color: var(--gold-light);
        }
        .inv-total-note {
            font-size: .72rem; color: rgba(255,255,255,.35);
            margin-top: 2px; font-weight: 300;
        }

        /* Status badge */
        .inv-status {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 5px 14px; border-radius: 20px;
            background: var(--success-pale, #e8f7f1);
            color: #2d7d5a;
            font-size: .72rem; font-weight: 600;
        }

        /* Footer */
        .inv-footer {
            margin-top: 36px; padding-top: 24px;
            border-top: 1px solid var(--sand-dark);
            display: flex; justify-content: space-between; align-items: flex-end;
            flex-wrap: wrap; gap: 16px;
        }
        .inv-footer-note {
            font-size: .75rem; color: var(--text-light); font-weight: 300;
            line-height: 1.6; max-width: 340px;
        }
        .inv-footer-thank {
            font-family: 'Cormorant Garamond', serif;
            font-size: 1.1rem; font-style: italic;
            color: var(--ocean-mid);
        }

        /* ── ERROR STATE ── */
        .error-wrap {
            max-width: 820px; margin: 80px auto; padding: 0 24px; text-align: center;
        }
        .error-icon { width: 72px; height: 72px; border-radius: 50%; background: var(--ocean-pale); display:flex; align-items:center; justify-content:center; margin: 0 auto 20px; }
        .error-title { font-family:'Cormorant Garamond',serif; font-size:1.6rem; margin-bottom:8px; }
        .error-sub { font-size:.85rem; color:var(--text-light); margin-bottom:24px; }
        .btn-back-center { display:inline-flex; align-items:center; gap:7px; padding:11px 22px; border-radius:8px; background:var(--ocean); color:var(--white); text-decoration:none; font-size:.78rem; font-weight:600; letter-spacing:.12em; text-transform:uppercase; }

        /* ── PRINT STYLES ── */
        @media print {
            .action-bar { display: none !important; }
            body { background: white; }
            .page-wrap { margin: 0; padding: 0; max-width: 100%; }
            .invoice { border-radius: 0; box-shadow: none; }
            .inv-header { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .inv-band   { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .inv-table thead tr { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .inv-total-box { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        }

        @media (max-width: 600px) {
            .action-bar { padding: 0 20px; }
            .inv-header { flex-direction: column; gap: 20px; padding: 28px 24px; }
            .inv-meta { text-align: left; }
            .inv-body { padding: 28px 24px; }
            .inv-section { grid-template-columns: 1fr; gap: 20px; }
            .inv-total-box { flex-direction: column; align-items: flex-start; gap: 8px; }
        }
    </style>
</head>
<body>

<!-- ═══ ACTION BAR ═══ -->
<div class="action-bar">
    <a class="nav-brand" href="${pageContext.request.contextPath}<%= backUrl %>">
        <svg width="30" height="30" viewBox="0 0 36 36" fill="none">
            <circle cx="18" cy="18" r="17" stroke="#c9a84c" stroke-width="1"/>
            <path d="M5 22 Q9 16 13 20 Q17 24 21 17 Q25 10 31 14" stroke="#c9a84c" stroke-width="1.2" fill="none" stroke-linecap="round"/>
        </svg>
        <div class="nav-brand-text">Ocean View <span>Resort</span></div>
    </a>
    
    <div class="bar-actions">
        <a href="${pageContext.request.contextPath}<%= backUrl %>" class="btn-back">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
            Back
        </a>
        <% if (r != null) { %>
        <form method="post" action="${pageContext.request.contextPath}/bill" style="margin:0">
            <input type="hidden" name="reservation_id" value="<%= r.getId() %>">
            <button type="submit" class="btn-email">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                Email Bill
            </button>
        </form>
        <% } %>
        <button class="btn-print" onclick="window.print()">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="6 9 6 2 18 2 18 9"/>
                <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/>
                <rect x="6" y="14" width="12" height="8"/>
            </svg>
            Print Bill
        </button>
    </div>
</div>

<%--  SUCCESS MESSAGE  --%>        
<% if ("1".equals(request.getParameter("emailed"))) { %>
<div style="max-width:820px;margin:20px auto 0;padding:0 24px;">
    <div style="background:#e8f7f1;border:1px solid #a8d5c2;border-left:3px solid #2d7d5a;
                border-radius:8px;padding:13px 18px;font-size:.83rem;color:#2d7d5a;
                display:flex;align-items:center;gap:10px;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
        Bill sent successfully to your email address.
    </div>
</div>
<% } %>        
<%-- ═══ ERROR STATE ═══ --%>
<% if (errMsg != null) { %>
<div class="error-wrap">
    <div class="error-icon">
        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="var(--ocean-light)" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    </div>
    <div class="error-title">Reservation Not Found</div>
    <div class="error-sub"><%= errMsg %></div>
    <a href="${pageContext.request.contextPath}/history" class="btn-back-center">
        View All Reservations
    </a>
</div>

<%-- ═══ INVOICE ═══ --%>

<% } else if (r != null) { %>
<div class="page-wrap">
<div class="invoice">

    <!-- Header -->
    <div class="inv-header">
        <div class="inv-brand">
            <div class="inv-brand-name">Ocean View <span>Resort</span></div>
            <div class="inv-brand-address">
                Marine Drive, Galle, Sri Lanka<br>
                +94 77 003 0380 &nbsp;·&nbsp; oceanviewresortapp@gmail.com<br>
                www.oceanviewresort.lk
            </div>
        </div>
        <div class="inv-meta">
            <div class="inv-title">Invoice</div>
            <div class="inv-number"><%= billNo %></div>
            <div class="inv-date">Issued: <%= new java.util.Date() %></div>
        </div>
    </div>
    <div class="inv-band"></div>

    <!-- Body -->
    <div class="inv-body">

        <!-- Guest & Stay info -->
        <div class="inv-section">
            <div>
                <div class="inv-section-title">Bill To</div>
                <div class="inv-field">
                    <div class="inv-field-label">Guest Name</div>
                    <div class="inv-field-value large"><%= r.getFirstName() %> <%= r.getLastName() %></div>
                </div>
                <div class="inv-field">
                    <div class="inv-field-label">Contact</div>
                    <div class="inv-field-value"><%= r.getContactNumber() %></div>
                </div>
                <div class="inv-field">
                    <div class="inv-field-label">Address</div>
                    <div class="inv-field-value"><%= r.getAddress() != null ? r.getAddress() : "—" %></div>
                </div>
            </div>
            <div>
                <div class="inv-section-title">Stay Details</div>
                <div class="inv-field">
                    <div class="inv-field-label">Reservation ID</div>
                    <div class="inv-field-value large">#<%= r.getId() %></div>
                </div>
                <div class="inv-field">
                    <div class="inv-field-label">Room</div>
                    <div class="inv-field-value"><%= r.getRoomNumber() %> &nbsp;·&nbsp; <%= r.getRoomType() %></div>
                </div>
                <div class="inv-field">
                    <div class="inv-field-label">Check-in</div>
                    <div class="inv-field-value"><%= r.getCheckIn() %></div>
                </div>
                <div class="inv-field">
                    <div class="inv-field-label">Check-out</div>
                    <div class="inv-field-value"><%= r.getCheckOut() %></div>
                </div>
                <div class="inv-field">
                    <div class="inv-field-label">Duration</div>
                    <div class="inv-field-value"><%= r.getNights() %> night<%= r.getNights() != 1 ? "s" : "" %></div>
                </div>
                <div style="margin-top:10px;">
                    <span class="inv-status">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                        Confirmed
                    </span>
                </div>
            </div>
        </div>

        <!-- Charges table -->
        <div class="inv-table-title">Itemised Charges</div>
        <table class="inv-table">
            <thead>
                <tr>
                    <th>Description</th>
                    <th>Nights</th>
                    <th>Rate / Night</th>
                    <th>Amount (LKR)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        <div class="charge-name">Room Accommodation — <%= r.getRoomType() %></div>
                        <div class="charge-detail">Room <%= r.getRoomNumber() %> &nbsp;·&nbsp; <%= r.getCheckIn() %> to <%= r.getCheckOut() %></div>
                        <% if (r.getDescription() != null && !r.getDescription().isEmpty()) { %>
                        <div class="charge-detail"><%= r.getDescription() %></div>
                        <% } %>
                    </td>
                    <td><%= r.getNights() %></td>
                    <td><%= String.format("LKR %,.0f", ratePerNight) %></td>
                    <td><%= String.format("LKR %,.0f", r.getTotalAmount()) %></td>
                </tr>
                <tr>
                    <td>
                        <div class="charge-name">Breakfast (included)</div>
                        <div class="charge-detail">Complimentary breakfast for two guests daily</div>
                    </td>
                    <td><%= r.getNights() %></td>
                    <td>Complimentary</td>
                    <td>LKR 0</td>
                </tr>
                <tr>
                    <td>
                        <div class="charge-name">Wi-Fi & Amenities (included)</div>
                        <div class="charge-detail">High-speed internet, pool access, beach access</div>
                    </td>
                    <td>—</td>
                    <td>Complimentary</td>
                    <td>LKR 0</td>
                </tr>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="3" style="text-align:right;font-size:.8rem;color:var(--text-light);font-weight:500;letter-spacing:.08em;">SUBTOTAL</td>
                    <td><%= String.format("LKR %,.0f", r.getTotalAmount()) %></td>
                </tr>
                <tr>
                    <td colspan="3" style="text-align:right;font-size:.8rem;color:var(--text-light);font-weight:500;letter-spacing:.08em;">TAX (0%)</td>
                    <td>LKR 0</td>
                </tr>
            </tfoot>
        </table>

        <!-- Total box -->
        <div class="inv-total-box">
            <div>
                <div class="inv-total-label">Total Amount Due</div>
                <div class="inv-total-note">Payable at check-in or check-out · LKR only</div>
            </div>
            <div class="inv-total-amount">
                LKR <%= String.format("%,.0f", r.getTotalAmount()) %>
            </div>
        </div>

        <!-- Footer -->
        <div class="inv-footer">
            <div class="inv-footer-note">
                Payment accepted in cash (LKR), Visa/Mastercard, or bank transfer.
                Cancellations within 48 hours of check-in may incur a one-night charge.
                For queries contact: oceanviewresortapp@gmail.com or +94 77 003 0380.
            </div>
            <div class="inv-footer-thank">Thank you for your stay.</div>
        </div>

    </div><!-- /inv-body -->
</div><!-- /invoice -->
</div><!-- /page-wrap -->
<% } %>

</body>
</html>
