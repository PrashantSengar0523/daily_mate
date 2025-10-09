import 'dart:io';

import 'package:daily_mate/utils/constants/image_strings.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/enums.dart';

class THelperFunctions {

    static ImagePicker picker = ImagePicker();


  static DateTime getStartOfWeek(DateTime date) {
    final int daysUntilMonday = date.weekday - 1;
    final DateTime startOfWeek = date.subtract(Duration(days: daysUntilMonday));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0, 0, 0);
  }

  static Color getOrderStatusColor(OrderStatus value) {
    if (OrderStatus.pending == value) {
      return Colors.blue;
    } else if (OrderStatus.processing == value) {
      return Colors.orange;
    } else if (OrderStatus.shipped == value) {
      return Colors.purple;
    } else if (OrderStatus.delivered == value) {
      return Colors.green;
    } else if (OrderStatus.cancelled == value) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  static Color? getColor(String value) {
    /// Define your product specific colors here and it will match the attribute colors and show specific 🟠🟡🟢🔵🟣🟤

    if (value == 'Green') {
      return Colors.green;
    } else if (value == 'Green') {
      return Colors.green;
    } else if (value == 'Red') {
      return Colors.red;
    } else if (value == 'Blue') {
      return Colors.blue;
    } else if (value == 'Pink') {
      return Colors.pink;
    } else if (value == 'Grey') {
      return Colors.grey;
    } else if (value == 'Purple') {
      return Colors.purple;
    } else if (value == 'Black') {
      return Colors.black;
    } else if (value == 'White') {
      return Colors.white;
    } else if (value == 'Yellow') {
      return Colors.yellow;
    } else if (value == 'Orange') {
      return Colors.deepOrange;
    } else if (value == 'Brown') {
      return Colors.brown;
    } else if (value == 'Teal') {
      return Colors.teal;
    } else if (value == 'Indigo') {
      return Colors.indigo;
    } else {
      return null;
    }
  }

  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showAlert(String title, String message) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

 static String getFormattedDate(dynamic date, {String format = 'd MMMM'}) {
    try {
      DateTime parsedDate;

      if (date is String) {
        parsedDate = DateTime.parse(date); // ISO format string
      } else if (date is DateTime) {
        parsedDate = date;
      } else {
        throw ArgumentError("Unsupported date type: $date");
      }

      return DateFormat(format).format(parsedDate);
    } catch (e) {
      return '';
    }
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];
    for (var i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(i, i + rowSize > widgets.length ? widgets.length : i + rowSize);
      wrappedList.add(Row(children: rowChildren));
    }
    return wrappedList;
  }

    static Future<File?> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return null;
    } else {
      return File(pickedFile.path); // Convert XFile to File
    }
  }

  static String getWeatherCondition(String iconCode) {
  switch (iconCode) {
    case '01d':
    case '01n':
      return 'Clear';
    case '02d':
    case '02n':
      return 'Few Clouds';
    case '03d':
    case '03n':
      return 'Cloudy';
    case '04d':
    case '04n':
      return 'Overcast';
    case '09d':
    case '09n':
      return 'Shower Rain';
    case '10d':
    case '10n':
      return 'Rain';
    case '11d':
    case '11n':
      return 'Thunderstorm';
    case '13d':
    case '13n':
      return 'Snow';
    case '50d':
    case '50n':
      return 'Mist';
    default:
      return 'Unknown';
  }
}

 static String getGreetMessage() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    final currentTimeInMinutes = hour * 60 + minute;

    if (currentTimeInMinutes >= 4 * 60 && currentTimeInMinutes < 12 * 60) {
      // 4:00 AM - 11:59 AM
      return TTexts.goodMorning.tr;
    } else if (currentTimeInMinutes >= 12 * 60 && currentTimeInMinutes < 16 * 60) {
      // 12:00 PM - 3:59 PM
      return TTexts.goodAfternoon.tr;
    } else if (currentTimeInMinutes >= 16 * 60 && currentTimeInMinutes < 19 * 60 + 30) {
      // 4:00 PM - 7:29 PM
      return TTexts.goodEvening.tr;
    } else {
      // 7:30 PM - 3:59 AM
      return TTexts.goodNight.tr;
    }
  }

 static String getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("clear")) return TImages.sunCloud;
    if (condition.contains("cloud")) return TImages.clouds;
    if (condition.contains("rain")) return TImages.rainClouds; // 🌧
    if (condition.contains("drizzle")) return TImages.mistClouds;
    if (condition.contains("thunderstorm")) return TImages.thunderClouds;
    if (condition.contains("snow")) return TImages.snowClouds;
    if (condition.contains("mist") || condition.contains("fog") || condition.contains("haze")) {
      return TImages.foggyClouds;
    }
    return TImages.defaultWeather; // fallback
  }

static String formatReminder(DateTime dateTime) {
  final dateFormatter = DateFormat("MMM d, yyyy h:mm a EEEE"); 
  return dateFormatter.format(dateTime);
}
}
