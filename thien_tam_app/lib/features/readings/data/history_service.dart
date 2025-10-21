import 'package:hive/hive.dart';

class HistoryService {
  final Box _box;

  HistoryService(this._box);

  // Add reading to history
  Future<void> addToHistory(String readingId, DateTime date) async {
    final history = _getHistory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Remove if already exists to update timestamp
    history.removeWhere((item) => item['readingId'] == readingId);

    // Add to beginning
    history.insert(0, {
      'readingId': readingId,
      'date': date.toIso8601String(),
      'timestamp': timestamp,
    });

    // Keep only last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    history.removeWhere((item) {
      final itemDate = DateTime.parse(item['date']);
      return itemDate.isBefore(thirtyDaysAgo);
    });

    // Limit to 100 items max
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    await _box.put('reading_history', history);
  }

  // Get history
  List<Map<String, dynamic>> getHistory() {
    return _getHistory();
  }

  // Get history count
  int getHistoryCount() {
    return _getHistory().length;
  }

  // Check if reading was read today
  bool wasReadToday(String readingId) {
    final history = _getHistory();
    final today = DateTime.now();

    for (var item in history) {
      if (item['readingId'] == readingId) {
        final timestamp = item['timestamp'] as int;
        final readDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

        return readDate.year == today.year &&
            readDate.month == today.month &&
            readDate.day == today.day;
      }
    }

    return false;
  }

  // Clear history
  Future<void> clearHistory() async {
    await _box.delete('reading_history');
  }

  // Private helper
  List<Map<String, dynamic>> _getHistory() {
    final data = _box.get('reading_history', defaultValue: <dynamic>[]);
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item)),
    );
  }
}
