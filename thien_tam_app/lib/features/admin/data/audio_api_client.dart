import 'package:dio/dio.dart';
import '../../../core/env.dart';
import '../../audio/data/models/audio.dart';

class AudioApiClient {
  final Dio _dio;

  AudioApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Env.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  /// Get all audios with filters (Admin view)
  Future<Map<String, dynamic>> getAllAudios({
    String? category,
    String? search,
    bool? isPublic,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    String? token,
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
      if (isPublic != null) {
        queryParams['isPublic'] = isPublic;
      }

      final response = await _dio.get(
        '/audio',
        queryParameters: queryParams,
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch audios: $e');
    }
  }

  /// Get audio by ID
  Future<Audio> getAudioById(String id, {String? token}) async {
    try {
      final response = await _dio.get(
        '/audio/$id',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      return Audio.fromJson(response.data['audio']);
    } catch (e) {
      throw Exception('Failed to fetch audio: $e');
    }
  }

  /// Upload audio file
  Future<Audio> uploadAudio({
    required String filePath,
    required String title,
    required String category,
    String? description,
    String? artist,
    List<String>? tags,
    bool isPublic = true,
    required String token,
    void Function(int, int)? onUploadProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'title': title,
        'category': category,
        if (description != null) 'description': description,
        if (artist != null) 'artist': artist,
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
        'isPublic': isPublic.toString(),
      });

      final response = await _dio.post(
        '/audio/upload',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
        onSendProgress: onUploadProgress,
      );

      return Audio.fromJson(response.data['audio']);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to upload audio',
        );
      }
      throw Exception('Failed to upload audio: $e');
    }
  }

  /// Create audio from Cloudinary URL
  Future<Audio> createAudioFromUrl({
    required String cloudinaryUrl,
    required String title,
    required String category,
    String? description,
    String? artist,
    List<String>? tags,
    int? duration,
    int? fileSize,
    String? format,
    bool isPublic = true,
    required String token,
  }) async {
    try {
      final data = <String, dynamic>{
        'cloudinaryUrl': cloudinaryUrl,
        'title': title,
        'category': category,
        if (description != null) 'description': description,
        if (artist != null) 'artist': artist,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        if (duration != null) 'duration': duration,
        if (fileSize != null) 'fileSize': fileSize,
        if (format != null) 'format': format,
        'isPublic': isPublic,
      };

      final response = await _dio.post(
        '/audio/from-url',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Audio.fromJson(response.data['audio']);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to create audio from URL',
        );
      }
      throw Exception('Failed to create audio from URL: $e');
    }
  }

  /// Update audio metadata
  Future<Audio> updateAudio({
    required String id,
    String? title,
    String? description,
    String? artist,
    String? category,
    List<String>? tags,
    bool? isPublic,
    required String token,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (artist != null) data['artist'] = artist;
      if (category != null) data['category'] = category;
      if (tags != null) data['tags'] = tags;
      if (isPublic != null) data['isPublic'] = isPublic;

      final response = await _dio.put(
        '/audio/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Audio.fromJson(response.data['audio']);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update audio',
        );
      }
      throw Exception('Failed to update audio: $e');
    }
  }

  /// Delete audio
  Future<void> deleteAudio(String id, {required String token}) async {
    try {
      await _dio.delete(
        '/audio/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to delete audio',
        );
      }
      throw Exception('Failed to delete audio: $e');
    }
  }

  /// Get audio categories
  Future<List<AudioCategory>> getCategories() async {
    try {
      final response = await _dio.get('/audio/categories');
      final List<dynamic> data = response.data['categories'];
      return data.map((c) => AudioCategory.fromJson(c)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get popular audios
  Future<List<Audio>> getPopularAudios({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/audio/popular',
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data['audios'];
      return data.map((a) => Audio.fromJson(a)).toList();
    } catch (e) {
      throw Exception('Failed to fetch popular audios: $e');
    }
  }
}
