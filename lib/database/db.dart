import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  final Database database;

  DatabaseHelper() : database = sqlite3.open('ecommerce_cms.db') {
    _createTables();
  }

  void _createTables() {
    database.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      );
    ''');

    database.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        category_id INTEGER,
        image_url TEXT
      );
    ''');

    database.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      );
    ''');
  }
}
