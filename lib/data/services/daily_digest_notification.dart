// daily_digest_service.dart - Updated for dynamic data
// ignore_for_file: avoid_print

import 'package:daily_mate/features/controllers/holiday_controller.dart';
import 'package:daily_mate/features/controllers/home_controller.dart';
import 'package:daily_mate/features/controllers/quote_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class DailyDigestService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final GetStorage storage = GetStorage();

  DailyDigestService(this._notificationsPlugin);

  /// Initialize daily digest on first app launch
  Future<void> initializeDailyDigest() async {
    final isInitialized = storage.read('daily_digest_initialized') ?? false;
    if (!isInitialized) {
      await scheduleDailyDigest();
      storage.write('daily_digest_initialized', true);
      print('✅ Daily digest initialized for first time');
    }
  }

  /// Schedule daily digest notification - TRIGGER ONLY
  Future<void> scheduleDailyDigest({int testDelayMinutes = 0}) async {
    try {
      tz.initializeTimeZones();

      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTime;

      if (testDelayMinutes > 0) {
        scheduledTime = now.add(Duration(minutes: testDelayMinutes));
        print('🧪 Test notification in $testDelayMinutes minutes');
      } else {
        scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 7, 30);
        
        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }
        print('📅 Daily digest scheduled for: $scheduledTime');
      }

      await _notificationsPlugin.cancel(999);

      // ✅ IMPORTANT: This is just a TRIGGER notification
      await _notificationsPlugin.zonedSchedule(
        999,
        "⏰ Daily Digest Trigger", // Won't be seen
        "Fetching your morning digest...", // Won't be seen
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_morning_digest',
            'Morning Digest',
            channelDescription: 'Daily morning summary at 7:30 AM',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: false, // Silent trigger
            playSound: false, // Silent trigger
            showWhen: false,
          ),
        ),
        matchDateTimeComponents: testDelayMinutes > 0 ? null : DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'daily_digest', // ✅ This triggers the callback
      );

      print('✅ Daily digest trigger scheduled!');
    } catch (e) {
      print('❌ Error scheduling: $e');
    }
  }

  /// ✅ MAIN FUNCTION - Shows notification with FRESH data
  Future<void> showDailyDigest() async {
    try {
      print('📱 Fetching fresh data for daily digest...');

      // Initialize controllers and fetch fresh data
      final weatherCtrl = Get.put(HomeController(), permanent: true);
      final holidayCtrl = Get.put(HolidayController(), permanent: true);
      final quoteCtrl = Get.put(QuoteController(), permanent: true);

      // Force refresh data if needed
      await Future.wait([
        weatherCtrl.onInit(),
        holidayCtrl.onInit(),
        quoteCtrl.onInit(),
      ] as Iterable<Future>);

      // Wait for data to load
      await Future.delayed(const Duration(milliseconds: 800));

      // ✅ GET FRESH DATA - THIS IS DYNAMIC!
      final weather = weatherCtrl.aqiWeather.value?.condition ?? "Clear";
      final temp = weatherCtrl.aqiWeather.value?.temperature.toStringAsFixed(1) ?? "25";
      final festival = holidayCtrl.todayHoliday.value?.name ?? "No special occasion";
      final quote = quoteCtrl.quoteOfTheDay.value ;

      print('🌡️ Weather: $weather, $temp°C');
      print('🎉 Festival: $festival');
      print('💭 Quote: $quote');

      // Build dynamic content
      final content = _buildNotificationContent(weather, temp, festival, quote);

      // ✅ SHOW ACTUAL NOTIFICATION WITH FRESH DATA
      await _notificationsPlugin.show(
        888, // Different ID for actual notification
        "Good Morning! 🌅",
        content,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_morning_digest',
            'Morning Digest',
            channelDescription: 'Daily morning summary with fresh data',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true, // Real notification
            playSound: true, // Real notification
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
        payload: 'daily_digest_shown',
      );

      print('✅ Dynamic daily digest shown with fresh data!');
      
      // Schedule next day
      await scheduleDailyDigest();

    } catch (e) {
      print('❌ Error showing digest: $e');
      await scheduleDailyDigest(); // Still reschedule
    }
  }

  String _buildNotificationContent(String weather, String temp, String festival, String quote) {
    final buffer = StringBuffer();
    
    buffer.write('🌡️ $weather, ${temp}°C');
    
    if (festival != "No special occasion") {
      buffer.write('\n🎉 $festival');
    }
    
    if (quote.isNotEmpty) {
      final shortQuote = quote.length > 60 ? '${quote.substring(0, 57)}...' : quote;
      buffer.write('\n💭 $shortQuote');
    }
    
    return buffer.toString();
  }

  // Rest of your existing methods...
  bool isDailyDigestScheduled() => storage.read('daily_digest_initialized') ?? false;
  
  Future<void> resetDailyDigest() async {
    await _notificationsPlugin.cancel(999);
    await _notificationsPlugin.cancel(888);
    storage.remove('daily_digest_initialized');
    print('🔄 Daily digest reset');
  }

  Future<void> triggerTestDigest() async => await showDailyDigest();
  
  Future<void> scheduleTestNotification({int minutes = 1}) async {
    await scheduleDailyDigest(testDelayMinutes: minutes);
  }
}