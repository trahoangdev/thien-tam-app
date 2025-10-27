import 'package:dio/dio.dart';
import '../../../core/config.dart';
import 'models/book_category.dart';

class BookCategoryService {
  final Dio _dio;

  BookCategoryService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  /// Get all book categories
  Future<List<BookCategory>> getCategories({bool? isActive}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isActive != null) {
        queryParams['isActive'] = isActive.toString();
      }

      final response = await _dio.get(
        '/book-categories',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => BookCategory.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Get categories error: $e');
      rethrow;
    }
  }

  /// Get category by ID
  Future<BookCategory?> getCategoryById(String id) async {
    try {
      final response = await _dio.get('/book-categories/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return BookCategory.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      print('Get category by ID error: $e');
      rethrow;
    }
  }

  /// Create new category (Admin only)
  Future<BookCategory?> createCategory(
    BookCategory category,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        '/book-categories',
        data: category.toCreateJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return BookCategory.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      print('Create category error: $e');
      rethrow;
    }
  }

  /// Update category (Admin only)
  Future<BookCategory?> updateCategory(
    String id,
    Map<String, dynamic> updates,
    String token,
  ) async {
    try {
      final response = await _dio.put(
        '/book-categories/$id',
        data: updates,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return BookCategory.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      print('Update category error: $e');
      rethrow;
    }
  }

  /// Delete category (Admin only)
  Future<bool> deleteCategory(String id, String token) async {
    try {
      final response = await _dio.delete(
        '/book-categories/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Delete category error: $e');
      rethrow;
    }
  }

  /// Reorder categories (Admin only)
  Future<bool> reorderCategories(List<String> categoryIds, String token) async {
    try {
      final response = await _dio.post(
        '/book-categories/reorder',
        data: {'categoryIds': categoryIds},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Reorder categories error: $e');
      rethrow;
    }
  }
}
