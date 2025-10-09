import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class NearbyPlacesService {
  /// Fetch nearby places from Overpass API (pharmacy, hospital, ATM, petrol pump)
  static Future<List<dynamic>> fetchNearbyPlaces(double lat, double lng) async {
    final query = """
      [out:json];
      (
        node["amenity"="pharmacy"](around:2000,$lat,$lng);
        node["amenity"="fuel"](around:2000,$lat,$lng);
        node["amenity"="shopping_mall"](around:2000,$lat,$lng);
        node["amenity"="mall"](around:2000,$lat,$lng);
        node["amenity"="theatre"](around:2000,$lat,$lng);
        node["amenity"="cafe"](around:2000,$lat,$lng);
        node["amenity"="hospital"](around:2000,$lat,$lng);
        node["amenity"="doctors"](around:2000,$lat,$lng);
        node["amenity"="fast_food"](around:2000,$lat,$lng);
        node["amenity"="restaurant"](around:2000,$lat,$lng);

      );
      out center;
    """;

    final url = Uri.parse(
      "https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}",
    );

    log(url.toString());
    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    final elements = data['elements'] as List;

    return elements;
  }
}
