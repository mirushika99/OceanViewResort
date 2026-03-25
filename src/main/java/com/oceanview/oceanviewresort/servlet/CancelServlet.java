package com.oceanview.oceanviewresort.servlet;

import com.oceanview.oceanviewresort.dao.ReservationDAO;
import com.oceanview.oceanviewresort.model.Reservation;
import com.oceanview.oceanviewresort.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/cancel")
public class CancelServlet extends HttpServlet {

    private static final long HOURS_48_MS = 48L * 60 * 60 * 1000;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/history");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String ctx = request.getContextPath();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(ctx + "/login.jsp"); return;
        }

        String  role    = (String)  session.getAttribute("role");
        Integer guestId = (Integer) session.getAttribute("guest_id");

        String idParam = request.getParameter("reservation_id");
        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(ctx + "/history?error=invalid"); return;
        }

        int reservationId;
        try { reservationId = Integer.parseInt(idParam); }
        catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/history?error=invalid"); return;
        }

        ReservationDAO dao = new ReservationDAO();
        Reservation reservation = dao.getReservationById(reservationId);

        if (reservation == null) {
            response.sendRedirect(ctx + "/history?error=not_found"); return;
        }
        if ("guest".equals(role) && (guestId == null || reservation.getGuestId() != guestId)) {
            response.sendRedirect(ctx + "/history?error=forbidden"); return;
        }
        if ("cancelled".equalsIgnoreCase(reservation.getStatus())) {
            response.sendRedirect(ctx + "/history?error=already_cancelled"); return;
        }

        // ── 48-hour rule ──────────────────────────────────────────────────────
        if (reservation.getCheckIn() != null) {
            long msUntilCheckIn = reservation.getCheckIn().getTime() - System.currentTimeMillis();
            if (msUntilCheckIn < HOURS_48_MS) {
                response.sendRedirect(ctx + "/history?error=too_late"); return;
            }
        }

        boolean success = dao.cancelReservation(reservationId);
        if (!success) {
            response.sendRedirect(ctx + "/history?error=failed"); return;
        }

        // ── Send cancellation email in background ─────────────────────────────
        String guestEmail = (String) session.getAttribute("user");
        String guestName  = (String) session.getAttribute("guest_name");
        if (guestName == null) guestName = "Guest";
        final Reservation fRes  = reservation;
        final String fEmail = guestEmail, fName = guestName;
        new Thread(() -> EmailUtil.sendCancellationConfirmation(
            fEmail, fName,
            fRes.getId(), fRes.getRoomType(),
            fRes.getCheckIn().toString(), fRes.getCheckOut().toString()
        )).start();

        response.sendRedirect(ctx + "/history?cancelled=1");
    }
}
