// streak_controller.dart
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:get/get.dart';

class StreakController extends GetxController {
  var streak = 0.obs;
  var bestStreak = 0.obs;

  final String streakKey = "user_streak";
  final String bestStreakKey = "best_streak";
  final String lastSharedDayKey = "last_shared_day";

  @override
  void onInit() {
    super.onInit();
    loadStreak();
  }

  void loadStreak() {
    streak.value = storageService.read(streakKey) ?? 0;
    bestStreak.value = storageService.read(bestStreakKey) ?? 0;
  }

  /// 🔹 Call this function when user shares a quote
  void onQuoteShared() {
    final today = DateTime.now();
    final lastSharedDay = storageService.read(lastSharedDayKey);

    if (lastSharedDay != null) {
      final lastDate = DateTime.parse(lastSharedDay);

      // Already shared today → do nothing
      if (_isSameDay(lastDate, today)) return;

      // Shared yesterday → continue streak
      if (_isSameDay(lastDate.add(const Duration(days: 1)), today)) {
        streak.value++;
      } else {
        // Missed → reset streak
        streak.value = 1;
      }
    } else {
      streak.value = 1; // first time sharing
    }

    // Update best streak if needed
    if (streak.value > bestStreak.value) {
      bestStreak.value = streak.value;
      storageService.write(bestStreakKey, bestStreak.value);
    }

    // Save
    storageService.write(streakKey, streak.value);
    storageService.write(lastSharedDayKey, today.toIso8601String());
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
