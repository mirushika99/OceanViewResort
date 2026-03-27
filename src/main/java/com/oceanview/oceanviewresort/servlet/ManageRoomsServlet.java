package com.oceanview.oceanviewresort.servlet;

import com.oceanview.oceanviewresort.dao.RoomDAO;
import com.oceanview.oceanviewresort.model.Room;
import com.oceanview.oceanviewresort.model.RoomType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/manage-rooms")
public class ManageRoomsServlet extends HttpServlet {

    // ── GET → show the room management page ──────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        loadAndForward(request, response);
    }

    // ── POST → handle add / update / delete actions ───────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        String ctx    = request.getContextPath();
        RoomDAO dao   = new RoomDAO();

        switch (action == null ? "" : action) {

            // ── Add new room type ─────────────────────────────────────────────
            case "add_type": {
                String typeName = trim(request.getParameter("type_name"));
                String rateStr  = trim(request.getParameter("rate"));
                String desc     = trim(request.getParameter("description"));

                if (typeName.isEmpty() || rateStr.isEmpty()) {
                    redirect(response, ctx, "error=missing_fields"); return;
                }
                try {
                    double rate = Double.parseDouble(rateStr);
                    if (rate <= 0) { redirect(response, ctx, "error=invalid_rate"); return; }
                    boolean ok = dao.insertRoomType(typeName, rate, desc);
                    redirect(response, ctx, ok ? "success=type_added" : "error=failed");
                } catch (NumberFormatException e) {
                    redirect(response, ctx, "error=invalid_rate");
                }
                break;
            }

            // ── Update existing room type ─────────────────────────────────────
            case "update_type": {
                String idStr    = trim(request.getParameter("type_id"));
                String typeName = trim(request.getParameter("type_name"));
                String rateStr  = trim(request.getParameter("rate"));
                String desc     = trim(request.getParameter("description"));

                if (idStr.isEmpty() || typeName.isEmpty() || rateStr.isEmpty()) {
                    redirect(response, ctx, "error=missing_fields"); return;
                }
                try {
                    int    id   = Integer.parseInt(idStr);
                    double rate = Double.parseDouble(rateStr);
                    if (rate <= 0) { redirect(response, ctx, "error=invalid_rate"); return; }
                    boolean ok = dao.updateRoomType(id, typeName, rate, desc);
                    redirect(response, ctx, ok ? "success=type_updated" : "error=failed");
                } catch (NumberFormatException e) {
                    redirect(response, ctx, "error=invalid_rate");
                }
                break;
            }

            // ── Add new individual room ───────────────────────────────────────
            case "add_room": {
                String roomNumber = trim(request.getParameter("room_number"));
                String typeIdStr  = trim(request.getParameter("type_id"));

                if (roomNumber.isEmpty() || typeIdStr.isEmpty()) {
                    redirect(response, ctx, "error=missing_fields"); return;
                }
                try {
                    int typeId = Integer.parseInt(typeIdStr);
                    boolean ok = dao.insertRoom(roomNumber, typeId);
                    redirect(response, ctx, ok ? "success=room_added" : "error=failed");
                } catch (NumberFormatException e) {
                    redirect(response, ctx, "error=invalid_type");
                }
                break;
            }

            // ── Delete a room ─────────────────────────────────────────────────
            case "delete_room": {
                String roomIdStr = trim(request.getParameter("room_id"));
                if (roomIdStr.isEmpty()) {
                    redirect(response, ctx, "error=missing_fields"); return;
                }
                try {
                    int roomId = Integer.parseInt(roomIdStr);
                    boolean ok = dao.deleteRoom(roomId);
                    // deleteRoom returns false if room has reservations
                    redirect(response, ctx, ok ? "success=room_deleted" : "error=has_reservations");
                } catch (NumberFormatException e) {
                    redirect(response, ctx, "error=invalid_id");
                }
                break;
            }

            default:
                redirect(response, ctx, "error=unknown_action");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    private void loadAndForward(HttpServletRequest request,
                                HttpServletResponse response)
            throws ServletException, IOException {
        RoomDAO dao = new RoomDAO();
        List<RoomType> roomTypes = dao.getAllRoomTypes();
        List<Room>     rooms     = dao.getAllRooms();

        // Total count per type
        int[] totalCounts = new int[roomTypes.size()];
        for (int i = 0; i < roomTypes.size(); i++) {
            totalCounts[i] = dao.getTotalRoomCount(roomTypes.get(i).getId());
        }

        request.setAttribute("roomTypes",   roomTypes);
        request.setAttribute("rooms",       rooms);
        request.setAttribute("totalCounts", totalCounts);
        request.getRequestDispatcher("/admin/manage-rooms.jsp").forward(request, response);
    }

    private boolean isAdmin(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    private void redirect(HttpServletResponse res, String ctx, String param)
            throws IOException {
        res.sendRedirect(ctx + "/manage-rooms?" + param);
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
}
