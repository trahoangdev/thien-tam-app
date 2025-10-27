import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/book_providers.dart';
import '../providers/book_category_providers.dart';
import '../../../books/data/models/book.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class AdminBookFormPage extends ConsumerStatefulWidget {
  final Book? book;

  const AdminBookFormPage({super.key, this.book});

  @override
  ConsumerState<AdminBookFormPage> createState() => _AdminBookFormPageState();
}

class _AdminBookFormPageState extends ConsumerState<AdminBookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _translatorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _cloudinaryUrlController = TextEditingController();
  final _coverUrlController = TextEditingController();

  String? _selectedCategory;
  String _selectedLanguage = 'vi';
  bool _isPublic = true;
  bool _isLoading = false;
  String? _selectedPdfPath;
  String? _selectedPdfFileName;
  String? _selectedCoverPath;
  String? _selectedCoverFileName;
  bool _useCloudinaryUrl = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author ?? '';
      _translatorController.text = widget.book!.translator ?? '';
      _descriptionController.text = widget.book!.description ?? '';
      _tagsController.text = widget.book!.tags.join(', ');
      _pageCountController.text = widget.book!.pageCount?.toString() ?? '';
      _selectedCategory = widget.book!.categoryId; // Get category ID
      _selectedLanguage = widget.book!.bookLanguage;
      _isPublic = widget.book!.isPublic;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _pageCountController.dispose();
    _cloudinaryUrlController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdfPath = result.files.single.path;
        _selectedPdfFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedCoverPath = result.files.single.path;
        _selectedCoverFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate category is selected
    if (_selectedCategory == null) {
      _showSnackBar('Vui lòng chọn thể loại', isError: true);
      return;
    }

    // Validation for new book
    if (widget.book == null) {
      if (_useCloudinaryUrl) {
        if (_cloudinaryUrlController.text.isEmpty) {
          _showSnackBar('Vui lòng nhập URL Cloudinary cho PDF', isError: true);
          return;
        }
      } else {
        if (_selectedPdfPath == null) {
          _showSnackBar('Vui lòng chọn file PDF', isError: true);
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ref.read(bookApiClientProvider);
      final token = ref.read(accessTokenProvider);

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final pageCount = int.tryParse(_pageCountController.text);

      if (widget.book == null) {
        // Create new book
        if (_useCloudinaryUrl) {
          await apiClient.createBookFromUrl(
            cloudinaryUrl: _cloudinaryUrlController.text,
            coverImageUrl: _coverUrlController.text.isEmpty
                ? null
                : _coverUrlController.text,
            title: _titleController.text,
            category: _selectedCategory!,
            author: _authorController.text.isEmpty
                ? null
                : _authorController.text,
            translator: _translatorController.text.isEmpty
                ? null
                : _translatorController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            bookLanguage: _selectedLanguage,
            tags: tags.isEmpty ? null : tags,
            pageCount: pageCount,
            isPublic: _isPublic,
            token: token,
          );
        } else {
          await apiClient.uploadBook(
            pdfPath: _selectedPdfPath!,
            coverPath: _selectedCoverPath,
            title: _titleController.text,
            category: _selectedCategory!,
            author: _authorController.text.isEmpty
                ? null
                : _authorController.text,
            translator: _translatorController.text.isEmpty
                ? null
                : _translatorController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            bookLanguage: _selectedLanguage,
            tags: tags.isEmpty ? null : tags,
            pageCount: pageCount,
            isPublic: _isPublic,
            token: token,
            onProgress: (progress) {
              ref.read(bookUploadProgressProvider.notifier).state = progress;
            },
          );
        }

        if (mounted) {
          _showSnackBar('Đã thêm kinh sách thành công', isError: false);
          Navigator.pop(context);
        }
      } else {
        // Update existing book
        await apiClient.updateBook(
          id: widget.book!.id,
          title: _titleController.text,
          author: _authorController.text.isEmpty
              ? null
              : _authorController.text,
          translator: _translatorController.text.isEmpty
              ? null
              : _translatorController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          category: _selectedCategory,
          bookLanguage: _selectedLanguage,
          tags: tags.isEmpty ? null : tags,
          pageCount: pageCount,
          isPublic: _isPublic,
          token: token,
        );

        if (mounted) {
          _showSnackBar('Đã cập nhật kinh sách thành công', isError: false);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Lỗi: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ref.read(bookUploadProgressProvider.notifier).state = 0.0;
      }
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
    final uploadProgress = ref.watch(bookUploadProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Thêm kinh sách' : 'Sửa kinh sách'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // URL Toggle (only for new books)
            if (widget.book == null) ...[
              SwitchListTile(
                title: const Text('Sử dụng URL Cloudinary'),
                subtitle: const Text(
                  'Nhập link thay vì upload file (tránh lag)',
                ),
                value: _useCloudinaryUrl,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _useCloudinaryUrl = value;
                          if (value) {
                            _selectedPdfPath = null;
                            _selectedPdfFileName = null;
                            _selectedCoverPath = null;
                            _selectedCoverFileName = null;
                          } else {
                            _cloudinaryUrlController.clear();
                            _coverUrlController.clear();
                          }
                        });
                      },
              ),
              const SizedBox(height: 16),
            ],

            // PDF URL Input (for new books with URL option)
            if (widget.book == null && _useCloudinaryUrl) ...[
              TextFormField(
                controller: _cloudinaryUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL PDF Cloudinary *',
                  hintText: 'https://res.cloudinary.com/.../book.pdf',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (_useCloudinaryUrl && (value == null || value.isEmpty)) {
                    return 'Vui lòng nhập URL PDF';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      !value.startsWith('http')) {
                    return 'URL không hợp lệ';
                  }
                  return null;
                },
                enabled: !_isLoading,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _coverUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL ảnh bìa Cloudinary',
                  hintText: 'https://res.cloudinary.com/.../cover.jpg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                enabled: !_isLoading,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
            ],

            // PDF File Picker (for new books without URL option)
            if (widget.book == null && !_useCloudinaryUrl) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(
                    _selectedPdfFileName ?? 'Chọn file PDF',
                    style: TextStyle(
                      color: _selectedPdfPath != null
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                  subtitle: const Text('PDF (tối đa 100MB)'),
                  trailing: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickPdfFile,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Chọn'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.image, color: Colors.blue),
                  title: Text(
                    _selectedCoverFileName ?? 'Chọn ảnh bìa (tùy chọn)',
                    style: TextStyle(
                      color: _selectedCoverPath != null
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                  subtitle: const Text('JPG, PNG (tối đa 5MB)'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedCoverPath != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _selectedCoverPath = null;
                                    _selectedCoverFileName = null;
                                  });
                                },
                        ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pickCoverImage,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Chọn'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Upload Progress (only for file uploads)
            if (_isLoading && !_useCloudinaryUrl && uploadProgress > 0) ...[
              LinearProgressIndicator(value: uploadProgress),
              const SizedBox(height: 8),
              Text(
                'Đang tải lên: ${(uploadProgress * 100).toInt()}%',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên kinh sách *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên kinh sách';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Author
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Tác giả',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Translator
            TextFormField(
              controller: _translatorController,
              decoration: const InputDecoration(
                labelText: 'Người dịch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.translate),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Category - Load from API
            Consumer(
              builder: (context, ref, child) {
                final categoriesState = ref.watch(bookCategoryNotifierProvider);

                return categoriesState.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Chưa có danh mục. Vui lòng tạo danh mục trước.',
                          ),
                        ),
                      );
                    }

                    // Auto-select first category if none selected
                    if (_selectedCategory == null && categories.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _selectedCategory = categories.first.id;
                        });
                      });
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Thể loại *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Row(
                            children: [
                              Text(
                                category.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(category.name)),
                            ],
                          ),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn thể loại';
                        }
                        return null;
                      },
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stack) => Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Lỗi load danh mục: $error'),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Language
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Ngôn ngữ *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
              items: const [
                DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'zh', child: Text('中文')),
                DropdownMenuItem(value: 'pi', child: Text('Pali')),
                DropdownMenuItem(value: 'sa', child: Text('Sanskrit')),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Thẻ (phân cách bằng dấu phẩy)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
                hintText: 'phật giáo, tịnh độ, thiền',
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Page Count
            TextFormField(
              controller: _pageCountController,
              decoration: const InputDecoration(
                labelText: 'Số trang',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pages),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Is Public
            SwitchListTile(
              title: const Text('Công khai'),
              subtitle: const Text('Hiển thị trong thư viện công cộng'),
              value: _isPublic,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.book == null ? 'Thêm kinh sách' : 'Cập nhật',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
