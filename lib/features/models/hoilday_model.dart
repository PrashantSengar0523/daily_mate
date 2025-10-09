// models/holiday_model.dart
class HolidayModel {
  final String name;
  final String description;
  final String date; // ISO 8601 string
  final String type;

  HolidayModel({
    required this.name,
    required this.description,
    required this.date,
    required this.type,
  });

  // Factory constructor to parse JSON from Calendarific
  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      name: json['name'] ?? 'Unknown Holiday',
      description: json['description'] ?? '',
      date: json['date'] is Map<String, dynamic>
          ? (json['date']['iso'] ?? '')
          : (json['date'] ?? ''), // fallback if already string
      type: (json['type'] != null && json['type'] is List && json['type'].isNotEmpty)
          ? json['type'][0] // Usually type is a list, take first
          : 'Unknown',
    );
  }

  /// ✅ Convert HolidayModel to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "date": date,
      "type": type,
    };
  }
}
