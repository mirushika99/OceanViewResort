<%-- 
    Document   : admin
    Created on : 21 Mar 2026, 06:57:40
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
    String role = (String) session.getAttribute("role");

    if(role == null || !role.equals("admin")){
        response.sendRedirect("index.jsp");
    }
%>

<h2>Welcome Admin</h2>
<a href="logout">Logout</a>