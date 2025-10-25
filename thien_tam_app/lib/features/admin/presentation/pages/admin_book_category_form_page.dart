import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../books/data/models/book_category.dart';
import '../providers/book_category_providers.dart';

class AdminBookCategoryFormPage extends ConsumerStatefulWidget {
  final BookCategory? category;

  const AdminBookCategoryFormPage({super.key, this.category});

  @override
  ConsumerState<AdminBookCategoryFormPage> createState() =>
      _AdminBookCategoryFormPageState();
}

class _AdminBookCategoryFormPageState
    extends ConsumerState<AdminBookCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nameEnController;
  late TextEditingController _descriptionController;
  late TextEditingController _iconController;
  late TextEditingController _colorController;
  late TextEditingController _displayOrderController;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _nameEnController = TextEditingController(text: widget.category?.nameEn);
    _descriptionController = TextEditingController(
      text: widget.category?.description,
    );
    _iconController = TextEditingController(
      text: widget.category?.icon ?? '📚',
    );
    _colorController = TextEditingController(
      text: widget.category?.color ?? '#8B7355',
    );
    _displayOrderController = TextEditingController(
      text: widget.category?.displayOrder.toString() ?? '0',
    );
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa danh mục' : 'Thêm danh mục'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên danh mục *',
                border: OutlineInputBorder(),
                helperText: 'Tên tiếng Việt của danh mục',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên danh mục';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameEnController,
              decoration: const InputDecoration(
                labelText: 'Tên tiếng Anh',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: 'Icon (Emoji)',
                border: OutlineInputBorder(),
                helperText: 'Nhập emoji để làm icon',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Màu sắc (Hex)',
                border: OutlineInputBorder(),
                helperText: 'Ví dụ: #8B7355',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayOrderController,
              decoration: const InputDecoration(
                labelText: 'Thứ tự hiển thị',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Kích hoạt'),
              subtitle: const Text('Danh mục có được hiển thị không'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCategory,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Cập nhật' : 'Tạo mới'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'name': _nameController.text.trim(),
        if (_nameEnController.text.isNotEmpty)
          'nameEn': _nameEnController.text.trim(),
        if (_descriptionController.text.isNotEmpty)
          'description': _descriptionController.text.trim(),
        'icon': _iconController.text.trim(),
        'color': _colorController.text.trim(),
        'displayOrder': int.tryParse(_displayOrderController.text) ?? 0,
        'isActive': _isActive,
      };

      final bool success;
      if (widget.category != null) {
        success = await ref
            .read(bookCategoryNotifierProvider.notifier)
            .updateCategory(widget.category!.id, data);
      } else {
        success = await ref
            .read(bookCategoryNotifierProvider.notifier)
            .createCategory(data);
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.category != null
                  ? 'Đã cập nhật danh mục'
                  : 'Đã tạo danh mục mới',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
