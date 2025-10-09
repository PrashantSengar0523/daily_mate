// ignore_for_file: avoid_print

import 'package:daily_mate/data/services/notification_service.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaterReminderController extends GetxController {
  var isLoading = false.obs;
  final _notificationService = NotificationService();

  final List<String> quickSelectReminders = const ["Every 1 hr", "Every 2 hrs"];
  final RxString selectedReminder = "Every 1 hr".obs;

  final Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);

  final RxInt intervalHours = 1.obs;
  final RxInt targetMl = 2000.obs;
  final RxInt alreadyDrankMl = 0.obs;
  final RxList<int> cupSizes = <int>[200, 250, 300, 350].obs;
  final RxnInt cupSize = RxnInt();
  final RxInt activeReminder = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    loadActiveReminders();
  }
  void addCustomCupSize(int size) {
  if (size > 0 && !cupSizes.contains(size)) {
    cupSizes.add(size);
    cupSizes.sort();
  }
  cupSize.value = size;
  }

  void selectReminder(String label) {
    selectedReminder.value = label;
    intervalHours.value = label.contains("2") ? 2 : 1;
  }

  Future<void> saveWaterReminder() async {
    try {
      isLoading.value = true;

      final parentId = storageService.read(waterRemiderParentIdKey);
      if (parentId != null) {
        TDialogs.customToast(
          message:
              "You already have an active water reminder.\nPlease delete it before adding a new one 💧",
          isSucces: false,
        );
        return;
      }

      // Validation
      if (startTime.value == null || endTime.value == null) {
        TDialogs.customToast(
          message: "Please set your wake-up and sleep time.",
          isSucces: false,
        );
        return;
      }

      if (targetMl.value <= 0) {
        TDialogs.customToast(
          message: "Please set a daily water goal.",
          isSucces: false,
        );
        return;
      }

      if (cupSize.value == null || cupSize.value! <= 0) {
        TDialogs.customToast(
          message: "Please select your cup size.",
          isSucces: false,
        );
        return;
      }

      final startHour = startTime.value!.hour;
      final startMinute = startTime.value!.minute;
      final endHour = endTime.value!.hour;
      final endMinute = endTime.value!.minute;

      final startTotal = startHour * 60 + startMinute;
      final endTotal = endHour * 60 + endMinute;
      if (endTotal <= startTotal) {
        TDialogs.customToast(
          message: "Sleep time must be after wake-up time.",
          isSucces: false,
        );
        return;
      }

      // Schedule reminders
      final id = await _notificationService.scheduleWaterReminders(
        startHour: startHour,
        startMinute: startMinute,
        endHour: endHour,
        endMinute: endMinute,
        cupSize: cupSize.value!,
        targetMl: targetMl.value,
      );


      // Save parent ID & total cups for deletion later
      await storageService.write(waterRemiderParentIdKey, id);
      await storageService.write(waterRemiderTotalCupsKey, (targetMl.value / cupSize.value!).ceil());

      await loadActiveReminders();

      TDialogs.customToast(
        message: "Daily water reminders scheduled successfully! 💧",
        color: Colors.deepOrange,
        textColor: TColors.textWhite,
      );

      resetFields();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadActiveReminders() async {
    final parentId = storageService.read(waterRemiderParentIdKey);
    activeReminder.value = parentId ?? -1;
  }

  Future<void> deleteReminder() async {
  try {
    final parentId = storageService.read(waterRemiderParentIdKey);
    final totalCups = storageService.read(waterRemiderTotalCupsKey);

    if (parentId != null && totalCups != null) {
      // Cancel all notifications using service
      await _notificationService.cancelWaterReminders(parentId, totalCups);

      // Remove stored IDs so new reminder can be added
      storageService.remove(waterRemiderParentIdKey);
      storageService.remove(waterRemiderTotalCupsKey);

      activeReminder.value = -1;

      TDialogs.customToast(
        message: "Water reminder deleted successfully 💧",
        isSucces: true,
      );
    } else {
      TDialogs.customToast(
        message: "No active water reminder found.",
        isSucces: false,
      );
    }
  } catch (e) {
    TDialogs.customToast(
      message: "Failed to delete water reminder",
      isSucces: false,
    );
    print("Error deleting water reminder: $e");
  }
}


  void resetFields() {
    startTime.value = null;
    endTime.value = null;
    targetMl.value = 2000;
    cupSize.value = null;
    alreadyDrankMl.value = 0;
    selectedReminder.value = "Every 1 hr";
    intervalHours.value = 1;
  }
}
