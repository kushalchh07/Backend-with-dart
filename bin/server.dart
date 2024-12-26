import 'package:pranshal_cms/routes/user_routes.dart';
import 'package:pranshal_cms/services/user_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';

Future<MySqlConnection> createConnection() async {
  // Create a connection to your MySQL database
  final settings = ConnectionSettings(
    host: 'localhost', // MySQL server address
    port: 3306, // MySQL default port
    user: 'root', // Your MySQL username
    password: 'pranita', // Your MySQL password
    db: 'pranshal_ecommerce', // Your MySQL database name
  );

  return await MySqlConnection.connect(settings);
}

Future<void> main() async {
  // Create the connection to the MySQL database
  final conn = await createConnection();

  // Create the UserService instance and pass the connection
  final userService = UserService(conn);

  // Initialize authentication routes with the userService
  final authRoutes = AuthRoutes(userService);

  // Create the app router and mount the routes
  final app = Router();
  app.mount('/api/auth/', authRoutes.router);

  // Create and configure the handler
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  // Start the server on localhost at port 8080
  final server = await io.serve(handler, 'localhost', 8080);

  print('Server running on http://${server.address.host}:${server.port}');
}
