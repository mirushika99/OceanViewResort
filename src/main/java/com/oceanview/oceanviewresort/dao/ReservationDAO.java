/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.dao;

import com.oceanview.oceanviewresort.util.DBConnection;

import java.sql.*;


public class ReservationDAO {

    public boolean isRoomAvailable(int roomId, Timestamp checkin, Timestamp checkout) throws Exception {

        String sql = "SELECT COUNT(*) FROM reservations " +
                     "WHERE room_id = ? AND (check_in < ? AND check_out > ?)";

        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setInt(1, roomId);
        ps.setTimestamp(2, checkout);
        ps.setTimestamp(3, checkin);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            return rs.getInt(1) == 0;
        }

        return false;
    }

    public void createReservation(int guestId, int roomId, Timestamp checkin, Timestamp checkout) throws Exception {

        String sql = "INSERT INTO reservations (guest_id, room_id, check_in, check_out) VALUES (?, ?, ?, ?)";

        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setInt(1, guestId);
        ps.setInt(2, roomId);
        ps.setTimestamp(3, checkin);
        ps.setTimestamp(4, checkout);

        ps.executeUpdate();
    }
}