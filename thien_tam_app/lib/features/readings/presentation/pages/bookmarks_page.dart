import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmark_providers.dart';
import '../providers/reading_providers.dart';
import '../../data/models/reading.dart';
import 'detail_page.dart';
import '../../../auth/presentation/providers/permission_providers.dart'
    as permissions;
import '../../../auth/presentation/pages/login_page.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canBookmark = ref.watch(permissions.canBookmarkProvider);

    // Show permission denied if user can't bookmark
    if (!canBookmark) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Đánh dấu'),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Cần đăng nhập để sử dụng tính năng này',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Đăng nhập để lưu và quản lý các bài đọc yêu thích',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    // Watch để rebuild khi bookmarks thay đổi
    ref.watch(bookmarkRefreshProvider);
    final bookmarkService = ref.read(bookmarkServiceProvider);
    final bookmarks = bookmarkService.getBookmarks();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    ).colorScheme.primary.withValues(alpha: 0.4),
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
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
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

  Future<void> _navigateToReadingDetail(
    BuildContext context,
    WidgetRef ref,
    String readingId,
  ) async {
    try {
      // We need to find the reading by ID to get its date
      // Since we don't have direct access to all readings, we'll need to search for it
      final readingRepo = ref.read(repoProvider);

      // Try to find the reading by searching through recent readings
      // This is a workaround since we don't have a direct "get by ID" method
      final todayReadings = await readingRepo.today();
      Reading? foundReading = todayReadings
          .where((r) => r.id == readingId)
          .firstOrNull;

      if (foundReading != null) {
        // Found in today's readings
        final normalizedDate = DateTime(
          foundReading.date.year,
          foundReading.date.month,
          foundReading.date.day,
        );

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailPage(date: normalizedDate, readingId: readingId),
            ),
          );
        }
        return;
      }

      // If not found in today's readings, try searching in the last 30 days
      if (foundReading == null) {
        final now = DateTime.now();
        for (int i = 1; i <= 30; i++) {
          final date = now.subtract(Duration(days: i));
          try {
            final readings = await readingRepo.getByDate(date);
            foundReading = readings.where((r) => r.id == readingId).firstOrNull;

            if (foundReading != null) {
              final normalizedDate = DateTime(
                foundReading.date.year,
                foundReading.date.month,
                foundReading.date.day,
              );

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailPage(date: normalizedDate, readingId: readingId),
                  ),
                );
              }
              return;
            }
          } catch (e) {
            // Continue searching
          }
        }
      }

      // If still not found, show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy bài đọc này'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi tải bài đọc'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

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
          // Navigate to detail page with readingId
          // We need to fetch the reading to get its date
          _navigateToReadingDetail(context, ref, readingId);
        },
      ),
    );
  }
}
