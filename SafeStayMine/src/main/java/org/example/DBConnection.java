package org.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=hostelManagementDB;encrypt=false;trustServerCertificate=true;";
    private static final String USER = "admin";
    private static final String PASSWORD = "123456";

    public static Connection getConnection() throws SQLException {
        try {
            // SQL Server Driver  load
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            System.err.println("Driver එක සොයාගත නොහැක: " + e.getMessage());
            throw new SQLException(e);
        }
    }
}