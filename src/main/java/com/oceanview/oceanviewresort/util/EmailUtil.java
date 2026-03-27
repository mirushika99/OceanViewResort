package com.oceanview.oceanviewresort.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

/**
 * Utility class for sending emails via Gmail SMTP.
 *
 * SETUP:
 * 1. Enable 2-Factor Authentication on your Gmail account
 * 2. Go to Google Account → Security → App Passwords
 * 3. Generate an App Password for "Mail"
 * 4. Replace GMAIL_ADDRESS and GMAIL_APP_PASSWORD below with your credentials
 */
public class EmailUtil {

    private static final String GMAIL_ADDRESS  = "oceanviewresortapp@gmail.com";   
    private static final String GMAIL_APP_PASSWORD = "yatb wbut dvzo tflr"; 

    // ── Core send method ─────────────────────────────────────────────────────
    private static void send(String toEmail, String subject, String htmlBody) throws Exception {
        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(GMAIL_ADDRESS, GMAIL_APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(GMAIL_ADDRESS, "Ocean View Resort"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(htmlBody, "text/html; charset=utf-8");
        Transport.send(message);
    }

    // ── 1. Send OTP for email verification ───────────────────────────────────
    public static void sendOtp(String toEmail, String otp) {
        String subject = "Ocean View Resort — Email Verification Code";
        String body =
            "<div style='font-family:Georgia,serif;max-width:520px;margin:0 auto;background:#f5efe6;padding:32px;border-radius:12px'>" +
            "<div style='background:#1a3a4a;padding:24px 32px;border-radius:8px;text-align:center;margin-bottom:24px'>" +
            "<h1 style='font-family:Georgia,serif;color:#ffffff;font-weight:300;font-size:22px;margin:0'>Ocean View <span style='color:#c9a84c;font-style:italic'>Resort</span></h1>" +
            "</div>" +
            "<h2 style='color:#1a3a4a;font-family:Georgia,serif;font-weight:400;margin-bottom:12px'>Verify your email address</h2>" +
            "<p style='color:#4a5a65;font-size:14px;line-height:1.6;margin-bottom:24px'>Enter this code on the registration page to verify your email:</p>" +
            "<div style='background:#1a3a4a;color:#c9a84c;font-size:36px;font-weight:700;letter-spacing:12px;text-align:center;padding:20px;border-radius:8px;margin-bottom:24px'>" + otp + "</div>" +
            "<p style='color:#7a8f9a;font-size:12px'>This code expires in 10 minutes. If you did not request this, please ignore this email.</p>" +
            "</div>";
        try {
            send(toEmail, subject, body);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ── 2. Send booking confirmation ─────────────────────────────────────────
    public static void sendBookingConfirmation(String toEmail, String guestName,
            int reservationId, String roomType, String roomNumber,
            String checkin, String checkout, int nights, double total) {

        String subject = "Booking Confirmed — Ocean View Resort #" + reservationId;
        String body =
            "<div style='font-family:Georgia,serif;max-width:560px;margin:0 auto;background:#f5efe6;padding:32px;border-radius:12px'>" +
            "<div style='background:#1a3a4a;padding:24px 32px;border-radius:8px;text-align:center;margin-bottom:24px'>" +
            "<h1 style='font-family:Georgia,serif;color:#ffffff;font-weight:300;font-size:22px;margin:0'>Ocean View <span style='color:#c9a84c;font-style:italic'>Resort</span></h1>" +
            "</div>" +
            "<h2 style='color:#2d7d5a;font-family:Georgia,serif;font-weight:400;margin-bottom:8px'>&#10003; Reservation Confirmed</h2>" +
            "<p style='color:#4a5a65;font-size:14px;margin-bottom:24px'>Dear " + guestName + ", your booking has been confirmed.</p>" +
            "<table style='width:100%;border-collapse:collapse;font-size:14px;margin-bottom:24px'>" +
            row("Reservation ID", "#" + reservationId) +
            row("Room Type", roomType) +
            row("Room Number", roomNumber) +
            row("Check-in", checkin) +
            row("Check-out", checkout) +
            row("Duration", nights + " night" + (nights > 1 ? "s" : "")) +
            row("Total Amount", "LKR " + String.format("%,.0f", total)) +
            "</table>" +
            "<div style='background:#1a3a4a;padding:16px 20px;border-radius:8px;color:rgba(255,255,255,0.6);font-size:12px;line-height:1.7'>" +
            "Check-in: 2:00 PM &nbsp;·&nbsp; Check-out: 11:00 AM<br>" +
            "Cancellations must be made at least 48 hours before check-in.<br>" +
            "Marine Drive, Galle, Sri Lanka &nbsp;·&nbsp; +94 77 003 0380" +
            "</div></div>";

        try {
            send(toEmail, subject, body);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ── 3. Send cancellation confirmation ─────────────────────────────────────
    public static void sendCancellationConfirmation(String toEmail, String guestName,
            int reservationId, String roomType, String checkin, String checkout) {

        String subject = "Reservation Cancelled — Ocean View Resort #" + reservationId;
        String body =
            "<div style='font-family:Georgia,serif;max-width:560px;margin:0 auto;background:#f5efe6;padding:32px;border-radius:12px'>" +
            "<div style='background:#1a3a4a;padding:24px 32px;border-radius:8px;text-align:center;margin-bottom:24px'>" +
            "<h1 style='font-family:Georgia,serif;color:#ffffff;font-weight:300;font-size:22px;margin:0'>Ocean View <span style='color:#c9a84c;font-style:italic'>Resort</span></h1>" +
            "</div>" +
            "<h2 style='color:#e05555;font-family:Georgia,serif;font-weight:400;margin-bottom:8px'>Reservation Cancelled</h2>" +
            "<p style='color:#4a5a65;font-size:14px;margin-bottom:24px'>Dear " + guestName + ", your reservation has been cancelled as requested.</p>" +
            "<table style='width:100%;border-collapse:collapse;font-size:14px;margin-bottom:24px'>" +
            row("Reservation ID", "#" + reservationId) +
            row("Room Type", roomType) +
            row("Check-in", checkin) +
            row("Check-out", checkout) +
            row("Status", "Cancelled") +
            "</table>" +
            "<p style='color:#7a8f9a;font-size:12px;line-height:1.6'>If you did not request this cancellation or need assistance, please contact us at oceanviewresortapp@gmail.com or +94 77 003 0380.</p>" +
            "</div>";

        try {
            send(toEmail, subject, body);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ── 4. Send bill by email ─────────────────────────────────────────────────
    public static void sendBill(String toEmail, String guestName,
            int reservationId, String roomType, String roomNumber,
            String checkin, String checkout, int nights, double total) {

        String subject = "Your Invoice — Ocean View Resort #OVR-" + String.format("%06d", reservationId);
        String billNo  = "OVR-" + String.format("%06d", reservationId);
        double ratePerNight = nights > 0 ? total / nights : 0;

        String body =
            "<div style='font-family:Georgia,serif;max-width:560px;margin:0 auto;background:#f5efe6;padding:32px;border-radius:12px'>" +
            "<div style='background:#1a3a4a;padding:24px 32px;border-radius:8px;display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:4px'>" +
            "<div><h1 style='font-family:Georgia,serif;color:#ffffff;font-weight:300;font-size:22px;margin:0'>Ocean View <span style='color:#c9a84c;font-style:italic'>Resort</span></h1>" +
            "<p style='color:rgba(255,255,255,0.4);font-size:11px;margin-top:6px'>Marine Drive, Galle, Sri Lanka</p></div>" +
            "<div style='text-align:right'><div style='color:#e2c47a;font-size:20px;font-style:italic'>Invoice</div>" +
            "<div style='color:rgba(255,255,255,0.4);font-size:12px'>" + billNo + "</div></div></div>" +
            "<div style='background:#c9a84c;height:3px;border-radius:0 0 4px 4px;margin-bottom:24px'></div>" +
            "<p style='color:#4a5a65;font-size:14px;margin-bottom:16px'>Dear " + guestName + ", please find your invoice below.</p>" +
            "<table style='width:100%;border-collapse:collapse;font-size:14px;margin-bottom:20px'>" +
            row("Bill To", guestName) +
            row("Reservation ID", "#" + reservationId) +
            row("Room", roomNumber + " — " + roomType) +
            row("Check-in", checkin) +
            row("Check-out", checkout) +
            row("Nights", String.valueOf(nights)) +
            row("Rate / Night", "LKR " + String.format("%,.0f", ratePerNight)) +
            "</table>" +
            "<div style='background:#1a3a4a;padding:16px 20px;border-radius:8px;display:flex;justify-content:space-between;align-items:center;margin-bottom:20px'>" +
            "<span style='color:rgba(255,255,255,0.5);font-size:12px;text-transform:uppercase;letter-spacing:0.1em'>Total Amount Due</span>" +
            "<span style='color:#e2c47a;font-size:24px;font-family:Georgia,serif'>LKR " + String.format("%,.0f", total) + "</span></div>" +
            "<p style='color:#7a8f9a;font-size:11px;line-height:1.6'>Payment accepted in cash (LKR), Visa/Mastercard, or bank transfer. For queries: oceanviewresortapp@gmail.com</p>" +
            "</div>";

        try {
            send(toEmail, subject, body);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ── Helper: table row ─────────────────────────────────────────────────────
    private static String row(String label, String value) {
        return "<tr style='border-bottom:1px solid #e8ddd0'>" +
               "<td style='padding:10px 12px;color:#7a8f9a;font-size:12px;text-transform:uppercase;letter-spacing:0.1em;width:40%'>" + label + "</td>" +
               "<td style='padding:10px 12px;color:#1a2630;font-weight:500'>" + value + "</td>" +
               "</tr>";
    }
}
