/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.oceanview.oceanviewresort.dao;

import com.oceanview.oceanviewresort.model.Reservation;
import com.oceanview.oceanviewresort.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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

    public int findAvailableRoom(int typeId, Date checkin, Date checkout) {

        int roomId = -1;

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT TOP 1 r.id FROM rooms r " +
                    "WHERE r.type_id = ? AND r.id NOT IN (" +
                    "SELECT room_id FROM reservations " +
                    "WHERE check_in < ? AND check_out > ? " +
                    "AND status != 'cancelled'" +
                    ")";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, typeId);
            ps.setDate(2, checkout);
            ps.setDate(3, checkin);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                roomId = rs.getInt("id");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return roomId;
    }

    public double getRoomRate(int typeId) {

        double rate = 0;

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT rate_per_night FROM room_types WHERE id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, typeId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                rate = rs.getDouble("rate_per_night");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return rate;
    }

    public void createReservation(int guestId, int roomId,
            Date checkin, Date checkout,
            int nights, double total) {

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "INSERT INTO reservations " +
                    "(guest_id, room_id, check_in, check_out, nights, total_amount) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, guestId);
            ps.setInt(2, roomId);
            ps.setDate(3, checkin);
            ps.setDate(4, checkout);
            ps.setInt(5, nights);
            ps.setDouble(6, total);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Reservation> getReservations(Integer guestId) {

        List<Reservation> list = new ArrayList<>();

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT r.id, r.guest_id, g.first_name, g.last_name, g.address, g.contact_number, " +
                    "rt.type_name, rt.description, rm.room_number, " +
                    "r.check_in, r.check_out, r.nights, r.total_amount, r.status " +
                    "FROM reservations r " +
                    "JOIN guests g ON r.guest_id = g.id " +
                    "JOIN rooms rm ON r.room_id = rm.id " +
                    "JOIN room_types rt ON rm.type_id = rt.id ";

            if (guestId != null) {
                sql += "WHERE r.guest_id = ?";
            }

            PreparedStatement ps = conn.prepareStatement(sql);

            if (guestId != null) {
                ps.setInt(1, guestId);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Reservation res = new Reservation();

                res.setId(rs.getInt("id"));
                res.setGuestId(rs.getInt("guest_id"));
                res.setFirstName(rs.getString("first_name"));
                res.setLastName(rs.getString("last_name"));
                res.setAddress(rs.getString("address"));
                res.setContactNumber(rs.getString("contact_number"));
                res.setDescription(rs.getString("description"));

                res.setRoomNumber(rs.getString("room_number"));
                res.setRoomType(rs.getString("type_name"));

                res.setCheckIn(rs.getDate("check_in"));
                res.setCheckOut(rs.getDate("check_out"));

                res.setNights(rs.getInt("nights"));
                res.setTotalAmount(rs.getDouble("total_amount"));
                res.setStatus(rs.getString("status"));

                // Optional extra fields (you can extend model)
                // res.setRoomType(rs.getString("type_name"));

                list.add(res);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Reservation getReservationById(int id) {

        Reservation res = null;

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "SELECT r.id, r.guest_id, " +
                                "g.first_name, g.last_name, g.address, g.contact_number, " +
                                "rt.type_name, rt.description, rt.rate_per_night, " +
                                "rm.room_number, " +
                                "r.check_in, r.check_out, r.nights, r.total_amount " +
                                "FROM reservations r " +
                                "JOIN guests g      ON r.guest_id = g.id " +
                                "JOIN rooms rm      ON r.room_id  = rm.id " +
                                "JOIN room_types rt ON rm.type_id  = rt.id " +
                                "WHERE r.id = ?")) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                res = new Reservation();
                res.setId(rs.getInt("id"));
                res.setGuestId(rs.getInt("guest_id"));
                res.setFirstName(rs.getString("first_name"));
                res.setLastName(rs.getString("last_name"));
                res.setAddress(rs.getString("address"));
                res.setContactNumber(rs.getString("contact_number"));
                res.setRoomType(rs.getString("type_name"));
                res.setDescription(rs.getString("description"));
                res.setRoomNumber(rs.getString("room_number"));
                res.setCheckIn(rs.getDate("check_in"));
                res.setCheckOut(rs.getDate("check_out"));
                res.setNights(rs.getInt("nights"));
                res.setTotalAmount(rs.getDouble("total_amount"));
                // Store rate per night — add ratePerNight field to Reservation model if needed
                // res.setRatePerNight(rs.getDouble("rate_per_night"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return res;
    }

    public boolean cancelReservation(int reservationId) {

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "UPDATE reservations SET status = 'cancelled' WHERE id = ?")) {

            ps.setInt(1, reservationId);
            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public Reservation getLatestReservationForGuest(int guestId) {
        String sql = "SELECT TOP 1 r.id, r.guest_id, " +
                "g.first_name, g.last_name, g.address, g.contact_number, " +
                "rt.type_name, rt.description, rt.rate_per_night, " +
                "rm.room_number, r.check_in, r.check_out, r.nights, r.total_amount, r.status " +
                "FROM reservations r " +
                "JOIN guests g      ON r.guest_id = g.id " +
                "JOIN rooms rm      ON r.room_id  = rm.id " +
                "JOIN room_types rt ON rm.type_id  = rt.id " +
                "WHERE r.guest_id = ? " +
                "ORDER BY r.id DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, guestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Reservation res = new Reservation();
                    res.setId(rs.getInt("id"));
                    res.setGuestId(rs.getInt("guest_id"));
                    res.setFirstName(rs.getString("first_name"));
                    res.setLastName(rs.getString("last_name"));
                    res.setRoomType(rs.getString("type_name"));
                    res.setDescription(rs.getString("description"));
                    res.setRoomNumber(rs.getString("room_number"));
                    res.setCheckIn(rs.getDate("check_in"));
                    res.setCheckOut(rs.getDate("check_out"));
                    res.setNights(rs.getInt("nights"));
                    res.setTotalAmount(rs.getDouble("total_amount"));
                    res.setStatus(rs.getString("status"));
                    return res;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}