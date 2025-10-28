import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/settings_providers.dart';
import '../providers/reading_providers.dart';
import '../../data/reading_stats_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/permission_providers.dart'
    as permissions;
import '../../../auth/data/models/user.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/register_page.dart';
import '../../../notifications/presentation/pages/notification_settings_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  ThemeMode _tempThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    // Initialize temp values from current settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ref = this.ref;
      _tempThemeMode = ref.read(themeModeProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = ref.read(settingsServiceProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isGuestMode = ref.watch(permissions.isGuestModeProvider);
    final effectiveRole = ref.watch(permissions.effectiveUserRoleProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Cài Đặt',
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
      body: ListView(
        children: [
          // User Profile Section
          _SectionHeader(title: 'Thông Tin Tài Khoản'),
          if (currentUser != null) ...[
            _UserProfileCard(user: currentUser),
          ] else if (isGuestMode) ...[
            _GuestProfileCard(role: effectiveRole),
          ] else ...[
            _LoginPromptCard(),
          ],
          const SizedBox(height: 16),

          // Appearance Section
          _SectionHeader(title: 'Giao Diện'),

          // Theme Mode
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Chế độ hiển thị'),
            subtitle: Text(_getThemeModeText(_tempThemeMode)),
            trailing: DropdownButton<ThemeMode>(
              value: _tempThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Hệ thống'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Sáng')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Tối')),
              ],
              onChanged: (mode) async {
                if (mode != null) {
                  setState(() {
                    _tempThemeMode = mode;
                  });
                  // Save immediately
                  final settingsService = ref.read(settingsServiceProvider);
                  await settingsService.setThemeMode(mode);
                  ref.read(themeModeProvider.notifier).state = mode;
                }
              },
            ),
          ),

          const Divider(),

          // Notification Settings Section
          _SectionHeader(title: 'Cài Đặt Thông Báo'),

          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Cài đặt thông báo'),
            subtitle: const Text('Nhắc nhở ngày lễ và đọc kinh'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),

          const Divider(),

          // Admin Section
          _SectionHeader(title: 'Quản Trị'),

          // Developer Mode Toggle
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer(
              builder: (context, ref, child) {
                final developerMode = ref.watch(developerModeProvider);
                return SwitchListTile(
                  secondary: Icon(
                    Icons.developer_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Nhà phát triển',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Bật/tắt chế độ nhà phát triển'),
                  value: developerMode,
                  onChanged: (value) async {
                    final settingsService = ref.read(settingsServiceProvider);
                    await settingsService.setDeveloperMode(value);
                    ref.read(developerModeProvider.notifier).state = value;
                  },
                );
              },
            ),
          ),

          // Admin Panel (only visible when developer mode is enabled)
          Consumer(
            builder: (context, ref, child) {
              final developerMode = ref.watch(developerModeProvider);
              if (!developerMode) return const SizedBox.shrink();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.admin_panel_settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Admin Panel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Quản lý nội dung và người dùng'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Check if user is already admin
                    if (currentUser != null) {
                      final userRole = permissions.UserRole.fromString(
                        currentUser.role.value,
                      );
                      if (userRole.canAccessAdminPanel) {
                        Navigator.of(context).pushNamed('/admin/home');
                      } else {
                        // User doesn't have admin rights, go to admin login
                        Navigator.of(context).pushNamed('/admin/login');
                      }
                    } else {
                      // No user logged in, go to admin login
                      Navigator.of(context).pushNamed('/admin/login');
                    }
                  },
                ),
              );
            },
          ),

          // Clear Cache Button
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: const Text(
                'Làm mới dữ liệu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Xóa cache và tải lại bài đọc mới nhất'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Show confirmation dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Làm mới dữ liệu'),
                    content: const Text(
                      'Xóa cache và tải lại bài đọc mới nhất từ server?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Làm mới'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  // Clear cache
                  final repo = ref.read(repoProvider);
                  await repo.clearCache();

                  // Invalidate all providers để force reload
                  ref.invalidate(todayProvider);
                  ref.invalidate(monthReadingsProvider);

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Đã làm mới dữ liệu'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
          ),

          const Divider(),

          // About Section
          _SectionHeader(title: 'Về Ứng Dụng'),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Phiên bản'),
            subtitle: const Text('1.3.0'),
          ),

          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Mã nguồn'),
            subtitle: const Text('GitHub'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              const url = 'https://github.com/trahoangdev/thien-tam-app';

              // Show dialog with options instead of direct launch
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Mở GitHub'),
                    content: const Text(
                      'Bạn muốn mở GitHub repository trong browser không?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          // Copy to clipboard as fallback
                          await Clipboard.setData(
                            const ClipboardData(
                              text:
                                  'https://github.com/trahoangdev/thien-tam-app',
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Đã copy link GitHub vào clipboard. Vui lòng paste vào browser.',
                                ),
                                backgroundColor: Colors.blue,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        child: const Text('Copy Link'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            // Try different launch modes
                            await launchUrl(
                              Uri.parse(url),
                              mode: LaunchMode.platformDefault,
                            );
                          } catch (e) {
                            // If still fails, copy to clipboard
                            await Clipboard.setData(
                              const ClipboardData(
                                text:
                                    'https://github.com/trahoangdev/thien-tam-app',
                              ),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Không thể mở browser. Đã copy link vào clipboard.',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Mở Browser'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Đánh giá ứng dụng'),
            trailing: const Icon(Icons.star_border),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cảm ơn bạn! ❤️')));
            },
          ),

          const SizedBox(height: 16),

          // Reset Settings
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Đặt lại cài đặt?'),
                        content: const Text(
                          'Tất cả cài đặt sẽ trở về mặc định.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Đặt lại'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      await settingsService.setFontSize(1);
                      await settingsService.setThemeMode(ThemeMode.system);
                      await settingsService.setLineHeight(1.8);

                      ref.read(fontSizeProvider.notifier).state = 1;
                      ref.read(themeModeProvider.notifier).state =
                          ThemeMode.system;
                      ref.read(lineHeightProvider.notifier).state = 1.8;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã đặt lại cài đặt')),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Đặt lại cài đặt'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Đặt lại thống kê?'),
                          content: const Text(
                            'Bạn có chắc muốn đặt lại tất cả thống kê đọc bài? Hành động này không thể hoàn tác.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Đặt lại'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await ref
                            .read(readingStatsProvider.notifier)
                            .resetStats();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã đặt lại thống kê'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Đặt lại thống kê'),
                  ),
                ),
              ],
            ),
          ),

          // Logout Section
          if (currentUser != null) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: 'Tài Khoản'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Đăng xuất?'),
                      content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Đăng xuất'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    await ref.read(authServiceProvider).logout();
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      default:
        return 'Theo hệ thống';
    }
  }
}

