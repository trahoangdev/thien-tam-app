import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'package:flutter/services.dart';
import '../../readings/data/buddhist_calendar_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification settings
  bool _holidayRemindersEnabled = true;
  bool _readingRemindersEnabled = true;
  bool _dailyReadingRemindersEnabled = true;
  int _holidayReminderHour = 8; // 8:00 AM
  int _holidayReminderMinute = 0;
  int _readingReminderHour = 7; // 7:00 AM
  int _readingReminderMinute = 0;
  int _dailyReadingReminderHour = 9; // 9:00 AM
  int _dailyReadingReminderMinute = 0;
  List<String> _enabledHolidayTypes = ['major', 'traditional', 'buddhist'];

  // Getters
  bool get holidayRemindersEnabled => _holidayRemindersEnabled;
  bool get readingRemindersEnabled => _readingRemindersEnabled;
  bool get dailyReadingRemindersEnabled => _dailyReadingRemindersEnabled;
  int get holidayReminderHour => _holidayReminderHour;
  int get holidayReminderMinute => _holidayReminderMinute;
  int get readingReminderHour => _readingReminderHour;
  int get readingReminderMinute => _readingReminderMinute;
  int get dailyReadingReminderHour => _dailyReadingReminderHour;
  int get dailyReadingReminderMinute => _dailyReadingReminderMinute;
  List<String> get enabledHolidayTypes => _enabledHolidayTypes;

  // Setters
  set holidayRemindersEnabled(bool value) => _holidayRemindersEnabled = value;
  set readingRemindersEnabled(bool value) => _readingRemindersEnabled = value;
  set dailyReadingRemindersEnabled(bool value) =>
      _dailyReadingRemindersEnabled = value;
  set holidayReminderHour(int value) => _holidayReminderHour = value;
  set holidayReminderMinute(int value) => _holidayReminderMinute = value;
  set readingReminderHour(int value) => _readingReminderHour = value;
  set readingReminderMinute(int value) => _readingReminderMinute = value;
  set dailyReadingReminderHour(int value) => _dailyReadingReminderHour = value;
  set dailyReadingReminderMinute(int value) =>
      _dailyReadingReminderMinute = value;
  set enabledHolidayTypes(List<String> value) => _enabledHolidayTypes = value;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _isInitialized = true;

    // Auto-schedule reminders after initialization
    await _autoScheduleReminders();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      // Request battery optimization exemption
      await _requestBatteryOptimizationExemption();
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _requestBatteryOptimizationExemption() async {
    if (Platform.isAndroid) {
      try {
        const platform = MethodChannel('com.thientam.app/battery_optimization');
        await platform.invokeMethod('requestBatteryOptimizationExemption');
      } catch (e) {
        print('Error requesting battery optimization exemption: $e');
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  // Auto-schedule reminders when app initializes
  Future<void> _autoScheduleReminders() async {
    try {
      // Wait a bit to ensure permissions are granted
      await Future.delayed(const Duration(seconds: 2));

      // Schedule holiday reminders if enabled
      if (_holidayRemindersEnabled) {
        await _scheduleWithRetry(
          () => scheduleHolidayReminders(),
          'holiday reminders',
        );
      }

      // Schedule reading reminders if enabled
      if (_readingRemindersEnabled) {
        await _scheduleWithRetry(
          () => _scheduleReadingRemindersForNextDays(),
          'reading reminders',
        );
      }

      // Schedule daily reading reminders if enabled
      if (_dailyReadingRemindersEnabled) {
        await _scheduleWithRetry(
          () => _scheduleDailyReadingReminders(),
          'daily reading reminders',
        );
      }

      print('All reminders auto-scheduled successfully');
    } catch (e) {
      print('Error auto-scheduling reminders: $e');
      // Retry once after a delay
      await Future.delayed(const Duration(seconds: 5));
      try {
        if (_holidayRemindersEnabled) {
          await scheduleHolidayReminders();
        }
        if (_readingRemindersEnabled) {
          await _scheduleReadingRemindersForNextDays();
        }
        print('Reminders scheduled on retry');
      } catch (retryError) {
        print('Failed to schedule reminders on retry: $retryError');
      }
    }
  }

  // Helper method to schedule with retry logic
  Future<void> _scheduleWithRetry(
    Future<void> Function() scheduleFunction,
    String type,
  ) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        await scheduleFunction();
        print('Successfully scheduled $type');
        return;
      } catch (e) {
        attempts++;
        print('Attempt $attempts failed for $type: $e');
        if (attempts < maxAttempts) {
          await Future.delayed(Duration(seconds: attempts * 2));
        }
      }
    }
    print('Failed to schedule $type after $maxAttempts attempts');
  }

  // Schedule holiday reminders for the next 30 days
  Future<void> scheduleHolidayReminders() async {
    if (!_holidayRemindersEnabled) return;

    try {
      final now = DateTime.now();
      int scheduledCount = 0;

      for (int i = 0; i < 30; i++) {
        final date = now.add(Duration(days: i));
        final holidays = BuddhistCalendarService.getHolidaysForDay(
          date.month,
          date.day,
        );

        if (holidays.isNotEmpty) {
          for (final holiday in holidays) {
            if (_enabledHolidayTypes.contains(holiday.type.name)) {
              try {
                await _scheduleHolidayNotification(holiday, date);
                scheduledCount++;
              } catch (e) {
                print(
                  'Failed to schedule holiday notification for ${holiday.name}: $e',
                );
              }
            }
          }
        }
      }

      print('Scheduled $scheduledCount holiday reminders');
    } catch (e) {
      print('Error scheduling holiday reminders: $e');
      rethrow;
    }
  }

  Future<void> _scheduleHolidayNotification(
    BuddhistHoliday holiday,
    DateTime date,
  ) async {
    final scheduledDate = tz.TZDateTime.from(
      DateTime(
        date.year,
        date.month,
        date.day,
        _holidayReminderHour,
        _holidayReminderMinute,
      ),
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'holiday_reminders',
          'Nhắc nhở ngày lễ',
          channelDescription: 'Thông báo về các ngày lễ Phật giáo',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
          showWhen: true,
          autoCancel: false,
          ongoing: false,
          visibility: NotificationVisibility.public,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _generateNotificationId(holiday, date),
      'Ngày lễ Phật giáo',
      'Hôm nay là ${holiday.name} - ${holiday.description}',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'holiday_${holiday.name}_${date.millisecondsSinceEpoch}',
    );
  }

  // Schedule reading reminders for days with readings
  Future<void> scheduleReadingReminders(List<DateTime> readingDates) async {
    if (!_readingRemindersEnabled) return;

    for (final date in readingDates) {
      await _scheduleReadingNotification(date);
    }
  }

  // Schedule reading reminders for the next 30 days (assuming every day has readings)
  Future<void> _scheduleReadingRemindersForNextDays() async {
    if (!_readingRemindersEnabled) return;

    try {
      final now = DateTime.now();
      int scheduledCount = 0;

      for (int i = 0; i < 30; i++) {
        final date = now.add(Duration(days: i));
        try {
          await _scheduleReadingNotification(date);
          scheduledCount++;
        } catch (e) {
          print(
            'Failed to schedule reading notification for ${date.toString()}: $e',
          );
        }
      }

      print('Scheduled $scheduledCount reading reminders');
    } catch (e) {
      print('Error scheduling reading reminders: $e');
      rethrow;
    }
  }

  // Schedule daily reading reminders for the next 30 days
  Future<void> _scheduleDailyReadingReminders() async {
    if (!_dailyReadingRemindersEnabled) return;

    try {
      final now = DateTime.now();
      int scheduledCount = 0;

      for (int i = 0; i < 30; i++) {
        final date = now.add(Duration(days: i));
        try {
          await _scheduleDailyReadingNotification(date);
          scheduledCount++;
        } catch (e) {
          print(
            'Failed to schedule daily reading notification for ${date.toString()}: $e',
          );
        }
      }

      print('Scheduled $scheduledCount daily reading reminders');
    } catch (e) {
      print('Error scheduling daily reading reminders: $e');
      rethrow;
    }
  }

  Future<void> _scheduleDailyReadingNotification(DateTime date) async {
    final scheduledDate = tz.TZDateTime.from(
      DateTime(
        date.year,
        date.month,
        date.day,
        _dailyReadingReminderHour,
        _dailyReadingReminderMinute,
      ),
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_reading_reminders',
          'Nhắc đọc hằng ngày',
          channelDescription: 'Thông báo nhắc đọc bài mỗi ngày',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
          showWhen: true,
          autoCancel: false,
          ongoing: false,
          visibility: NotificationVisibility.public,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _generateDailyReadingNotificationId(date),
      'Nhắc đọc hằng ngày',
      'Hãy dành thời gian để đọc và suy ngẫm bài học hôm nay.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reading_${date.millisecondsSinceEpoch}',
    );
  }

  Future<void> _scheduleReadingNotification(DateTime date) async {
    final scheduledDate = tz.TZDateTime.from(
      DateTime(
        date.year,
        date.month,
        date.day,
        _readingReminderHour,
        _readingReminderMinute,
      ),
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reading_reminders',
          'Nhắc nhở đọc kinh',
          channelDescription: 'Thông báo về bài đọc hàng ngày',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
          showWhen: true,
          autoCancel: false,
          ongoing: false,
          visibility: NotificationVisibility.public,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _generateReadingNotificationId(date),
      'Bài đọc hàng ngày',
      'Hôm nay có bài đọc mới. Hãy dành thời gian để đọc và suy ngẫm.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'reading_${date.millisecondsSinceEpoch}',
    );
  }

  // Generate unique notification ID
  int _generateNotificationId(BuddhistHoliday holiday, DateTime date) {
    return holiday.name.hashCode + date.millisecondsSinceEpoch.hashCode;
  }

  int _generateReadingNotificationId(DateTime date) {
    return 'reading_${date.millisecondsSinceEpoch}'.hashCode;
  }

  int _generateDailyReadingNotificationId(DateTime date) {
    return 'daily_reading_${date.millisecondsSinceEpoch}'.hashCode;
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'immediate_notifications',
          'Thông báo tức thì',
          channelDescription: 'Thông báo hiển thị ngay lập tức',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Update notification settings
  Future<void> updateSettings({
    bool? holidayRemindersEnabled,
    bool? readingRemindersEnabled,
    bool? dailyReadingRemindersEnabled,
    int? holidayReminderHour,
    int? holidayReminderMinute,
    int? readingReminderHour,
    int? readingReminderMinute,
    int? dailyReadingReminderHour,
    int? dailyReadingReminderMinute,
    List<String>? enabledHolidayTypes,
  }) async {
    try {
      // Update settings
      if (holidayRemindersEnabled != null)
        _holidayRemindersEnabled = holidayRemindersEnabled;
      if (readingRemindersEnabled != null)
        _readingRemindersEnabled = readingRemindersEnabled;
      if (dailyReadingRemindersEnabled != null)
        _dailyReadingRemindersEnabled = dailyReadingRemindersEnabled;
      if (holidayReminderHour != null)
        _holidayReminderHour = holidayReminderHour;
      if (holidayReminderMinute != null)
        _holidayReminderMinute = holidayReminderMinute;
      if (readingReminderHour != null)
        _readingReminderHour = readingReminderHour;
      if (readingReminderMinute != null)
        _readingReminderMinute = readingReminderMinute;
      if (dailyReadingReminderHour != null)
        _dailyReadingReminderHour = dailyReadingReminderHour;
      if (dailyReadingReminderMinute != null)
        _dailyReadingReminderMinute = dailyReadingReminderMinute;
      if (enabledHolidayTypes != null)
        _enabledHolidayTypes = enabledHolidayTypes;

      // Clear existing notifications first
      await _notifications.cancelAll();

      // Wait a bit before rescheduling
      await Future.delayed(const Duration(milliseconds: 500));

      // Reschedule notifications with new settings
      if (_holidayRemindersEnabled) {
        await _scheduleWithRetry(
          () => scheduleHolidayReminders(),
          'holiday reminders',
        );
      }

      // Also schedule reading reminders if enabled
      if (_readingRemindersEnabled) {
        await _scheduleWithRetry(
          () => _scheduleReadingRemindersForNextDays(),
          'reading reminders',
        );
      }

      // Also schedule daily reading reminders if enabled
      if (_dailyReadingRemindersEnabled) {
        await _scheduleWithRetry(
          () => _scheduleDailyReadingReminders(),
          'daily reading reminders',
        );
      }

      print('Settings updated and reminders rescheduled successfully');
    } catch (e) {
      print('Error updating settings: $e');
      // Don't rethrow to avoid breaking the UI
    }
  }
}
