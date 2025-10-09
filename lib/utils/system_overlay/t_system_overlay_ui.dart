import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TSystemOverlayUi {
  static setStatusBarTheme(Brightness brightness) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // or a custom color
      statusBarIconBrightness: brightness, // Icon color
      statusBarBrightness: brightness, // For iOS
    ),
  );
}
}