
package com.supermarket.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DB {

    private DB() {
    }

    private static String env(String key, String fallback) {
        String value = System.getenv(key);
        return value == null || value.isBlank() ? fallback : value;
    }

    public static Connection open() throws SQLException {
        String url = env(
                "DB_URL",
                "jdbc:mariadb://127.0.0.1:3306/onlinesupermarketdb"
        );

        String username = env("DB_USER", "supermarket_app");
        String password = System.getenv("DB_PASSWORD");

        if (password == null || password.isBlank()) {
            throw new SQLException(
                    "Chua cau hinh DB_PASSWORD cho Tomcat."
            );
        }
        try {
            Class.forName("org.mariadb.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "MariaDB JDBC Driver khong co trong ung dung",
                    e
            );
        }

        return DriverManager.getConnection(url, username, password);
    }
}
