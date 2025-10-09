// ignore_for_file: unused_local_variable, avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:daily_mate/data/services/location_service.dart';
import 'package:daily_mate/data/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'package:timezone/data/latest.dart' as tz;

/// 🔹 FCM background handler (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {
    final notification = message.notification;
    final payload = message.data;
    NotificationService().showNotification(
      title: notification?.title ?? "",
      body: notification?.body ?? '',
      payload: jsonEncode(payload),
    );
  }
}

/// Entry point of Flutter App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize storage
  await GetStorage.init();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize NotificationService
  final notificationService = NotificationService();
  await notificationService.requestPermissions();

  //Storag Permission
  await Permission.storage.request();

  // Request location permission (if needed)
  final location = LocationService();
  await location.requestPermission();

  // Request FCM notification permission
  await FirebaseMessaging.instance.requestPermission();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      final notification = message.notification!;
      final payload = jsonEncode(message.data);
      notificationService.showNotification(
        title: notification.title ?? 'No Title',
        body: notification.body ?? 'No Body',
        payload: payload,
      );
    }
  });

  // Run the app
  runApp(const App());
}


