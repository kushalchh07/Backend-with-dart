import 'package:pranshal_cms/database/db.dart';
import 'package:pranshal_cms/routes/user_routes.dart';
import 'package:pranshal_cms/routes/category_routes.dart'; // Import category routes
import 'package:pranshal_cms/services/user_service.dart';
import 'package:pranshal_cms/services/category_service.dart'; // Import category service
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:io';

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
  try {
    // Initialize database connection
    final connection = await Database.getConnection();
    print('Database connection established.');

    // Initialize services
    final userService = UserService(connection);
    final categoryService = CategoryService(connection);

    // Initialize routes
    final authRoutes = AuthRoutes(userService);
    final categoryRoutes = CategoryRoutes(categoryService);

    // Create router and mount routes
    final app = Router();
    app.mount('/api/auth/', authRoutes.router);
    app.mount(
        '/api/categories/', categoryRoutes.router); // Mount category routes

    // Create a pipeline with middlewares
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(corsHeaders()) // Add CORS middleware
        .addHandler(app);

    // Start the server
    final server = await io.serve(handler, '0.0.0.0', 8080);
    print('Server running on http://${server.address.host}:${server.port}');

    // Handle application shutdown signals
    ProcessSignal.sigint.watch().listen((_) async {
      print('Shutting down server...');
      await Database.closeConnection(); // Close database connection
      await server.close(); // Stop the server
      print('Server stopped.');
      exit(0);
    });
  } catch (e) {
    print('Failed to start the server: $e');
    exit(1);
  }
}
