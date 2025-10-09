import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  var selectedLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();

    // Load saved locale from local storage
    final savedLocale = storageService.getSavedLocale();
    selectedLanguage.value = savedLocale.languageCode;

    // Apply it to GetX
    Get.updateLocale(savedLocale);
  }

  void updateLanguage(String langCode) {
    selectedLanguage.value = langCode;
    Locale newLocale = Locale(langCode, langCode == 'en' ? 'US' : 'IN');
    
    // Save and apply
    storageService.saveLanguage(newLocale);
    Get.updateLocale(newLocale);
  }
}
