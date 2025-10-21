import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reading_providers.dart';
import '../providers/bookmark_providers.dart';
import '../providers/history_providers.dart';
import '../../../../core/app_lifecycle.dart';
import 'package:intl/intl.dart';
import 'search_page.dart';
import '../../data/models/reading.dart';
import 'detail_page.dart';
import 'not_found_page.dart'; // NEW

// Provider cho ngày được chọn (mặc định là hôm nay)
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

/// Legacy wrapper - kept for backwards compatibility
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TodayPageContent();
  }
}

/// Main today page content with clean AppBar
class TodayPageContent extends ConsumerWidget {
  const TodayPageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final isToday = selectedDate == null;

    // Listen to app lifecycle for auto-refresh
    ref.listen<AppLifecycleState>(appLifecycleProvider, (previous, next) {
      if (previous != AppLifecycleState.resumed &&
          next == AppLifecycleState.resumed) {
        // App đã resume từ background → refresh data
        print('🔄 Auto-refreshing today page after app resume');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (isToday) {
            ref.invalidate(todayProvider);
          } else {
            ref.invalidate(readingByDateProvider(selectedDate));
          }
        });
      }
    });

    // Nếu có ngày được chọn, dùng readingByDateProvider, không thì dùng todayProvider
    final state = isToday
        ? ref.watch(todayProvider)
        : ref.watch(readingByDateProvider(selectedDate));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isToday
                    ? 'Bài đọc hôm nay'
                    : _fmtDate(selectedDate), // Format selected date
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: !isToday
            ? IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state = null;
                },
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => _pickDate(context, ref),
            tooltip: 'Chọn ngày',
            color: Theme.of(context).colorScheme.primary,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            tooltip: 'Tìm kiếm',
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      body: state.when(
        data: (readings) {
          if (readings.isEmpty) {
            return const Center(child: Text('Không có bài đọc nào'));
          }

          // Track reading history for the first reading (backward compatibility)
          final firstReading = readings.first;
          Future.microtask(() async {
            final historyService = ref.read(historyServiceProvider);
            await historyService.addToHistory(
              firstReading.id,
              firstReading.date,
            );
          });

          // Always show reading list format for consistency
          return _buildReadingsList(
            context,
            ref,
            readings,
            isToday,
            selectedDate,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          // Check for 404 errors (both not_found and DioException with 404)
          final errorString = error.toString().toLowerCase();
          if (errorString.contains('not_found') ||
              errorString.contains('404') ||
              errorString.contains('dioexception') &&
                  errorString.contains('404')) {
            return NotFoundPage(
              message: isToday
                  ? 'Chưa có bài đọc nào được đăng cho hôm nay.'
                  : 'Không có bài đọc nào cho ngày ${_fmtDate(selectedDate)}.',
              onRetry: () {
                if (isToday) {
                  ref.invalidate(todayProvider);
                } else {
                  ref.invalidate(readingByDateProvider(selectedDate));
                }
              },
              onGoHome: () {
                ref.read(selectedDateProvider.notifier).state = null;
              },
            );
          }

          // Other errors - show simple error message
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lỗi: $error',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (isToday) {
                        ref.invalidate(todayProvider);
                      } else {
                        ref.invalidate(readingByDateProvider(selectedDate));
                      }
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _fmtDate(DateTime date) {
    // Use shorter format to avoid overflow
    return DateFormat('dd/MM/yyyy', 'vi').format(date.toLocal());
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final initialDate = ref.read(selectedDateProvider) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initialDate) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }

  /// Build reading list - always show list format for consistency
  Widget _buildReadingsList(
    BuildContext context,
    WidgetRef ref,
    List<Reading> readings,
    bool isToday,
    DateTime? selectedDate,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        final repo = ref.read(repoProvider);
        if (isToday) {
          await repo.clearTodayCache();
          ref.invalidate(todayProvider);
        } else {
          await repo.clearCacheForDate(selectedDate!);
          ref.invalidate(readingByDateProvider(selectedDate));
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: readings.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            // Header card
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Prevent overflow
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.library_books,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${readings.length} bài đọc',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fmtDate(readings.first.date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Reading card
          final reading = readings[index - 1];
          return _buildReadingCard(context, ref, reading, index);
        },
      ),
    );
  }

  /// Build individual reading card in the list
  Widget _buildReadingCard(
    BuildContext context,
    WidgetRef ref,
    Reading reading,
    int index,
  ) {
    final bookmarkService = ref.watch(bookmarkServiceProvider);
    final isBookmarked = ref.watch(
      bookmarkServiceProvider.select((s) => s.isBookmarked(reading.id)),
    );

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to detail page with the specific reading
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(date: reading.date),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevent overflow
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Bài $index',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () async {
                      await bookmarkService.toggleBookmark(reading.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                reading.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Preview
              if (reading.body != null)
                Text(
                  reading.body!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4, // Better line height
                  ),
                  maxLines: 4, // More lines for better readability
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),

              // Topics
              if (reading.topicSlugs.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: reading.topicSlugs.take(3).map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer
                            .withOpacity(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 0.3
                                  : 0.5,
                            ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              // Read more indicator
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Đọc tiếp',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
