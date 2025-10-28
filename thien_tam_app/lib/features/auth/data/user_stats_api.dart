import 'package:dio/dio.dart';
import '../../../core/config.dart';

class UserStatsApi {
  final Dio _dio;

  UserStatsApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: '${AppConfig.apiBaseUrl}/user-auth',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  /// Get current user stats
  Future<Map<String, dynamic>> getMyStats(String token) async {
    try {
      final response = await _dio.get(
        '/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['user'] != null &&
          response.data['user']['stats'] != null) {
        return response.data['user']['stats'] as Map<String, dynamic>;
      }

      // Return default stats if null
      return {
        'totalReadings': 0,
        'totalReadingTime': 0,
        'streakDays': 0,
        'longestStreak': 0,
        'favoriteTopics': [],
        'readingHistory': [],
      };
    } on DioException catch (e) {
      print('[UserStatsApi] Error getting stats: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get user stats',
      );
    }
  }

  /// Update user reading stats
  Future<Map<String, dynamic>> updateReadingStats({
    required String token,
    required String readingId,
    required int timeSpent,
  }) async {
    try {
      final response = await _dio.post(
        '/reading-stats',
        data: {'readingId': readingId, 'timeSpent': timeSpent},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['stats'] != null) {
        return response.data['stats'] as Map<String, dynamic>;
      }

      return response.data;
    } on DioException catch (e) {
      print('[UserStatsApi] Error updating stats: ${e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update reading stats',
      );
    }
  }
}
