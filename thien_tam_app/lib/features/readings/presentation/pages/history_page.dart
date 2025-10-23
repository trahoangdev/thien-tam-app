import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_providers.dart';
import '../../../auth/presentation/providers/permission_providers.dart'
    as permissions;
import '../../../auth/presentation/pages/login_page.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canViewHistory = ref.watch(permissions.canViewHistoryProvider);

    // Show permission denied if user can't view history
    if (!canViewHistory) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Lịch sử'),
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Cần đăng nhập để xem lịch sử',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Đăng nhập để theo dõi lịch sử đọc của bạn',
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

    // Watch để rebuild khi history thay đổi
    ref.watch(historyRefreshProvider);
    final historyService = ref.read(historyServiceProvider);
    final history = historyService.getHistory();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Lịch Sử (${history.length})',
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
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa lịch sử?'),
                    content: const Text(
                      'Bạn có chắc muốn xóa toàn bộ lịch sử đọc?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await historyService.clearHistory();
                  ref.read(historyRefreshProvider.notifier).state++;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa lịch sử')),
                  );
                }
              },
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có lịch sử đọc',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Các bài bạn đọc sẽ được lưu tại đây',
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
              itemCount: history.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final item = history[index];
                return _HistoryItem(item: item);
              },
            ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _HistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final readingId = item['readingId'] as String;
    final dateStr = item['date'] as String;
    final timestamp = item['timestamp'] as int;

    final date = DateTime.parse(dateStr);
    final readTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final now = DateTime.now();
    final isToday =
        readTime.year == now.year &&
        readTime.month == now.month &&
        readTime.day == now.day;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isToday
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceVariant,
          child: Icon(
            Icons.check_circle,
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text('Bài đọc ngày ${_formatDate(date)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: $readingId',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              'Đọc lúc: ${_formatTime(readTime)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: isToday
            ? Chip(
                label: Text(
                  'Hôm nay',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: EdgeInsets.zero,
              )
            : null,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xem bài đọc ngày ${_formatDate(date)}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'vi').format(date);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays == 1) {
      return 'Hôm qua lúc ${DateFormat('HH:mm').format(time)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm', 'vi').format(time);
    }
  }
}
