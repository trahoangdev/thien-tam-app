import 'package:dio/dio.dart';
import 'models/auth_response.dart';
import 'models/login_request.dart';
import 'models/reading_create_request.dart';
import 'models/reading_update_request.dart';
import '../../readings/data/models/reading.dart';

class AdminApiClient {
  final Dio _dio;
  final String baseUrl;

  AdminApiClient({required this.baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  String? _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _authHeaders {
    if (_accessToken == null) {
      throw Exception('Not authenticated. Please login first.');
    }
    return {'Authorization': 'Bearer $_accessToken'};
  }

  // ========== Auth Endpoints ==========

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh': refreshToken},
      );
      return response.data['access'] as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Admin CRUD Endpoints ==========

  Future<Map<String, dynamic>> getReadings({
    int page = 1,
    int limit = 20,
    String? topic,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (topic != null) queryParams['topic'] = topic;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/admin/readings',
        queryParameters: queryParams,
        options: Options(headers: _authHeaders),
      );

      return {
        'items': (response.data['items'] as List)
            .map((e) => Reading.fromJson(e))
            .toList(),
        'total': response.data['total'] as int,
        'page': response.data['page'] as int,
        'pages': response.data['pages'] as int,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Reading> getReadingById(String id) async {
    try {
      final response = await _dio.get(
        '/admin/readings/$id',
        options: Options(headers: _authHeaders),
      );
      return Reading.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Reading> createReading(ReadingCreateRequest request) async {
    try {
      final payload = request.toJson();
      print('📤 Creating reading - Payload: $payload');

      final response = await _dio.post(
        '/admin/readings',
        data: payload,
        options: Options(headers: _authHeaders),
      );

      print('✅ Create response: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      return Reading.fromJson(response.data['reading']);
    } on DioException catch (e) {
      print(
        '❌ Create reading error: ${e.response?.statusCode} - ${e.response?.data}',
      );
      throw _handleError(e);
    }
  }

  Future<Reading> updateReading(String id, ReadingUpdateRequest request) async {
    try {
      final response = await _dio.put(
        '/admin/readings/$id',
        data: request.toJson(),
        options: Options(headers: _authHeaders),
      );
      return Reading.fromJson(response.data['reading']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteReading(String id) async {
    try {
      await _dio.delete(
        '/admin/readings/$id',
        options: Options(headers: _authHeaders),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get(
        '/admin/stats',
        options: Options(headers: _authHeaders),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Error Handling ==========

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      final message = data is Map
          ? data['message'] ?? 'Unknown error'
          : 'Unknown error';
      return Exception('API Error: $message');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}
