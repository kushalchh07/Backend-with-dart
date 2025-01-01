import 'package:mysql1/mysql1.dart';

import '../models/product_category_model.dart';

class ProductService {
  final MySqlConnection connection;

  ProductService(this.connection);

  // Add a new product under a category
  Future<Product> addProduct(Product product) async {
    final result = await connection.query(
      'INSERT INTO categorized_products (product_name, product_description, product_thumbnail, normal_price, sell_price, total_product_count, category_id, category_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        product.productName,
        product.productDescription,
        product.productThumbnail,
        product.normalPrice,
        product.sellPrice,
        product.totalProductCount,
        product.categoryId,
        product.categoryName,
      ],
    );

    return Product(
      productId: result.insertId,
      productName: product.productName,
      productDescription: product.productDescription,
      productThumbnail: product.productThumbnail,
      normalPrice: product.normalPrice,
      sellPrice: product.sellPrice,
      totalProductCount: product.totalProductCount,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
    );
  }

  // Retrieve all products for a specific category by categoryId
  Future<List<Product>> getProductsByCategoryId(int categoryId) async {
    final results = await connection.query(
      'SELECT * FROM categorized_products WHERE category_id = ?',
      [categoryId],
    );
    return results.map((row) => Product.fromMap(row.fields)).toList();
  }

  // Get a single product by ID
  Future<Product?> getProductById(int productId) async {
    final results = await connection.query(
      'SELECT * FROM categorized_products WHERE product_id = ?',
      [productId],
    );

    if (results.isEmpty) {
      return null;
    }

    return Product.fromMap(results.first.fields);
  }
}
