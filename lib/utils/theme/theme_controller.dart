
// ignore_for_file: deprecated_member_use

import 'package:daily_mate/utils/constants/enums.dart';
import 'package:daily_mate/utils/system_overlay/t_system_overlay_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'appTheme';
  final _primaryKey = 'primaryColor';
  final _secondaryKey = 'secondaryColor';

  Rx<AppThemeMode> currentTheme = AppThemeMode.system.obs;
   Rx<Color> primaryColor = const Color(0xFF3949AB).obs;
  Rx<Color> secondaryColor = const Color(0xFFFF9800).obs;

  @override
  void onInit() {
    super.onInit();
    currentTheme.value = _loadThemeFromStorage();

     final p = _box.read(_primaryKey);
    final s = _box.read(_secondaryKey);
    if (p != null) primaryColor.value = Color(p);
    if (s != null) secondaryColor.value = Color(s);
  }

  void setTheme(BuildContext context, AppThemeMode mode) {
    currentTheme.value = mode;
    _saveThemeToStorage(mode);
    updateStatusBar(context); // <-- New method
}

void updateStatusBar(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final Brightness platformBrightness = MediaQuery.of(context).platformBrightness;

    final brightness = (themeMode == ThemeMode.system)
        ? (platformBrightness == Brightness.dark ? Brightness.light : Brightness.dark)
        : (themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark);

    TSystemOverlayUi.setStatusBarTheme(brightness);
  });
}
  AppThemeMode _loadThemeFromStorage() {
    final savedTheme = _box.read(_key);
    switch (savedTheme) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  void _saveThemeToStorage(AppThemeMode mode) {
    _box.write(_key, mode.name);
  }

  ThemeMode get themeMode {
    switch (currentTheme.value) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setPrimaryColor(Color color) {
    primaryColor.value = color;
    _box.write(_primaryKey, color.value);
  }

  void setSecondaryColor(Color color) {
    secondaryColor.value = color;
    _box.write(_secondaryKey, color.value);
  }
}
