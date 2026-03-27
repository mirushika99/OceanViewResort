package com.oceanview.oceanviewresort.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=OCEANVIEW;encrypt=true;trustServerCertificate=true";
    private static final String USER = "sa";
    private static final String PASSWORD = "Mithu@123";
    
    public static Connection getConnection() {
        Connection conn = null;

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); 
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            
            
        } catch (Exception e) {
            e.printStackTrace();
        }

        return conn;
    }
}