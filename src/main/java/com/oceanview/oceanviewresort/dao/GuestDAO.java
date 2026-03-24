/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.dao;

import com.oceanview.oceanviewresort.model.Guest;
import com.oceanview.oceanviewresort.util.DBConnection;

import java.sql.*;

public class GuestDAO {

    public static int insertGuest(Guest guest) {
        // FIX 1: OUTPUT INSERTED.id → RETURN_GENERATED_KEYS (standard JDBC, works on
        // all DBs)
        // FIX 2: try-with-resources — connection always closed
        String sql = "INSERT INTO guests (first_name, last_name, address, district, contact_number, nic) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, guest.getFirstName());
            ps.setString(2, guest.getLastName());
            ps.setString(3, guest.getAddress());
            ps.setString(4, guest.getDistrict());
            ps.setString(5, guest.getContactNumber());
            ps.setString(6, guest.getNic());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next())
                    return keys.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static boolean nicExists(String nic) {
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT 1 FROM guests WHERE nic=?")) {

            ps.setString(1, nic.toUpperCase());
            return ps.executeQuery().next();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean contactExists(String contact) {
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT 1 FROM guests WHERE contact_number=?")) {

            ps.setString(1, contact);
            return ps.executeQuery().next();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

}