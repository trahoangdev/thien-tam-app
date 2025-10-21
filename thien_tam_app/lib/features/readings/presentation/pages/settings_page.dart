import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/settings_providers.dart';
import '../providers/reading_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsService = ref.read(settingsServiceProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final lineHeight = ref.watch(lineHeightProvider);

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
          // Appearance Section
          _SectionHeader(title: 'Giao Diện'),

          // Theme Mode
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Chế độ hiển thị'),
            subtitle: Text(_getThemeModeText(themeMode)),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
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
                  await settingsService.setThemeMode(mode);
                  ref.read(themeModeProvider.notifier).state = mode;
                }
              },
            ),
          ),

          const Divider(),

          // Reading Section
          _SectionHeader(title: 'Đọc Bài'),

          // Font Size
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Kích thước chữ'),
            subtitle: Text(_getFontSizeText(fontSize)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Nhỏ'),
                Expanded(
                  child: Slider(
                    value: fontSize.toDouble(),
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: _getFontSizeText(fontSize),
                    onChanged: (value) async {
                      final newSize = value.toInt();
                      await settingsService.setFontSize(newSize);
                      ref.read(fontSizeProvider.notifier).state = newSize;
                    },
                  ),
                ),
                const Text('Lớn'),
              ],
            ),
          ),

          // Line Height
          ListTile(
            leading: const Icon(Icons.format_line_spacing),
            title: const Text('Khoảng cách dòng'),
            subtitle: Text('${lineHeight.toStringAsFixed(1)}x'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Hẹp'),
                Expanded(
                  child: Slider(
                    value: lineHeight,
                    min: 1.2,
                    max: 2.5,
                    divisions: 13,
                    label: '${lineHeight.toStringAsFixed(1)}x',
                    onChanged: (value) async {
                      await settingsService.setLineHeight(value);
                      ref.read(lineHeightProvider.notifier).state = value;
                    },
                  ),
                ),
                const Text('Rộng'),
              ],
            ),
          ),

          const Divider(),

          // Notifications Section
          _SectionHeader(title: 'Thông Báo'),

          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Nhắc đọc hằng ngày'),
            subtitle: const Text('Thông báo lúc 7:00 sáng mỗi ngày'),
            value: notificationsEnabled,
            onChanged: (value) async {
              await settingsService.setNotificationsEnabled(value);
              ref.read(notificationsEnabledProvider.notifier).state = value;

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Đã bật thông báo hằng ngày'
                          : 'Đã tắt thông báo hằng ngày',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),

          const Divider(),

          // Admin Section
          _SectionHeader(title: 'Quản Trị'),

          Card(
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
              subtitle: const Text('Quản lý nội dung (yêu cầu đăng nhập)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pushNamed('/admin/login');
              },
            ),
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
            subtitle: const Text('1.0.0'),
          ),

          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Mã nguồn'),
            subtitle: const Text('GitHub'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open GitHub link
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Mở GitHub...')));
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

          const SizedBox(height: 32),

          // Reset Settings
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Đặt lại cài đặt?'),
                    content: const Text('Tất cả cài đặt sẽ trở về mặc định.'),
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
                  await settingsService.setNotificationsEnabled(true);

                  ref.read(fontSizeProvider.notifier).state = 1;
                  ref.read(themeModeProvider.notifier).state = ThemeMode.system;
                  ref.read(lineHeightProvider.notifier).state = 1.8;
                  ref.read(notificationsEnabledProvider.notifier).state = true;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đặt lại cài đặt')),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Đặt lại cài đặt'),
            ),
          ),
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

  String _getFontSizeText(int size) {
    switch (size) {
      case 0:
        return 'Nhỏ (14px)';
      case 2:
        return 'Lớn (18px)';
      default:
        return 'Vừa (16px)';
    }
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
