import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _notificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final NotificationService instance = NotificationService();

  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  static const String channelId = 'habit_reminder_channel';
  static const String channelName = 'Reminders';
  static const String channelDescription =
      'Notifications for scheduled reminders and habit alerts';

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
    );
  }

  Future<bool> requestPermissions() async {
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted =
          await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  bool isScheduleValid(DateTime scheduledDate) {
    return scheduledDate.isAfter(DateTime.now());
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    String? notes,
    required DateTime scheduledDate,
  }) async {
    if (!isScheduleValid(scheduledDate)) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id,
      title,
      notes,
      notificationDetails,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
