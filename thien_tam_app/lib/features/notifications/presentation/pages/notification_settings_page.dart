import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notification_service.dart';
import '../../../readings/data/buddhist_calendar_service.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  final NotificationService _notificationService = NotificationService();
  late bool _holidayRemindersEnabled;
  late bool _readingRemindersEnabled;
  late int _holidayReminderTime;
  late int _readingReminderTime;
  late List<String> _enabledHolidayTypes;

  @override
  void initState() {
    super.initState();
    _holidayRemindersEnabled = _notificationService.holidayRemindersEnabled;
    _readingRemindersEnabled = _notificationService.readingRemindersEnabled;
    _holidayReminderTime = _notificationService.holidayReminderTime;
    _readingReminderTime = _notificationService.readingReminderTime;
    _enabledHolidayTypes = List.from(_notificationService.enabledHolidayTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Holiday Reminders Section
            _buildSectionHeader(
              'Nhắc nhở ngày lễ',
              Icons.temple_buddhist,
              Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Bật nhắc nhở ngày lễ'),
                      subtitle: const Text(
                        'Nhận thông báo về các ngày lễ Phật giáo',
                      ),
                      value: _holidayRemindersEnabled,
                      onChanged: (value) {
                        setState(() {
                          _holidayRemindersEnabled = value;
                        });
                      },
                    ),

                    if (_holidayRemindersEnabled) ...[
                      const Divider(),
                      ListTile(
                        title: const Text('Thời gian nhắc nhở'),
                        subtitle: Text('${_holidayReminderTime}:00'),
                        trailing: const Icon(Icons.access_time),
                        onTap: _showTimePickerDialog,
                      ),

                      const Divider(),
                      const ListTile(
                        title: Text('Loại ngày lễ'),
                        subtitle: Text('Chọn loại ngày lễ muốn nhận thông báo'),
                      ),

                      ...HolidayType.values.map(
                        (type) => CheckboxListTile(
                          title: Text(type.displayName),
                          subtitle: Text(_getHolidayTypeDescription(type)),
                          value: _enabledHolidayTypes.contains(type.name),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _enabledHolidayTypes.add(type.name);
                              } else {
                                _enabledHolidayTypes.remove(type.name);
                              }
                            });
                          },
                          secondary: Icon(type.icon, color: type.color),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reading Reminders Section
            _buildSectionHeader(
              'Nhắc nhở đọc kinh',
              Icons.menu_book,
              Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Bật nhắc nhở đọc kinh'),
                      subtitle: const Text(
                        'Nhận thông báo về bài đọc hàng ngày',
                      ),
                      value: _readingRemindersEnabled,
                      onChanged: (value) {
                        setState(() {
                          _readingRemindersEnabled = value;
                        });
                      },
                    ),

                    if (_readingRemindersEnabled) ...[
                      const Divider(),
                      ListTile(
                        title: const Text('Thời gian nhắc nhở'),
                        subtitle: Text('${_readingReminderTime}:00'),
                        trailing: const Icon(Icons.access_time),
                        onTap: _showReadingTimePickerDialog,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Test Notifications Section
            _buildSectionHeader(
              'Kiểm tra thông báo',
              Icons.notifications_active,
              Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Gửi thông báo test'),
                      subtitle: const Text(
                        'Kiểm tra xem thông báo có hoạt động không',
                      ),
                      leading: const Icon(Icons.send),
                      onTap: _sendTestNotification,
                    ),

                    const Divider(),

                    ListTile(
                      title: const Text('Xem thông báo đã lên lịch'),
                      subtitle: const Text('Kiểm tra các thông báo sắp tới'),
                      leading: const Icon(Icons.schedule),
                      onTap: _showScheduledNotifications,
                    ),

                    const Divider(),

                    ListTile(
                      title: const Text('Xóa tất cả thông báo'),
                      subtitle: const Text('Hủy tất cả thông báo đã lên lịch'),
                      leading: const Icon(Icons.clear_all, color: Colors.red),
                      onTap: _clearAllNotifications,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text(
                  'Lưu cài đặt',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getHolidayTypeDescription(HolidayType type) {
    switch (type) {
      case HolidayType.major:
        return 'Các ngày lễ quan trọng như Phật Đản, Vu Lan';
      case HolidayType.traditional:
        return 'Các ngày lễ truyền thống Việt Nam';
      case HolidayType.buddhist:
        return 'Các ngày tu tập định kỳ như Rằm, Mùng Một';
    }
  }

  Future<void> _showTimePickerDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _holidayReminderTime, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _holidayReminderTime = picked.hour;
      });
    }
  }

  Future<void> _showReadingTimePickerDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _readingReminderTime, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _readingReminderTime = picked.hour;
      });
    }
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.showImmediateNotification(
      title: 'Test Thông báo',
      body: 'Thông báo đang hoạt động bình thường!',
      payload: 'test_notification',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi thông báo test'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showScheduledNotifications() async {
    final pendingNotifications = await _notificationService
        .getPendingNotifications();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thông báo đã lên lịch'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pendingNotifications.length,
              itemBuilder: (context, index) {
                final notification = pendingNotifications[index];
                return ListTile(
                  title: Text(notification.title ?? 'Không có tiêu đề'),
                  subtitle: Text(notification.body ?? 'Không có nội dung'),
                  trailing: Text('ID: ${notification.id}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _clearAllNotifications() async {
    await _notificationService.cancelAllNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa tất cả thông báo'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    await _notificationService.updateSettings(
      holidayRemindersEnabled: _holidayRemindersEnabled,
      readingRemindersEnabled: _readingRemindersEnabled,
      holidayReminderTime: _holidayReminderTime,
      readingReminderTime: _readingReminderTime,
      enabledHolidayTypes: _enabledHolidayTypes,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu cài đặt thông báo'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
