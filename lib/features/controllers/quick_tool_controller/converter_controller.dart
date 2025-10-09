import 'package:daily_mate/data/services/convert_service.dart';
import 'package:get/get.dart';

class ConverterController extends GetxController {
  final ConverterService _service = ConverterService();

  var categories =
      [
        "Length",
        "Weight",
        "Temperature",
        "Volume",
        "Area",
        "Speed",
        "Data",
        "Currency",
      ].obs;

  final Map<String, List<String>> unitMap = {
    "Length": ["m", "km", "cm", "mm", "mi", "yd", "ft", "in"],
    "Weight": ["kg", "g", "mg", "lb", "oz", "ton"],
    "Temperature": ["C", "F", "K"],
    "Volume": ["L", "mL", "cup", "pint", "quart", "gallon"],
    "Area": ["m²", "km²", "ft²", "yd²", "acre", "hectare"],
    "Speed": ["m/s", "km/h", "mph", "ft/s", "knot"],
    "Data": ["B", "KB", "MB", "GB", "TB", "PB"],
    "Currency": ["USD","EUR","GBP","JPY","CNY","INR","AUD","CAD","CHF","NZD","SGD","HKD","AED","SAR","KWD","BHD","OMR","JOD","ZAR","THB","MYR",
    ],
  };

  var selectedCategory = "Length".obs;
  var fromUnit = "m".obs;
  var toUnit = "km".obs;

  var isLoading = false.obs;
  var result = "".obs;

Future<void> convert(double value, String from, String to) async {
  try {
    isLoading.value = true;

    // If category = currency, hit API
    if (selectedCategory.value.toLowerCase() == "currency") {
      final converted = await _service.convertCurrency(
        amount: value,
        from: fromUnit.value.toLowerCase(), // API expects lowercase codes
        to: toUnit.value.toLowerCase(),
      );

      if (converted != null) {
        result.value =
            "$value (${fromUnit.value}) = ${converted.toStringAsFixed(2)} (${toUnit.value})";
      } else {
        result.value =
            "Conversion not available for ${fromUnit.value} → ${toUnit.value}";
      }
    } 
    //  Otherwise, use normal unit conversion
    else {
      final converted = await _service.convert(
        value: value,
        from: fromUnit.value,
        to: toUnit.value,
      );

      if (converted != null) {
        result.value =
            "$value ${fromUnit.value} = ${converted.toStringAsFixed(2)} ${toUnit.value}";
      } else {
        result.value =
            "Conversion not available for ${fromUnit.value} → ${toUnit.value}";
      }
    }
  } catch (e) {
    result.value = "Error: $e";
  } finally {
    isLoading.value = false;
  }
}


  List<String> getUnits(String category) {
    return unitMap[category] ?? [];
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    final units = getUnits(category);
    fromUnit.value = units.first;
    toUnit.value = units.length > 1 ? units[1] : units.first;
  }

  void swapUnits() {
    final temp = fromUnit.value;
    fromUnit.value = toUnit.value;
    toUnit.value = temp;
  }
}
