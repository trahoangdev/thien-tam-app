import 'package:hive/hive.dart';
import 'models/reading.dart';
import 'reading_api.dart';

class ReadingRepo {
  final ReadingApi api;
  final Box cache;

  ReadingRepo(this.api, this.cache);

  // Cache TTL: 30 phút
  static const cacheDuration = Duration(minutes: 30);

  /// Kiểm tra cache có còn hợp lệ không
  bool _isCacheValid(String key) {
    final timestamp = cache.get('${key}_timestamp');
    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    final now = DateTime.now();

    return now.difference(cacheTime) < cacheDuration;
  }

  Future<List<Reading>> today() async {
    const key = 'today';

    // Kiểm tra cache còn hợp lệ không
    if (_isCacheValid(key)) {
      final j = cache.get(key);
      if (j != null) {
        try {
          final list = (j as List)
              .map((e) => Reading.fromJson(e.cast<String, dynamic>()))
              .toList();
          return list;
        } catch (_) {
          // Cache bị lỗi, xóa và fetch mới
        }
      }
    }

    // Fetch từ API
    try {
      final readings = await api.getToday();
      await cache.put(key, readings.map((r) => r.toJson()).toList());
      await cache.put(
        '${key}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
      return readings;
    } catch (_) {
      // Nếu API lỗi, dùng cache cũ (dù đã hết hạn)
      final j = cache.get(key);
      if (j != null) {
        final list = (j as List)
            .map((e) => Reading.fromJson(e.cast<String, dynamic>()))
            .toList();
        return list;
      }
      rethrow;
    }
  }

  Future<List<Reading>> getByDate(DateTime date) async {
    final key = 'date_${date.toIso8601String().split('T')[0]}';

    // Kiểm tra cache còn hợp lệ không
    if (_isCacheValid(key)) {
      final j = cache.get(key);
      if (j != null) {
        try {
          final list = (j as List)
              .map((e) => Reading.fromJson(e.cast<String, dynamic>()))
              .toList();
          return list;
        } catch (_) {
          // Cache bị lỗi, fetch mới
        }
      }
    }

    // Fetch từ API
    try {
      final readings = await api.getByDate(date);
      await cache.put(key, readings.map((r) => r.toJson()).toList());
      await cache.put(
        '${key}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
      return readings;
    } catch (_) {
      // Nếu API lỗi, dùng cache cũ (dù đã hết hạn)
      final j = cache.get(key);
      if (j != null) {
        final list = (j as List)
            .map((e) => Reading.fromJson(e.cast<String, dynamic>()))
            .toList();
        return list;
      }
      rethrow;
    }
  }

  Future<List<Reading>> getMonth(int year, int month) async {
    return await api.getMonth(year, month);
  }

  Future<Reading> getRandom() async {
    return await api.getRandom();
  }

  Future<Map<String, dynamic>> search({
    String? query,
    String? topic,
    int page = 1,
  }) async {
    return await api.search(query: query, topic: topic, page: page);
  }

  /// Clear all cache (dùng khi cần force refresh)
  Future<void> clearCache() async {
    await cache.clear();
  }

  /// Clear cache cho một ngày cụ thể
  Future<void> clearCacheForDate(DateTime date) async {
    final key = 'date_${date.toIso8601String().split('T')[0]}';
    await cache.delete(key);
    await cache.delete('${key}_timestamp');
  }

  /// Clear cache today
  Future<void> clearTodayCache() async {
    await cache.delete('today');
    await cache.delete('today_timestamp');
  }
}
