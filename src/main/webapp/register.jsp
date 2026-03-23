<%-- 
    Document   : register
    Created on : 21 Mar 2026, 07:25:36
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <form action="register" method="post">

            First Name: <input type="text" name="firstName"><br><br>
            Last Name: <input type="text" name="lastName"><br><br>
            Address: <input type="text" name="address"><br><br>
            District: <input type="text" name="district"><br><br>
            Contact: <input type="text" name="contact"><br><br>

            Email: <input type="text" name="email"><br><br>
            Password: <input type="password" name="password"><br><br>

            <input type="submit" value="Register">
        </form>
    </body>
</html>
