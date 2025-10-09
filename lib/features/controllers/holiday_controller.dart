// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:daily_mate/data/services/holiday_service.dart';
import 'package:daily_mate/data/services/location_service.dart';
import 'package:daily_mate/features/models/hoilday_model.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:daily_mate/utils/local_storage/storage_utility.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HolidayController extends GetxController {
  final HolidayService _holidayService = HolidayService();
  final LocationService _locationService = LocationService();
  final storageService = StorageService();

  var isLoading = false.obs;
  var holidays = <HolidayModel>[].obs;
  var currentMonthHolidays = <HolidayModel>[].obs;
  var todayHoliday = Rxn<HolidayModel>();
  var groupedHolidays = <String, List<HolidayModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    try {
      isLoading.value = true;
      final now = DateTime.now();

      /// 1. पहले local storage check करो
      final cachedData = storageService.read(yearlyHolidays);
      if (cachedData != null) {
        final decoded = jsonDecode(cachedData);

        // year check करो
        final int cachedYear = decoded['year'] ?? 0;
        if (cachedYear == now.year) {
          print("📦 Loaded holidays of $cachedYear from local storage");

          final list = decoded['holidays'] as List;
          holidays.value = list.map((e) => HolidayModel.fromJson(e)).toList();
          
          // तुरंत UI update करो
          _updateGrouped();
          _filterCurrentMonth(now);
          checkTodayHoliday();
          
          // Loading false करने से पहले थोड़ा delay
          await Future.delayed(Duration(milliseconds: 100));
          isLoading.value = false;
          return;
        } else {
          print("⚠️ Cached year ($cachedYear) != Current year (${now.year}), fetching new data");
        }
      }

      /// 2. अगर local नहीं मिले या पुराना year है → API call करो
      print("🌐 Fetching holidays from API...");
      
      final location = await _locationService.getCurrentLocation();
      print("📍 Location obtained: ${location.latitude}, ${location.longitude}");

      final apiData = await _holidayService.fetchHolidays(
        location.latitude,
        location.longitude,
        now.year,
      );

      print("📅 API returned ${apiData.length} holidays");

      if (apiData.isNotEmpty) {
        holidays.value = apiData;
        
        // तुरंत UI update करो
        _updateGrouped();
        _filterCurrentMonth(now);
        checkTodayHoliday();

        /// Local में store करो with year
        final encoded = jsonEncode({
          "year": now.year,
          "holidays": apiData.map((h) => h.toJson()).toList(),
        });
        storageService.write(yearlyHolidays, encoded);

        print("✅ Stored holidays for year ${now.year} in local storage");
      } else {
        print("⚠️ No holidays received from API");
      }

    } catch (e) {
      print("❌ Error fetching holidays: $e");
      // Error के case में भी grouped holidays को empty करके refresh करो
      groupedHolidays.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// सिर्फ current month holidays
  void _filterCurrentMonth(DateTime now) {
    currentMonthHolidays.value = holidays.where((h) {
      try {
        final holidayDate = DateTime.parse(h.date);
        return holidayDate.year == now.year && holidayDate.month == now.month;
      } catch (e) {
        print("Date parse error: ${h.date}");
        return false;
      }
    }).toList();
    
    print("📊 Current month holidays: ${currentMonthHolidays.length}");
  }

  /// आज का holiday check करो
  void checkTodayHoliday() {
    final today = DateTime.now();
    final todayIso =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final holiday = holidays.firstWhereOrNull((h) => h.date == todayIso);
    todayHoliday.value = holiday;
    
    if (holiday != null) {
      print("🎉 Today's holiday: ${holiday.name}");
    }
  }

  /// Month wise grouping
  void _updateGrouped() {
    final Map<String, List<HolidayModel>> grouped = {};

    for (var holiday in holidays) {
      try {
        final date = DateTime.parse(holiday.date);
        final month = DateFormat.MMMM().format(date);

        grouped.putIfAbsent(month, () => []);
        grouped[month]!.add(holiday);
      } catch (e) {
        print("Date parse error in grouping: ${holiday.date}");
      }
    }

    // Sort holidays within each month by date
    grouped.forEach((month, holidayList) {
      holidayList.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.date);
          final dateB = DateTime.parse(b.date);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });
    });

    groupedHolidays.value = grouped;
    print("🗂️ Grouped holidays updated: ${grouped.keys.toList()} (Total: ${holidays.length})");
    
    // Force refresh the observable
    groupedHolidays.refresh();
  }

  /// Manual refresh function
  Future<void> refreshHolidays() async {
    // Clear cache और fresh data fetch करो
    storageService.remove(yearlyHolidays);
    holidays.clear();
    groupedHolidays.clear();
    currentMonthHolidays.clear();
    todayHoliday.value = null;
    
    await getData();
  }
}