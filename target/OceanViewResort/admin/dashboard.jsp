<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
    String role = (String) session.getAttribute("role");

    if(role == null || !"guest".equals(role)){
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
</head>
<body>

<h1>Admin Dashboard</h1>

<h3>Welcome, ${sessionScope.user}</h3>

<a href="${pageContext.request.contextPath}/reservation">Make Reservation</a>
<a href="${pageContext.request.contextPath}/history">View My Reservations</a>

<br><br>

<a href="${pageContext.request.contextPath}/logout">Logout</a>

</body>
</html>