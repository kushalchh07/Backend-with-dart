import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import '../services/user_service.dart';
import '../models/user.dart';

class UserRoutes {
  final UserService _userService = UserService();

  Router get router {
    final router = Router();

    router.get('/users', (request) {
      final users = _userService.getAllUsers();
      return Response.ok(jsonEncode(users));
    });

    router.post('/users', (request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      final user = User.fromJson(data);
      _userService.createUser(user);
      return Response.ok('User created successfully');
    });

    router.put('/users/<id>', (request, String id) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      final user = User.fromJson(data);
      _userService.updateUser(int.parse(id), user);
      return Response.ok('User updated successfully');
    });

    router.delete('/users/<id>', (request, String id) {
      _userService.deleteUser(int.parse(id));
      return Response.ok('User deleted successfully');
    });

    return router;
  }
}
