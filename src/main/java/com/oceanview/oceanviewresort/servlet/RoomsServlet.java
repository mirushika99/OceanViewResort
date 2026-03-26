package com.oceanview.oceanviewresort.servlet;

import com.oceanview.oceanviewresort.dao.RoomDAO;
import com.oceanview.oceanviewresort.model.RoomType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet("/rooms")
public class RoomsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Auth guard ────────────────────────────────────────────────────────
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        RoomDAO dao = new RoomDAO();
        List<RoomType> roomTypes = dao.getAllRoomTypes();

        // ── Read optional date filter params ──────────────────────────────────
        String checkinParam  = request.getParameter("checkin");
        String checkoutParam = request.getParameter("checkout");

        boolean datesProvided = false;
        Date checkin  = null;
        Date checkout = null;

        if (checkinParam  != null && !checkinParam.isBlank()
         && checkoutParam != null && !checkoutParam.isBlank()) {
            try {
                checkin  = Date.valueOf(checkinParam);
                checkout = Date.valueOf(checkoutParam);

                if (checkout.after(checkin)) {
                    datesProvided = true;
                } else {
                    request.setAttribute("dateError", "Check-out date must be after check-in.");
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("dateError", "Invalid date format. Please use the date picker.");
            }
        }

        // ── Build counts per type ─────────────────────────────────────────────
        // availableCounts[i] = -1  → dates not yet chosen (show "select dates")
        //                    = 0   → fully booked for those dates
        //                    = N   → N rooms free
        int[] availableCounts = new int[roomTypes.size()];
        int[] totalCounts     = new int[roomTypes.size()];

        for (int i = 0; i < roomTypes.size(); i++) {
            int typeId         = roomTypes.get(i).getId();
            totalCounts[i]     = dao.getTotalRoomCount(typeId);
            availableCounts[i] = datesProvided
                ? dao.getAvailableRoomCount(typeId, checkin, checkout)
                : -1;
        }

        request.setAttribute("roomTypes",       roomTypes);
        request.setAttribute("totalCounts",     totalCounts);
        request.setAttribute("availableCounts", availableCounts);
        request.setAttribute("datesProvided",   datesProvided);
        request.setAttribute("checkinVal",      checkinParam  != null ? checkinParam  : "");
        request.setAttribute("checkoutVal",     checkoutParam != null ? checkoutParam : "");

        request.getRequestDispatcher("/rooms.jsp").forward(request, response);
    }
}
