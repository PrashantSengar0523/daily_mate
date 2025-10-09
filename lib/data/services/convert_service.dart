// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ConverterService {
  /// 🌍 Unit conversion base URL
  static const String baseUrl = "https://converter.pluginapi.xyz/convert";

  Future<dynamic> convert({
    required double value,
    required String from,
    required String to,
  }) async {
    try {
      final url = Uri.parse(
        "$baseUrl?value=$value&from=${from.toLowerCase()}&to=${to.toLowerCase()}",
      );
      final response = await http.get(url);
      log("Unit API Call: $url");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data["convertedValue"]);
      } else {
        throw Exception("Failed to fetch conversion");
      }
    } catch (e) {
      print("Error in conversion: $e");
      return null;
    }
  }

  /// 💱 Currency conversion APIs
  static const String currencyBaseUrl =
      "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies";


  Future<dynamic> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      // ✅ Use correct currency base
      String url = "$currencyBaseUrl/${from.toLowerCase()}.json";
      log("Currency API Call: $url");

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        /// Example JSON:
        /// {
        ///   "usd": { "inr": 83.1, "eur": 0.92 }
        /// }
        final rates = data[from.toLowerCase()] as Map<String, dynamic>;
        final rate = (rates[to.toLowerCase()] as num).toDouble();

        return amount * rate;
      }

      return null;
    } catch (e) {
      print("Currency conversion error: $e");
      return null;
    }
  }
}
