/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.dao;

import com.oceanview.oceanviewresort.model.Room;
import com.oceanview.oceanviewresort.util.DBConnection;



import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {

    public List<Room> getAvailableRooms(Date checkin, Date checkout) throws Exception {
        List<Room> rooms = new ArrayList<>();

        String sql = "SELECT * FROM rooms WHERE id NOT IN (" +
                     "SELECT room_id FROM reservations " +
                     "WHERE (checkin <= ? AND checkout >= ?))";

        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setDate(1, new java.sql.Date(checkout.getTime()));
        ps.setDate(2, new java.sql.Date(checkin.getTime()));

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Room room = new Room();
            room.setId(rs.getInt("id"));
            room.setType(rs.getString("type"));
            room.setRatePerNight(rs.getDouble("ratePerNight"));
            rooms.add(room);
        }

        return rooms;
    }

    public List<Room> getAllRooms() {

        List<Room> rooms = new ArrayList<>();

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT * FROM rooms";
            PreparedStatement ps = conn.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Room room = new Room();

                room.setId(rs.getInt("id"));
                room.setType(rs.getString("type"));
                room.setRatePerNight(rs.getDouble("rate_per_night"));

                rooms.add(room);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return rooms;
    }
}