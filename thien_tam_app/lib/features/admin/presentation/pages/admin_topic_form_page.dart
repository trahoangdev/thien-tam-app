import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/topic_providers.dart';
import '../../data/models/topic.dart';

class AdminTopicFormPage extends ConsumerStatefulWidget {
  final Topic? topic; // null for create, non-null for edit

  const AdminTopicFormPage({super.key, this.topic});

  @override
  ConsumerState<AdminTopicFormPage> createState() => _AdminTopicFormPageState();
}

class _AdminTopicFormPageState extends ConsumerState<AdminTopicFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _slugController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconController = TextEditingController();

  String _selectedColor = '#4CAF50';
  int _sortOrder = 0;
  bool _isActive = true;

  final List<String> _predefinedColors = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#00BCD4', // Cyan
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];

  final List<String> _predefinedIcons = [
    'label',
    'spa',
    'favorite',
    'lightbulb',
    'book',
    'star',
    'home',
    'school',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.topic != null) {
      _loadTopicData(widget.topic!);
    }
  }

  @override
  void dispose() {
    _slugController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _loadTopicData(Topic topic) {
    _slugController.text = topic.slug;
    _nameController.text = topic.name;
    _descriptionController.text = topic.description;
    _iconController.text = topic.icon;
    _selectedColor = topic.color;
    _sortOrder = topic.sortOrder;
    _isActive = topic.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(topicFormProvider);
    final isEdit = widget.topic != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa chủ đề' : 'Tạo chủ đề mới'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (formState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin cơ bản',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Slug field
                      TextFormField(
                        controller: _slugController,
                        decoration: const InputDecoration(
                          labelText: 'Slug *',
                          hintText: 'chinh-niem',
                          helperText: 'Chỉ chữ thường, số và dấu gạch ngang',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !isEdit, // Slug cannot be changed when editing
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Slug không được để trống';
                          }
                          if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
                            return 'Slug chỉ được chứa chữ thường, số và dấu gạch ngang';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên chủ đề *',
                          hintText: 'Chính niệm',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tên chủ đề không được để trống';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          hintText: 'Mô tả ngắn về chủ đề này...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Appearance Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giao diện',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Color selection
                      Text(
                        'Màu sắc',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _predefinedColors.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(color.replaceFirst('#', '0xFF')),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(color: Colors.black, width: 3)
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Icon selection
                      Text(
                        'Biểu tượng',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _predefinedIcons.map((iconName) {
                          final isSelected = _iconController.text == iconName;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _iconController.text = iconName;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              child: Icon(
                                _getIconData(iconName),
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Settings Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cài đặt',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sort order
                      TextFormField(
                        initialValue: _sortOrder.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Thứ tự sắp xếp',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _sortOrder = int.tryParse(value) ?? 0;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Active status
                      SwitchListTile(
                        title: const Text('Trạng thái hoạt động'),
                        subtitle: Text(
                          _isActive
                              ? 'Chủ đề đang hoạt động'
                              : 'Chủ đề đã tạm khóa',
                        ),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Error message
              if (formState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: formState.isLoading ? null : _saveTopic,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: formState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Cập nhật chủ đề' : 'Tạo chủ đề'),
                ),
              ),
            ],
          ),
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
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      default:
        return Icons.label;
    }
  }

  Future<void> _saveTopic() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(topicFormProvider.notifier);
    final apiClient = ref.read(topicApiClientProvider);

    try {
      formNotifier.setLoading(true);
      formNotifier.setError(null);

      if (widget.topic == null) {
        // Create new topic
        await apiClient.createTopic(
          slug: _slugController.text.trim(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          color: _selectedColor,
          icon: _iconController.text.trim(),
          sortOrder: _sortOrder,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo chủ đề thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        // Update existing topic
        await apiClient.updateTopic(
          id: widget.topic!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          color: _selectedColor,
          icon: _iconController.text.trim(),
          isActive: _isActive,
          sortOrder: _sortOrder,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật chủ đề thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      formNotifier.setError(e.toString());
    } finally {
      formNotifier.setLoading(false);
    }
  }
}
