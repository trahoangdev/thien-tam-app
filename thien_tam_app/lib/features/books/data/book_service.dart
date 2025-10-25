import 'package:dio/dio.dart';
import '../../../core/env.dart';
import 'models/book.dart';

class BookService {
  final Dio _dio;

  BookService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Env.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  /// Get all books with filters
  Future<Map<String, dynamic>> getBooks({
    String? category,
    String? search,
    String? bookLanguage,
    bool? isPublic,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (bookLanguage != null && bookLanguage.isNotEmpty) {
        queryParams['bookLanguage'] = bookLanguage;
      }
      if (isPublic != null) {
        queryParams['isPublic'] = isPublic;
      }

      final response = await _dio.get('/books', queryParameters: queryParams);

      // Ensure response.data is a Map
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format from server');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  /// Get book by ID
  Future<Book> getBookById(String id) async {
    try {
      final response = await _dio.get('/books/$id');
      return Book.fromJson(response.data['book']);
    } catch (e) {
      throw Exception('Failed to fetch book: $e');
    }
  }

  /// Get book categories
  Future<List<BookCategory>> getCategories() async {
    try {
      final response = await _dio.get('/books/categories');
      final List<dynamic> data = response.data['categories'];
      return data.map((c) => BookCategory.fromJson(c)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get popular books
  Future<List<Book>> getPopularBooks({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/books/popular',
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data['books'];
      return data.map((b) => Book.fromJson(b)).toList();
    } catch (e) {
      throw Exception('Failed to fetch popular books: $e');
    }
  }

  /// Increment download count
  Future<void> incrementDownloadCount(String id) async {
    try {
      await _dio.post('/books/$id/download');
    } catch (e) {
      // Ignore error, not critical
      print('Failed to increment download count: $e');
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String id) async {
    try {
      await _dio.post('/books/$id/view');
    } catch (e) {
      // Ignore error, not critical
      print('Failed to increment view count: $e');
    }
  }
}
