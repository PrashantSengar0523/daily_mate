import 'dart:convert';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TodayHistoryController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var events = <Map<String, dynamic>>[].obs;


  @override
  void onInit() {
    fetchTodayHistory();
    super.onInit();
  }

  Future<void> fetchTodayHistory() async {
    isLoading.value = true;
    hasError.value = false;
    events.clear();

    try {
      final today = DateTime.now();
      final cachedData = storageService.read(historyEvents);

      // Use cached data if month matches
      if (cachedData != null && cachedData["month"] == today.month) {
        events.addAll(List<Map<String, dynamic>>.from(cachedData["events"]));
      } else {
        // Fetch new data from Wikipedia API
        final url = Uri.parse(
            'https://en.wikipedia.org/api/rest_v1/feed/onthisday/events/${today.month}/${today.day}');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final list = data['events'] as List;

          // Map each event to {year, text} format
          final fetchedEvents = list
              .map((e) => {
                    "year": e["year"],
                    "text": e["text"],
                  })
              .toList();

          // Save to local storage
          storageService.write(historyEvents, {
            "month": today.month,
            "events": fetchedEvents,
          });

          events.addAll(fetchedEvents);
        } else {
          hasError.value = true;
        }
      }
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
