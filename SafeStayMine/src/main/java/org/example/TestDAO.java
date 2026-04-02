package org.example;

import java.sql.Connection;
import java.sql.SQLException;

public class TestDAO {
    public static void main(String[] args) {
        try {
            Connection conn = DBConnection.getConnection();
            if (conn != null) {
                System.out.println("සාර්ථකයි! Database එකට සම්බන්ධ වුණා.");
            }
        } catch (SQLException e) {
            System.out.println("සම්බන්ධතාවය අසාර්ථකයි: " + e.getMessage());
        }
    }
}
