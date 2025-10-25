import 'package:dio/dio.dart';
import '../../../core/env.dart';
import '../../books/data/models/book_category.dart';

class BookCategoryApiClient {
  final Dio _dio;

  BookCategoryApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  /// Get all categories
  Future<List<BookCategory>> getCategories({String? token}) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await _dio.get('/book-categories', options: options);

      if (response.statusCode == 200) {
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
  Future<BookCategory?> getCategoryById(String id, {String? token}) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final response = await _dio.get('/book-categories/$id', options: options);

      if (response.statusCode == 200) {
        return BookCategory.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      print('Get category error: $e');
      rethrow;
    }
  }

  /// Create category
  Future<BookCategory> createCategory(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        '/book-categories',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return BookCategory.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to create category');
    } catch (e) {
      print('Create category error: $e');
      rethrow;
    }
  }

  /// Update category
  Future<BookCategory> updateCategory(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await _dio.put(
        '/book-categories/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return BookCategory.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to update category');
    } catch (e) {
      print('Update category error: $e');
      rethrow;
    }
  }

  /// Delete category
  Future<void> deleteCategory(String id, String token) async {
    try {
      final response = await _dio.delete(
        '/book-categories/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to delete category',
        );
      }
    } catch (e) {
      print('Delete category error: $e');
      rethrow;
    }
  }

  /// Reorder categories
  Future<void> reorderCategories(List<String> categoryIds, String token) async {
    try {
      final response = await _dio.post(
        '/book-categories/reorder',
        data: {'categoryIds': categoryIds},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Failed to reorder categories',
        );
      }
    } catch (e) {
      print('Reorder categories error: $e');
      rethrow;
    }
  }
}
