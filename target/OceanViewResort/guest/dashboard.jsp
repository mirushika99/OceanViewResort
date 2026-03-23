<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
    String role = (String) session.getAttribute("role");

    if(role == null || !"guest".equals(role)){
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Guest Dashboard</title>
</head>
<body>

<h1>Guest Dashboard</h1>

<h3>Welcome, ${sessionScope.user}</h3>

<a href="${pageContext.request.contextPath}/reservation">Make Reservation</a>

<br><br>

<a href="${pageContext.request.contextPath}/logout">Logout</a>

</body>
</html>