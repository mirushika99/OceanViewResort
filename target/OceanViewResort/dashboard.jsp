<%-- 
    Document   : dashboard
    Created on : 21 Mar 2026, 06:43:49
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%@ page session="true" %>

<%
    String role = (String) session.getAttribute("role");

    if(role == null || !role.equals("guest")){
        response.sendRedirect("index.jsp");
    }
%>

<h2>Welcome Guest</h2>

<a href="logout">Logout</a>="logout">Logout</a>