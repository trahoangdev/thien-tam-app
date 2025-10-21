import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/bookmark_service.dart';
import '../../../../main.dart';

// Bookmark service provider
final bookmarkServiceProvider = Provider((ref) {
  return BookmarkService(ref.read(cacheProvider));
});

// Provider to check if a reading is bookmarked
final isBookmarkedProvider = Provider.family<bool, String>((ref, readingId) {
  return ref.watch(bookmarkServiceProvider).isBookmarked(readingId);
});

// State provider to trigger UI refresh after bookmark toggle
final bookmarkRefreshProvider = StateProvider<int>((ref) => 0);
