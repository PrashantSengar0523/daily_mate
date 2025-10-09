// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class QuoteController extends GetxController {
  var isLoading = false.obs;
  var quoteOfTheDay = ''.obs;
  var author = ''.obs;

  var allQuotesLoading = false.obs;
  var allQuotes = <Map<String, String>>[].obs;

  /// tag wise map storage (category -> list of quotes)
  var tagWiseQuotes = <String, List<Map<String, String>>>{}.obs;

  final storage = GetStorage();
  final String allQuotesKey = "all_quotes";
  final String lastFetchKey = "all_quotes_last_fetch";
  final String tagWiseQuotesKey = "tag_wise_quotes_key";
  final String lastFetchTagWiseKey = "last_fetch_tag_wise";
  final String todayDay = "today_day";
  final String dailyMoodKeyPrefix = "mood_"; // mood_YYYY-MM-DD

  /// Mood → quote category mapping
  final Map<String, String> moodToCategory = {
    "happy": "happiness",
    "sad": "motivation",
    "neutral": "life",
    "stressed": "inspiration",
    "excited": "success",
  };

  final List<String> topTags = [
    "inspiration",
    "life",
    "love",
    "success",
    "happiness",
    "confidence",
    "motivation",
  ];

  @override
  void onInit() {
    super.onInit();
    getAllQuotes();
    getAllTagsQuotes();
    loadQuote();
  }

  @override
  void onReady() {
    super.onReady();
    _showDailyMoodDialog();
  }

  Future<void> _showDailyMoodDialog() async {
    final todayKey =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    final moodKey = "$dailyMoodKeyPrefix$todayKey";

    // Agar user ne already mood select kar liya aaj
    if (storage.read(moodKey) != null) return;

    // Show dialog
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            "How are you feeling today?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            // Mood buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  moodToCategory.keys.map((mood) {
                    return InkWell(
                       onTap: () {
        _submitMood(mood, moodKey);
        Future.delayed(Duration(milliseconds: 50), () {
          Get.back();
        });
      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purpleAccent, Colors.deepPurple],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          mood.capitalizeFirst!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 16),

            // Skip button
            TextButton(
              onPressed: () {
                storage.write(moodKey, null); // User skips
                Get.back();
              },
              child: Text(
                "Skip",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),

      barrierDismissible: false,
    );
  }

  void _submitMood(String mood, String moodKey) {
    // Save mood for today
    storage.write(moodKey, mood);

    // Map mood to category
    final category = moodToCategory[mood] ?? topTags.first;

    // Fetch random quote from tagWiseQuotes
    final quotesList = tagWiseQuotes[category] ?? [];
    if (quotesList.isNotEmpty) {
      quotesList.shuffle();
      final q = quotesList.first;
      quoteOfTheDay.value = q['quote']!;
      author.value = q['author']!;
    }

    // Save daily quote
    storage.write(
      todayDay,
      jsonEncode({
        "date": "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}",
        "quote": quoteOfTheDay.value,
        "author": author.value,
      }),
    );
  }

  /// ------------------ DAILY QUOTE ------------------
  Future<void> loadQuote() async {
    try {
      isLoading.value = true;

      final todayKey =
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

      // 🔹 Check local storage first
      final cached = storage.read(todayDay);
      if (cached != null) {
        final decoded = jsonDecode(cached);
        if (decoded['date'] == todayKey) {
          quoteOfTheDay.value = decoded['quote'];
          author.value = decoded['author'];
          print("📦 Loaded quote from local storage");
          return;
        }
      }

      // 🔹 If no cached quotes at all, fetch single quote
      final newQuote = await _fetchQuoteFromApi();
      if (newQuote != null) {
        quoteOfTheDay.value = newQuote['quote']!;
        author.value = newQuote['author']!;
        storage.write(
          todayDay,
          jsonEncode({
            "date": todayKey,
            "quote": newQuote['quote'],
            "author": newQuote['author'],
          }),
        );
      }
    } catch (e) {
      print("❌ Error loading quote: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ------------------ ALL QUOTES (Random) ------------------
  Future<void> getAllQuotes() async {
    try {
      allQuotesLoading.value = true;

      final lastFetchStr = storage.read(lastFetchKey);
      DateTime? lastFetch;
      if (lastFetchStr != null) {
        lastFetch = DateTime.tryParse(lastFetchStr);
      }

      final now = DateTime.now();

      if (lastFetch == null ||
          (lastFetch.year < now.year || lastFetch.month < now.month)) {
        // 🔹 Fetch from API
        final quotes = await fetchMultipleQuotesFromApi();
        if (quotes.isNotEmpty) {
          storage.write(allQuotesKey, jsonEncode(quotes));
          storage.write(lastFetchKey, now.toIso8601String());
          allQuotes.assignAll(quotes);
          print("✅ All quotes fetched from API and saved locally");
        }
      } else {
        // 🔹 Load from local storage
        final cachedQuotes = await _getAllQuotesFromStorage();
        allQuotes.assignAll(cachedQuotes);
        print("📦 Loaded all quotes from local storage");
      }

      allQuotes.shuffle();
    } catch (e) {
      print("❌ Error fetching all quotes: $e");
    } finally {
      allQuotesLoading.value = false;
    }
  }

  Future<List<Map<String, String>>> _getAllQuotesFromStorage() async {
    final cached = storage.read(allQuotesKey);
    if (cached != null) {
      final List<dynamic> decoded = jsonDecode(cached);
      return decoded.map<Map<String, String>>((item) {
        return {
          "quote": item['quote'] ?? item['q'] ?? '',
          "author": item['author'] ?? item['a'] ?? 'Unknown',
        };
      }).toList();
    }
    return [];
  }

  /// ------------------ TAG WISE QUOTES ------------------
  Future<void> getAllTagsQuotes() async {
    try {
      final cached = storage.read(tagWiseQuotesKey);
      Map<String, List<Map<String, String>>> cachedData = {};

      // 🔹 Load cached data if exists
      if (cached != null) {
        final Map<String, dynamic> decoded = jsonDecode(cached);
        cachedData = decoded.map((key, value) {
          final List<dynamic> list = value;
          return MapEntry(
            key,
            list.map<Map<String, String>>((item) {
              return {
                "quote": item['quote'] ?? item['q'] ?? '',
                "author": item['author'] ?? item['a'] ?? 'Unknown',
                "category": key,
              };
            }).toList(),
          );
        });
        print("📦 Loaded cached tag-wise quotes");
      }

      Map<String, List<Map<String, String>>> freshData = {};

      // 🔹 Ensure each tag has data
      for (final tag in topTags) {
        if (cachedData.containsKey(tag) && cachedData[tag]!.isNotEmpty) {
          // ✅ Use cached data
          freshData[tag] = cachedData[tag]!;
          print("✅ Using cached quotes for $tag (${freshData[tag]!.length})");
        } else {
          // 🔄 Fetch fresh data from API
          final apiData = await fetchQuotesForSingleTag(tag);
          if (apiData.isNotEmpty) {
            freshData[tag] = apiData;
            print("🌍 Fetched ${apiData.length} quotes for $tag");
          } else {
            freshData[tag] = [];
            print("⚠️ No quotes fetched for $tag");
          }
        }
      }

      // 🔹 Save back merged data
      storage.write(tagWiseQuotesKey, jsonEncode(freshData));
      tagWiseQuotes.assignAll(freshData);

      print("✅ Tag-wise quotes ready for all tags");
    } catch (e) {
      print("❌ Error in getAllTagsQuotes: $e");
    }
  }

  Future<List<Map<String, String>>> fetchQuotesForSingleTag(
    String tag, {
    int retries = 3,
    int delayMs = 800,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final url = Uri.parse("https://zenquotes.io/api/quotes/$tag");
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);

          if (data.isNotEmpty) {
            print("✅ [$tag] Success on attempt $attempt");
            return data.map<Map<String, String>>((item) {
              return {
                "quote": item['q'] ?? '',
                "author": item['a'] ?? 'Unknown',
                "category": tag,
              };
            }).toList();
          }
        }

        print("⚠️ [$tag] Empty/Invalid response on attempt $attempt");
      } catch (e) {
        print("❌ [$tag] API error on attempt $attempt: $e");
      }

      // Retry delay (exponential)
      if (attempt < retries) {
        final wait = delayMs * attempt;
        print("⏳ Retrying $tag in ${wait}ms...");
        await Future.delayed(Duration(milliseconds: wait));
      }
    }

    print("❌ [$tag] Failed after $retries attempts");
    return [];
  }

  /// ------------------ API CALLS ------------------
  Future<Map<String, String>?> _fetchQuoteFromApi() async {
    try {
      final url = Uri.parse(
        "https://indian-quotes-api.vercel.app/api/quotes/random",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "quote": data['quote'] ?? '',
          "author": data['author']['name'] ?? 'Unknown',
        };
      }
    } catch (e) {
      print("❌ API error: $e");
    }
    return null;
  }

  Future<List<Map<String, String>>> fetchMultipleQuotesFromApi() async {
    try {
      final url = Uri.parse("https://zenquotes.io/api/quotes/");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<Map<String, String>>((item) {
          return {"quote": item['q'] ?? '', "author": item['a'] ?? 'Unknown'};
        }).toList();
      }
    } catch (e) {
      print("❌ API error: $e");
    }
    return [];
  }

  Future<Map<String, List<Map<String, String>>>> fetchQuotesForTags() async {
    Map<String, List<Map<String, String>>> tagQuotes = {};

    for (final tag in topTags) {
      try {
        final url = Uri.parse("https://zenquotes.io/api/quotes/$tag");
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          tagQuotes[tag] =
              data.map<Map<String, String>>((item) {
                return {
                  "quote": item['q'] ?? '',
                  "author": item['a'] ?? 'Unknown',
                  "category": tag,
                };
              }).toList();
        } else {
          tagQuotes[tag] = [];
        }
      } catch (e) {
        print("❌ API error for $tag: $e");
        tagQuotes[tag] = [];
      }
    }

    return tagQuotes;
  }
}
