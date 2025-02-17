import 'package:mysql1/mysql1.dart';
import '../models/order_model.dart';

class OrderService {
  final MySqlConnection connection;

  OrderService(this.connection);
  Future<int> placeSingleOrder(Order order, List<OrderItem> items) async {
    try {
      await connection.transaction((txn) async {
        // Insert into orders table
        var orderResult = await txn.query(
          'INSERT INTO orders (user_id, total_amount) VALUES (?, ?)',
          [order.userId, order.totalAmount],
        );
        int orderId = orderResult.insertId!;

        // Insert into order_items table
        for (var item in items) {
          await txn.query(
            'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
            [orderId, item.productId, item.quantity, item.price],
          );
        }
      });
      return 1; // Success
    } catch (e) {
      print("Order placement failed: $e");
      return 0; // Failure
    }
  }

// ✅ Place an Order with a Custom List of Products
  Future<bool> placeCustomOrder(
      int userId, List<Map<String, dynamic>> products) async {
    try {
      double totalAmount = 0;
      List<Map<String, dynamic>> orderItems = [];

      for (var item in products) {
        int productId = item['product_id'];
        int quantity = item['quantity'];

        // Fetch product price
        var result = await connection.query(
            "SELECT sell_price FROM products WHERE product_id = ?",
            [productId]);

        if (result.isEmpty) {
          print("Product with ID $productId not found!");
          return false;
        }

        double price = result.first['sell_price'];
        double totalPrice = price * quantity;
        totalAmount += totalPrice;

        orderItems.add({
          'product_id': productId,
          'quantity': quantity,
          'price': price,
          'total_price': totalPrice
        });
      }

      // Insert into orders table
      var orderResult = await connection.query(
          "INSERT INTO orders (user_id, total_amount) VALUES (?, ?)",
          [userId, totalAmount]);

      int orderId = orderResult.insertId!;

      // Insert all order items
      for (var item in orderItems) {
        await connection.query(
            "INSERT INTO order_items (order_id, product_id, quantity, price, total_price) VALUES (?, ?, ?, ?, ?)",
            [
              orderId,
              item['product_id'],
              item['quantity'],
              item['price'],
              item['total_price']
            ]);
      }

      print("Custom order placed successfully!");
      return true;
    } catch (e) {
      print("Error placing custom order: $e");
      return false;
    }
  }

  Future<int> placeCartOrder(int userId) async {
    try {
      print("Placing order for user: $userId");

      // Fetch cart items
      var cartResults = await connection.query(
        'SELECT product_id, quantity, sell_price FROM cart WHERE user_id = ?',
        [userId],
      );

      if (cartResults.isEmpty) {
        print("No cart items for user: $userId");
        return 0; // No cart items
      }

      double totalAmount = 0;
      List<OrderItem> orderItems = [];

      print("Fetching products in the cart for user: $userId");
      for (var row in cartResults) {
        int productId = row['product_id'];
        int quantity = row['quantity'];
        double price = row['sell_price'];

        totalAmount += quantity * price;

        orderItems.add(OrderItem(
          orderId: 0,
          productId: productId,
          quantity: quantity,
          price: price,
        ));
      }

      print("Inserting into orders table for user: $userId");
      // Insert into orders table
      var orderResult = await connection.query(
        'INSERT INTO orders (user_id, total_amount) VALUES (?, ?)',
        [userId, totalAmount],
      );
      int orderId = orderResult.insertId!;

      print("Inserting into order_items table for user: $userId");
      // Insert into order_items table
      for (var item in orderItems) {
        await connection.query(
          'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
          [orderId, item.productId, item.quantity, item.price],
        );
      }

      print("Clearing the cart after order placement for user: $userId");
      // Clear the cart after order placement
      await connection.query('DELETE FROM cart WHERE user_id = ?', [userId]);

      print("Order placement from cart successful for user: $userId");
      return 1; // Success
    } catch (e) {
      print("Order placement from cart failed for user: $userId, error: $e");
      return 0; // Failure
    }
  }

  Future<List<Order>> getUserOrders(int userId) async {
    var results = await connection.query(
      'SELECT * FROM orders WHERE user_id = ? ORDER BY order_date DESC',
      [userId],
    );

    return results.map((row) => Order.fromMap(row.fields)).toList();
  }

  Future<List<OrderItem>> getOrderDetails(int orderId) async {
    var results = await connection.query(
      'SELECT * FROM order_items WHERE order_id = ?',
      [orderId],
    );

    return results.map((row) => OrderItem.fromMap(row.fields)).toList();
  }
}
