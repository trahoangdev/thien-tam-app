import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmark_providers.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch để rebuild khi bookmarks thay đổi
    ref.watch(bookmarkRefreshProvider);
    final bookmarkService = ref.read(bookmarkServiceProvider);
    final bookmarks = bookmarkService.getBookmarks();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Yêu thích (${bookmarks.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có bài yêu thích',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn vào biểu tượng 🔖 để lưu bài đọc',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: bookmarks.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final readingId =
                    bookmarks[bookmarks.length - 1 - index]; // Reverse order
                return _BookmarkItem(readingId: readingId);
              },
            ),
    );
  }
}

class _BookmarkItem extends ConsumerWidget {
  final String readingId;

  const _BookmarkItem({required this.readingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          Icons.bookmark,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text('Bài đọc #$readingId'),
        subtitle: const Text('Nhấn để xem chi tiết'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chevron_right),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                final bookmarkService = ref.read(bookmarkServiceProvider);
                await bookmarkService.toggleBookmark(readingId);
                ref.read(bookmarkRefreshProvider.notifier).state++;

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa khỏi yêu thích'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        onTap: () {
          // Navigate to detail - need to get date from reading
          // For now, just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xem bài đọc $readingId'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
