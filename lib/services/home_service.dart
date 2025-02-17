import 'package:mysql1/mysql1.dart';
import 'package:pranshal_cms/services/product_service.dart';

class HomeService {
  final MySqlConnection connection;

  HomeService(this.connection, this.productService);
  ProductService productService;
  // Fetch categories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final categories = await connection.query('SELECT * FROM categories');
    return categories
        .map((category) => {
              'category_id': category['category_id'],
              'category_name': category['category_name'],
              'category_description': category['category_description'],
              'category_thumbnail': category['category_thumbnail'],
            })
        .toList();
  }

  // Fetch brands
  Future<List<Map<String, dynamic>>> fetchBrands() async {
    final brands = await connection.query('SELECT * FROM brands');
    return brands
        .map((brand) => {
              'brand_id': brand['brand_id'],
              'brand_name': brand['brand_name'],
              'brand_thumbnail': brand['brand_thumbnail'],
              'brand_description': brand['brand_description'],
            })
        .toList();
  }

  // Fetch products
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final products = await connection.query('SELECT * FROM products');
    return products
        .map((product) => {
              'product_id': product['product_id'],
              'category_id': product['category_id'],
              'brand_id': product['brand_id'],
              'product_name': product['product_name'],
              'category_name': product['category_name'],
              'brand_name': product['brand_name'],
              'product_description': product['product_description'],
              'product_thumbnail': product['product_thumbnail'],
              'normal_price': product['normal_price'],
              'sell_price': product['sell_price'],
              'total_product_count': product['total_product_count'],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchflashsaleProducts() async {
    final products =
        await connection.query('SELECT * FROM flash_sale_products');
    return products
        .map((product) => {
              'product_id': product['product_id'],
              'category_id': product['category_id'],
              'brand_id': product['brand_id'],
              'product_name': product['product_name'],
              'category_name': product['category_name'],
              'brand_name': product['brand_name'],
              'product_description': product['product_description'],
              'product_thumbnail': product['product_thumbnail'],
              'normal_price': product['normal_price'],
              'sell_price': product['sell_price'],
              'total_product_count': product['total_product_count'],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchRecommendedProducts(
      String userId) async {
    try {
      final int id = int.parse(userId);
      print("Fetching recommendations for User ID: $id");

      // Step 1: Get Recently Viewed Product IDs
      final viewedResults = await connection.query(
          'SELECT product_id FROM user_activity WHERE user_id = ? AND action_type = "view" ORDER BY timestamp DESC LIMIT 5',
          [id]);

      List<int> productIds =
          viewedResults.map((row) => row['product_id'] as int).toList();
      print("Recently Viewed Products: $productIds");

      List<Map<String, dynamic>> recommendedProducts = [];

      if (productIds.isEmpty) {
        // No viewing history? Return trending products instead
        print("User has no history, returning trending products.");
        recommendedProducts = await productService.getTrendingProducts();
      } else {
        // Step 2: Get Categories of Viewed Products
        String placeholders = List.filled(productIds.length, '?').join(',');
        final categoryResults = await connection.query(
            'SELECT DISTINCT category_id FROM products WHERE product_id IN ($placeholders)',
            productIds);

        List<int> categoryIds =
            categoryResults.map((row) => row['category_id'] as int).toList();
        print("Related Categories: $categoryIds");

        if (categoryIds.isNotEmpty) {
          // Step 3: Get Products from Those Categories
          String categoryPlaceholders =
              List.filled(categoryIds.length, '?').join(',');
          final recommendedResults = await connection.query(
              'SELECT * FROM products WHERE category_id IN ($categoryPlaceholders) LIMIT 10',
              categoryIds);

          recommendedProducts = recommendedResults.map((row) {
            final fields = Map<String, dynamic>.from(row.fields);

            // Convert all DateTime fields to String
            fields.forEach((key, value) {
              if (value is DateTime) {
                fields[key] = value.toIso8601String();
              }
            });

            return fields;
          }).toList();
        }
      }

      print("Recommended Products: ${recommendedProducts.length}");
      return recommendedProducts;
    } catch (e) {
      print("Error fetching recommendations: $e");
      return [];
    }
  }

  Future<void> logUserActivity(
      int userId, int productId, String actionType) async {
    await connection.query(
        'INSERT INTO user_activity (user_id, product_id, action_type) VALUES (?, ?, ?)',
        [userId, productId, actionType]);
  }
}
