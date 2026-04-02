package org.example.dao;

import org.example.model.Room;
import java.sql.*;
import java.util.*;

public class RoomDAO {

    private Connection getConnection() throws SQLException {
        String dbURL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
        String dbUser = "admin";
        String dbPass = "123456";
        return DriverManager.getConnection(dbURL, dbUser, dbPass);
    }

    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM room ORDER BY floor, room_number";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomType(rs.getString("room_type"));
                room.setPriceMonthly(rs.getDouble("price_monthly"));
                room.setHasAc(rs.getString("has_ac"));
                room.setHasFan(rs.getString("has_fan"));
                room.setHasAttachedBathroom(rs.getString("has_attached_bathroom"));
                room.setStatus(rs.getString("status"));
                room.setFloor(rs.getInt("floor"));
                list.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Room> getAvailableRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM room WHERE status = 'Available' ORDER BY floor, room_number";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {

            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomType(rs.getString("room_type"));
                room.setPriceMonthly(rs.getDouble("price_monthly"));
                room.setHasAc(rs.getString("has_ac"));
                room.setHasFan(rs.getString("has_fan"));
                room.setHasAttachedBathroom(rs.getString("has_attached_bathroom"));
                room.setFloor(rs.getInt("floor"));
                list.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Room getRoomById(int id) {
        String sql = "SELECT * FROM room WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setInt(1, id);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomType(rs.getString("room_type"));
                room.setPriceMonthly(rs.getDouble("price_monthly"));
                room.setHasAc(rs.getString("has_ac"));
                room.setHasFan(rs.getString("has_fan"));
                room.setHasAttachedBathroom(rs.getString("has_attached_bathroom"));
                room.setStatus(rs.getString("status"));
                room.setFloor(rs.getInt("floor"));
                return room;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}