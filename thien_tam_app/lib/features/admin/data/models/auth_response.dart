import 'admin_user.dart';

/// Auth response from login endpoint
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final AdminUser user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
      user: AdminUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
      'user': user.toJson(),
    };
  }
}
