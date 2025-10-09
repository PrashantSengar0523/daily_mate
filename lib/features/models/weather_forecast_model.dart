class WeatherForecastModel {
  final List<Map<String, dynamic>> list; // 3-hourly forecasts (5 days)
  final Map<String, dynamic> city;       // city info

  WeatherForecastModel({
    required this.list,
    required this.city,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    return WeatherForecastModel(
      list: List<Map<String, dynamic>>.from(json['list']),
      city: Map<String, dynamic>.from(json['city']),
    );
  }
}
