// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:math';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;


class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_id',
    'Channel Title',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );

  NotificationService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  /// Request notification permissions (for Android 13+)
  Future<bool?> requestPermissions() async {
    if (flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >() !=
        null) {
      return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .requestNotificationsPermission();
    }
    return null;
  }

  /// Check if notifications are enabled
  Future<bool?> areNotificationsEnabled() async {
    if (flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >() !=
        null) {
      return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .areNotificationsEnabled();
    }
    return null;
  }

   void showNotification({
    required String title,
    required String body,
    required String? payload,
  }) {
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: payload,
    );
  }

  /// Generate Unique 10-digit Random ID
  int _generateUniqueId() {
    final rand = Random();
    return 1000000000 + rand.nextInt(899999999);
  }

  Future<int> scheduleWaterReminders({
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int cupSize,
    required int targetMl,
  }) async {
    try {
      // Calculate total cups needed
      final totalCups = (targetMl / cupSize).ceil();

      // Calculate time range in minutes
      final startTotalMinutes = startHour * 60 + startMinute;
      final endTotalMinutes = endHour * 60 + endMinute;
      final totalMinutes = endTotalMinutes - startTotalMinutes;

      // Edge case: Invalid time range
      if (totalMinutes <= 0) {
        TDialogs.customToast(
          message: "Error: End time must be after start time",
          isSucces: false,
        );
        return -1;
      }

      // Edge case: Not enough time (minimum 2 minutes between reminders)
      final minimumTimeNeeded = totalCups * 2; // 2 minutes minimum gap
      if (totalMinutes < minimumTimeNeeded) {
        TDialogs.customToast(
          message:
              "Error: Not enough time for all reminders. Need at least $minimumTimeNeeded minutes",
          isSucces: false,
        );
        return -1;
      }

      // Calculate interval between reminders
      final intervalMinutes = (totalMinutes / totalCups).floor();

      // Generate reminder times
      final List<DateTime> reminderTimes = [];
      final now = DateTime.now();

      for (int i = 0; i < totalCups; i++) {
        final reminderMinutes = startTotalMinutes + (i * intervalMinutes);
        final reminderHour = reminderMinutes ~/ 60;
        final reminderMinute = reminderMinutes % 60;

        // Create DateTime for today
        DateTime reminderDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          reminderHour,
          reminderMinute,
        );

        // If reminder time has passed today, schedule for tomorrow
        if (reminderDateTime.isBefore(now)) {
          reminderDateTime = reminderDateTime.add(const Duration(days: 1));
        }

        reminderTimes.add(reminderDateTime);
      }

      // Generate a parent ID for this reminder set
      final parentId = _generateUniqueId();

      // Schedule all notifications
      for (int i = 0; i < reminderTimes.length; i++) {
        final scheduledTime = tz.TZDateTime.from(reminderTimes[i], tz.local);
        final notificationId = parentId + i; // Unique ID for each notification

        final cupNumber = i + 1;
        final remainingCups = totalCups - i;
        final remainingMl = remainingCups * cupSize;

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          "💧 Time to Drink Water!",
          "Cup $cupNumber of $totalCups • ${cupSize}ml\nRemaining: ${remainingMl}ml",
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'water_reminder_channel_id',
              'Water Reminders',
              channelDescription: 'Daily water intake reminder notifications',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              enableVibration: true,
              color: Color(0xFF2196F3), // Blue color for water
              largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
        );

        print(
          "Scheduled water reminder $cupNumber at ${scheduledTime.toString()}",
        );
      }

      print(
        "Successfully scheduled $totalCups water reminders with parent ID: $parentId",
      );
      return parentId;
    } catch (e) {
      print("Error scheduling water reminders: $e");
      return -1;
    }
  }

  /// Cancel all water reminder notifications for a given parent ID
  Future<void> cancelWaterReminders(int parentId, int totalCups) async {
    try {
      for (int i = 0; i < totalCups; i++) {
        final notificationId = parentId + i;
        await flutterLocalNotificationsPlugin.cancel(notificationId);
        print("Cancelled water reminder notification: $notificationId");
      }
      print("All water reminders cancelled for parent ID: $parentId");
    } catch (e) {
      print("Error cancelling water reminders: $e");
    }
  }

  /// Cancel a single notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      print("Cancelled notification with ID: $id");
    } catch (e) {
      print("Error cancelling notification: $e");
    }
  }

  // /// Schedule a one-time reminder (today only)
  // Future<void> scheduleOneTimeMedicineReminder(
  //   DateTime dateTime,
  //   String title,
  //   String description,
  // ) async {
  //   final id = _generateUniqueId();

  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     id,
  //     title,
  //     description,
  //     tz.TZDateTime.from(dateTime, tz.local),
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         channelDescription: channel.description,
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         icon: '@mipmap/ic_launcher',
  //       ),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }

  // /// Schedule daily reminders for N days
  // Future<void> scheduleDailyMedicineReminder(
  //   TimeOfDay reminderTime,
  //   int days,
  //   String title,
  //   String description,
  // ) async {
  //   final now = DateTime.now();

  //   // Calculate first notification time
  //   DateTime firstNotificationTime = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     reminderTime.hour,
  //     reminderTime.minute,
  //   );

  //   // If today's reminder time has passed, start from tomorrow
  //   if (firstNotificationTime.isBefore(now) ||
  //       firstNotificationTime.isAtSameMomentAs(now)) {
  //     firstNotificationTime = firstNotificationTime.add(Duration(days: 1));
  //   }

  //   // Schedule notifications for the specified number of days
  //   for (int i = 0; i < days; i++) {
  //     final scheduledDateTime = firstNotificationTime.add(Duration(days: i));
  //     final scheduledTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
  //     final id = _generateUniqueId();

  //     print("Scheduling notification $i for: $scheduledTime"); // Debug log

  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //       id,
  //       title,
  //       description,
  //       scheduledTime,
  //       NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           channel.id,
  //           channel.name,
  //           channelDescription: channel.description,
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           icon: '@mipmap/ic_launcher',
  //         ),
  //       ),
  //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     );
  //   }
  // }

  /// Schedule a one-time reminder (today only)
