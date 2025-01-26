import 'package:mysql1/mysql1.dart';
import 'package:pranshal_cms/models/products_model.dart';

class ProductService {
  final MySqlConnection connection;

  ProductService(this.connection);

  // Add a new product to the database
  Future<Product> addProduct(Product product) async {
    final result = await connection.query(
      'INSERT INTO products (category_id, brand_id, product_name, category_name, brand_name, product_description, product_thumbnail, normal_price, sell_price, total_product_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?)',
      [
        product.categoryId,
        product.brandId,
        product.productName,
        product.categoryName,
        product.brandName,
        product.productDescription,
        product.productThumbnail,
        product.normalPrice,
        product.sellPrice,
        product.totalProductCount,
      ],
    );

    return Product(
      productId: result.insertId,
      categoryId: product.categoryId,
      brandId: product.brandId,
      productName: product.productName,
      categoryName: product.categoryName,
      brandName: product.brandName,
      productDescription: product.productDescription,
      productThumbnail: product.productThumbnail,
      normalPrice: product.normalPrice,
      sellPrice: product.sellPrice,
      totalProductCount: product.totalProductCount,
    );
  }

  // Retrieve all products
  Future<List<Product>> getAllProducts() async {
    final results = await connection.query('SELECT * FROM products');
    return results.map((row) => Product.fromMap(row.fields)).toList();
  }

  // Retrieve products by category ID
  Future<List<Product>> getProductsByCategoryId(int categoryId) async {
    final results = await connection.query(
      'SELECT * FROM products WHERE category_id = ?',
      [categoryId],
    );
    return results.map((row) => Product.fromMap(row.fields)).toList();
  }

  // Retrieve products by brand ID
  Future<List<Product>> getProductsByBrandId(int brandId) async {
    final results = await connection.query(
      'SELECT * FROM products WHERE brand_id = ?',
      [brandId],
    );
    return results.map((row) => Product.fromMap(row.fields)).toList();
  }
}
