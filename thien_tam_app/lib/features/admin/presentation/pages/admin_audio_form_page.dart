import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/audio_providers.dart';
import '../providers/admin_providers.dart';
import '../../../audio/data/models/audio.dart';

class AdminAudioFormPage extends ConsumerStatefulWidget {
  final Audio? audio;

  const AdminAudioFormPage({super.key, this.audio});

  @override
  ConsumerState<AdminAudioFormPage> createState() => _AdminAudioFormPageState();
}

class _AdminAudioFormPageState extends ConsumerState<AdminAudioFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _artistController = TextEditingController();
  final _tagsController = TextEditingController();
  final _cloudinaryUrlController = TextEditingController();

  String _selectedCategory = 'other';
  bool _isPublic = true;
  bool _isLoading = false;
  File? _selectedFile;
  String? _selectedFileName;
  bool _useCloudinaryUrl = false; // Toggle between file upload and URL input

  @override
  void initState() {
    super.initState();
    if (widget.audio != null) {
      _titleController.text = widget.audio!.title;
      _descriptionController.text = widget.audio!.description ?? '';
      _artistController.text = widget.audio!.artist ?? '';
      _tagsController.text = widget.audio!.tags.join(', ');
      _selectedCategory = widget.audio!.category;
      _isPublic = widget.audio!.isPublic;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _artistController.dispose();
    _tagsController.dispose();
    _cloudinaryUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        setState(() {
          _selectedFile = file;
          _selectedFileName = result.files.first.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn file: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if file or URL is provided for new audio
    if (widget.audio == null) {
      if (_useCloudinaryUrl && _cloudinaryUrlController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập URL Cloudinary')),
        );
        return;
      }
      if (!_useCloudinaryUrl && _selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn file audio')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ref.read(audioApiClientProvider);
      final token = ref.read(accessTokenProvider);

      if (token == null) {
        throw Exception('No admin token');
      }

      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (widget.audio == null) {
        // Create new audio
        if (_useCloudinaryUrl) {
          // Create from URL
          await apiClient.createAudioFromUrl(
            cloudinaryUrl: _cloudinaryUrlController.text,
            title: _titleController.text,
            category: _selectedCategory,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            artist: _artistController.text.isEmpty
                ? null
                : _artistController.text,
            tags: tags.isEmpty ? null : tags,
            isPublic: _isPublic,
            token: token,
          );
        } else {
          // Upload file
          await apiClient.uploadAudio(
            filePath: _selectedFile!.path,
            title: _titleController.text,
            category: _selectedCategory,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            artist: _artistController.text.isEmpty
                ? null
                : _artistController.text,
            tags: tags.isEmpty ? null : tags,
            isPublic: _isPublic,
            token: token,
            onUploadProgress: (sent, total) {
              final progress = sent / total;
              ref.read(audioUploadProgressProvider.notifier).state = progress;
            },
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _useCloudinaryUrl
                    ? 'Đã tạo audio từ URL thành công'
                    : 'Đã upload audio thành công',
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Update existing audio
        await apiClient.updateAudio(
          id: widget.audio!.id,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          artist: _artistController.text.isEmpty
              ? null
              : _artistController.text,
          category: _selectedCategory,
          tags: tags.isEmpty ? null : tags,
          isPublic: _isPublic,
          token: token,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật audio thành công')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ref.read(audioUploadProgressProvider.notifier).state = 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadProgress = ref.watch(audioUploadProgressProvider);
    final categoriesAsync = ref.watch(audioCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.audio == null ? 'Thêm Audio' : 'Sửa Audio'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Toggle between file upload and URL input (only for new audio)
            if (widget.audio == null) ...[
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
                            _selectedFile = null;
                            _selectedFileName = null;
                          } else {
                            _cloudinaryUrlController.clear();
                          }
                        });
                      },
              ),
              const SizedBox(height: 16),
            ],

            // Cloudinary URL Input (only for new audio with URL mode)
            if (widget.audio == null && _useCloudinaryUrl) ...[
              TextFormField(
                controller: _cloudinaryUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Cloudinary *',
                  hintText: 'https://res.cloudinary.com/.../audio.mp3',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (_useCloudinaryUrl && (value == null || value.isEmpty)) {
                    return 'Vui lòng nhập URL Cloudinary';
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
            ],

            // File Picker (only for new audio with file mode)
            if (widget.audio == null && !_useCloudinaryUrl) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.audiotrack),
                  title: Text(
                    _selectedFileName ?? 'Chọn file audio',
                    style: TextStyle(
                      color: _selectedFileName != null
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  subtitle: const Text('MP3, WAV, OGG, AAC, FLAC'),
                  trailing: const Icon(Icons.upload_file),
                  onTap: _isLoading ? null : _pickFile,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Upload Progress
            if (_isLoading && uploadProgress > 0) ...[
              LinearProgressIndicator(value: uploadProgress),
              const SizedBox(height: 8),
              Text(
                'Đang upload: ${(uploadProgress * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                if (value.length > 200) {
                  return 'Tiêu đề không được quá 200 ký tự';
                }
                return null;
              },
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
              maxLines: 3,
              maxLength: 1000,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Artist
            TextFormField(
              controller: _artistController,
              decoration: const InputDecoration(
                labelText: 'Nghệ sĩ / Giảng sư',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              maxLength: 100,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Category
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Danh mục *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.value,
                    child: Text(cat.label),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Lỗi tải danh mục'),
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (phân cách bằng dấu phẩy)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
                helperText: 'Ví dụ: thiền, kinh, pháp thoại',
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Is Public
            SwitchListTile(
              title: const Text('Công khai'),
              subtitle: Text(
                _isPublic
                    ? 'Audio sẽ hiển thị cho tất cả người dùng'
                    : 'Audio chỉ admin mới thấy',
              ),
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
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(widget.audio == null ? 'Upload Audio' : 'Cập nhật'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
