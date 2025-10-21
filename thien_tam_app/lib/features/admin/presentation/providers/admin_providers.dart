import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/admin_api_client.dart';
import '../../data/models/admin_user.dart';
import '../../data/models/login_request.dart';
import '../../../../core/config.dart';

// Admin API Client provider
final adminApiClientProvider = Provider<AdminApiClient>((ref) {
  return AdminApiClient(baseUrl: AppConfig.apiBaseUrl);
});

// Auth state providers
final accessTokenProvider = StateProvider<String?>((ref) => null);
final refreshTokenProvider = StateProvider<String?>((ref) => null);
final currentAdminUserProvider = StateProvider<AdminUser?>((ref) => null);

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<AdminUser?>> {
  final AdminApiClient _apiClient;
  final Ref _ref;
  Box? _authBox;

  AuthNotifier(this._apiClient, this._ref)
    : super(const AsyncValue.data(null)) {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      _authBox = await Hive.openBox('admin_auth');
      await _loadSavedAuth();
    } catch (e) {
      print('Error initializing Hive: $e');
    }
  }

  Future<void> _loadSavedAuth() async {
    if (_authBox == null) return;

    final accessToken = _authBox!.get('accessToken') as String?;
    final refreshToken = _authBox!.get('refreshToken') as String?;
    final userJson = _authBox!.get('user') as Map?;

    if (accessToken != null && userJson != null) {
      _apiClient.setAccessToken(accessToken);
      _ref.read(accessTokenProvider.notifier).state = accessToken;
      _ref.read(refreshTokenProvider.notifier).state = refreshToken;

      final user = AdminUser.fromJson(Map<String, dynamic>.from(userJson));
      _ref.read(currentAdminUserProvider.notifier).state = user;
      state = AsyncValue.data(user);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiClient.login(request);

      // Save to state
      _apiClient.setAccessToken(response.accessToken);
      _ref.read(accessTokenProvider.notifier).state = response.accessToken;
      _ref.read(refreshTokenProvider.notifier).state = response.refreshToken;
      _ref.read(currentAdminUserProvider.notifier).state = response.user;

      // Save to Hive
      if (_authBox != null) {
        await _authBox!.put('accessToken', response.accessToken);
        await _authBox!.put('refreshToken', response.refreshToken);
        await _authBox!.put('user', response.user.toJson());
      }

      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    _apiClient.setAccessToken(null);
    _ref.read(accessTokenProvider.notifier).state = null;
    _ref.read(refreshTokenProvider.notifier).state = null;
    _ref.read(currentAdminUserProvider.notifier).state = null;

    if (_authBox != null) {
      await _authBox!.clear();
    }

    state = const AsyncValue.data(null);
  }

  bool get isAuthenticated => state.value != null;
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AdminUser?>>((ref) {
      final apiClient = ref.watch(adminApiClientProvider);
      return AuthNotifier(apiClient, ref);
    });

// Helper to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.value != null;
});
