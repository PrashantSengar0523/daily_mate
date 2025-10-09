// models/aqi_weather_model.dart
class AqiWeatherModel {
  // Weather
  final double temperature;
  final int humidity;
  final double wind;
  final String condition;

  // AQI
  final int aqi;
  final int pm25;
  final int pm10;
  final String mainPollutant;

  final String city;

  AqiWeatherModel({
    required this.temperature,
    required this.humidity,
    required this.wind,
    required this.condition,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.mainPollutant,
    required this.city,
  });

  factory AqiWeatherModel.fromJson(Map<String, dynamic> json) {
    final pollution = json['current']['pollution'];
    final weather = json['current']['weather'];

    return AqiWeatherModel(
      temperature: weather['tp'].toDouble(),
      humidity: weather['hu'],
      wind: weather['ws'].toDouble(),
      condition: weather['ic'], // you can map this to icon or main condition
      aqi: pollution['aqius'],
      pm25: pollution['pm25'] ?? 0,
      pm10: pollution['pm10'] ?? 0,
      mainPollutant: pollution['mainus'] ?? 'N/A',
      city: json['city'],
    );
  }
}
