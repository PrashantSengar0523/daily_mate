// ignore_for_file: avoid_print


import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:daily_mate/data/services/notification_service.dart';

class MedicineReminderController extends GetxController {
  final TextEditingController medicineName = TextEditingController();
  final Rx<TimeOfDay?> reminderTime = Rx<TimeOfDay?>(null);
  final RxInt selectedDuration = 1.obs;
  final RxnInt customDays = RxnInt();
  
  // Changed: Now stores list of all active reminders
  var activeMedicineReminders = <Map<String, dynamic>>[].obs;

  final storage = GetStorage();
  final _notificationService = NotificationService();

  @override
  void onInit() {
    loadReminders();
    super.onInit();
  }

  /// Save reminder with validation + scheduling
  Future<void> saveReminder() async {
    // Validation
    if (medicineName.value.text.trim().isEmpty) {
      TDialogs.customToast(
          message: "Please enter medicine name", isSucces: false);
      return;
    }
    if (reminderTime.value == null) {
      TDialogs.customToast(
          message: "Please select reminder time", isSucces: false);
      return;
    }

    final days = customDays.value ?? selectedDuration.value;
    if (days <= 0) {
      TDialogs.customToast(
          message: "Invalid duration selected", isSucces: false);
      return;
    }

    // Generate unique ID for this reminder
    final reminderId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final title = "💊 ${medicineName.value.text}";
    final body = "It's time to take your medicine";

    if (days == 1) {
      /// Case 1: Today only
      final minutes = getMinutesUntilReminder(reminderTime.value);
      if (minutes != null && minutes > 0) {
        final dateTime = DateTime.now().add(Duration(minutes: minutes));
        await _notificationService.scheduleOneTimeMedicineReminder(
          dateTime,
          title,
          body,
        );
        _saveToLocal(days, reminderId);
        TDialogs.customToast(
            message: "Reminder set for today", isSucces: true);
      } else {
        TDialogs.customToast(
            message: "Selected time already passed", isSucces: false);
      }
    } else {
      /// Case 2 & 3: Multiple days
      await _notificationService.scheduleDailyMedicineReminder(
        reminderTime.value!,
        days,
        title,
        body,
      );
      _saveToLocal(days, reminderId);
      TDialogs.customToast(
          message: "Reminder set for next $days days", isSucces: true);
    }

    medicineName.clear();
    reminderTime.value = null;
    selectedDuration.value = 1;
    customDays.value = null;
  }

  /// Save reminder details into local storage
  void _saveToLocal(int days, String reminderId) {
    // Calculate actual end date (not just days from now)
    final startDate = DateTime.now();
    DateTime expiryDate;
    
    if (days == 1) {
      // For today only, expire at end of day
      expiryDate = DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59);
    } else {
      // For multiple days, calculate the last notification time
      final reminderHour = reminderTime.value!.hour;
      final reminderMinute = reminderTime.value!.minute;
      
      // Check if today's reminder time has passed
      final todayReminderTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        reminderHour,
        reminderMinute,
      );
      
      int actualDays = days;
      if (todayReminderTime.isBefore(startDate)) {
        // Today's time passed, so notifications will start tomorrow
        actualDays = days; // Already counted correctly
      }
      
