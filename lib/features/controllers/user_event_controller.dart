// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:convert';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:daily_mate/utils/local_storage/storage_utility.dart'; // your StorageService

class UserEventController extends GetxController {
  final storageService = StorageService();
  final String _storageKey = 'user_events';

  // Reactive list of user events
  RxList<UserEventModel> userEvents = <UserEventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadEventsFromStorage();
    getAllEventDates();
  }

  /// Add a new event
  void addEvent(String title, DateTime date) {
    final event = UserEventModel(
      id: const Uuid().v4(),
      title: title,
      dateOfEvent: date,
    );
    userEvents.add(event);
    _saveEventsToStorage();
    TDialogs.customToast(
      message: "Event added",
      color: Colors.deepOrangeAccent,
      textColor: TColors.textWhite,
    );
  }

  /// Delete an event by ID
  void deleteEvent(String id) {
    userEvents.removeWhere((e) => e.id == id);
    _saveEventsToStorage();
    TDialogs.customToast(
      message: "Event deleted",
      color: TColors.error,
      textColor: TColors.textWhite,
    );
  }

  /// Edit an event
  void editEvent(String id, String newTitle, DateTime newDate) {
    final index = userEvents.indexWhere((e) => e.id == id);
    if (index != -1) {
      userEvents[index] = UserEventModel(
        id: id,
        title: newTitle,
        dateOfEvent: newDate,
      );
      _saveEventsToStorage();
    }
  }

  /// Save events to local storage
  void _saveEventsToStorage() {
    final data = userEvents.map((e) => e.toJson()).toList();
    storageService.write(_storageKey, jsonEncode(data));
  }

  /// Load events from local storage
  void _loadEventsFromStorage() {
    final storedData = storageService.read(_storageKey);
    if (storedData != null) {
      try {
        final List<dynamic> list = jsonDecode(storedData);
        userEvents.assignAll(list.map((e) => UserEventModel.fromJson(e)));
      } catch (e) {
        print("Error decoding stored events: $e");
        userEvents.clear();
      }
    }
  }

  List<DateTime> getAllEventDates() {
    return userEvents.map((e) => e.dateOfEvent).toList();
  }

  List<UserEventModel> getEventsByDate(DateTime date) {
    return userEvents.where((e) => isSameDate(e.dateOfEvent, date)).toList();
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class UserEventModel {
  String id;
  String title;
  DateTime dateOfEvent;

  UserEventModel({
    required this.id,
    required this.title,

    required this.dateOfEvent,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dateOfEvent': dateOfEvent.toIso8601String(),
  };

  factory UserEventModel.fromJson(Map<String, dynamic> json) => UserEventModel(
    id: json['id'],
    title: json['title'],
    dateOfEvent: DateTime.parse(json['dateOfEvent']),
  );
}
