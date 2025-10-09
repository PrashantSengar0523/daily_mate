// services/aqi_weather_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:daily_mate/features/models/aqi_weather_model.dart';
import 'package:daily_mate/features/models/weather_forecast_model.dart';
import 'package:http/http.dart' as http;

class AqiWeatherService {
  final String aqiKey = "f2ffd230-cd12-4603-b762-3220f98a9b99"; 
  final String openWeatherKey = "d382b6a348bde8ef2c577ea32758bde6"; 

  // Fetch AQI
  Future<AqiWeatherModel> fetchData(double lat, double lon) async {
    final url =
        "https://api.airvisual.com/v2/nearest_city?lat=$lat&lon=$lon&key=$aqiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return AqiWeatherModel.fromJson(data);
    } else {
      throw Exception("Failed to fetch AQI data");
    }
  }

  // Fetch weather forecast
  Future<WeatherForecastModel> fetchWeather(double lat, double lon) async {
    final url =
    "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&exclude=minutely,alerts&units=metric&appid=$openWeatherKey";

    log(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherForecastModel.fromJson(data);
    } else {
      throw Exception("Failed to fetch weather forecast");
    }
  }
}
