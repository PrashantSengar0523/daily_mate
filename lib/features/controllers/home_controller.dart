// controllers/home_controller.dart
// ignore_for_file: avoid_print

import 'package:daily_mate/data/services/location_service.dart';
import 'package:daily_mate/data/services/weather_service.dart';
import 'package:daily_mate/features/models/hoilday_model.dart';
import 'package:daily_mate/features/models/aqi_weather_model.dart';
import 'package:daily_mate/features/models/weather_forecast_model.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final LocationService _locationService = LocationService();
  final AqiWeatherService _aqiWeatherService = AqiWeatherService();

  var isLoading = false.obs;
  var aqiWeather = Rxn<AqiWeatherModel>();
  var weatherForecast = Rxn<WeatherForecastModel>();
  var todayForecast = <Map<String, dynamic>>[].obs;
  var fiveDayForecast = <Map<String, dynamic>>[].obs;
  var maskSuggestion = false.obs;
  var umbrellaSuggestion = false.obs;

  var holidays = <HolidayModel>[].obs;

  // New observable for today's holiday/festival
  var todayHoliday = Rxn<HolidayModel>();

Future<void> getData() async {
  try {
    isLoading.value = true;

    // Location 
    final location = await _locationService.getCurrentLocation();

    // Fetch AQI + Current Weather
    final data = await _aqiWeatherService.fetchData(
      location.latitude,
      location.longitude,
    );
    aqiWeather.value = data;

    // Store AQI data locally (overwrite every time)
    storageService.write(temp, aqiWeather.value?.temperature.toStringAsFixed(1));
    storageService.write(city, aqiWeather.value?.city.toString());
    storageService.write(condition, aqiWeather.value?.condition.toString());
    storageService.write(humidity, aqiWeather.value?.humidity.toString());
    storageService.write(wind, aqiWeather.value?.wind.toString());
    storageService.write(aqi, aqiWeather.value?.aqi.toString());
    storageService.write(pm25, aqiWeather.value?.pm25.toString());
    storageService.write(pm10, aqiWeather.value?.pm10.toString());
     
     // Generate suggestions
    generateSuggestions();

    // Weather Forecast (call once per day)
    final lastFetchedDate = storageService.read(lastFetchedDateKey);
    final todayDate = DateTime.now().toString().split(" ")[0]; // yyyy-MM-dd

    if (lastFetchedDate == todayDate) {
      print("Using cached forecast for today: $todayDate");

      todayForecast.value = List<Map<String, dynamic>>.from(
        storageService.read(todayForecastKey) ?? [],
      );

      fiveDayForecast.value = List<Map<String, dynamic>>.from(
        storageService.read(fiveDayForecastKey) ?? [],
      );
    } else {
      //  Fresh forecast API call (once per day)
      final forecast = await _aqiWeatherService.fetchWeather(
        location.latitude,
        location.longitude,
      );
      weatherForecast.value = forecast;

      todayForecast.value = getTodayForecast(forecast);
      fiveDayForecast.value = getFiveDayForecast(forecast);

      // Save forecast locally
      storageService.write(todayForecastKey, todayForecast);
      storageService.write(fiveDayForecastKey, fiveDayForecast);
      storageService.write(lastFetchedDateKey, todayDate);

      print("Forecast fetched & stored for $todayDate");
    }

  } catch (e) {
    print("Error fetching data: $e");
  } finally {
    isLoading.value = false;
  }
}

  void generateSuggestions() {
    try {
      // Use live data instead of storage for better reliability
      final currentAqi = aqiWeather.value?.aqi ?? 0;
      final currentCondition = aqiWeather.value?.condition.toLowerCase() ?? '';

      // Mask suggestion → AQI check
      maskSuggestion.value = currentAqi > 100;

      // Umbrella suggestion → check weather conditions
      umbrellaSuggestion.value = currentCondition.contains("rain") ||
          currentCondition.contains("drizzle") ||
          currentCondition.contains("thunderstorm") ||
          currentCondition.contains("shower");

      print("=== SUGGESTIONS GENERATED ===");
      print("AQI: $currentAqi -> Mask: ${maskSuggestion.value}");
      print("Condition: $currentCondition -> Umbrella: ${umbrellaSuggestion.value}");
      
    } catch (e) {
      print("Error generating suggestions: $e");
      // Fallback values
      maskSuggestion.value = false;
      umbrellaSuggestion.value = false;
    }
  }

  // Alternative method using storage (if needed)
  void generateSuggestionsFromStorage() {
    try {
      // Get values from storage with proper type handling
      final storedAqi = storageService.read(aqi);
      final storedCondition = storageService.read(condition);
      
      int aqiValue = 0;
      String weatherCondition = '';
      
      // Handle different data types from storage
      if (storedAqi is int) {
        aqiValue = storedAqi;
      } else if (storedAqi is String) {
        aqiValue = int.tryParse(storedAqi) ?? 0;
      }
      
      if (storedCondition is String) {
        weatherCondition = storedCondition.toLowerCase();
      }

      // Generate suggestions
      maskSuggestion.value = aqiValue > 100;
      
      umbrellaSuggestion.value = weatherCondition.contains("rain") ||
          weatherCondition.contains("drizzle") ||
          weatherCondition.contains("thunderstorm");

      print("=== SUGGESTIONS FROM STORAGE ===");
      print("Stored AQI: $storedAqi ($aqiValue) -> Mask: ${maskSuggestion.value}");
      print("Stored Condition: $storedCondition -> Umbrella: ${umbrellaSuggestion.value}");
      
    } catch (e) {
      print("Error generating suggestions from storage: $e");
      maskSuggestion.value = false;
      umbrellaSuggestion.value = false;
    }
  }

  List<Map<String, dynamic>> getTodayForecast(WeatherForecastModel forecast) {
    final today = DateTime.now();
    return forecast.list.where((item) {
      final date = DateTime.parse(item['dt_txt']);
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();
  }

  List<Map<String, dynamic>> getFiveDayForecast(WeatherForecastModel forecast) {
    final Map<String, List<Map<String, dynamic>>> groupedByDay = {};

    for (var item in forecast.list) {
      final date = DateTime.parse(item['dt_txt']);
      final dayKey = DateTime(date.year, date.month, date.day).toString();

      if (!groupedByDay.containsKey(dayKey)) {
        groupedByDay[dayKey] = [];
      }
      groupedByDay[dayKey]!.add(item);
    }

    // Ab har din ke liye summary banao
    final List<Map<String, dynamic>> fiveDays = [];

    groupedByDay.forEach((day, items) {
      final temps = items.map((e) => e['main']['temp'] as num).toList();
      final minTemp = temps.reduce((a, b) => a < b ? a : b);
      final maxTemp = temps.reduce((a, b) => a > b ? a : b);

      // Weather icon & description first entry se lelo
      final weather = items.first['weather'][0];

      fiveDays.add({
        "date": day,
        "min": minTemp,
        "max": maxTemp,
        "condition": weather['main'],
        "description": weather['description'],
        "icon": weather['icon'],
      });
    });

    return fiveDays;
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
