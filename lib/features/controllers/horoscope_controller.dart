// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class HoroscopeController extends GetxController {
  var isLoading = false.obs;
  var horoscopeResult = "".obs;
  var cachedHoroscopes = <String, Map<String, dynamic>>{}.obs;

  Future<void> getHoroscopeData(String sign) async {
    try {
      isLoading.value = true;

      final today = DateTime.now().toIso8601String().substring(0, 10);

      print("[Horoscope] Fetching horoscope for $sign on $today");

      // Check cache
      if (cachedHoroscopes.containsKey(sign) &&
          cachedHoroscopes[sign]!['date'] == today) {
        horoscopeResult.value = cachedHoroscopes[sign]!['horoscope'];
        print("[Horoscope] Using cached data: ${horoscopeResult.value}");
        isLoading.value = false;
        return;
      }

      final url = 'https://horoscope-app-api.vercel.app/api/v1/get-horoscope/daily?sign=$sign&day=TODAY';
      print("[Horoscope] Calling API: $url");

      final res = await http.get(Uri.parse(url));
      print("[Horoscope] Response status: ${res.statusCode}");
      print("[Horoscope] Response body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print("[Horoscope] Parsed data: $data");

        if (data['data'] != null && data['data']['horoscope_data'] != null) {
          horoscopeResult.value = data['data']['horoscope_data'];
          // Save to cache
          cachedHoroscopes[sign] = {
            "date": today,
            "horoscope": horoscopeResult.value,
          };
          print("[Horoscope] Horoscope stored: ${horoscopeResult.value}");
        } else {
          horoscopeResult.value = "No horoscope found for $sign";
          print("[Horoscope] API returned no data");
        }
      } else {
        horoscopeResult.value = "Couldn't fetch data, status: ${res.statusCode}";
        print("[Horoscope] API error: ${res.statusCode}");
      }
    } catch (e) {
      horoscopeResult.value = "Error fetching data: $e";
      print("[Horoscope] Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
