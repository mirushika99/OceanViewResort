/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.servlet;

import com.oceanview.oceanviewresort.dao.UserDAO;
import com.oceanview.oceanviewresort.model.User;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        
       

        User user = UserDAO.getUser(email, password);
        System.out.println(email);
        System.out.println(password);    

        if (user != null) {
            

            HttpSession session = request.getSession();
            session.setAttribute("user", user.getEmail());
            session.setAttribute("role", user.getRole());
            session.setAttribute("guest_id", user.getGuestId());

            String contextPath = request.getContextPath();

            if (user.getRole().equals("admin")) {
                System.out.println("admin");  
                response.sendRedirect(contextPath + "/admin.jsp");
            } else {
                System.out.println("guest");  
                response.sendRedirect(request.getContextPath() + "/guest-dashboard");
            }

        } else {
            response.sendRedirect(request.getContextPath() + "/error.jsp");
        }
    }
}
    
