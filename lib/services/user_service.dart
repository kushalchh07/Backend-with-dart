import 'package:mysql1/mysql1.dart';

import '../models/user_model.dart';

class UserService {
  final MySqlConnection connection;

  UserService(this.connection);

  // Register a new user
  Future<User> registerUser(User user) async {
    final result = await connection.query(
      '''INSERT INTO users (fullname, email_address, contact_number, password, otp, email_verified) 
      VALUES (?, ?, ?, ?, ?, ?)''',
      [user.fullname, user.emailAddress, user.contactNumber, user.password, user.otp, user.emailVerified],
    );

    return User(
      userId: result.insertId,
      fullname: user.fullname,
      emailAddress: user.emailAddress,
      contactNumber: user.contactNumber,
      password: user.password,
      otp: user.otp,
      emailVerified: user.emailVerified,
    );
  }

  // Login user
  Future<User?> loginUser(String emailAddress, String password) async {
    final result = await connection.query(
      'SELECT * FROM users WHERE email_address = ? AND password = ?',
      [emailAddress, password],
    );

    if (result.isEmpty) return null;

    return User.fromMap(result.first.fields);
  }

  // Update user profile
  Future<void> updateProfile(User user) async {
    await connection.query(
      '''UPDATE users 
         SET fullname = ?, email_address = ?, contact_number = ?, address = ? 
         WHERE user_id = ?''',
      [user.fullname, user.emailAddress, user.contactNumber, user.address, user.userId],
    );
  }

  // Update profile image
 Future<void> updateProfileImage(int userId, String profileImageFilename) async {
    await connection.query(
      '''UPDATE users SET profile_image = ? WHERE user_id = ?''',
      [profileImageFilename, userId],
    );
  }

  // Change password
  Future<void> changePassword(int userId, String newPassword) async {
    await connection.query(
      'UPDATE users SET password = ? WHERE user_id = ?',
      [newPassword, userId],
    );
  }

  // Handle forgot password
  Future<void> updatePasswordWithOtp(String emailAddress, String newPassword) async {
    await connection.query(
      'UPDATE users SET password = ? WHERE email_address = ?',
      [newPassword, emailAddress],
    );
  }

  // Verify OTP
  Future<bool> verifyOtp(String emailAddress, String otp) async {
    final result = await connection.query(
      'SELECT * FROM users WHERE email_address = ? AND otp = ?',
      [emailAddress, otp],
    );

    if (result.isEmpty) return false;

    // Update email_verified status to true
    await connection.query(
      'UPDATE users SET email_verified = 1 WHERE email_address = ?',
      [emailAddress],
    );

    return true;
  }
}
