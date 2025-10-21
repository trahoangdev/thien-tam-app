import 'package:hive/hive.dart';

class BookmarkService {
  final Box _box;

  BookmarkService(this._box);

  // Get all bookmarks
  List<String> getBookmarks() {
    return List<String>.from(_box.get('bookmarks', defaultValue: <String>[]));
  }

  // Check if reading is bookmarked
  bool isBookmarked(String readingId) {
    final bookmarks = getBookmarks();
    return bookmarks.contains(readingId);
  }

  // Toggle bookmark
  Future<bool> toggleBookmark(String readingId) async {
    final bookmarks = getBookmarks();

    if (bookmarks.contains(readingId)) {
      bookmarks.remove(readingId);
      await _box.put('bookmarks', bookmarks);
      return false; // Removed
    } else {
      bookmarks.add(readingId);
      await _box.put('bookmarks', bookmarks);
      return true; // Added
    }
  }

  // Get bookmark count
  int getBookmarkCount() {
    return getBookmarks().length;
  }
}
