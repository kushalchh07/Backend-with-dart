import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class UserRoutes {
  final UserService userService;

  UserRoutes(this.userService);

  Router get router {
    final router = Router();

    // Register user
    router.post('/register', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final user = User(
          fullname: data['fullname'],
          emailAddress: data['email_address'],
          contactNumber: data['contact_number'],
          password: data['password'],
          otp: data['otp'],
          userId: data['user_id'],
        );

        final registeredUser = await userService.registerUser(user);

        return Response.ok(jsonEncode({
          'status': true,
          'message': 'User registered successfully',
          'user': registeredUser.toMap(),
        }));
      } catch (e) {
        return Response(500, body: jsonEncode({'status': false, 'message': e.toString()}));
      }
    });

    // Login user
    router.post('/login', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final user = await userService.loginUser(data['email_address'], data['password']);

        if (user == null) {
          return Response(401, body: jsonEncode({'status': false, 'message': 'Invalid credentials'}));
        }

        return Response.ok(jsonEncode({'status': true, 'user': user.toMap()}));
      } catch (e) {
        return Response(500, body: jsonEncode({'status': false, 'message': e.toString()}));
      }
    });

    // Update profile
    router.put('/update-profile', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final user = User(
          userId: data['user_id'],
          fullname: data['fullname'],
          emailAddress: data['email_address'],
          contactNumber: data['contact_number'],
          address: data['address'],
          password: '',
        );

        await userService.updateProfile(user);

        return Response.ok(jsonEncode({'status': true, 'message': 'Profile updated successfully'}));
      } catch (e) {
        return Response(500, body: jsonEncode({'status': false, 'message': e.toString()}));
      }
    });

    // Update profile image
// Update profile image
router.post('/update-profile-image', (Request request) async {
  try {
    // Validate Content-Type
    final contentType = request.headers['content-type'];
    if (contentType == null || !contentType.startsWith('multipart/form-data')) {
      return Response(400, body: jsonEncode({'status': false, 'message': 'Invalid request. Content-Type must be multipart/form-data.'}));
    }

    // Parse the multipart request (we use await here)
    final parts =  request.multipart(); // Using shelf_multipart package

   

    int? userId;
    String? profileImageFilename;

    // Ensure upload directory exists
    final uploadDir = Directory('uploads/profileImages');
    if (!await uploadDir.exists()) {
      await uploadDir.create(recursive: true);
    }

    // Iterate over parts safely
    await for (final part in parts) {
      if (part.name == 'user_id') {
        // Parse user_id from the form-data
        final userIdString = await part.readAsString();
        userId = int.tryParse(userIdString);

        if (userId == null) {
          return Response(400, body: jsonEncode({'status': false, 'message': 'Invalid user ID'}));
        }
      } else if (part.name == 'profile_image') {
        // Handle the file upload
        final filename = part.filename ?? 'default.jpg';
        profileImageFilename = DateTime.now().millisecondsSinceEpoch.toString() + '.' + filename.split('.').last;

        final file = File('${uploadDir.path}/$profileImageFilename');
        await part.pipe(file.openWrite());
      }
    }

    if (userId == null) {
      return Response(400, body: jsonEncode({'status': false, 'message': 'Missing user ID in the request'}));
    }

    if (profileImageFilename != null) {
      await userService.updateProfileImage(userId, profileImageFilename);

      return Response.ok(jsonEncode({
        'status': true,
        'message': 'Profile image updated successfully',
        'profile_image_url': 'http://yourdomain.com/profileImages/$profileImageFilename',
      }));
    }

    return Response(400, body: jsonEncode({'status': false, 'message': 'Image upload failed. No file uploaded.'}));
  } catch (e) {
    return Response(500, body: jsonEncode({'status': false, 'message': e.toString()}));
  }
});


    // Change password
    router.put('/change-password', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        await userService.changePassword(data['user_id'], data['new_password']);

        return Response.ok(jsonEncode({'status': true, 'message': 'Password changed successfully'}));
      } catch (e) {
        return Response(500, body: jsonEncode({'status': false, 'message': e.toString()}));
      }
    });

    // Forgot password
    router.post('/forgot-password', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        await userService.updatePasswordWithOtp(data['email_address'], data['new_password']);

        return Response.ok(jsonEncode({'status': true, 'message': 'Password updated successfully'}));
      } catch (e) {
        return Response(500, body: jsonEncode({'status': false, 'message': e.toString()}));
      }
    });

    return router;
  }
}
