import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/admin_readings_providers.dart';
import '../../../readings/data/models/reading.dart';
import 'admin_reading_form_page.dart';
import '../../../../core/app_lifecycle.dart';

class AdminReadingsListPage extends ConsumerStatefulWidget {
  const AdminReadingsListPage({super.key});

  @override
  ConsumerState<AdminReadingsListPage> createState() =>
      _AdminReadingsListPageState();
}

class _AdminReadingsListPageState extends ConsumerState<AdminReadingsListPage> {
  int _currentPage = 1;
  final int _limit = 20;
  String? _searchQuery;
  String? _topicFilter;

  @override
  Widget build(BuildContext context) {
    // Listen to app lifecycle for auto-refresh
    ref.listen<AppLifecycleState>(appLifecycleProvider, (previous, next) {
      if (previous != AppLifecycleState.resumed &&
          next == AppLifecycleState.resumed) {
        print('🔄 Auto-refreshing admin readings after app resume');
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.invalidate(adminReadingsProvider);
        });
      }
    });

    final params = AdminReadingsParams(
      page: _currentPage,
      limit: _limit,
      search: _searchQuery,
      topic: _topicFilter,
    );

    final readingsAsync = ref.watch(adminReadingsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý bài đọc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminReadingsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài đọc...',
                hintStyle: TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.isEmpty ? null : value;
                  _currentPage = 1;
                });
              },
            ),
          ),

          // Readings list
          Expanded(
            child: readingsAsync.when(
              data: (data) {
                final readings = data['items'] as List<Reading>;
                final total = data['total'] as int;
                final page = data['page'] as int;
                final pages = data['pages'] as int;

                if (readings.isEmpty) {
                  return const Center(child: Text('Không có bài đọc nào'));
                }

                return Column(
                  children: [
                    // Info bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: Row(
                        children: [
                          Text(
                            'Tổng: $total bài đọc',
                            style: const TextStyle(fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            'Trang $page / $pages',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: readings.length,
                        itemBuilder: (context, index) {
                          return _buildReadingCard(context, readings[index]);
                        },
                      ),
                    ),

                    // Pagination
                    _buildPagination(page, pages),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Lỗi: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(adminReadingsProvider);
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 60,
        ), // Nâng FAB lên tránh pagination
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminReadingFormPage(),
              ),
            );

            if (result == true && mounted) {
              // Reset về trang 1 để thấy bài mới
              setState(() {
                _currentPage = 1;
                _searchQuery = null; // Clear search nếu có
              });
              // Invalidate provider để reload
              ref.invalidate(adminReadingsProvider);

              // Show refreshing message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔄 Đang tải lại danh sách...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Tạo bài mới'),
        ),
      ),
    );
  }

  Widget _buildReadingCard(BuildContext context, Reading reading) {
    final dateStr = DateFormat('dd/MM/yyyy').format(reading.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.article,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          reading.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (reading.topicSlugs.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: reading.topicSlugs.take(2).map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      topic,
                      style: TextStyle(
                        fontSize: 9,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminReadingFormPage(readingId: reading.id),
                  ),
                );

                if (result == true && mounted) {
                  ref.invalidate(adminReadingsProvider);
                }
              },
            ),
            IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, reading),
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminReadingFormPage(readingId: reading.id),
            ),
          );

          if (result == true && mounted) {
            ref.invalidate(adminReadingsProvider);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Reading reading) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa bài đọc "${reading.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(adminReadingsCrudProvider.notifier)
            .deleteReading(reading.id);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã xóa bài đọc')));
          ref.invalidate(adminReadingsProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  Widget _buildPagination(int currentPage, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 20,
              padding: const EdgeInsets.all(8),
              icon: const Icon(Icons.chevron_left),
              onPressed: currentPage > 1
                  ? () {
                      setState(() {
                        _currentPage = currentPage - 1;
                      });
                    }
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              'Trang $_currentPage / $totalPages',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(width: 12),
            IconButton(
              iconSize: 20,
              padding: const EdgeInsets.all(8),
              icon: const Icon(Icons.chevron_right),
              onPressed: currentPage < totalPages
                  ? () {
                      setState(() {
                        _currentPage = currentPage + 1;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
