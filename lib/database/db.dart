import 'package:mysql1/mysql1.dart';

class Database {
  static MySqlConnection? _connection;

  // Create or reuse an existing MySQL connection
  static Future<MySqlConnection> getConnection() async {
    if (_connection == null) {
      final settings = ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'root',
        password: '', // Replace with your database password
        db: 'pranshal_ecommerce', // Replace with your database name
      );

      try {
        _connection = await MySqlConnection.connect(settings);
        print('Database connection established.');

        // Ensure required tables exist
        await _ensureTablesExist(_connection!);
      } catch (e) {
        print('Failed to connect to the database: $e');
        rethrow; // Rethrow the exception for further handling
      }
    }
    return _connection!;
  }

  // Close the connection when no longer needed
  static Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      print('Database connection closed.');
    }
  }

  // Ensure required tables exist
  static Future<void> _ensureTablesExist(MySqlConnection connection) async {
    try {
      // Ensure "categories" table exists
      await connection.query('''
        CREATE TABLE IF NOT EXISTS categories (
          category_id INT AUTO_INCREMENT PRIMARY KEY,
          category_name VARCHAR(255) NOT NULL,
          category_thumbnail TEXT,
          category_description TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
      ''');
      print('Ensured "categories" table exists.');

      // Ensure "users" table exists
      await connection.query('''
        CREATE TABLE IF NOT EXISTS users (
          id INT AUTO_INCREMENT PRIMARY KEY,
          username VARCHAR(255) NOT NULL,
          email VARCHAR(255) NOT NULL UNIQUE,
          password VARCHAR(255) NOT NULL,
          phone_number VARCHAR(20) NOT NULL,
          token TEXT,
          otp VARCHAR(6),
          email_verified ENUM('yes', 'no') DEFAULT 'no',
          thumbnail VARCHAR(500),
          address VARCHAR(500),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
      ''');
      // we are using varchar (500) for address because it produced blob error when we try to store address as text similarly for thumbnail
      print('Ensured "users" table exists.');
    } catch (e) {
      print('Error ensuring tables exist: $e');
      rethrow; // Rethrow the exception for further handling
    }
  }
}