Future<void> scheduleOneTimeMedicineReminder(
  DateTime dateTime,
  String title,
  String description,
) async {
  final id = _generateUniqueId();

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    description,
    tz.TZDateTime.from(dateTime, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

/// Schedule daily reminders for N days
Future<void> scheduleDailyMedicineReminder(
  TimeOfDay reminderTime,
  int days,
  String title,
  String description,
) async {
  final now = DateTime.now();

  // Calculate first notification time
  DateTime firstNotificationTime = DateTime(
    now.year,
    now.month,
    now.day,
    reminderTime.hour,
    reminderTime.minute,
  );

  // If today's reminder time has passed, start from tomorrow
  if (firstNotificationTime.isBefore(now) ||
      firstNotificationTime.isAtSameMomentAs(now)) {
    firstNotificationTime = firstNotificationTime.add(Duration(days: 1));
  }

  // Schedule notifications for the specified number of days
  for (int i = 0; i < days; i++) {
    final scheduledDateTime = firstNotificationTime.add(Duration(days: i));
    final scheduledTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
    final id = _generateUniqueId();

    print("Scheduling notification ${i + 1}/$days for: $scheduledTime");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      description,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // Add sound and vibration for better visibility
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      
    );
  }
}

/// Cancel all medicine notifications
Future<void> cancelAllMedicineNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

/// Cancel specific notification by ID (if you store notification IDs)
Future<void> cancelMedicineNotification(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

  /// Schedule daily exercise reminder
  Future<void> scheduleDailyExerciseReminder(
    TimeOfDay reminderTime,
    String title,
    String description,
  ) async {
    // Use device local time (same as medicine method)
    final now = DateTime.now();

    // Calculate notification time using device local time
    DateTime notificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // If today's reminder time has passed, start from tomorrow
    if (notificationTime.isBefore(now) ||
        notificationTime.isAtSameMomentAs(now)) {
      notificationTime = notificationTime.add(const Duration(days: 1));
    }

    // Convert to TZDateTime (same as medicine method)
    final scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);
    final id = _generateUniqueId();

    // Debug logs
    print("Device current time: $now");
    print("Notification time: $notificationTime");
    print("TZ Scheduled time: $scheduledTime");
    print(
      "Minutes until notification: ${notificationTime.difference(now).inMinutes}",
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      description,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'exercise_reminder_channel_id',
          'Exercise Reminders',
          channelDescription: 'Daily exercise reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
    );

    print("Exercise reminder scheduled successfully with ID: $id");
  }

  /// Debug/test method: schedules a one-time notification after X minutes
  Future<void> scheduleTestReminder(
    int afterMinutes,
    String title,
    String description,
  ) async {
    final now = tz.TZDateTime.now(tz.local);

    final scheduledTime = now.add(Duration(minutes: afterMinutes));

    final id = _generateUniqueId();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      "🔔 Test Water Reminder",
      "This is a test notification after $afterMinutes minutes.",
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // 
   /// Schedule reminder for a note
  Future<void> scheduleNoteReminder({
    required String noteId,
    required String title,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      noteId.hashCode, // unique ID per note
      "Note Reminder",
      title,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'note_channel',
          'Note Reminders',
          channelDescription: 'Reminders for saved notes',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// Cancel reminder
  Future<void> cancelNoteReminder(String noteId) async {
    await flutterLocalNotificationsPlugin.cancel(noteId.hashCode);
  }
  
}

@pragma('vm:entry-point')
Future<void> onDidReceiveBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  print("Tapped on notification: ${response.payload}");
  // Handle notification tap action here
  // You can navigate to specific screens or perform actions
}
