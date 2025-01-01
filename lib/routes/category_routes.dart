import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/categories_model.dart';
import '../services/category_service.dart';

class CategoryRoutes {
  final CategoryService categoryService;

  CategoryRoutes(this.categoryService);

  Router get router {
    final router = Router();

    // Add a new category
    router.post('/add', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final category = Category(
          categoryName: data['category_name'],
          categoryThumbnail: data['category_thumbnail'], // Can be null
          categoryDescription: data['category_description'], // Can be null
        );

        final addedCategory = await categoryService.addCategory(category);

        return Response.ok(jsonEncode({
          'status': true,
          'message': 'Category added successfully',
          'category': addedCategory.toMap(),
        }));
      } catch (e) {
        return Response(500, body: jsonEncode({
          'status': false,
          'message': 'Failed to add category: ${e.toString()}',
        }));
      }
    });

    // Retrieve all categories
    router.get('/all', (Request request) async {
      try {
        final categories = await categoryService.getAllCategories();
        return Response.ok(jsonEncode({
          'status': true,
          'categories': categories.map((cat) => cat.toMap()).toList(),
        }));
      } catch (e) {
        return Response(500, body: jsonEncode({
          'status': false,
          'message': 'Failed to fetch categories: ${e.toString()}',
        }));
      }
    });

    // Retrieve a single category by ID
    router.get('/<id|[0-9]+>', (Request request, String id) async {
      try {
        final categoryId = int.parse(id);
        final category = await categoryService.getCategoryById(categoryId);

        if (category == null) {
          return Response(404, body: jsonEncode({
            'status': false,
            'message': 'Category not found',
          }));
        }

        return Response.ok(jsonEncode({
          'status': true,
          'category': category.toMap(),
        }));
      } catch (e) {
        return Response(500, body: jsonEncode({
          'status': false,
          'message': 'Failed to fetch category: ${e.toString()}',
        }));
      }
    });

    return router;
  }
}
