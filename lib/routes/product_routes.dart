import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/products_model.dart';
import '../services/product_service.dart';

class ProductRoutes {
  final ProductService productService;

  ProductRoutes(this.productService);

  Router get router {
    final router = Router();

    // Add a new product
    router.post('/add', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final product = Product(
          categoryId: data['category_id'],
          brandId: data['brand_id'],
          productName: data['product_name'],
          categoryName: data['category_name'],
          brandName: data['brand_name'],
          productDescription: data['product_description'],
          productThumbnail: data['product_thumbnail'],
          normalPrice: data['normal_price'],
          sellPrice: data['sell_price'],
          totalProductCount: data['total_product_count'],
        );
        print('Attempting to add product: $data'); // Log incoming data
        final addedProduct = await productService.addProduct(product);

        return Response.ok(jsonEncode({
          'status': true,
          'message': 'Product added successfully',
          'product': addedProduct.toMap(),
        }));
      } catch (e) {
        print('Error adding product: $e');
        return Response(500,
            body: jsonEncode({
              'status': false,
              'message': 'Failed to add product: ${e.toString()}',
            }));
      }
    });

    // Retrieve all products
    router.get('/all', (Request request) async {
      try {
        final products = await productService.getAllProducts();

        return Response.ok(jsonEncode({
          'status': true,
          'products': products.map((product) => product.toMap()).toList(),
        }));
      } catch (e) {
        return Response(500,
            body: jsonEncode({
              'status': false,
              'message': 'Failed to fetch products: ${e.toString()}',
            }));
      }
    });

    // Retrieve products by category ID
    router.get('/category/<id|[0-9]+>', (Request request, String id) async {
      try {
        final categoryId = int.parse(id);
        final products =
            await productService.getProductsByCategoryId(categoryId);

        return Response.ok(jsonEncode({
          'status': true,
          'products': products.map((product) => product.toMap()).toList(),
        }));
      } catch (e) {
        return Response(500,
            body: jsonEncode({
              'status': false,
              'message': 'Failed to fetch products: ${e.toString()}',
            }));
      }
    });

    // Retrieve products by brand ID
    router.get('/brand/<id|[0-9]+>', (Request request, String id) async {
      try {
        final brandId = int.parse(id);
        final products = await productService.getProductsByBrandId(brandId);

        return Response.ok(jsonEncode({
          'status': true,
          'products': products.map((product) => product.toMap()).toList(),
        }));
      } catch (e) {
        return Response(500,
            body: jsonEncode({
              'status': false,
              'message': 'Failed to fetch products: ${e.toString()}',
            }));
      }
    });
//route to delete product
    router.delete('/delete/<id|[0-9]+>', (Request request, String id) async {
      try {
        final productId = int.parse(id);
        final deleted = await productService.deleteProduct(productId);
        return Response.ok(jsonEncode({
          'status': true,
          'message': 'Product deleted successfully',
          'deleted': deleted,
        }));
      } catch (e) {
        return Response(500,
            body: jsonEncode({
              'status': false,
              'message': 'Failed to delete product: ${e.toString()}',
            }));
      }
    });
    return router;
  }
}
