/// Admin User model
class AdminUser {
  final String id;
  final String email;
  final String name;
  final String role; // Changed from List<String> roles to single String role

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'].toString(), // Convert to string to handle ObjectId
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'role': role};
  }

  bool get isAdmin => role == 'ADMIN';
}
