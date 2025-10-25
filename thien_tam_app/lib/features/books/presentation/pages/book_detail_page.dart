import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/book.dart';
import '../providers/book_providers.dart';
import 'pdf_viewer_page.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    // Increment view count when page opens
    _incrementViewCount();
  }

  Future<void> _incrementViewCount() async {
    try {
      await ref.read(bookServiceProvider).incrementViewCount(widget.book.id);
    } catch (e) {
      // Silently fail - not critical
      debugPrint('Failed to increment view count: $e');
    }
  }

  Future<void> _viewPDF() async {
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(book: widget.book),
      ),
    );
  }

  Future<void> _downloadPDF() async {

    setState(() {
      _isDownloading = true;
    });

    try {
      // Increment download count
      await ref.read(bookServiceProvider).incrementDownloadCount(widget.book.id);
      
      // TODO: Implement actual download
      // For now, just open the URL in browser
      _showSnackBar('Chức năng tải xuống đang được phát triển', isError: false);
      
      // Update the book in the provider
      ref.invalidate(bookDetailProvider(widget.book.id));
    } catch (e) {
      _showSnackBar('Lỗi khi tải xuống: $e', isError: true);
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookDetailAsync = ref.watch(bookDetailProvider(widget.book.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết kinh sách'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(bookDetailProvider(widget.book.id));
            },
          ),
        ],
      ),
      body: bookDetailAsync.when(
        data: (book) => _buildContent(book),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(bookDetailProvider(widget.book.id));
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildContent(Book book) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          if (book.coverImageUrl != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    book.coverImageUrl!,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _defaultCover(book);
                    },
                  ),
                ),
              ),
            )
          else
            Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                height: 300,
                child: _defaultCover(book),
              ),
            ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),

          // Author
          if (book.author != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tác giả: ${book.author}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          const SizedBox(height: 16),

          // Metadata Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetadataChip(
                  icon: Icons.category,
                  label: book.categoryLabel,
                  color: Theme.of(context).colorScheme.primary,
                ),
                _buildMetadataChip(
                  icon: Icons.language,
                  label: book.languageLabel,
                  color: Colors.blue,
                ),
                if (book.pageCount != null)
                  _buildMetadataChip(
                    icon: Icons.pages,
                    label: '${book.pageCount} trang',
                    color: Colors.green,
                  ),
                _buildMetadataChip(
                  icon: Icons.storage,
                  label: book.fileSizeFormatted,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatItem(
                  icon: Icons.download,
                  count: book.downloadCount,
                  label: 'Tải xuống',
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  icon: Icons.visibility,
                  count: book.viewCount,
                  label: 'Lượt xem',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Divider(),

          // Description
          if (book.description != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mô tả',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Tags
          if (book.tags.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thẻ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: book.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          // Bottom padding for bottomNavigationBar
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _viewPDF,
              icon: const Icon(Icons.visibility),
              label: const Text('Xem PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _downloadPDF,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_isDownloading ? 'Đang tải...' : 'Tải xuống'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultCover(Book book) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              book.title,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

