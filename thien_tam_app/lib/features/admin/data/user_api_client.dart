import 'package:dio/dio.dart';
import '../../../core/env.dart';
import '../../auth/data/models/user.dart';

class UserApiClient {
  final Dio _dio;

  UserApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Env.apiBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  /// Get all users (Admin only)
  Future<Map<String, dynamic>> getAllUsers({
    String? role,
    String? search,
    bool? isActive,
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

      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (isActive != null) {
        queryParams['isActive'] = isActive;
      }

      final response = await _dio.get(
        '/admin/users',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch users');
      }
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Get user by ID
  Future<User> getUserById(String id, {required String token}) async {
    try {
      final response = await _dio.get(
        '/admin/users/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return User.fromJson(response.data['user']);
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch user');
      }
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// Update user role
  Future<User> updateUserRole({
    required String id,
    required String role,
    required String token,
  }) async {
    try {
      final response = await _dio.put(
        '/admin/users/$id/role',
        data: {'role': role},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return User.fromJson(response.data['user']);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update user role',
        );
      }
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Update user active status
  Future<User> updateUserStatus({
    required String id,
    required bool isActive,
    required String token,
  }) async {
    try {
      final response = await _dio.put(
        '/admin/users/$id/status',
        data: {'isActive': isActive},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return User.fromJson(response.data['user']);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to update user status',
        );
      }
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Create new user
  Future<User> createUser({
    required String name,
    required String email,
    required String password,
    bool isActive = true,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/admin/users',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'isActive': isActive,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return User.fromJson(response.data['user']);
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create user');
      }
      throw Exception('Failed to create user: $e');
    }
  }

  /// Update user
  Future<User> updateUser({
    required String id,
    String? name,
    String? email,
    String? password,
    bool? isActive,
    required String token,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (password != null && password.isNotEmpty) data['password'] = password;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _dio.put(
        '/admin/users/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return User.fromJson(response.data['user']);
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update user');
      }
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(String id, {required String token}) async {
    try {
      await _dio.delete(
        '/admin/users/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete user');
      }
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats({required String token}) async {
    try {
      final response = await _dio.get(
        '/admin/users/stats',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch user stats',
        );
      }
      throw Exception('Failed to fetch user stats: $e');
    }
  }
}
