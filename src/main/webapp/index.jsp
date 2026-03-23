<%-- 
    Document   : index
    Created on : 20 Mar 2026, 21:54:11
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Login Page</title>
</head>
<body>
    <h2>Login</h2>

    <form action="${pageContext.request.contextPath}/login" method="post">
        Email: <input type="text" name="email"><br><br>
        Password: <input type="password" name="password"><br><br>
        <input type="submit" value="Login">
    </form>

</body>
</html>