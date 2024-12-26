
import 'package:sqlite3/sqlite3.dart';
import '../database/db.dart';
import '../models/user.dart';

class UserService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<User> getAllUsers() {
    final result = _dbHelper.database.select('SELECT * FROM users;');
    return result.map((row) => User.fromJson(row)).toList();
  }

  void createUser(User user) {
    _dbHelper.database.execute('''
      INSERT INTO users (username, email, password)
      VALUES (?, ?, ?);
    ''', [user.username, user.email, user.password]);
  }

  void updateUser(int id, User user) {
    _dbHelper.database.execute('''
      UPDATE users
      SET username = ?, email = ?, password = ?
      WHERE id = ?;
    ''', [user.username, user.email, user.password, id]);
  }

  void deleteUser(int id) {
    _dbHelper.database.execute('DELETE FROM users WHERE id = ?;', [id]);
  }
}
