package com.oceanview.oceanviewresort.dao;

import com.oceanview.oceanviewresort.model.RoomType;
import com.oceanview.oceanviewresort.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {

    // Get all room types (for dropdown)
    public List<RoomType> getAllRoomTypes() {

        List<RoomType> list = new ArrayList<>();

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT * FROM room_types";
            PreparedStatement ps = conn.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                RoomType rt = new RoomType();

                rt.setId(rs.getInt("id"));
                rt.setTypeName(rs.getString("type_name"));
                rt.setRatePerNight(rs.getDouble("rate_per_night"));
                rt.setDescription(rs.getString("description"));

                list.add(rt);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // Find available room (core logic)
    public int findAvailableRoom(int typeId, Date checkin, Date checkout) {

        int roomId = -1;

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT TOP 1 r.id FROM rooms r " +
                         "WHERE r.type_id = ? AND r.id NOT IN (" +
                         "SELECT room_id FROM reservations " +
                         "WHERE check_in < ? AND check_out > ?" +
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

    // Get room rate by type
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

    // Get room details (for display / history)
    public String getRoomNumber(int roomId) {

        String roomNumber = "";

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT room_number FROM rooms WHERE id=?";
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, roomId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                roomNumber = rs.getString("room_number");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return roomNumber;
    }
    
    public int getAvailableRoomCount(int typeId, Date checkin, Date checkout) {

        int count = 0;

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT COUNT(*) FROM rooms r " +
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
                count = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }
    
    
    
    public String getRoomDescription(int typeId) {

        String desc = "";

        try {
            Connection conn = DBConnection.getConnection();

            String sql = "SELECT description FROM room_types WHERE id=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, typeId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                desc = rs.getString("description");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return desc;
    }
    
    
    public int getTotalRoomCount(int typeId) {

        int count = 0;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT COUNT(*) FROM rooms WHERE type_id = ?")) {

            ps.setInt(1, typeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }
    
    public List<com.oceanview.oceanviewresort.model.Room> getAllRooms() {
        List<com.oceanview.oceanviewresort.model.Room> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT r.id, r.room_number, r.type_id, rt.type_name " +
                "FROM rooms r JOIN room_types rt ON r.type_id = rt.id " +
                "ORDER BY rt.type_name, r.room_number")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                com.oceanview.oceanviewresort.model.Room room =
                    new com.oceanview.oceanviewresort.model.Room();
                room.setId(rs.getInt("id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setTypeId(rs.getInt("type_id"));
                room.setTypeName(rs.getString("type_name"));
                list.add(room);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Insert a new room type */
    public boolean insertRoomType(String typeName, double rate, String description) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO room_types (type_name, rate_per_night, description) VALUES (?,?,?)")) {
            ps.setString(1, typeName);
            ps.setDouble(2, rate);
            ps.setString(3, description);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Update an existing room type */
    public boolean updateRoomType(int id, String typeName, double rate, String description) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "UPDATE room_types SET type_name=?, rate_per_night=?, description=? WHERE id=?")) {
            ps.setString(1, typeName);
            ps.setDouble(2, rate);
            ps.setString(3, description);
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Insert a new individual room */
    public boolean insertRoom(String roomNumber, int typeId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO rooms (room_number, type_id) VALUES (?,?)")) {
            ps.setString(1, roomNumber);
            ps.setInt(2, typeId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /** Delete a room — only if it has no reservations */
    public boolean deleteRoom(int roomId) {
        try (Connection conn = DBConnection.getConnection()) {
            // Safety check — don't delete if reservations exist
            PreparedStatement check = conn.prepareStatement(
                "SELECT COUNT(*) FROM reservations WHERE room_id = ?");
            check.setInt(1, roomId);
            ResultSet rs = check.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) return false; // has reservations

            PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM rooms WHERE id = ?");
            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

   

    
    
    
}
