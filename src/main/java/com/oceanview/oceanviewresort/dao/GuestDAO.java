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

        int guestId = 0;

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "INSERT INTO guests (first_name, last_name, address, district, contact_number) OUTPUT INSERTED.id VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, guest.getFirstName());
            ps.setString(2, guest.getLastName());
            ps.setString(3, guest.getAddress());
            ps.setString(4, guest.getDistrict());
            ps.setString(5, guest.getContactNumber());

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                guestId = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return guestId;
    }
}