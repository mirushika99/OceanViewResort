package com.oceanview.oceanviewresort.servlet;

import com.oceanview.oceanviewresort.dao.GuestDAO;
import com.oceanview.oceanviewresort.dao.UserDAO;
import com.oceanview.oceanviewresort.model.Guest;
import com.oceanview.oceanviewresort.model.User;
import com.oceanview.oceanviewresort.util.EmailUtil;
import com.oceanview.oceanviewresort.util.OtpStore;
import com.oceanview.oceanviewresort.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String ctx    = request.getContextPath();
        String action = request.getParameter("action");

        // ── STEP 1: Send OTP ──────────────────────────────────────────────────
        if ("send_otp".equals(action)) {
            String email = trim(request.getParameter("email"));

            if (email.isEmpty() || !email.contains("@")) {
                redirect(response, ctx, "register?error=invalid_email"); return;
            }
            if (UserDAO.emailExists(email)) {
                redirect(response, ctx, "register?error=email_exists"); return;
            }

            String otp = OtpStore.generateOtp(email);
            final String fe = email, fo = otp;
            new Thread(() -> EmailUtil.sendOtp(fe, fo)).start();

            redirect(response, ctx, "register?step=otp&email=" + encode(email));
            return;
        }

        // ── STEP 2: Verify OTP + Create Account ───────────────────────────────
        if ("create_account".equals(action)) {
            String firstName = trim(request.getParameter("first_name"));
            String lastName  = trim(request.getParameter("last_name"));
            String email     = trim(request.getParameter("email"));
            String address   = trim(request.getParameter("address"));
            String district  = trim(request.getParameter("district"));
            String contact   = trim(request.getParameter("contact_number"));
            String nic       = trim(request.getParameter("nic"));
            String password  = trim(request.getParameter("password"));
            String confirm   = trim(request.getParameter("confirm_password"));
            String otp       = trim(request.getParameter("otp"));
            String emailEnc  = encode(email);
            String stepParam = "&step=otp&email=" + emailEnc;
            
            
            // Check if any required field is empty
            if (firstName.isEmpty() || lastName.isEmpty() || email.isEmpty()
                    || contact.isEmpty() || nic.isEmpty() || password.isEmpty()) {
                redirect(response, ctx, "register?error=missing_fields" + stepParam); return;
            }
            
            // Verify the OTP entered by the user
            if (!OtpStore.verify(email, otp)) {
                redirect(response, ctx, "register?error=invalid_otp" + stepParam); return;
            }
            
            // Check if password and confirm password match
            if (!password.equals(confirm)) {
                redirect(response, ctx, "register?error=password_mismatch" + stepParam); return;
            }
            
            // Validate password strength (custom validation method)
            if (!PasswordUtil.isValidPassword(password)) {
                redirect(response, ctx, "register?error=weak_password" + stepParam); return;
            }
            
            // Validate NIC format (Sri Lankan NIC: 12 digits OR 9 digits + V/X)
            if (!nic.matches("\\d{12}") && !nic.matches("\\d{9}[VXvx]")) {
                redirect(response, ctx, "register?error=invalid_nic" + stepParam); return;
            }
            
            // Validate contact number (must start with 0 and contain 10 digits)
            if (!contact.matches("0[0-9]{9}")) {
                redirect(response, ctx, "register?error=invalid_contact" + stepParam); return;
            }
            
            // Check if email already exists in the system
            if (UserDAO.emailExists(email)) {
                redirect(response, ctx, "register?error=email_exists"); return;
            }
            
            // Check if NIC already exists in guest records
            if (GuestDAO.nicExists(nic)) {
                redirect(response, ctx, "register?error=nic_exists" + stepParam); return;
            }
            
            // Check if contact number already exists
            if (GuestDAO.contactExists(contact)) {
                redirect(response, ctx, "register?error=contact_exists" + stepParam); return;
            }

            Guest guest = new Guest();
            guest.setFirstName(firstName);
            guest.setLastName(lastName);
            guest.setAddress(address);
            guest.setDistrict(district);
            guest.setContactNumber(contact);
            guest.setNic(nic.toUpperCase());

            int guestId = GuestDAO.insertGuest(guest);
            if (guestId == 0) {
                redirect(response, ctx, "register?error=server_error"); return;
            }

            User user = new User();
            user.setGuestId(guestId);
            user.setEmail(email);
            user.setPassword(PasswordUtil.hashPassword(password));
            user.setRole("guest");

            if (!UserDAO.insertUser(user)) {
                redirect(response, ctx, "register?error=server_error"); return;
            }

            redirect(response, ctx, "login.jsp?registered=true");
            return;
        }

        redirect(response, ctx, "register");
    }

    private void redirect(HttpServletResponse res, String ctx, String path) throws IOException {
        res.sendRedirect(ctx + "/" + path);
    }
    private String trim(String s) { return s == null ? "" : s.trim(); }
    private String encode(String s) {
        try { return java.net.URLEncoder.encode(s, "UTF-8"); }
        catch (Exception e) { return s; }
    }
}
