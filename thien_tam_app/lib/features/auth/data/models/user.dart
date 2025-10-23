class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
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
  user('USER'),
  editor('EDITOR'),
  admin('ADMIN');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    switch (value) {
      case 'USER':
        return UserRole.user;
      case 'EDITOR':
        return UserRole.editor;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Người dùng';
      case UserRole.editor:
        return 'Biên tập viên';
      case UserRole.admin:
        return 'Quản trị viên';
    }
  }

  bool get isPremium => false; // Không còn premium
  bool get isVip => false; // Không còn vip
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
      dailyTarget: json['dailyTarget'] ?? 15,
      weeklyTarget: json['weeklyTarget'] ?? 5,
    );
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
      totalReadings: json['totalReadings'] ?? 0,
      totalReadingTime: json['totalReadingTime'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      favoriteTopics: List<String>.from(json['favoriteTopics'] ?? []),
      readingHistory: (json['readingHistory'] as List<dynamic>? ?? [])
          .map((entry) => ReadingHistoryEntry.fromJson(entry))
          .toList(),
    );
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
      readingId: json['readingId'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      timeSpent: json['timeSpent'] ?? 0,
    );
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
