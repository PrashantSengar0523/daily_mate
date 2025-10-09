// ignore_for_file: avoid_print

import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:daily_mate/data/services/notification_service.dart';

class ExerciseReminderController extends GetxController {
  final Rx<TimeOfDay?> reminderTime = Rx<TimeOfDay?>(null);
  var activeExerciseReminder = {}.obs;

  /// Check if reminder is active
  bool get hasActiveReminder => activeExerciseReminder.isNotEmpty;

  final _notificationService = NotificationService();

  @override
  void onInit() {
    loadReminder();
    super.onInit();
  }

  /// Save reminder with validation + scheduling daily notifications
  Future<void> saveReminder() async {
    // Validation
    if (reminderTime.value == null) {
      TDialogs.customToast(
        message: "Please select reminder time",
        isSucces: false,
      );
      return;
    }

    // Check if reminder already exists
    if (activeExerciseReminder.isNotEmpty) {
      TDialogs.customToast(
        message:
            "Exercise reminder already exists. Delete first to create new.",
        isSucces: false,
      );
      return;
    }

    try {
      // Schedule daily repeating notification
      await _notificationService.scheduleDailyExerciseReminder(
        reminderTime.value!,
        "🏃 Exercise Reminder",
        "Time to do your exercise! Let's get moving! 💪",
      );

      // Save to local storage
      _saveToLocal();

      TDialogs.customToast(
        message: "Daily exercise reminder set successfully!",
        isSucces: true,
      );

      // Reset form
      reminderTime.value = null;
    } catch (e) {
      TDialogs.customToast(
        message: "Failed to set reminder. Try again.",
        isSucces: false,
      );
      print("Error saving exercise reminder: $e");
    }
  }

  /// Save reminder details to local storage
  void _saveToLocal() {
    final reminderData = {
      "reminderTime":
          "${reminderTime.value!.hour}:${reminderTime.value!.minute}",
      "createdAt": DateTime.now().toIso8601String(),
      "isActive": true,
    };

    storageService.write(exerciseReminderIdKey, reminderData);
    activeExerciseReminder.value = reminderData;
  }

  /// Load reminder from storage
  void loadReminder() {
    final data = storageService.read(exerciseReminderIdKey);
    if (data != null && data["isActive"] == true) {
      activeExerciseReminder.value = data;
    }
  }

  /// Delete reminder manually
  Future<void> deleteReminder() async {
    try {
      // Cancel all pending notifications for exercise
      await _cancelAllExerciseNotifications();

      // Remove from local storage
      storageService.remove(exerciseReminderIdKey);
      activeExerciseReminder.clear();

      TDialogs.customToast(
        message: "Exercise reminder deleted successfully",
        isSucces: true,
      );
    } catch (e) {
      TDialogs.customToast(
        message: "Failed to delete reminder",
        isSucces: false,
      );
      print("Error deleting exercise reminder: $e");
    }
  }

  /// Cancel all exercise notifications
  Future<void> _cancelAllExerciseNotifications() async {
    final pendingNotifications =
        await _notificationService.flutterLocalNotificationsPlugin
            .pendingNotificationRequests();

    // Cancel exercise related notifications
    for (var notification in pendingNotifications) {
      if (notification.title?.contains("Exercise") == true) {
        await _notificationService.flutterLocalNotificationsPlugin.cancel(
          notification.id,
        );
      }
    }
  }

  /// Reset all fields
  void reset() {
    reminderTime.value = null;
  }

  // /// Get formatted time string for display
  // String getFormattedTime() {
  //   if (activeExerciseReminder.isEmpty) return "";

  //   final timeStr = activeExerciseReminder["reminderTime"];
  //   if (timeStr == null) return "";

  //   final parts = timeStr.split(":");
  //   if (parts.length != 2) return "";

  //   final hour = int.tryParse(parts[0]) ?? 0;
  //   final minute = int.tryParse(parts[1]) ?? 0;

  //   final timeOfDay = TimeOfDay(hour: hour, minute: minute);
  //   final now = DateTime.now();
  //   final dateTime = DateTime(now.year, now.month, now.day, hour, minute);

  //   return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  // }

  Future<void> debugTimeZone() async {
    final now = tz.TZDateTime.now(tz.local);
    final deviceTime = DateTime.now();

    print("=== TIMEZONE DEBUG ===");
    print("Device local time: $deviceTime");
    print("TZ local time: $now");
    print("Timezone name: ${now.timeZoneName}");
    print("Timezone offset: ${now.timeZoneOffset}");
    print("Is same moment? ${deviceTime.isAtSameMomentAs(now.toLocal())}");

    if (reminderTime.value != null) {
      final testSchedule = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminderTime.value!.hour,
        reminderTime.value!.minute,
      );
      print("Test schedule time: $testSchedule");
      print(
        "Minutes until notification: ${testSchedule.difference(now).inMinutes}",
      );
    }
    print("=====================");
  }

  /// Debug method to check pending notifications
  Future<void> checkPendingNotifications() async {
    final pendingNotifications =
        await _notificationService.flutterLocalNotificationsPlugin
            .pendingNotificationRequests();

    print("=== EXERCISE PENDING NOTIFICATIONS ===");
    for (var notification in pendingNotifications) {
      if (notification.title?.contains("Exercise") == true) {
        print("ID: ${notification.id}");
        print("Title: ${notification.title}");
        print("Body: ${notification.body}");
        print("------------------------");
      }
    }
    print(
      "Total exercise notifications: ${pendingNotifications.where((n) => n.title?.contains("Exercise") == true).length}",
    );
  }

  // Method 1: Check if daily repeat is properly set
Future<void> verifyDailyRepeat() async {
  final pendingNotifications = await _notificationService
      .flutterLocalNotificationsPlugin
      .pendingNotificationRequests();
  
  print("=== DAILY REPEAT VERIFICATION ===");
  
  for (var notification in pendingNotifications) {
    if (notification.title?.contains("Exercise") == true) {
      print("Notification ID: ${notification.id}");
      print("Title: ${notification.title}");
      print("Body: ${notification.body}");
      
      // Check if it has repeat components
      print("This notification should repeat daily at same time");
      print("------------------------");
    }
  }
  
  // The key is: with matchDateTimeComponents: DateTimeComponents.time,
  // it should automatically create recurring notifications
  print("Total exercise notifications pending: ${pendingNotifications.where((n) => n.title?.contains("Exercise") == true).length}");
  print("If count = 1, it means ONE repeating notification is set correctly");
  print("================================");
}
}
