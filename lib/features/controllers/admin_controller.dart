import 'dart:io';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends GetxController {
  var isLoading = false.obs;

  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  /// -------------------------------
  /// SINGLE UPLOAD - Festival
  Future<void> uploadFestivalTemplate() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    isLoading.value = true;
    try {
      File file = File(picked.path);

      // Upload to Firebase Storage
      final ref = _storage
          .ref()
          .child("templates/festivals/${DateTime.now().millisecondsSinceEpoch}.png");

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      // Save in Firestore
      await _firestore.collection("templates").add({
        "imageUrl": url,
        "type": "festival",
        "createdAt": DateTime.now(),
      });

      TDialogs.customToast(message: "Festival template uploaded!",isSucces: true);
    } catch (e) {
      TDialogs.customToast(message:e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// -------------------------------
  /// BULK UPLOAD - Festival
  Future<void> uploadFestivalTemplatesBulk() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    isLoading.value = true;
    try {
      for (var picked in pickedFiles) {
        File file = File(picked.path);

        final ref = _storage
            .ref()
            .child("templates/festivals/${DateTime.now().millisecondsSinceEpoch}_${picked.name}");

        await ref.putFile(file);
        final url = await ref.getDownloadURL();

        await _firestore.collection("templates").add({
          "imageUrl": url,
          "type": "festival",
          "createdAt": DateTime.now(),
        });
      }

      TDialogs.customToast(message: "All festival templates uploaded!", isSucces: true);
    } catch (e) {
     TDialogs.customToast(message:e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// -------------------------------
  /// SINGLE UPLOAD - Background
  Future<void> uploadBackgroundTemplate() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    isLoading.value = true;
    try {
      File file = File(picked.path);

      final ref = _storage
          .ref()
          .child("templates/backgrounds/${DateTime.now().millisecondsSinceEpoch}.png");

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await _firestore.collection("templates").add({
        "imageUrl": url,
        "type": "background",
        "createdAt": DateTime.now(),
      });

      TDialogs.customToast(message: "Background template uploaded!",isSucces: true);
    } catch (e) {
      TDialogs.customToast(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// BULK UPLOAD - Background
  Future<void> uploadBackgroundTemplatesBulk() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    isLoading.value = true;
    try {
      for (var picked in pickedFiles) {
        File file = File(picked.path);

        final ref = _storage
            .ref()
            .child("templates/backgrounds/${DateTime.now().millisecondsSinceEpoch}_${picked.name}");

        await ref.putFile(file);
        final url = await ref.getDownloadURL();

        await _firestore.collection("templates").add({
          "imageUrl": url,
          "type": "background",
          "createdAt": DateTime.now(),
        });
      }

      TDialogs.customToast(message: "All background templates uploaded!",isSucces: true);
    } catch (e) {
      TDialogs.customToast(message:e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
