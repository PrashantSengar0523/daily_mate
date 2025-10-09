import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:daily_mate/routes/app_routes.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String userCollection = "users"; // Collection where you store users
  final String userId = "current_user_id"; // Replace with actual user ID if you have auth

  @override
  void onInit() {
    super.onInit();
    _handleFCMToken();

    // Navigate to dashboard after splash delay
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.dashboardView);
    });
  }

  void _handleFCMToken() async {
    try {
      // 1️⃣ Get initial token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      // 2️⃣ Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await _saveTokenToFirestore(newToken);
      });
    } catch (e) {
      log("Error handling FCM token: $e");
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      await _firestore.collection(userCollection).doc(userId).set(
        {
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // Merge to avoid overwriting other user data
      );
      log("FCM token saved/updated in Firestore: $token");
    } catch (e) {
      log("Error saving token to Firestore: $e");
    }
  }
}