class _UserProfileCard extends ConsumerWidget {
  final User user;

  const _UserProfileCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingStats = ref.watch(readingStatsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.role.isPremium
                        ? Colors.amber.withOpacity(0.2)
                        : Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: user.role.isPremium
                          ? Colors.amber.shade800
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.auto_stories_outlined,
                    label: 'Bài đọc',
                    value: readingStats.totalReadings.toString(),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.timer_outlined,
                    label: 'Thời gian',
                    value: '${readingStats.totalReadingTime} phút',
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Chuỗi ngày',
                    value: '${readingStats.streakDays} ngày',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestProfileCard extends ConsumerWidget {
  final permissions.UserRole role;

  const _GuestProfileCard({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tài khoản khách',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chế độ xem không đăng nhập',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Quyền hạn của bạn:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _PermissionChip('Đọc bài viết', true),
                _PermissionChip('Xem lịch', true),
                _PermissionChip('Đánh dấu', false),
                _PermissionChip('Lịch sử', false),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Đăng nhập để có thêm quyền'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginPromptCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Đăng nhập để trải nghiệm đầy đủ',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập để lưu bookmark và xem lịch sử',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Đăng nhập'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Đăng ký'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final String label;
  final bool enabled;

  const _PermissionChip(this.label, this.enabled);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enabled
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check : Icons.close,
            size: 12,
            color: enabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: enabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
