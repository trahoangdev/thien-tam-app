import 'package:dio/dio.dart';
import '../../../core/env.dart';
import '../../books/data/models/book.dart';

class BookApiClient {
  final Dio _dio;

  BookApiClient(this._dio);

  // Get all books (Admin view with pagination and filters)
  Future<Map<String, dynamic>> getAllBooks({
    String? category,
    String? search,
    String? bookLanguage,
    bool? isPublic,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (category != null) queryParams['category'] = category;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (bookLanguage != null) queryParams['bookLanguage'] = bookLanguage;
      if (isPublic != null) queryParams['isPublic'] = isPublic;

      final response = await _dio.get(
        '${Env.apiBaseUrl}/books',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch books');
    }
  }

  // Get book by ID
  Future<Book> getBookById(String id, {required String token}) async {
    try {
      final response = await _dio.get(
        '${Env.apiBaseUrl}/books/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Book.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch book');
    }
  }

  // Delete book
  Future<void> deleteBook(String id, {required String token}) async {
    try {
      await _dio.delete(
        '${Env.apiBaseUrl}/books/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete book');
    }
  }

  // Update book
  Future<Book> updateBook({
    required String id,
    String? title,
    String? author,
    String? translator,
    String? description,
    String? category,
    String? bookLanguage,
    List<String>? tags,
    int? pageCount,
    bool? isPublic,
    required String token,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (title != null) data['title'] = title;
      if (author != null) data['author'] = author;
      if (translator != null) data['translator'] = translator;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;
      if (bookLanguage != null) data['bookLanguage'] = bookLanguage;
      if (tags != null) data['tags'] = tags;
      if (pageCount != null) data['pageCount'] = pageCount;
      if (isPublic != null) data['isPublic'] = isPublic;

      final response = await _dio.put(
        '${Env.apiBaseUrl}/books/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Book.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update book');
    }
  }

  // Upload book (PDF + cover image)
  Future<Book> uploadBook({
    required String pdfPath,
    String? coverPath,
    required String title,
    required String category,
    String? author,
    String? translator,
    String? description,
    String? bookLanguage,
    List<String>? tags,
    int? pageCount,
    bool isPublic = true,
    required String token,
    Function(double)? onProgress,
  }) async {
    try {
      final formData = FormData();

      // Add PDF file
      formData.files.add(
        MapEntry(
          'pdf',
          await MultipartFile.fromFile(
            pdfPath,
            filename: pdfPath.split('/').last,
          ),
        ),
      );

      // Add cover image if provided
      if (coverPath != null) {
        formData.files.add(
          MapEntry(
            'cover',
            await MultipartFile.fromFile(
              coverPath,
              filename: coverPath.split('/').last,
            ),
          ),
        );
      }

      // Add other fields
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('category', category),
        if (author != null) MapEntry('author', author),
        if (translator != null) MapEntry('translator', translator),
        if (description != null) MapEntry('description', description),
        MapEntry('bookLanguage', bookLanguage ?? 'vi'),
        if (tags != null) MapEntry('tags', tags.join(',')),
        if (pageCount != null) MapEntry('pageCount', pageCount.toString()),
        MapEntry('isPublic', isPublic.toString()),
      ]);

      final response = await _dio.post(
        '${Env.apiBaseUrl}/books/upload',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
        onSendProgress: onProgress != null
            ? (sent, total) {
                onProgress(sent / total);
              }
            : null,
      );

      return Book.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to upload book');
    }
  }

  // Create book from URL
  Future<Book> createBookFromUrl({
    required String cloudinaryUrl,
    String? coverImageUrl,
    required String title,
    required String category,
    String? author,
    String? translator,
    String? description,
    String? bookLanguage,
    List<String>? tags,
    int? pageCount,
    int? fileSize,
    bool isPublic = true,
    required String token,
  }) async {
    try {
      final data = <String, dynamic>{
        'pdfUrl':
            cloudinaryUrl, // Backend expects 'pdfUrl', not 'cloudinaryUrl'
        'title': title,
        'category': category,
        'isPublic': isPublic,
        'bookLanguage': bookLanguage ?? 'vi',
      };

      if (coverImageUrl != null) data['coverImageUrl'] = coverImageUrl;
      if (author != null) data['author'] = author;
      if (translator != null) data['translator'] = translator;
      if (description != null) data['description'] = description;
      if (tags != null) data['tags'] = tags;
      if (pageCount != null) data['pageCount'] = pageCount;
      if (fileSize != null) data['fileSize'] = fileSize;

      final response = await _dio.post(
        '${Env.apiBaseUrl}/books/from-url',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Book.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create book from URL',
      );
    }
  }
}
