class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime? dateOfBirth;
  final UserRole role;
  final UserPreferences preferences;
  final UserStats stats;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.dateOfBirth,
    required this.role,
    required this.preferences,
    required this.stats,
    required this.isActive,
    required this.isEmailVerified,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      role: UserRole.fromString(json['role'] ?? 'USER'),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      isActive: json['isActive'] ?? true,
      isEmailVerified: json['isEmailVerified'] ?? false,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'role': role.value,
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    DateTime? dateOfBirth,
    UserRole? role,
    UserPreferences? preferences,
    UserStats? stats,
    bool? isActive,
    bool? isEmailVerified,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role)';
  }
}

enum UserRole {
  user('USER');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.user; // Chỉ có 1 role
  }

  String get displayName => 'Người dùng';

  bool get isPremium => false;
  bool get isVip => false;
}

class UserPreferences {
  final String theme;
  final String fontSize;
  final double lineHeight;
  final NotificationPreferences notifications;
  final ReadingGoals readingGoals;

  UserPreferences({
    required this.theme,
    required this.fontSize,
    required this.lineHeight,
    required this.notifications,
    required this.readingGoals,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] ?? 'auto',
      fontSize: json['fontSize'] ?? 'medium',
      lineHeight: (json['lineHeight'] ?? 1.6).toDouble(),
      notifications: NotificationPreferences.fromJson(
        json['notifications'] ?? {},
      ),
      readingGoals: ReadingGoals.fromJson(json['readingGoals'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'notifications': notifications.toJson(),
      'readingGoals': readingGoals.toJson(),
    };
  }

  UserPreferences copyWith({
    String? theme,
    String? fontSize,
    double? lineHeight,
    NotificationPreferences? notifications,
    ReadingGoals? readingGoals,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      notifications: notifications ?? this.notifications,
      readingGoals: readingGoals ?? this.readingGoals,
    );
  }
}

class NotificationPreferences {
  final bool dailyReading;
  final bool weeklyDigest;
  final bool newContent;

  NotificationPreferences({
    required this.dailyReading,
    required this.weeklyDigest,
    required this.newContent,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      dailyReading: json['dailyReading'] ?? true,
      weeklyDigest: json['weeklyDigest'] ?? true,
      newContent: json['newContent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyReading': dailyReading,
      'weeklyDigest': weeklyDigest,
      'newContent': newContent,
    };
  }

  NotificationPreferences copyWith({
    bool? dailyReading,
    bool? weeklyDigest,
    bool? newContent,
  }) {
    return NotificationPreferences(
      dailyReading: dailyReading ?? this.dailyReading,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      newContent: newContent ?? this.newContent,
    );
  }
}

class ReadingGoals {
  final int dailyTarget;
  final int weeklyTarget;

  ReadingGoals({required this.dailyTarget, required this.weeklyTarget});

  factory ReadingGoals.fromJson(Map<String, dynamic> json) {
    return ReadingGoals(
      dailyTarget: _parseInt(json['dailyTarget'], defaultValue: 15),
      weeklyTarget: _parseInt(json['weeklyTarget'], defaultValue: 5),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {'dailyTarget': dailyTarget, 'weeklyTarget': weeklyTarget};
  }

  ReadingGoals copyWith({int? dailyTarget, int? weeklyTarget}) {
    return ReadingGoals(
      dailyTarget: dailyTarget ?? this.dailyTarget,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
    );
  }
}

class UserStats {
  final int totalReadings;
  final int totalReadingTime;
  final int streakDays;
  final int longestStreak;
  final List<String> favoriteTopics;
  final List<ReadingHistoryEntry> readingHistory;

  UserStats({
    required this.totalReadings,
    required this.totalReadingTime,
    required this.streakDays,
    required this.longestStreak,
    required this.favoriteTopics,
    required this.readingHistory,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalReadings: _parseInt(json['totalReadings']),
      totalReadingTime: _parseInt(json['totalReadingTime']),
      streakDays: _parseInt(json['streakDays']),
      longestStreak: _parseInt(json['longestStreak']),
      favoriteTopics:
          (json['favoriteTopics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      readingHistory: (json['readingHistory'] as List<dynamic>? ?? [])
          .map((entry) => ReadingHistoryEntry.fromJson(entry))
          .toList(),
    );
  }

  // Helper method to safely parse int from dynamic
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReadings': totalReadings,
      'totalReadingTime': totalReadingTime,
      'streakDays': streakDays,
      'longestStreak': longestStreak,
      'favoriteTopics': favoriteTopics,
      'readingHistory': readingHistory.map((entry) => entry.toJson()).toList(),
    };
  }

  UserStats copyWith({
    int? totalReadings,
    int? totalReadingTime,
    int? streakDays,
    int? longestStreak,
    List<String>? favoriteTopics,
    List<ReadingHistoryEntry>? readingHistory,
  }) {
    return UserStats(
      totalReadings: totalReadings ?? this.totalReadings,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      favoriteTopics: favoriteTopics ?? this.favoriteTopics,
      readingHistory: readingHistory ?? this.readingHistory,
    );
  }
}

class ReadingHistoryEntry {
  final String readingId;
  final DateTime date;
  final int timeSpent;

  ReadingHistoryEntry({
    required this.readingId,
    required this.date,
    required this.timeSpent,
  });

  factory ReadingHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ReadingHistoryEntry(
      readingId: json['readingId']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      timeSpent: _parseInt(json['timeSpent']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'readingId': readingId,
      'date': date.toIso8601String(),
      'timeSpent': timeSpent,
    };
  }
}

// Auth tokens
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }
}

// Auth response
class AuthResponse {
  final String message;
  final User user;
  final AuthTokens tokens;

  AuthResponse({
    required this.message,
    required this.user,
    required this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      tokens: AuthTokens.fromJson(json['tokens'] ?? {}),
    );
  }
}
