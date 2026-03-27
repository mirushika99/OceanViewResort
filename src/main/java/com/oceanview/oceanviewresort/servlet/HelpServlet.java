package com.oceanview.oceanviewresort.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/help")
public class HelpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Session guard ─────────────────────────────────────────────────────
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Both guests and admins can access help — no role restriction needed
        request.getRequestDispatcher("/help.jsp").forward(request, response);
    }
}
