import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/user.dart';
import '../services/email_services.dart';
import '../services/user_service.dart';
import 'dart:math';

class AuthRoutes {
  final UserService userService;
  final EmailService emailService = EmailService(); // Email service instance

  AuthRoutes(this.userService);

  Router get router {
    final router = Router();

    // Register User
    router.post('/register', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      try {
        // Check if the email already exists
        if (await userService.isEmailExists(data['email'])) {
          return Response(400,
              body: jsonEncode({
                'status': false,
                'message': 'User with this email already exists',
              }));
        }

        // Creating user object
        final user = User(
          id: DateTime.now()
              .millisecondsSinceEpoch, // Temporary ID, will be updated after DB insert
          username: data['username'],
          email: data['email'],
          password: data['password'],
          phoneNumber: data['phoneNumber'],
        );

        // Register the user by hashing the password and saving in MySQL
        final registeredUser = await userService.registerUser(user);

        // Generate OTP and send email (optional)
        String otpCode = generateOtp(); // Implement OTP generator
        await emailService.sendOtpEmail(user.email, otpCode);

        return Response.ok(jsonEncode({
          'status': true,
          'token': registeredUser.token,
          'name': registeredUser.username,
          'id': registeredUser.id,
          'email': registeredUser.email,
          'phoneNumber': registeredUser.phoneNumber,
        }));
      } catch (e) {
        return Response(400,
            body: jsonEncode({
              'status': false,
              'message': 'Registration failed: ${e.toString()}',
            }));
      }
    });

    // Login User
    router.post('/login', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      try {
        // Authenticate the user and generate JWT token
        final token = await userService.login(data['email'], data['password']);

        return Response.ok(jsonEncode({
          'status': true,
          'token': token,
          'message': 'Login successful',
          'email': data['email'],
          'phoneNumber': data['phoneNumber'],
          'id': data['id'],
        }));
      } catch (e) {
        return Response(400,
            body: jsonEncode({
              'status': false,
              'message': 'Login failed: ${e.toString()}',
            }));
      }
    });

    // Protected Profile Route
    router.get('/profile', (Request request) async {
      final authHeader = request.headers['Authorization'];

      // Check if the Authorization header is missing or not in the correct format
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401,
            body: jsonEncode({
              'status': false,
              'message': 'Unauthorized: Missing or invalid token',
            }));
      }

      final token = authHeader.substring(7); // Remove the 'Bearer ' prefix

      try {
        // Verify if the token is valid
        final isValid = await userService.verifyToken(token);
        if (!isValid) {
          return Response(401,
              body: jsonEncode({
                'status': false,
                'message': 'Unauthorized: Invalid or expired token',
              }));
        }

        // Get user information associated with the token
        final user = await userService.getUserByToken(token);
        return Response.ok(jsonEncode({
          'status': true,
          'user': {
            'id': user.id,
            'name': user.username,
            'email': user.email,
            'phoneNumber': user.phoneNumber,
          },
        }));
      } catch (e) {
        return Response(401,
            body: jsonEncode({
              'status': false,
              'message': 'Unauthorized: ${e.toString()}',
            }));
      }
    });

    return router;
  }
}

String generateOtp([int length = 6]) {
  const characters = '0123456789';
  final rand = Random();
  String otp = '';
  for (int i = 0; i < length; i++) {
    otp += characters[rand.nextInt(characters.length)];
  }
  return otp;
}
