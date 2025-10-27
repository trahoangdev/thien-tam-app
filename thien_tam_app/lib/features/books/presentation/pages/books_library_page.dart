import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_providers.dart';
import '../../data/models/book.dart';
import '../../data/models/book_category.dart' as cat;
import 'book_detail_page.dart';

class BooksLibraryPage extends ConsumerStatefulWidget {
  const BooksLibraryPage({super.key});

  @override
  ConsumerState<BooksLibraryPage> createState() => _BooksLibraryPageState();
}

class _BooksLibraryPageState extends ConsumerState<BooksLibraryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(bookSearchQueryProvider);
    final selectedCategory = ref.watch(selectedBookCategoryProvider);
    final selectedLanguage = ref.watch(selectedBookLanguageProvider);
    final currentPage = ref.watch(bookCurrentPageProvider);
    final sortBy = ref.watch(bookSortByProvider);
    final sortOrder = ref.watch(bookSortOrderProvider);

    final params = BooksParams(
      category: selectedCategory,
      search: searchQuery.isEmpty ? null : searchQuery,
      bookLanguage: selectedLanguage,
      page: currentPage,
      limit: 20,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final booksAsync = ref.watch(booksProvider(params));
    final categoriesAsync = ref.watch(bookCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư Viện Kinh Sách'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(booksProvider);
              ref.invalidate(popularBooksProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Search Bar
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
                              ref.read(bookSearchQueryProvider.notifier).state =
                                  '';
                              ref.read(bookCurrentPageProvider.notifier).state =
                                  1;
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(bookSearchQueryProvider.notifier).state = value;
                    ref.read(bookCurrentPageProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: 12),

                // Category Filter Chips
                categoriesAsync.when(
                  data: (categories) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Tất cả'),
                          selected: selectedCategory == null,
                          onSelected: (selected) {
                            ref
                                    .read(selectedBookCategoryProvider.notifier)
                                    .state =
                                null;
                            ref.read(bookCurrentPageProvider.notifier).state =
                                1;
                          },
                        ),
                        const SizedBox(width: 8),
                        ...categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: Text(
                                category.icon,
                                style: const TextStyle(fontSize: 16),
                              ),
                              label: Text(category.name),
                              selected: selectedCategory == category.id,
                              onSelected: (selected) {
                                ref
                                    .read(selectedBookCategoryProvider.notifier)
                                    .state = selected
                                    ? category.id
                                    : null;
                                ref
                                        .read(bookCurrentPageProvider.notifier)
                                        .state =
                                    1;
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Lỗi: $error'),
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
                          'Không tìm thấy kinh sách',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Tìm thấy $total kinh sách',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),

                    // Books Grid/List
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  0.6, // Adjusted for better book card proportions
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          return _BookCard(book: books[index]);
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
                                                bookCurrentPageProvider
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
                                                bookCurrentPageProvider
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
                        ref.invalidate(booksProvider);
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
    );
  }
}

class _BookCard extends ConsumerWidget {
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookDetailPage(book: book)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Expanded(
              flex: 3,
              child: book.coverImageUrl != null
                  ? Image.network(
                      book.coverImageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _defaultCover(context);
                      },
                    )
                  : _defaultCover(context),
            ),

            // Book Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Author
                    if (book.author != null)
                      Text(
                        book.author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    const Spacer(),

                    // Category
                    Row(
                      children: [
                        Text(
                          _getCategoryIcon(book),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.categoryLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Stats
                    Row(
                      children: [
                        Icon(Icons.download, size: 11, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text(
                          '${book.downloadCount}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.visibility,
                          size: 11,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${book.viewCount}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultCover(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 4,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(Book book) {
    // If category is a BookCategory object, use its icon emoji
    if (book.category is cat.BookCategory) {
      return (book.category as cat.BookCategory).icon;
    }

    // Fallback for old string-based categories
    final categoryStr = book.categoryId;
    switch (categoryStr) {
      case 'sutra':
        return '📖';
      case 'commentary':
        return '💬';
      case 'biography':
        return '👤';
      case 'practice':
        return '🧘';
      case 'dharma-talk':
        return '🎙️';
      case 'history':
        return '📜';
      case 'philosophy':
        return '🧠';
      default:
        return '📚';
    }
  }
}
