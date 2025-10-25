import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config.dart';
import 'models/audio.dart';

class AudioService {
  final String baseUrl = AppConfig.apiBaseUrl;

  /// Get all audios with filters
  Future<List<Audio>> getAudios({
    String? category,
    List<String>? tags,
    String? search,
    bool? isPublic,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (category != null) queryParams['category'] = category;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isPublic != null) queryParams['isPublic'] = isPublic.toString();

      final uri = Uri.parse(
        '$baseUrl/audio',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final audios = (data['audios'] as List)
            .map((json) => Audio.fromJson(json))
            .toList();
        return audios;
      } else {
        throw Exception('Failed to load audios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading audios: $e');
    }
  }

  /// Get audio by ID
  Future<Audio> getAudioById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/audio/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Audio.fromJson(data['audio']);
      } else {
        throw Exception('Failed to load audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading audio: $e');
    }
  }

  /// Get audio categories
  Future<List<AudioCategory>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/audio/categories'));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final categories = (data['categories'] as List)
            .map((json) => AudioCategory.fromJson(json))
            .toList();
        return categories;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading categories: $e');
    }
  }

  /// Get popular audios
  Future<List<Audio>> getPopularAudios({int limit = 10}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/audio/popular',
      ).replace(queryParameters: {'limit': limit.toString()});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final audios = (data['audios'] as List)
            .map((json) => Audio.fromJson(json))
            .toList();
        return audios;
      } else {
        throw Exception(
          'Failed to load popular audios: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error loading popular audios: $e');
    }
  }

  /// Increment play count
  Future<void> incrementPlayCount(String id) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/audio/$id/play'));

      if (response.statusCode != 200) {
        // Don't throw error, just log
        print('Failed to increment play count: ${response.statusCode}');
      }
    } catch (e) {
      // Don't throw error, just log
      print('Error incrementing play count: $e');
    }
  }
}
