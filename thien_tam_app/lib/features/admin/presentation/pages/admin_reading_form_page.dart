import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/admin_readings_providers.dart';
import '../../data/models/reading_create_request.dart';
import '../../data/models/reading_update_request.dart';

class AdminReadingFormPage extends ConsumerStatefulWidget {
  final String? readingId; // null = create mode, non-null = edit mode

  const AdminReadingFormPage({super.key, this.readingId});

  @override
  ConsumerState<AdminReadingFormPage> createState() =>
      _AdminReadingFormPageState();
}

class _AdminReadingFormPageState extends ConsumerState<AdminReadingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _topicsController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _sourceController = TextEditingController(text: 'Admin');

  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  bool get _isEditMode => widget.readingId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _topicsController.dispose();
    _keywordsController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final crud = ref.read(adminReadingsCrudProvider.notifier);

      if (_isEditMode) {
        // Update mode
        final request = ReadingUpdateRequest(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          topicSlugs: _topicsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          keywords: _keywordsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          source: _sourceController.text.trim(),
        );

        await crud.updateReading(widget.readingId!, request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Cập nhật thành công')),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Create mode
        final request = ReadingCreateRequest(
          date: _selectedDate,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          topicSlugs: _topicsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          keywords: _keywordsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          source: _sourceController.text.trim(),
        );

        await crud.createReading(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Tạo bài đọc thành công')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load existing data in edit mode
    if (_isEditMode) {
      final readingAsync = ref.watch(
        adminReadingByIdProvider(widget.readingId!),
      );

      return readingAsync.when(
        data: (reading) {
          // Populate form with existing data (only once)
          if (_titleController.text.isEmpty) {
            _titleController.text = reading.title;
            _bodyController.text = reading.body ?? '';
            _topicsController.text = reading.topicSlugs.join(', ');
            _keywordsController.text = reading.keywords.join(', ');
            _sourceController.text = reading.source;
            _selectedDate = reading.date;
          }

          return _buildForm();
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Đang tải...')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Lỗi')),
          body: Center(child: Text('Lỗi tải dữ liệu: $error')),
        ),
      );
    }

    return _buildForm();
  }

  Widget _buildForm() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Sửa bài đọc' : 'Tạo bài đọc mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Ngày'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.edit),
                onTap: _isEditMode
                    ? null
                    : _selectDate, // Can't change date in edit mode
                enabled: !_isEditMode,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Body
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Nội dung *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.article),
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập nội dung';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Topics
            TextFormField(
              controller: _topicsController,
              decoration: const InputDecoration(
                labelText: 'Topics (ngăn cách bởi dấu phẩy)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                hintText: 'chinh-niem, tu-bi, giac-ngo',
              ),
            ),
            const SizedBox(height: 16),

            // Keywords
            TextFormField(
              controller: _keywordsController,
              decoration: const InputDecoration(
                labelText: 'Keywords (ngăn cách bởi dấu phẩy)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
                hintText: 'chánh niệm, từ bi, giác ngộ',
              ),
            ),
            const SizedBox(height: 16),

            // Source
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Nguồn',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.source),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isEditMode ? 'Cập nhật' : 'Tạo bài đọc',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
