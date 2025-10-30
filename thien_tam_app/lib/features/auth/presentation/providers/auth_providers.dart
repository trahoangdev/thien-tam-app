import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/user_auth_api_client.dart';
import '../../data/models/user.dart';
import 'permission_providers.dart' as permissions;

// Secure storage for tokens
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

// API Client Provider
final userAuthApiClientProvider = Provider((ref) {
  final client = UserAuthApiClient();
  final accessToken = ref.watch(accessTokenProvider);
  client.setAccessToken(accessToken);
  return client;
});

// Token providers
final accessTokenProvider = StateProvider<String?>((ref) => null);
final refreshTokenProvider = StateProvider<String?>((ref) => null);

// Current user provider
final currentUserProvider = StateProvider<User?>((ref) => null);

// Auth state provider
final authStateProvider = StateProvider<AuthState>((ref) => AuthState.initial);

enum AuthState { initial, loading, authenticated, unauthenticated, error }

// Auth service provider
final authServiceProvider = Provider((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref ref;

  AuthService(this.ref);

  // Initialize auth state from storage
  Future<void> initialize() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final accessToken = await storage.read(key: 'access_token');
      final refreshToken = await storage.read(key: 'refresh_token');

      if (accessToken != null && refreshToken != null) {
        ref.read(accessTokenProvider.notifier).state = accessToken;
        ref.read(refreshTokenProvider.notifier).state = refreshToken;

        // Try to get current user
        try {
          final user = await ref
              .read(userAuthApiClientProvider)
              .getCurrentUser();
          ref.read(currentUserProvider.notifier).state = user;
          ref.read(authStateProvider.notifier).state = AuthState.authenticated;
        } catch (e) {
          // Token might be expired, try to refresh
          await _refreshToken();
        }
      } else {
        ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
      }
    } catch (e) {
      ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;
    }
  }

  // Register new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      ref.read(authStateProvider.notifier).state = AuthState.loading;

      final apiClient = ref.read(userAuthApiClientProvider);
      final response = await apiClient.register(
        email: email,
        password: password,
        name: name,
      );

      await _saveTokens(response.tokens);
      ref.read(currentUserProvider.notifier).state = response.user;
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;

      // Reset guest mode when user registers
      ref.read(permissions.isGuestModeProvider.notifier).state = false;

      return response;
    } catch (e) {
      ref.read(authStateProvider.notifier).state = AuthState.error;
      rethrow;
    }
  }

  // Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      ref.read(authStateProvider.notifier).state = AuthState.loading;

      final apiClient = ref.read(userAuthApiClientProvider);
      final response = await apiClient.login(email: email, password: password);

      await _saveTokens(response.tokens);
      ref.read(currentUserProvider.notifier).state = response.user;
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;

      // Reset guest mode when user logs in
      ref.read(permissions.isGuestModeProvider.notifier).state = false;

      return response;
    } catch (e) {
      ref.read(authStateProvider.notifier).state = AuthState.error;
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final apiClient = ref.read(userAuthApiClientProvider);
      await apiClient.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _clearTokens();
      ref.read(currentUserProvider.notifier).state = null;
      ref.read(authStateProvider.notifier).state = AuthState.unauthenticated;

      // Set guest mode when user logs out
      ref.read(permissions.isGuestModeProvider.notifier).state = true;
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? name,
    String? avatar,
    DateTime? dateOfBirth,
    UserPreferences? preferences,
  }) async {
    try {
      final apiClient = ref.read(userAuthApiClientProvider);
      final updatedUser = await apiClient.updateProfile(
        name: name,
        avatar: avatar,
        dateOfBirth: dateOfBirth,
        preferences: preferences,
      );

      ref.read(currentUserProvider.notifier).state = updatedUser;
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  // Update reading statistics
  Future<void> updateReadingStats({
    required String readingId,
    required int timeSpent,
  }) async {
    try {
      final apiClient = ref.read(userAuthApiClientProvider);
      final stats = await apiClient.updateReadingStats(
        readingId: readingId,
        timeSpent: timeSpent,
      );

      // Update current user stats
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(stats: stats);
        ref.read(currentUserProvider.notifier).state = updatedUser;
      }
    } catch (e) {
      // Don't rethrow - reading stats update shouldn't break the app
    }
  }

  // Refresh access token
  Future<void> _refreshToken() async {
    try {
      final refreshToken = ref.read(refreshTokenProvider);
      if (refreshToken == null) {
        await logout();
        return;
      }

      final apiClient = ref.read(userAuthApiClientProvider);
      final response = await apiClient.refreshToken(refreshToken);

      final newAccessToken = response['accessToken'];
      ref.read(accessTokenProvider.notifier).state = newAccessToken;

      final storage = ref.read(secureStorageProvider);
      await storage.write(key: 'access_token', value: newAccessToken);

      // Try to get current user again
      final user = await apiClient.getCurrentUser();
      ref.read(currentUserProvider.notifier).state = user;
      ref.read(authStateProvider.notifier).state = AuthState.authenticated;
    } catch (e) {
      await logout();
    }
  }

  // Save tokens to secure storage
  Future<void> _saveTokens(AuthTokens tokens) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: 'access_token', value: tokens.accessToken);
    await storage.write(key: 'refresh_token', value: tokens.refreshToken);

    ref.read(accessTokenProvider.notifier).state = tokens.accessToken;
    ref.read(refreshTokenProvider.notifier).state = tokens.refreshToken;
  }

  // Clear tokens from storage
  Future<void> _clearTokens() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    ref.read(accessTokenProvider.notifier).state = null;
    ref.read(refreshTokenProvider.notifier).state = null;
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    final state = ref.read(authStateProvider);
    return state == AuthState.authenticated;
  }

  // Get current user
  User? get currentUser {
    return ref.read(currentUserProvider);
  }
}

// Form state providers for login/register
class LoginFormState {
  final String email;
  final String password;
  final bool isLoading;
  final String? error;

  LoginFormState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.error,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? error,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isValid => email.isNotEmpty && password.isNotEmpty;
}

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(LoginFormState());

  void setEmail(String email) => state = state.copyWith(email: email);
  void setPassword(String password) =>
      state = state.copyWith(password: password);
  void setLoading(bool loading) => state = state.copyWith(isLoading: loading);
  void setError(String? error) => state = state.copyWith(error: error);
}

final loginFormProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormState>(
      (ref) => LoginFormNotifier(),
    );

class RegisterFormState {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final bool isLoading;
  final String? error;

  RegisterFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.name = '',
    this.isLoading = false,
    this.error,
  });

  RegisterFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? name,
    bool? isLoading,
    String? error,
  }) {
    return RegisterFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      name: name ?? this.name,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      name.isNotEmpty &&
      password == confirmPassword &&
      password.length >= 6;
}

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  RegisterFormNotifier() : super(RegisterFormState());

  void setEmail(String email) => state = state.copyWith(email: email);
  void setPassword(String password) =>
      state = state.copyWith(password: password);
  void setConfirmPassword(String confirmPassword) =>
      state = state.copyWith(confirmPassword: confirmPassword);
  void setName(String name) => state = state.copyWith(name: name);
  void setLoading(bool loading) => state = state.copyWith(isLoading: loading);
  void setError(String? error) => state = state.copyWith(error: error);
}

final registerFormProvider =
    StateNotifierProvider<RegisterFormNotifier, RegisterFormState>(
      (ref) => RegisterFormNotifier(),
    );
