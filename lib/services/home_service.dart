import 'package:mysql1/mysql1.dart';

class HomeService {
  final MySqlConnection connection;

  HomeService(this.connection);

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
}
