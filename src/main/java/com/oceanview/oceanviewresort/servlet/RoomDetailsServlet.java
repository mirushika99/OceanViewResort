package com.oceanview.oceanviewresort.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import com.oceanview.oceanviewresort.dao.RoomDAO;
import java.sql.Date;

@WebServlet("/room-details")
public class RoomDetailsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // ── 1. Parse typeId ───────────────────────────────────────────────
            String typeIdParam = request.getParameter("typeId");
            if (typeIdParam == null || typeIdParam.isBlank()) {
                out.write("{\"available\":0,\"description\":\"\",\"error\":\"Missing typeId\"}");
                return;
            }
            int typeId = Integer.parseInt(typeIdParam);

            // ── 2. Parse dates ────────────────────────────────────────────────
            String cin = request.getParameter("checkin");
            String cout = request.getParameter("checkout");

            if (cin == null || cin.isBlank() || cout == null || cout.isBlank()) {
                // Dates not yet selected — return description only, no availability
                RoomDAO dao = new RoomDAO();
                String desc = escapeJson(dao.getRoomDescription(typeId));
                out.write("{\"available\":-1,\"description\":\"" + desc + "\"}");
                return;
            }

            Date checkin = Date.valueOf(cin);
            Date checkout = Date.valueOf(cout);

            // ── 3. Validate date range ────────────────────────────────────────
            if (!checkout.after(checkin)) {
                out.write("{\"available\":0,\"description\":\"\",\"error\":\"Invalid date range\"}");
                return;
            }

            // ── 4. Fetch from DB ──────────────────────────────────────────────
            RoomDAO dao = new RoomDAO();
            int available = dao.getAvailableRoomCount(typeId, checkin, checkout);
            String description = escapeJson(dao.getRoomDescription(typeId));

            // ── 5. Write safe JSON ────────────────────────────────────────────
            // FIX: hand-built format string replaced with safe escaping
            out.write(String.format(
                    "{\"available\":%d,\"description\":\"%s\"}",
                    available, description));

        } catch (NumberFormatException e) {
            out.write("{\"available\":0,\"description\":\"\",\"error\":\"Invalid typeId\"}");
        } catch (IllegalArgumentException e) {
            // Date.valueOf() throws this for bad date strings
            out.write("{\"available\":0,\"description\":\"\",\"error\":\"Invalid date format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"available\":0,\"description\":\"\",\"error\":\"Server error\"}");
        }
    }

    /**
     * Properly escapes a string for safe embedding inside a JSON string value.
     * Handles backslash, double quote, newline, carriage return, tab.
     * FIX: original only escaped double quotes — any other special char broke JSON.
     */
    private String escapeJson(String s) {
        if (s == null)
            return "";
        return s.replace("\\", "\\\\") // backslash first
                .replace("\"", "\\\"") // double quote
                .replace("\n", "\\n") // newline
                .replace("\r", "\\r") // carriage return
                .replace("\t", "\\t"); // tab
    }
}
