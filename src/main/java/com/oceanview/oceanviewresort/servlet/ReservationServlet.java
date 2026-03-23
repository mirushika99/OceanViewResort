/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.servlet;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;
import java.io.IOException;
import com.oceanview.oceanviewresort.dao.*;
import java.sql.Date;
import java.sql.Timestamp;

@WebServlet("/reservation")
public class ReservationServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("ReservationServlet GET called 🔥");

        // Load rooms from DB
        RoomDAO roomDAO = new RoomDAO();
        request.setAttribute("rooms", roomDAO.getAllRooms());

        // Forward to JSP
        request.getRequestDispatcher("/guest/reservation.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Integer guestId = (Integer) request.getSession().getAttribute("guest_id");
            System.out.println("Guest ID: " + guestId);

            if (guestId == null) {
                response.sendRedirect(request.getContextPath() + "/index.jsp");
                return;
            }

            // Get values
            String checkinDate = request.getParameter("checkin_date");
            String checkinTime = request.getParameter("checkin_time");

            String checkoutDate = request.getParameter("checkout_date");
            String checkoutTime = request.getParameter("checkout_time");
            
            System.out.println("Check-in Time: " + checkinTime);
            System.out.println("Check-out Time: " + checkoutTime);
            
            if (checkinDate == null || checkinTime == null ||
                checkoutDate == null || checkoutTime == null) {

                request.setAttribute("error", "Please select date and time");
                request.getRequestDispatcher("/guest/reservation.jsp").forward(request, response);
                return;
            }

            // Combine date + time
            String checkinStr = checkinDate + " " + checkinTime + ":00";
            String checkoutStr = checkoutDate + " " + checkoutTime + ":00";

            // Convert to Timestamp
            Timestamp checkinTS = Timestamp.valueOf(checkinStr);
            Timestamp checkoutTS = Timestamp.valueOf(checkoutStr);
            
            System.out.println("Date: " + request.getParameter("checkin_date"));
            System.out.println("Time: " + request.getParameter("checkin_time"));
            System.out.println("Room: " + request.getParameter("room_id"));
            
            
            
            

            int roomId = Integer.parseInt(request.getParameter("room_id"));

            ReservationDAO dao = new ReservationDAO();

            // 🔴 Validation
            if (!checkoutTS.after(checkinTS)) {
                request.setAttribute("error", "Invalid date range!");
                request.getRequestDispatcher("/guest/reservation.jsp").forward(request, response);
                return;
            }

            // 🔴 Availability check
            if (!dao.isRoomAvailable(roomId, checkinTS, checkoutTS)) {
                request.setAttribute("error", "Room already booked!");
                request.getRequestDispatcher("/guest/reservation.jsp").forward(request, response);
                return;
            }

            // ✅ Save booking
            dao.createReservation(guestId, roomId, checkinTS, checkoutTS);

            response.sendRedirect(request.getContextPath() + "/guest/success.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}