import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String city;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.city,
  });
}

class LocationService {
  /// 🔹 Requests location permission
  Future<void> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();

    if (!status.isGranted) {
      throw LocationException('Location permission denied');
    }
  }

  /// 🔹 Checks if location services are enabled
  Future<void> checkLocationServices() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw LocationException('Location services are disabled. Please enable GPS.');
    }
  }

  /// 🔹 Gets the current position
  Future<Position> getCurrentPosition() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw LocationException('Location permission denied');
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw LocationException('Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  /// 🔹 Get current location including city name
  Future<LocationData> getCurrentLocation() async {
    await requestPermission();
    await checkLocationServices();

    final position = await getCurrentPosition();

    String cityName = "Unknown";
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        cityName = placemarks.first.locality ?? "Unknown";
      }
    } catch (_) {
      cityName = "Unknown";
    }

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      city: cityName,
    );
  }
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  @override
  String toString() => message;
}
