import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_providers.dart';
import '../../../../core/config.dart';

// Supabase init guard
bool _sbInitialized = false;

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  late TextEditingController _nameController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _error = 'Tên không được để trống';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final updated = await ref
          .read(authServiceProvider)
          .updateProfile(name: _nameController.text.trim());
      ref.read(currentUserProvider.notifier).state = updated;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật tên thành công')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi cập nhật: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateDateOfBirth() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final now = DateTime.now();
    final initial =
        user.dateOfBirth ?? DateTime(now.year - 20, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final updated = await ref
            .read(authServiceProvider)
            .updateProfile(dateOfBirth: picked);
        ref.read(currentUserProvider.notifier).state = updated;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật ngày sinh thành công')),
          );
        }
      } catch (e) {
        setState(() {
          _error = 'Lỗi cập nhật: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _updateAvatar() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Initialize Supabase if needed
      if (!_sbInitialized) {
        try {
          await Supabase.initialize(
            url: AppConfig.supabaseUrl,
            anonKey: AppConfig.supabaseAnonKey,
          );
          _sbInitialized = true;
          print('✅ Supabase initialized successfully');
        } catch (e) {
          throw Exception('Không thể kết nối Supabase: $e');
        }
      }

      // Pick image (file_picker handles permissions internally)
      print('📸 Opening file picker...');
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (picked == null || picked.files.isEmpty) {
        print('❌ No file selected');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final file = picked.files.first;
      print(
        '✅ File selected: ${file.name}, size: ${file.bytes?.length ?? 0} bytes',
      );

      if (file.bytes == null) {
        throw Exception('Không thể đọc file ảnh. Vui lòng thử lại.');
      }

      // Upload to Supabase
      final fileName =
          'avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.${file.extension ?? 'png'}';
      final path = 'users/${user.id}/$fileName';

      print('📤 Uploading to Supabase: $path');
      final storage = Supabase.instance.client.storage.from('avatars');

      try {
        await storage.uploadBinary(
          path,
          file.bytes!,
          fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
        );
        print('✅ Upload successful');
      } catch (e) {
        throw Exception('Lỗi upload ảnh lên Supabase: $e');
      }

      final publicUrl = storage.getPublicUrl(path);
      print('🔗 Public URL: $publicUrl');

      // Update profile with new avatar URL
      print('💾 Updating profile...');
      final updated = await ref
          .read(authServiceProvider)
          .updateProfile(avatar: publicUrl);
      ref.read(currentUserProvider.notifier).state = updated;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Đã cập nhật ảnh đại diện thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isLoading = _isLoading;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thông Tin Cá Nhân')),
        body: const Center(child: Text('Vui lòng đăng nhập để xem thông tin')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Thông Tin Cá Nhân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error message
                if (_error != null)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Avatar Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              backgroundImage:
                                  (user.avatar != null &&
                                      user.avatar!.isNotEmpty)
                                  ? NetworkImage(user.avatar!)
                                  : null,
                              child:
                                  (user.avatar == null || user.avatar!.isEmpty)
                                  ? Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: isLoading ? null : _updateAvatar,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ảnh Đại Diện',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Name Section
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Họ và Tên',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Nhập tên của bạn',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _updateName,
                            ),
                          ),
                          onSubmitted: (_) => _updateName(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Email Section (Read-only)
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                    trailing: const Icon(Icons.lock_outline),
                  ),
                ),

                const SizedBox(height: 16),

                // Date of Birth Section
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.cake_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Ngày Sinh'),
                    subtitle: Text(
                      user.dateOfBirth != null
                          ? '${user.dateOfBirth!.day.toString().padLeft(2, '0')}/${user.dateOfBirth!.month.toString().padLeft(2, '0')}/${user.dateOfBirth!.year}'
                          : 'Chưa cập nhật',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: isLoading ? null : _updateDateOfBirth,
                  ),
                ),

                const SizedBox(height: 16),

                // Account Info Section
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Thông Tin Tài Khoản',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Vai trò'),
                        subtitle: Text(user.role.displayName),
                      ),
                      ListTile(
                        title: const Text('Trạng thái'),
                        subtitle: Text(
                          user.isActive ? 'Đang hoạt động' : 'Đã khóa',
                          style: TextStyle(
                            color: user.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Ngày tham gia'),
                        subtitle: Text(
                          '${user.createdAt.day.toString().padLeft(2, '0')}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.year}',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
