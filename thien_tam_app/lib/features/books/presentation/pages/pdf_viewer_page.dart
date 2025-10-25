import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../data/models/book.dart';

class PdfViewerPage extends StatefulWidget {
  final Book book;

  const PdfViewerPage({super.key, required this.book});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 0;
  int _totalPages = 0;

  String _getPdfUrl() {
    // Cloudinary raw URLs need proper flags for PDF viewer compatibility
    String url = widget.book.cloudinarySecureUrl;

    // Method 1: Try without any transformation first (direct raw URL)
    // Cloudinary raw URLs should work with PDF viewers if CORS is configured

    debugPrint('[PdfViewer] Using direct URL: $url');
    return url;
  }

  @override
  void initState() {
    super.initState();
    // Debug logging
    debugPrint('[PdfViewer] Book title: ${widget.book.title}');
    debugPrint('[PdfViewer] Original URL: ${widget.book.cloudinarySecureUrl}');
    debugPrint('[PdfViewer] Transformed URL: ${_getPdfUrl()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            if (_totalPages > 0)
              Text(
                'Trang $_currentPage / $_totalPages',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Zoom out
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  _pdfViewerController.zoomLevel - 0.25;
            },
          ),
          // Zoom in
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  _pdfViewerController.zoomLevel + 0.25;
            },
          ),
          // Jump to page
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showPageNavigator,
          ),
        ],
      ),
      body: widget.book.cloudinarySecureUrl.isNotEmpty
          ? Stack(
              children: [
                SfPdfViewer.network(
                  _getPdfUrl(),
                  controller: _pdfViewerController,
                  onPageChanged: (PdfPageChangedDetails details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                    });
                  },
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    debugPrint('[PdfViewer] Document loaded successfully!');
                    debugPrint(
                      '[PdfViewer] Total pages: ${details.document.pages.count}',
                    );
                    setState(() {
                      _totalPages = details.document.pages.count;
                    });
                  },
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    debugPrint('[PdfViewer] Load failed: ${details.error}');
                    debugPrint(
                      '[PdfViewer] Description: ${details.description}',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi tải PDF: ${details.description}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Chi tiết',
                            textColor: Colors.white,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Lỗi tải PDF'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Error: ${details.error}'),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Description: ${details.description}',
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Original URL: ${widget.book.cloudinarySecureUrl}',
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Transformed URL: ${_getPdfUrl()}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
                // Loading indicator
                if (_totalPages == 0)
                  const Center(child: CircularProgressIndicator()),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Không tìm thấy file PDF'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
      floatingActionButton: _totalPages > 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Previous page
                FloatingActionButton.small(
                  heroTag: 'prev_page',
                  onPressed: _currentPage > 1
                      ? () {
                          _pdfViewerController.previousPage();
                        }
                      : null,
                  backgroundColor: _currentPage > 1
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
                const SizedBox(height: 8),
                // Next page
                FloatingActionButton.small(
                  heroTag: 'next_page',
                  onPressed: _currentPage < _totalPages
                      ? () {
                          _pdfViewerController.nextPage();
                        }
                      : null,
                  backgroundColor: _currentPage < _totalPages
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  child: const Icon(Icons.arrow_downward, color: Colors.white),
                ),
              ],
            )
          : null,
    );
  }

  void _showPageNavigator() {
    if (_totalPages == 0) return;

    showDialog(
      context: context,
      builder: (context) {
        int targetPage = _currentPage;
        return AlertDialog(
          title: const Text('Chuyển đến trang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số trang (1-$_totalPages)',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  targetPage = int.tryParse(value) ?? _currentPage;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Trang hiện tại: $_currentPage / $_totalPages',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (targetPage >= 1 && targetPage <= _totalPages) {
                  _pdfViewerController.jumpToPage(targetPage);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Vui lòng nhập số trang từ 1 đến $_totalPages',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Chuyển'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}
