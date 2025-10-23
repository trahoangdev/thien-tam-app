import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class ReadingStats {
  final int totalReadings;
  final int totalReadingTime; // in minutes
  final int streakDays;
  final DateTime? lastReadingDate;

  const ReadingStats({
    required this.totalReadings,
    required this.totalReadingTime,
    required this.streakDays,
    this.lastReadingDate,
  });

  ReadingStats copyWith({
    int? totalReadings,
    int? totalReadingTime,
    int? streakDays,
    DateTime? lastReadingDate,
  }) {
    return ReadingStats(
      totalReadings: totalReadings ?? this.totalReadings,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      streakDays: streakDays ?? this.streakDays,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReadings': totalReadings,
      'totalReadingTime': totalReadingTime,
      'streakDays': streakDays,
      'lastReadingDate': lastReadingDate?.toIso8601String(),
    };
  }

  factory ReadingStats.fromJson(Map<String, dynamic> json) {
    return ReadingStats(
      totalReadings: json['totalReadings'] ?? 0,
      totalReadingTime: json['totalReadingTime'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      lastReadingDate: json['lastReadingDate'] != null
          ? DateTime.parse(json['lastReadingDate'])
          : null,
    );
  }
}

class ReadingStatsService {
  static const String _boxName = 'reading_stats';
  static const String _statsKey = 'user_stats';

  static Future<Box> get _box async => await Hive.openBox(_boxName);

  static Future<ReadingStats> getStats() async {
    final box = await _box;
    final statsJson = box.get(_statsKey);

    if (statsJson != null) {
      return ReadingStats.fromJson(Map<String, dynamic>.from(statsJson));
    }

    return const ReadingStats(
      totalReadings: 0,
      totalReadingTime: 0,
      streakDays: 0,
    );
  }

  static Future<void> saveStats(ReadingStats stats) async {
    final box = await _box;
    await box.put(_statsKey, stats.toJson());
  }

  static Future<void> addReading({int readingTimeMinutes = 1}) async {
    final currentStats = await getStats();
    final now = DateTime.now();

    // Calculate streak
    int newStreakDays = currentStats.streakDays;
    if (currentStats.lastReadingDate != null) {
      final daysDifference = now
          .difference(currentStats.lastReadingDate!)
          .inDays;
      if (daysDifference == 1) {
        // Consecutive day
        newStreakDays = currentStats.streakDays + 1;
      } else if (daysDifference > 1) {
        // Streak broken
        newStreakDays = 1;
      }
      // If daysDifference == 0, same day, keep current streak
    } else {
      // First reading
      newStreakDays = 1;
    }

    final newStats = currentStats.copyWith(
      totalReadings: currentStats.totalReadings + 1,
      totalReadingTime: currentStats.totalReadingTime + readingTimeMinutes,
      streakDays: newStreakDays,
      lastReadingDate: now,
    );

    await saveStats(newStats);
  }

  static Future<void> resetStats() async {
    await saveStats(
      const ReadingStats(totalReadings: 0, totalReadingTime: 0, streakDays: 0),
    );
  }
}

// Riverpod providers
final readingStatsProvider =
    StateNotifierProvider<ReadingStatsNotifier, ReadingStats>((ref) {
      return ReadingStatsNotifier();
    });

class ReadingStatsNotifier extends StateNotifier<ReadingStats> {
  ReadingStatsNotifier()
    : super(
        const ReadingStats(
          totalReadings: 0,
          totalReadingTime: 0,
          streakDays: 0,
        ),
      ) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ReadingStatsService.getStats();
    state = stats;
  }

  Future<void> addReading({int readingTimeMinutes = 1}) async {
    await ReadingStatsService.addReading(
      readingTimeMinutes: readingTimeMinutes,
    );
    await _loadStats();
  }

  Future<void> resetStats() async {
    await ReadingStatsService.resetStats();
    await _loadStats();
  }

  Future<void> refreshStats() async {
    await _loadStats();
  }
}
