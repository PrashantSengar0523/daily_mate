class TrackExpenseModel {
  final String name;
  final double amount;
  final DateTime date;

  TrackExpenseModel({
    required this.name,
    required this.amount,
    required this.date,
  });

  /// Convert TrackExpenseModel → Map (for storage)
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "amount": amount,
      "date": date.toIso8601String(),
    };
  }

  /// Convert Map → TrackExpenseModel (for reading from storage)
  factory TrackExpenseModel.fromJson(Map<String, dynamic> json) {
    return TrackExpenseModel(
      name: json["name"] ?? "",
      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json["date"] ?? "") ?? DateTime.now(),
    );
  }
}
