import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/home_service.dart';

class HomeRoutes {
  final HomeService homeService;

  HomeRoutes(this.homeService);

  Router get router {
    final router = Router();

    router.get('/home', (Request request) async {
      try {
        // Fetch data using the HomeService
        final categories = await homeService.fetchCategories();
        final brands = await homeService.fetchBrands();
        final products = await homeService.fetchProducts();
        final flashSaleProducts = await homeService.fetchflashsaleProducts();
        // Combine data into a single response
        return Response.ok(
          jsonEncode({
            'status': true,
            'categories': categories,
            'brands': brands,
            'products': products,
            'flashSaleProducts': flashSaleProducts,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({
            'status': false,
            'message': 'Failed to fetch data: ${e.toString()}',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}
