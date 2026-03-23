<%-- 
    Document   : reservation
    Created on : 21 Mar 2026, 09:40:40
    Author     : Admin
--%>

<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
    String role = (String) session.getAttribute("role");

    if(role == null || !role.equals("guest")){
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <form action="${pageContext.request.contextPath}/reservation" method="post">

            Check-in Date:
            <input type="date" name="checkin_date" required><br><br>

            Check-in Time:
            <select name="checkin_time">
            <%
                for(int h = 0; h < 24; h++){
                    for(int m = 0; m < 60; m += 30){
                        String time = String.format("%02d:%02d", h, m);
            %>
                <option value="<%=time%>"><%=time%></option>
            <%
                    }
                }
            %>
            </select><br><br>
            
            
            Check-out Date:
            <input type="date" name="checkout_date" required><br><br>

            Check-out Time:
            <select name="checkout_time">
            <%
                for(int h = 0; h < 24; h++){
                    for(int m = 0; m < 60; m += 30){
                        String time = String.format("%02d:%02d", h, m);
            %>
                <option value="<%=time%>"><%=time%></option>
            <%
                    }
                }
            %>
            </select><br><br>

            Room:
            <select name="room_id" required>
                <option value="">Select Room</option>

                <c:forEach var="room" items="${rooms}">
                    <option value="${room.id}">
                        ${room.type} - $${room.ratePerNight}
                    </option>
                </c:forEach>

            </select><br><br>

            <button type="submit">Book</button>

        </form>

<p style="color:red">${error}</p>
    </body>
</html>