      // Expiry should be after the last notification
      expiryDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        reminderHour,
        reminderMinute,
      ).add(Duration(days: actualDays));
    }

    final reminderData = {
      "id": reminderId,
      "medicineName": medicineName.value.text.trim(),
      "reminderTime": "${reminderTime.value!.hour}:${reminderTime.value!.minute}",
      "duration": days,
      "startDate": startDate.toIso8601String(),
      "expiry": expiryDate.toIso8601String(),
    };

    // Load existing reminders
    final existingReminders = storage.read<List>("medicine_reminders") ?? [];
    
    // Add new reminder
    final updatedReminders = List<Map<String, dynamic>>.from(
      existingReminders.map((e) => Map<String, dynamic>.from(e))
    );
    updatedReminders.add(reminderData);
    
    // Save back to storage
    storage.write("medicine_reminders", updatedReminders);
    
    // Update observable
    activeMedicineReminders.value = updatedReminders;
  }

  /// Load reminders from storage (and clear expired ones)
  void loadReminders() {
    final data = storage.read<List>("medicine_reminders");
    if (data != null && data.isNotEmpty) {
      final now = DateTime.now();
      final validReminders = <Map<String, dynamic>>[];
      
      for (var reminder in data) {
        final reminderMap = Map<String, dynamic>.from(reminder);
        final expiry = DateTime.tryParse(reminderMap["expiry"] ?? "");
        
        if (expiry != null && now.isBefore(expiry)) {
          validReminders.add(reminderMap);
        }
      }
      
      // Update storage with only valid reminders
      if (validReminders.length != data.length) {
        storage.write("medicine_reminders", validReminders);
      }
      
      activeMedicineReminders.value = validReminders;
    } else {
      activeMedicineReminders.clear();
    }
  }

  /// Delete specific reminder
  Future<void> deleteReminder(String reminderId) async {
    final reminders = storage.read<List>("medicine_reminders") ?? [];
    final updatedReminders = reminders
        .where((r) => Map<String, dynamic>.from(r)["id"] != reminderId)
        .toList();
    
    storage.write("medicine_reminders", updatedReminders);
    activeMedicineReminders.value = List<Map<String, dynamic>>.from(
      updatedReminders.map((e) => Map<String, dynamic>.from(e))
    );

    // Cancel all notifications for this reminder (you'll need to implement this)
    // await _notificationService.cancelMedicineReminders(reminderId);

    TDialogs.customToast(
        message: "Reminder deleted successfully", isSucces: true);
  }

  /// Delete all reminders
  Future<void> deleteAllReminders() async {
    storage.remove("medicine_reminders");
    activeMedicineReminders.clear();
    
    // Cancel all medicine notifications
    await _notificationService.cancelAllMedicineNotifications();

    TDialogs.customToast(
        message: "All reminders deleted successfully", isSucces: true);
  }

  /// Reset all fields
  void reset() {
    medicineName.clear();
    reminderTime.value = null;
    selectedDuration.value = 1;
    customDays.value = null;
  }

  /// Get formatted time string from reminder data
  String getFormattedTime(Map<String, dynamic> reminder) {
    final timeStr = reminder["reminderTime"] as String;
    final parts = timeStr.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);
    return timeOfDay.format(Get.context!);
  }

  /// Get remaining days for a reminder
  int getRemainingDays(Map<String, dynamic> reminder) {
    final expiry = DateTime.parse(reminder["expiry"]);
    final now = DateTime.now();
    final difference = expiry.difference(now);
    return difference.inDays + (difference.inHours % 24 > 0 ? 1 : 0);
  }

  Future<void> checkPendingNotifications() async {
    final pendingNotifications = await _notificationService
        .flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    
    print("=== PENDING NOTIFICATIONS ===");
    for (var notification in pendingNotifications) {
      print("ID: ${notification.id}");
      print("Title: ${notification.title}");
      print("Body: ${notification.body}");
      print("Payload: ${notification.payload}");
      print("------------------------");
    }
    print("Total pending: ${pendingNotifications.length}");
  }

  /// Calculate minutes until next reminder
  int? getMinutesUntilReminder(TimeOfDay? reminderTime) {
    if (reminderTime == null) return null;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final reminderMinutes = reminderTime.hour * 60 + reminderTime.minute;

    if (reminderMinutes >= nowMinutes) {
      return reminderMinutes - nowMinutes;
    } else {
      final minutesInDay = 24 * 60;
      return (minutesInDay - nowMinutes) + reminderMinutes;
    }
  }
}

// import 'package:daily_mate/utils/popups/dialogs.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:daily_mate/data/services/notification_service.dart';

// class MedicineReminderController extends GetxController {
//   final TextEditingController medicineName = TextEditingController();
//   final Rx<TimeOfDay?> reminderTime = Rx<TimeOfDay?>(null);
//   final RxInt selectedDuration = 1.obs; // 1 = Today, 7, 15, or custom
//   final RxnInt customDays = RxnInt();
//   var activeMedicineReminder = {}.obs;

//   final storage = GetStorage();
//   final _notificationService = NotificationService();

//   @override
//   void onInit() {
//     loadReminder();
//     super.onInit();
//   }

