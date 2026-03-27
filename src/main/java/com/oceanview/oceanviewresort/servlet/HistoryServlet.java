/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.servlet;
import com.oceanview.oceanviewresort.dao.ReservationDAO;
import com.oceanview.oceanviewresort.model.Reservation;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.util.List;



@WebServlet("/history")
public class HistoryServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        System.out.println(role);
        Integer guestId = (Integer) session.getAttribute("guest_id");

        ReservationDAO dao = new ReservationDAO();

        List<Reservation> list;

        if ("admin".equals(role)) {
            list = dao.getReservations(null); // ALL
        } 
        else if ("guest".equals(role)) {

            if (guestId == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            list = dao.getReservations(guestId); // ONLY USER
        } 
        else {
            response.sendRedirect("login.jsp"); // invalid role
            return;
        }
        request.setAttribute("reservations", list);

        request.getRequestDispatcher("/history.jsp").forward(request, response);
    }
}