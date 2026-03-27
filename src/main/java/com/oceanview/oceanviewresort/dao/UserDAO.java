package com.oceanview.oceanviewresort.dao;

import com.oceanview.oceanviewresort.util.DBConnection;
import com.oceanview.oceanviewresort.util.PasswordUtil;
import com.oceanview.oceanviewresort.model.User;

import java.sql.*;

public class UserDAO {

    public static boolean validate(String username, String password) {

        boolean status = false;

        try {
            Connection conn = DBConnection.getConnection();

            String hashedPassword = PasswordUtil.hashPassword(password);

            String sql = "SELECT * FROM users WHERE username=? AND password=?";
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, username);
            ps.setString(2, hashedPassword);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                status = true;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return status;
    }
    
    public static String validateUser(String email, String password) {

        String role = null;

        try {
            Connection conn = DBConnection.getConnection();

            String hashedPassword = PasswordUtil.hashPassword(password);

            String sql = "SELECT role FROM users WHERE email=? AND password=?";
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, email);
            ps.setString(2, hashedPassword);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                role = rs.getString("role"); // admin or guest
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return role;
    }
    
    
    public static boolean insertUser(User user) {

        boolean status = false;

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "INSERT INTO users (guest_id, email, password, role) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);

            if (user.getGuestId() != null) {
                ps.setInt(1, user.getGuestId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }

            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getRole());

            int rows = ps.executeUpdate();

            if (rows > 0) {
                status = true;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return status;
    }
    
    public static User getUser(String email, String password) {
        // FIX 1: try-with-resources — connection always closed
        // FIX 2: JOIN guests to fetch first_name for session display
        // FIX 3: explicit columns, no SELECT *
        String sql = "SELECT u.id, u.guest_id, u.email, u.role, g.first_name " +
                     "FROM users u " +
                     "LEFT JOIN guests g ON u.guest_id = g.id " +
                     "WHERE u.email = ? AND u.password = ?";
 
        String hashedPassword = PasswordUtil.hashPassword(password);
        if (hashedPassword == null) return null;
 
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
 
            ps.setString(1, email);
            ps.setString(2, hashedPassword);
 
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setGuestId(rs.getObject("guest_id") != null ? rs.getInt("guest_id") : null);
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setFirstName(rs.getString("first_name"));
                    return user;
                }
            }
 
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    public static boolean emailExists(String email) {

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT 1 FROM users WHERE email=?")) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    
    
}

