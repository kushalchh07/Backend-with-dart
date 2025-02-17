import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/order_service.dart';
import '../models/order_model.dart';

class OrderRoutes {
  final OrderService orderService;

  OrderRoutes(this.orderService);

  Router get router {
    final router = Router();

    // Place a single order
    router.post('/place', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final order = Order(
          userId: data['user_id'],
          totalAmount:
              (data['total_amount'] ?? 0).toDouble(), // Prevent null issue
        );

        final items = (data['items'] != null && data['items'] is List)
            ? List<Map<String, dynamic>>.from(data['items'])
            : [];

        final orderItems = items
            .map((item) => OrderItem(
                  orderId: 0,
                  productId: item['product_id'],
                  quantity: item['quantity'],
                  price: item['price'],
                ))
            .toList();

        if (orderItems.isEmpty) {
          return Response(400,
              body: jsonEncode({
                'status': false,
                'message': 'No items provided in the order'
              }));
        }

        final success = await orderService.placeSingleOrder(order, orderItems);

        if (success == 1) {
          return Response.ok(jsonEncode(
              {'status': true, 'message': 'Order placed successfully'}));
        } else {
          return Response(500,
              body: jsonEncode(
                  {'status': false, 'message': 'Order placement failed'}));
        }
      } catch (e) {
        return Response(500,
            body: jsonEncode(
                {'status': false, 'message': 'Error: ${e.toString()}'}));
      }
    });

    // Place order from cart
    router.post('/place-from-cart/<userId>',
        (Request request, String userId) async {
      final success = await orderService.placeCartOrder(int.parse(userId));

      if (success == 1) {
        return Response.ok(jsonEncode({
          'status': true,
          'message': 'Order placed from cart successfully'
        }));
      } else {
        return Response(500,
            body: jsonEncode({
              'status': false,
              'message': 'Failed to place order from cart'
            }));
      }
    });

    // ✅ Place an Order for a Custom List of Products
    router.post('/place-custom', (Request req) async {
      try {
        var body = await req.readAsString();
        var jsonData = jsonDecode(body);

        int userId = jsonData['user_id'];
        List<Map<String, dynamic>> products =
            List<Map<String, dynamic>>.from(jsonData['products']);

        bool success = await orderService.placeCustomOrder(userId, products);

        return Response.ok(jsonEncode({'success': success}));
      } catch (e) {
        return Response.internalServerError(
            body: jsonEncode({'error': e.toString()}));
      }
    });
    return router;
  }
}
