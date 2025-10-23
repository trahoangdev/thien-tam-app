import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
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
  int _holidayReminderTime = 8; // 8:00 AM
  int _readingReminderTime = 7; // 7:00 AM
  List<String> _enabledHolidayTypes = ['major', 'traditional', 'buddhist'];

  // Getters
  bool get holidayRemindersEnabled => _holidayRemindersEnabled;
  bool get readingRemindersEnabled => _readingRemindersEnabled;
  int get holidayReminderTime => _holidayReminderTime;
  int get readingReminderTime => _readingReminderTime;
  List<String> get enabledHolidayTypes => _enabledHolidayTypes;

  // Setters
  set holidayRemindersEnabled(bool value) => _holidayRemindersEnabled = value;
  set readingRemindersEnabled(bool value) => _readingRemindersEnabled = value;
  set holidayReminderTime(int value) => _holidayReminderTime = value;
  set readingReminderTime(int value) => _readingReminderTime = value;
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
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  // Schedule holiday reminders for the next 30 days
  Future<void> scheduleHolidayReminders() async {
    if (!_holidayRemindersEnabled) return;

    await _notifications.cancelAll(); // Clear existing notifications

    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      final holidays = BuddhistCalendarService.getHolidaysForDay(
        date.month,
        date.day,
      );

      if (holidays.isNotEmpty) {
        for (final holiday in holidays) {
          if (_enabledHolidayTypes.contains(holiday.type.name)) {
            await _scheduleHolidayNotification(holiday, date);
          }
        }
      }
    }
  }

  Future<void> _scheduleHolidayNotification(
    BuddhistHoliday holiday,
    DateTime date,
  ) async {
    final scheduledDate = tz.TZDateTime.from(
      DateTime(date.year, date.month, date.day, _holidayReminderTime),
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'holiday_reminders',
          'Nhắc nhở ngày lễ',
          channelDescription: 'Thông báo về các ngày lễ Phật giáo',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
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

  Future<void> _scheduleReadingNotification(DateTime date) async {
    final scheduledDate = tz.TZDateTime.from(
      DateTime(date.year, date.month, date.day, _readingReminderTime),
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reading_reminders',
          'Nhắc nhở đọc kinh',
          channelDescription: 'Thông báo về bài đọc hàng ngày',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
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
    int? holidayReminderTime,
    int? readingReminderTime,
    List<String>? enabledHolidayTypes,
  }) async {
    if (holidayRemindersEnabled != null)
      _holidayRemindersEnabled = holidayRemindersEnabled;
    if (readingRemindersEnabled != null)
      _readingRemindersEnabled = readingRemindersEnabled;
    if (holidayReminderTime != null) _holidayReminderTime = holidayReminderTime;
    if (readingReminderTime != null) _readingReminderTime = readingReminderTime;
    if (enabledHolidayTypes != null) _enabledHolidayTypes = enabledHolidayTypes;

    // Reschedule notifications with new settings
    await scheduleHolidayReminders();
  }
}
