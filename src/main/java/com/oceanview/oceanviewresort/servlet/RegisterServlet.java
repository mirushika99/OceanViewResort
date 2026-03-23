/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.servlet;

import com.oceanview.oceanviewresort.dao.*;
import com.oceanview.oceanviewresort.util.PasswordUtil;
import com.oceanview.oceanviewresort.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form data
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String address = request.getParameter("address");
        String district = request.getParameter("district");
        String contact = request.getParameter("contact");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // 🔒 Validate password
        if (!PasswordUtil.isValidPassword(password)) {
            response.getWriter().println("Weak Password!");
            return;
        }

        // Create Guest object
        Guest guest = new Guest();
        guest.setFirstName(firstName);
        guest.setLastName(lastName);
        guest.setAddress(address);
        guest.setDistrict(district);
        guest.setContactNumber(contact);

        // Insert guest → get ID
        int guestId = GuestDAO.insertGuest(guest);

        // Hash password
        String hashedPassword = PasswordUtil.hashPassword(password);

        // Create User object
        User user = new User();
        user.setGuestId(guestId);
        user.setEmail(email);
        user.setPassword(hashedPassword);
        user.setRole("guest");

        // Insert user
        boolean status = UserDAO.insertUser(user);

        if (status) {
            response.sendRedirect("index.jsp");
        } else {
            response.getWriter().println("Registration Failed!");
        }
    }
}