//   /// Save reminder with validation + scheduling
//   Future<void> saveReminder() async {
//     // Validation
//     if (medicineName.value.text.trim().isEmpty) {
//       TDialogs.customToast(
//           message: "Please enter medicine name", isSucces: false);
//       return;
//     }
//     if (reminderTime.value == null) {
//       TDialogs.customToast(
//           message: "Please select reminder time", isSucces: false);
//       return;
//     }

//     final days = customDays.value ?? selectedDuration.value;
//     if (days <= 0) {
//       TDialogs.customToast(
//           message: "Invalid duration selected", isSucces: false);
//       return;
//     }

//     // Title & body for notifications
//     final title = "💊 ${medicineName.value.text}";
//     final body = "It's time to take your medicine";

//     if (days == 1) {
//       /// Case 1: Today only
//       final minutes = getMinutesUntilReminder(reminderTime.value);
//       if (minutes != null && minutes > 0) {
//         final dateTime = DateTime.now().add(Duration(minutes: minutes));
//         await _notificationService.scheduleOneTimeMedicineReminder(
//           dateTime,
//           title,
//           body,
//         );
//         _saveToLocal(days);
//         TDialogs.customToast(
//             message: "Reminder set for today", isSucces: true);
//       } else {
//         TDialogs.customToast(
//             message: "Selected time already passed", isSucces: false);
//       }
//     } else {
//       /// Case 2 & 3: Multiple N days
//       await _notificationService.scheduleDailyMedicineReminder(
//         reminderTime.value!,
//         days,
//         title,
//         body,
//       );
//       _saveToLocal(days);
//       TDialogs.customToast(
//           message: "Reminder set for next $days days", isSucces: true);
//     }

//     medicineName.clear();
//     reminderTime.value = null;
//     selectedDuration.value = 1;
//     customDays.value = null;
//   }

//   /// Save reminder details into local storage
//   void _saveToLocal(int days) {
//     final expiryDate = DateTime.now().add(Duration(days: days));
//     final reminderData = {
//       "medicineName": medicineName.value,
//       "reminderTime":
//           "${reminderTime.value!.hour}:${reminderTime.value!.minute}",
//       "duration": days,
//       "expiry": expiryDate.toIso8601String(),
//     };

//     storage.write("medicine_reminder", reminderData);
//     activeMedicineReminder.value = reminderData;
//   }

//   /// Load reminder from storage (and clear if expired)
//   void loadReminder() {
//     final data = storage.read("medicine_reminder");
//     if (data != null) {
//       final expiry = DateTime.tryParse(data["expiry"]);
//       if (expiry != null && DateTime.now().isAfter(expiry)) {
//         storage.remove("medicine_reminder");
//         activeMedicineReminder.clear();
//       } else {
//         activeMedicineReminder.value = data;
//       }
//     }
//   }

//     /// Delete reminder manually
//   Future<void> deleteReminder() async {
//     storage.remove("medicine_reminder");
//     activeMedicineReminder.clear();

//     TDialogs.customToast(
//         message: "Reminder deleted successfully", isSucces: true);
//   }

//   /// Reset all fields
//   void reset() {
//     medicineName.clear();
//     reminderTime.value = null;
//     selectedDuration.value = 1;
//     customDays.value = null;
//   }

//   Future<void> checkPendingNotifications() async {
//   final pendingNotifications = await _notificationService
//       .flutterLocalNotificationsPlugin
//       .pendingNotificationRequests();
  
//   print("=== PENDING NOTIFICATIONS ===");
//   for (var notification in pendingNotifications) {
//     print("ID: ${notification.id}");
//     print("Title: ${notification.title}");
//     print("Body: ${notification.body}");
//     print("Payload: ${notification.payload}");
//     print("------------------------");
//   }
//   print("Total pending: ${pendingNotifications.length}");
// }

//   /// Calculate minutes until next reminder
//   int? getMinutesUntilReminder(TimeOfDay? reminderTime) {
//     if (reminderTime == null) return null;

//     final now = TimeOfDay.now();

//     final nowMinutes = now.hour * 60 + now.minute;
//     final reminderMinutes = reminderTime.hour * 60 + reminderTime.minute;

//     if (reminderMinutes >= nowMinutes) {
//       return reminderMinutes - nowMinutes;
//     } else {
//       final minutesInDay = 24 * 60;
//       return (minutesInDay - nowMinutes) + reminderMinutes;
//     }
//   }
// }
