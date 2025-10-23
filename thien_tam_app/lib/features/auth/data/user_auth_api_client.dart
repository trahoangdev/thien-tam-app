import 'package:dio/dio.dart';
import 'models/user.dart';
import '../../../core/config.dart';

class UserAuthApiClient {
  final Dio _dio;
  String? _accessToken;

  UserAuthApiClient()
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

  // POST /user-auth/register - Register new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final res = await _dio.post(
        '/user-auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );
      // Backend returns: { message, user, tokens: { accessToken, refreshToken } }
      return AuthResponse(
        message: res.data['message'] ?? '',
        user: User.fromJson(res.data['user']),
        tokens: AuthTokens(
          accessToken: res.data['tokens']['accessToken'],
          refreshToken: res.data['tokens']['refreshToken'],
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Đăng ký thất bại';
      throw Exception(message);
    }
  }

  // POST /user-auth/login - Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/user-auth/login',
        data: {'email': email, 'password': password},
      );
      // Backend returns: { message, user, tokens: { accessToken, refreshToken } }
      return AuthResponse(
        message: res.data['message'] ?? '',
        user: User.fromJson(res.data['user']),
        tokens: AuthTokens(
          accessToken: res.data['tokens']['accessToken'],
          refreshToken: res.data['tokens']['refreshToken'],
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Đăng nhập thất bại';
      throw Exception(message);
    }
  }

  // POST /user-auth/refresh - Refresh access token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final res = await _dio.post(
      '/user-auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return res.data;
  }

  // GET /user-auth/me - Get current user profile
  Future<User> getCurrentUser() async {
    final res = await _dio.get(
      '/user-auth/me',
      options: Options(headers: _authHeaders),
    );
    return User.fromJson(res.data['user']);
  }

  // PUT /user-auth/profile - Update user profile
  Future<User> updateProfile({
    String? name,
    UserPreferences? preferences,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) {
      data['name'] = name;
    }

    if (preferences != null) {
      data['preferences'] = preferences.toJson();
    }

    final res = await _dio.put(
      '/user-auth/profile',
      data: data,
      options: Options(headers: _authHeaders),
    );
    return User.fromJson(res.data['user']);
  }

  // POST /user-auth/logout - Logout user
  Future<Map<String, dynamic>> logout() async {
    final res = await _dio.post(
      '/user-auth/logout',
      options: Options(headers: _authHeaders),
    );
    return res.data;
  }

  // POST /user-auth/reading-stats - Update reading statistics
  Future<UserStats> updateReadingStats({
    required String readingId,
    required int timeSpent,
  }) async {
    final res = await _dio.post(
      '/user-auth/reading-stats',
      data: {'readingId': readingId, 'timeSpent': timeSpent},
      options: Options(headers: _authHeaders),
    );
    return UserStats.fromJson(res.data['stats']);
  }
}
