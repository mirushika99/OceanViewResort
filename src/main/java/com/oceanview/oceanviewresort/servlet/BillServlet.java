package com.oceanview.oceanviewresort.servlet;

import com.oceanview.oceanviewresort.dao.ReservationDAO;
import com.oceanview.oceanviewresort.model.Reservation;
import com.oceanview.oceanviewresort.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/bill")
public class BillServlet extends HttpServlet {

    // ── GET → show the bill page ──────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/history"); return;
        }

        int reservationId;
        try { reservationId = Integer.parseInt(idParam); }
        catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/history"); return;
        }

        ReservationDAO dao = new ReservationDAO();
        Reservation reservation = dao.getReservationById(reservationId);

        if (reservation == null) {
            request.setAttribute("error", "Reservation #" + reservationId + " not found.");
            request.getRequestDispatcher("/bill.jsp").forward(request, response); return;
        }

        // Guests can only view their own bills
        String  role    = (String)  session.getAttribute("role");
        Integer guestId = (Integer) session.getAttribute("guest_id");
        if ("guest".equals(role) && guestId != null && reservation.getGuestId() != guestId) {
            response.sendRedirect(request.getContextPath() + "/history"); return;
        }

        // Check if email was just sent
        if ("1".equals(request.getParameter("emailed"))) {
            request.setAttribute("emailed", true);
        }

        request.setAttribute("reservation", reservation);
        request.getRequestDispatcher("/bill.jsp").forward(request, response);
    }

    // ── POST → send bill by email ─────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
        }

        String idParam = request.getParameter("reservation_id");
        int reservationId;
        try { reservationId = Integer.parseInt(idParam); }
        catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/history"); return;
        }

        ReservationDAO dao = new ReservationDAO();
        Reservation res = dao.getReservationById(reservationId);

        if (res == null) {
            response.sendRedirect(request.getContextPath() + "/history"); return;
        }

        String guestEmail = (String) session.getAttribute("user");
        String guestName  = (String) session.getAttribute("guest_name");
        if (guestName == null) guestName = "Guest";
        final Reservation fRes  = res;
        final String fEmail = guestEmail, fName = guestName;

        new Thread(() -> EmailUtil.sendBill(
            fEmail, fName,
            fRes.getId(), fRes.getRoomType(), fRes.getRoomNumber(),
            fRes.getCheckIn().toString(), fRes.getCheckOut().toString(),
            fRes.getNights(), fRes.getTotalAmount()
        )).start();

        // Redirect back to bill page with success flag
        response.sendRedirect(request.getContextPath() + "/bill?id=" + reservationId + "&emailed=1");
    }
}
