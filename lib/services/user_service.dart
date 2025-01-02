import 'package:mysql1/mysql1.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../models/user.dart';

class UserService {
  final MySqlConnection connection;

  UserService(this.connection);

  // Check if an email already exists in the database
  Future<bool> isEmailExists(String email) async {
    final results =
        await connection.query('SELECT id FROM users WHERE email = ?', [email]);
    return results.isNotEmpty;
  }

  // Hash the password using bcrypt
  String _hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  // Verify the password using bcrypt
  bool _verifyPassword(String plainPassword, String hashedPassword) {
    return BCrypt.checkpw(plainPassword, hashedPassword);
  }

  // Register a new user and save to the database
  Future<User> registerUser(User user) async {
    // Hash the password before saving
    final hashedPassword = _hashPassword(user.password);
    final token = await _generateToken(user);

    // Return the user with the token
    user.token = token;

    // Insert the user into the database
    final result = await connection.query(
      'INSERT INTO users (username, email, password, phone_number, ) VALUES (?, ?, ?, ?,)',
      [user.username, user.email, hashedPassword, user.phoneNumber,],
    );

    // Set the user ID after insert (auto-incremented by MySQL)
    user.id = result.insertId;

    return user;
  }

  // Login user and generate a JWT token
  Future<String> login(String email, String password) async {
    final results = await connection.query(
      'SELECT id, username, email, password FROM users WHERE email = ?',
      [email],
    );

    if (results.isEmpty) {
      throw Exception('Invalid email or password');
    }

    final user = results.first;
    if (!_verifyPassword(password, user['password'])) {
      throw Exception('Invalid email or password');
    }

    // Generate JWT token
    final token = await _generateToken(User(
      id: user['id'],
      username: user['username'],
      email: user['email'],
      password: password, // Password is not needed here
      phoneNumber: user['phone_number'], // Phone number is not needed for login
    ));

    return token;
  }

  // Generate JWT token
  Future<String> _generateToken(User user) async {
    final jwt = JWT(
      {
        'id': user.id,
        'email': user.email,
        'exp': DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch ~/
            1000,
      },
      issuer: 'your-issuer',
    );
    return jwt.sign(SecretKey('your-secret-key'));
  }

  // Verify the token (check expiration and validity)
  Future<bool> verifyToken(String token) async {
    try {
      final jwt = JWT.verify(token, SecretKey('your-secret-key'));
      final exp = jwt.payload['exp'];
      if (exp != null && exp < DateTime.now().millisecondsSinceEpoch ~/ 1000) {
        return false; // Token expired
      }
      return true; // Token is valid
    } catch (e) {
      return false; // Invalid or malformed token
    }
  }

  // Get user by token
  Future<User> getUserByToken(String token) async {
    final jwt = JWT.verify(token, SecretKey('your-secret-key'));
    final userId = jwt.payload['id'];

    final results = await connection.query(
      'SELECT id, username, email, phoneNumber FROM users WHERE id = ?',
      [userId],
    );

    if (results.isEmpty) {
      throw Exception('User not found');
    }

    final user = results.first;
    return User(
      id: user['id'],
      username: user['username'],
      email: user['email'],
      password: '', // Password is not needed when returning user info
      phoneNumber: user['phone_number'],
    );
  }
}
