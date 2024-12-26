import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import '../lib/routes/user_routes.dart';

void main() async {
  final app = Router();

  app.mount('/api', UserRoutes().router);

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await io.serve(handler, 'localhost', 8080);

  print('Server running on http://${server.address.host}:${server.port}');
}
