package com.oceanview.oceanviewresort.servlet;

import com.oceanview.oceanviewresort.dao.ReservationDAO;
import com.oceanview.oceanviewresort.dao.RoomDAO;
import com.oceanview.oceanviewresort.model.Reservation;
import com.oceanview.oceanviewresort.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/reservation")
public class ReservationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"guest".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
        }
        loadRoomsAndForward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"guest".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
        }

        String roomTypeParam = request.getParameter("room_type");
        String checkinParam  = request.getParameter("checkin_date");
        String checkoutParam = request.getParameter("checkout_date");

        if (roomTypeParam == null || checkinParam == null || checkoutParam == null
                || roomTypeParam.isBlank() || checkinParam.isBlank() || checkoutParam.isBlank()) {
            forwardWithError(request, response, "Please fill in all fields."); return;
        }

        int typeId; Date checkin, checkout;
        try {
            typeId   = Integer.parseInt(roomTypeParam);
            checkin  = Date.valueOf(checkinParam);
            checkout = Date.valueOf(checkoutParam);
        } catch (Exception e) {
            forwardWithError(request, response, "Invalid input. Please use the date picker."); return;
        }

        Object guestIdObj = session.getAttribute("guest_id");
        if (guestIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
        }
        int guestId = (int) guestIdObj;

        long diffMs = checkout.getTime() - checkin.getTime();
        int  nights = (int) (diffMs / (1000L * 60 * 60 * 24));
        if (nights <= 0) {
            forwardWithError(request, response, "Check-out must be after check-in."); return;
        }

        try {
            ReservationDAO dao = new ReservationDAO();
            int roomId = dao.findAvailableRoom(typeId, checkin, checkout);
            if (roomId == -1) {
                forwardWithError(request, response,
                    "No rooms of this type are available for the selected dates."); return;
            }

            double rate  = dao.getRoomRate(typeId);
            double total = nights * rate;
            dao.createReservation(guestId, roomId, checkin, checkout, nights, total);

            // ── Fetch the just-created reservation and email confirmation ─────
            Reservation res = dao.getLatestReservationForGuest(guestId);
            if (res != null) {
                String guestEmail = (String) session.getAttribute("user");
                String guestName  = (String) session.getAttribute("guest_name");
                if (guestName == null) guestName = "Guest";
                final Reservation fRes  = res;
                final String fEmail = guestEmail, fName = guestName;
                new Thread(() -> EmailUtil.sendBookingConfirmation(
                    fEmail, fName,
                    fRes.getId(), fRes.getRoomType(), fRes.getRoomNumber(),
                    fRes.getCheckIn().toString(), fRes.getCheckOut().toString(),
                    fRes.getNights(), fRes.getTotalAmount()
                )).start();
            }

            response.sendRedirect(request.getContextPath() + "/history?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            forwardWithError(request, response, "A server error occurred. Please try again.");
        }
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse res, String msg)
            throws ServletException, IOException {
        req.setAttribute("error", msg);
        loadRoomsAndForward(req, res);
    }

    private void loadRoomsAndForward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("rooms", new RoomDAO().getAllRoomTypes());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("rooms", new java.util.ArrayList<>());
        }
        request.getRequestDispatcher("/guest/reservation.jsp").forward(request, response);
    }
}
