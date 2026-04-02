package org.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class App {
    public static void main(String[] args) {
        // 1. Connection URL එක (Database නම සහ Port එක පරීක්ෂා කරන්න)
        String dbName = "hostelManagementDB";
        String user = "sa";
        String password = "ඔයා_දුන්න_Password_එක"; // මෙතනට ඔයාගේ password එක දාන්න

        String url = "jdbc:sqlserver://localhost:1433;databaseName=" + dbName + ";encrypt=false;trustServerCertificate=true;";

        try {
            System.out.println("Connecting to Database...");

            // 2. Connection එක ලබා ගැනීම
            Connection conn = DriverManager.getConnection(url, user, password);

            if (conn != null) {
                System.out.println("---------------------------------");
                System.out.println("සාර්ථකයි! Database එකට සම්බන්ධ වුණා.");
                System.out.println("---------------------------------");

                conn.close(); // වැඩේ ඉවර වුණාම close කරන්න
            }

        } catch (SQLException e) {
            System.err.println("සම්බන්ධතාවය අසාර්ථකයි!");
            System.err.println("Error Message: " + e.getMessage());
        }
    }
}