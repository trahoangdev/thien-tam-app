import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/topic_providers.dart';
import '../../data/models/topic.dart';
import 'admin_topic_form_page.dart';

class AdminTopicsListPage extends ConsumerStatefulWidget {
  const AdminTopicsListPage({super.key});

  @override
  ConsumerState<AdminTopicsListPage> createState() =>
      _AdminTopicsListPageState();
}

class _AdminTopicsListPageState extends ConsumerState<AdminTopicsListPage> {
  final _searchController = TextEditingController();
  int _currentPage = 1;
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicsState = ref.watch(
      adminTopicsProvider((
        page: _currentPage,
        limit: 20,
        search: _searchQuery,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chủ đề'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(
                adminTopicsProvider((
                  page: _currentPage,
                  limit: 20,
                  search: _searchQuery,
                )),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm chủ đề...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = null;
                            _currentPage = 1;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value.isEmpty ? null : value;
                  _currentPage = 1;
                });
              },
            ),
          ),

          // Topics list
          Expanded(
            child: topicsState.when(
              data: (data) {
                final topics = (data['items'] as List)
                    .map((e) => Topic.fromJson(e))
                    .toList();
                final total = data['total'] as int;
                final pages = data['pages'] as int;

                if (topics.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.label_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Không có chủ đề nào',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Info bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Tổng: $total chủ đề',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          if (_searchQuery != null)
                            Text(
                              'Kết quả tìm kiếm: "${_searchQuery}"',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),

                    // Topics list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return _buildTopicCard(context, topic);
                        },
                      ),
                    ),

                    // Pagination
                    if (pages > 1)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _currentPage > 1
                                  ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text(
                              'Trang $_currentPage/$pages',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            IconButton(
                              onPressed: _currentPage < pages
                                  ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
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
                        ref.invalidate(
                          adminTopicsProvider((
                            page: _currentPage,
                            limit: 20,
                            search: _searchQuery,
                          )),
                        );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminTopicFormPage()),
          );

          // Refresh list if topic was created successfully
          if (result == true && mounted) {
            ref.invalidate(
              adminTopicsProvider((
                page: _currentPage,
                limit: 20,
                search: _searchQuery,
              )),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo chủ đề'),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Topic topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(int.parse(topic.color.replaceFirst('#', '0xFF'))),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getIconData(topic.icon), color: Colors.white, size: 20),
        ),
        title: Text(
          topic.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: topic.isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.description.isNotEmpty
                  ? topic.description
                  : 'Slug: ${topic.slug}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: topic.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    topic.isActive ? 'Hoạt động' : 'Tạm khóa',
                    style: TextStyle(
                      fontSize: 10,
                      color: topic.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${topic.readingCount} bài đọc',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminTopicFormPage(topic: topic),
                  ),
                );

                // Refresh list if topic was updated successfully
                if (result == true && mounted) {
                  ref.invalidate(
                    adminTopicsProvider((
                      page: _currentPage,
                      limit: 20,
                      search: _searchQuery,
                    )),
                  );
                }
                break;
              case 'delete':
                _showDeleteDialog(context, topic);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'label':
        return Icons.label;
      case 'spa':
        return Icons.spa;
      case 'favorite':
        return Icons.favorite;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'book':
        return Icons.book;
      case 'star':
        return Icons.star;
      default:
        return Icons.label;
    }
  }

  void _showDeleteDialog(BuildContext context, Topic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa chủ đề'),
        content: Text(
          'Bạn có chắc chắn muốn xóa chủ đề "${topic.name}"?\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTopic(topic);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTopic(Topic topic) async {
    try {
      final apiClient = ref.read(topicApiClientProvider);
      await apiClient.deleteTopic(topic.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa chủ đề "${topic.name}"'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the list
        ref.invalidate(
          adminTopicsProvider((
            page: _currentPage,
            limit: 20,
            search: _searchQuery,
          )),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
