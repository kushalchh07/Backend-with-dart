import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class AuthRoutes {
  final UserService userService;

  AuthRoutes(this.userService);

  Router get router {
    final router = Router();

    // Register User
    router.post('/register', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      try {
        // Check if the email already exists in the database
        if (await userService.isEmailExists(data['email'])) {
          return Response(400, body: jsonEncode({
            'status': false,
            'message': 'User with this email already exists',
          }));
        }

        final user = User(
          id: DateTime.now().millisecondsSinceEpoch, // Temporary, will be replaced by MySQL auto-increment
          username: data['username'],
          email: data['email'],
          password: data['password'], // Password will be hashed inside the service
          phoneNumber: data['phoneNumber'],
        );

        // Register the user by hashing the password and saving in MySQL
        final registeredUser = await userService.registerUser(user);

        return Response.ok(jsonEncode({
          'status': true,
          'token': registeredUser.token,
          'name': registeredUser.username,
          'id': registeredUser.id,
          'email': registeredUser.email,
          'phoneNumber': registeredUser.phoneNumber,
        }));
      } catch (e) {
        return Response(400, body: jsonEncode({
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
        // Authenticate and generate a token
        final token = await userService.login(data['email'], data['password']);

        return Response.ok(jsonEncode({
          'status': true,
          'token': token,
        }));
      } catch (e) {
        return Response(400, body: jsonEncode({
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
        return Response(401, body: jsonEncode({
          'status': false,
          'message': 'Unauthorized: Missing or invalid token',
        }));
      }

      final token = authHeader.substring(7); // Remove the 'Bearer ' prefix

      try {
        // Verify if the token is valid
        final isValid = await userService.verifyToken(token);
        if (!isValid) {
          return Response(401, body: jsonEncode({
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
        return Response(401, body: jsonEncode({
          'status': false,
          'message': 'Unauthorized: ${e.toString()}',
        }));
      }
    });

    return router;
  }
}
