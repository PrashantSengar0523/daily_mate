// services/holiday_service.dart
// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:convert';
import 'package:daily_mate/features/models/hoilday_model.dart';
import 'package:http/http.dart' as http;

class HolidayService {
  final String apiKey = "kOn6puDPHfO9W5mG67ePwxHjl3M7GJEk";

  /// Fetch holidays for current lat/lon
  Future<List<HolidayModel>> fetchHolidays(double lat, double lon, int year) async {
    try {
      
      final countryCode = 'IN';
      print(year);

      final url = Uri.parse(
        'https://calendarific.com/api/v2/holidays?api_key=$apiKey&country=$countryCode&year=$year',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final holidaysJson = data['response']['holidays'] as List;

        return holidaysJson.map((json) => HolidayModel.fromJson(json)).toList();
      } else {
        print("Error fetching holidays: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error in HolidayService: $e");
      return [];
    }
  }
}
