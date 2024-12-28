import 'package:pranshal_cms/database/db.dart';
import 'package:pranshal_cms/routes/user_routes.dart';
import 'package:pranshal_cms/services/user_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// CORS Middleware
Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      final response = await handler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type',
      });
    };
  };
}

Future<void> main() async {
  final conn = await createConnection();
  final userService = UserService(conn);
  final authRoutes = AuthRoutes(userService);

  final app = Router();
  app.mount('/api/auth/', authRoutes.router);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders()) // Add CORS middleware
      .addHandler(app);

  // Bind to all network interfaces
  final server = await io.serve(handler, '0.0.0.0', 8080);

  print('Server running on http://${server.address.host}:${server.port}');
}
