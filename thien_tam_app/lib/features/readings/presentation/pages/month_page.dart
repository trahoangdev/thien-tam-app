import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reading_providers.dart';
import '../../../../core/app_lifecycle.dart';
import 'package:intl/intl.dart';
import 'detail_page.dart';

class MonthPage extends ConsumerWidget {
  final int year;
  final int month;

  const MonthPage({super.key, required this.year, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to app lifecycle for auto-refresh
    ref.listen<AppLifecycleState>(appLifecycleProvider, (previous, next) {
      if (previous != AppLifecycleState.resumed &&
          next == AppLifecycleState.resumed) {
        print('🔄 Auto-refreshing month page after app resume');
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.invalidate(monthReadingsProvider);
        });
      }
    });

    final state = ref.watch(monthReadingsProvider((year, month)));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tháng $month/$year',
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
      body: state.when(
        data: (readings) {
          if (readings.isEmpty) {
            return const Center(
              child: Text('Không có bài đọc nào trong tháng này'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate provider để force reload từ server
              ref.invalidate(monthReadingsProvider);
            },
            child: ListView.builder(
              itemCount: readings.length,
              padding: const EdgeInsets.all(8),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final reading = readings[index];
                // Convert UTC to local date for display and navigation
                final localDate = reading.date.toLocal();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        localDate.day.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      reading.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      DateFormat('EEEE, dd/MM/yyyy', 'vi').format(localDate),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Pass local date to match API format (yyyy-mm-dd)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(date: localDate),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $e', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(monthReadingsProvider((year, month))),
                child: const Text('Thử Lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
