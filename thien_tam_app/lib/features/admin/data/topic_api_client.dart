import 'package:dio/dio.dart';
import 'models/topic.dart';
import '../../../core/config.dart';

class TopicApiClient {
  final Dio _dio;
  String? _accessToken;

  TopicApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _authHeaders {
    if (_accessToken == null) {
      throw Exception('Not authenticated. Please login first.');
    }
    return {'Authorization': 'Bearer $_accessToken'};
  }

  // GET /admin/topics - Get all topics with pagination and search
  Future<Map<String, dynamic>> getTopics({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final res = await _dio.get(
      '/admin/topics',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      options: Options(headers: _authHeaders),
    );
    return res.data;
  }

  // GET /admin/topics/:id - Get a single topic by ID
  Future<Topic> getTopic(String id) async {
    final res = await _dio.get(
      '/admin/topics/$id',
      options: Options(headers: _authHeaders),
    );
    return Topic.fromJson(res.data);
  }

  // POST /admin/topics - Create a new topic
  Future<Map<String, dynamic>> createTopic({
    required String slug,
    required String name,
    String? description,
    String? color,
    String? icon,
    int? sortOrder,
  }) async {
    final res = await _dio.post(
      '/admin/topics',
      data: {
        'slug': slug,
        'name': name,
        if (description != null) 'description': description,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
        if (sortOrder != null) 'sortOrder': sortOrder,
      },
      options: Options(headers: _authHeaders),
    );
    return res.data;
  }

  // PUT /admin/topics/:id - Update an existing topic
  Future<Map<String, dynamic>> updateTopic({
    required String id,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    int? sortOrder,
  }) async {
    final res = await _dio.put(
      '/admin/topics/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
        if (isActive != null) 'isActive': isActive,
        if (sortOrder != null) 'sortOrder': sortOrder,
      },
      options: Options(headers: _authHeaders),
    );
    return res.data;
  }

  // DELETE /admin/topics/:id - Delete a topic
  Future<Map<String, dynamic>> deleteTopic(String id) async {
    final res = await _dio.delete(
      '/admin/topics/$id',
      options: Options(headers: _authHeaders),
    );
    return res.data;
  }

  // GET /admin/topics/stats - Get topic statistics
  Future<Map<String, dynamic>> getTopicStats() async {
    final res = await _dio.get(
      '/admin/topics/stats',
      options: Options(headers: _authHeaders),
    );
    return res.data;
  }
}
