import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/todo.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  Future<bool> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final bool? androidGranted = await androidImplementation
        ?.requestNotificationsPermission();

    final iOSImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final bool? iOSGranted = await iOSImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await androidImplementation?.requestExactAlarmsPermission();

    return (androidGranted ?? false) || (iOSGranted ?? false);
  }

  int _getNotificationId(String todoId) {
    return todoId.hashCode & 0x7FFFFFFF;
  }

  Future<void> scheduleNotification(Todo todo) async {
    await cancelNotification(todo.id);

    if (todo.isCompleted) return;
    if (todo.dueDate == null || todo.reminder == TodoReminder.none) return;

    final scheduleTime = _calculateReminderTime(todo.dueDate!, todo.reminder);
    if (scheduleTime.isBefore(DateTime.now())) return;

    final tzScheduleTime = tz.TZDateTime.from(scheduleTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tidyduu_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for TidyDuu task reminders',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: _getNotificationId(todo.id),
      title: 'Task Reminder: ${todo.title}',
      body: todo.description.isNotEmpty
          ? todo.description
          : 'Your task is starting soon.',
      scheduledDate: tzScheduleTime,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(String todoId) async {
    await _notificationsPlugin.cancel(id: _getNotificationId(todoId));
  }

  Future<void> showInstantNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tidyduu_focus',
          'Focus Reminders',
          channelDescription: 'Notifications for TidyDuu Focus Mode sessions',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      id: 999, // Static ID for focus session alerts
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  DateTime _calculateReminderTime(DateTime dueDate, TodoReminder reminder) {
    switch (reminder) {
      case TodoReminder.atDueTime:
        return dueDate;
      case TodoReminder.tenMinutesBefore:
        return dueDate.subtract(const Duration(minutes: 10));
      case TodoReminder.oneHourBefore:
        return dueDate.subtract(const Duration(hours: 1));
      case TodoReminder.oneDayBefore:
        return dueDate.subtract(const Duration(days: 1));
      case TodoReminder.none:
        return dueDate;
    }
  }
}
