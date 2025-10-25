import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_providers.dart';
import '../../../books/data/models/book.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'admin_book_form_page.dart';

class AdminBooksListPage extends ConsumerStatefulWidget {
  const AdminBooksListPage({super.key});

  @override
  ConsumerState<AdminBooksListPage> createState() => _AdminBooksListPageState();
}

class _AdminBooksListPageState extends ConsumerState<AdminBooksListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa kinh sách "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteBook(book.id);
    }
  }

  Future<void> _deleteBook(String id) async {
    try {
      final apiClient = ref.read(bookApiClientProvider);
      final token = ref.read(accessTokenProvider);

      if (token == null) {
        throw Exception('Not authenticated');
      }

      await apiClient.deleteBook(id, token: token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa kinh sách thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the list
        ref.invalidate(adminBooksProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToAddBook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminBookFormPage()),
    ).then((_) {
      // Refresh list after adding
      ref.invalidate(adminBooksProvider);
    });
  }

  void _navigateToEditBook(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminBookFormPage(book: book)),
    ).then((_) {
      // Refresh list after editing
      ref.invalidate(adminBooksProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(adminBookSearchQueryProvider);
    final selectedCategory = ref.watch(adminBookSelectedCategoryProvider);
    final selectedLanguage = ref.watch(adminBookSelectedLanguageProvider);
    final isPublicFilter = ref.watch(adminBookIsPublicFilterProvider);
    final currentPage = ref.watch(adminBookCurrentPageProvider);
    final sortBy = ref.watch(adminBookSortByProvider);
    final sortOrder = ref.watch(adminBookSortOrderProvider);

    final params = AdminBooksParams(
      category: selectedCategory,
      search: searchQuery.isEmpty ? null : searchQuery,
      bookLanguage: selectedLanguage,
      isPublic: isPublicFilter,
      page: currentPage,
      limit: 20,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final booksAsync = ref.watch(adminBooksProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Kinh Sách'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminBooksProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm kinh sách...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                      .read(
                                        adminBookSearchQueryProvider.notifier,
                                      )
                                      .state =
                                  '';
                              ref
                                      .read(
                                        adminBookCurrentPageProvider.notifier,
                                      )
                                      .state =
                                  1;
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(adminBookSearchQueryProvider.notifier).state =
                        value;
                    ref.read(adminBookCurrentPageProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: 12),

                // Filters Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Public/Private Filter
                      DropdownButton<bool?>(
                        value: isPublicFilter,
                        hint: const Text('Trạng thái'),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tất cả')),
                          DropdownMenuItem(
                            value: true,
                            child: Text('Công khai'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Riêng tư'),
                          ),
                        ],
                        onChanged: (value) {
                          ref
                                  .read(
                                    adminBookIsPublicFilterProvider.notifier,
                                  )
                                  .state =
                              value;
                          ref
                                  .read(adminBookCurrentPageProvider.notifier)
                                  .state =
                              1;
                        },
                      ),
                      const SizedBox(width: 16),

                      // Sort By
                      DropdownButton<String>(
                        value: sortBy,
                        items: const [
                          DropdownMenuItem(
                            value: 'createdAt',
                            child: Text('Ngày tạo'),
                          ),
                          DropdownMenuItem(value: 'title', child: Text('Tên')),
                          DropdownMenuItem(
                            value: 'downloadCount',
                            child: Text('Lượt tải'),
                          ),
                          DropdownMenuItem(
                            value: 'viewCount',
                            child: Text('Lượt xem'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(adminBookSortByProvider.notifier).state =
                                value;
                          }
                        },
                      ),
                      const SizedBox(width: 8),

                      // Sort Order
                      IconButton(
                        icon: Icon(
                          sortOrder == 'asc'
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                        onPressed: () {
                          ref.read(adminBookSortOrderProvider.notifier).state =
                              sortOrder == 'asc' ? 'desc' : 'asc';
                        },
                        tooltip: sortOrder == 'asc' ? 'Tăng dần' : 'Giảm dần',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Books List
          Expanded(
            child: booksAsync.when(
              data: (data) {
                final books =
                    (data['books'] as List<dynamic>?)
                        ?.map((b) => Book.fromJson(b))
                        .toList() ??
                    [];
                final total = (data['total'] as int?) ?? 0;
                final totalPages = (data['totalPages'] as int?) ?? 1;

                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có kinh sách',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Results count
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng: $total kinh sách',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            'Trang $currentPage/$totalPages',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                    // Books List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          return _BookListItem(
                            book: books[index],
                            onEdit: () => _navigateToEditBook(books[index]),
                            onDelete: () => _confirmDelete(books[index]),
                          );
                        },
                      ),
                    ),

                    // Pagination
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: currentPage > 1
                                  ? () {
                                      ref
                                              .read(
                                                adminBookCurrentPageProvider
                                                    .notifier,
                                              )
                                              .state =
                                          currentPage - 1;
                                    }
                                  : null,
                            ),
                            Text(
                              'Trang $currentPage / $totalPages',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: currentPage < totalPages
                                  ? () {
                                      ref
                                              .read(
                                                adminBookCurrentPageProvider
                                                    .notifier,
                                              )
                                              .state =
                                          currentPage + 1;
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
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
                        ref.invalidate(adminBooksProvider);
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
        onPressed: _navigateToAddBook,
        icon: const Icon(Icons.add),
        label: const Text('Thêm kinh sách'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _BookListItem extends StatelessWidget {
  final Book book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookListItem({
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: book.coverImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  book.coverImageUrl!,
                  width: 40,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.menu_book, size: 40);
                  },
                ),
              )
            : const Icon(Icons.menu_book, size: 40),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.author != null) Text(book.author!),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  book.isPublic ? Icons.public : Icons.lock,
                  size: 14,
                  color: book.isPublic ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  book.isPublic ? 'Công khai' : 'Riêng tư',
                  style: TextStyle(
                    fontSize: 12,
                    color: book.isPublic ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.download, size: 12),
                const SizedBox(width: 4),
                Text(
                  '${book.downloadCount}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.visibility, size: 12),
                const SizedBox(width: 4),
                Text('${book.viewCount}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Sửa',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Xóa',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
