/// Admin User model
class AdminUser {
  final String id;
  final String email;
  final List<String> roles;

  AdminUser({required this.id, required this.email, required this.roles});

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'roles': roles};
  }

  bool get isAdmin => roles.contains('ADMIN');
  bool get isEditor => roles.contains('EDITOR');
}
