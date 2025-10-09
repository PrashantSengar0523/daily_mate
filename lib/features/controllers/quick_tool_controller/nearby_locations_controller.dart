// ignore_for_file: avoid_print
import 'dart:math';
import 'package:daily_mate/data/services/location_service.dart';
import 'package:daily_mate/data/services/nearby_location_service.dart';
import 'package:daily_mate/features/models/nearby_place_model.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:get/get.dart';

class NearbyPlacesController extends GetxController {
  final LocationService _locationService = LocationService();

  var searchText = ''.obs;
  var places = <NearbyPlaceModel>[].obs;
  var filterePlaces = <NearbyPlaceModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;

  Future<void> loadNearbyPlaces() async {
    isLoading.value = true;

    try {
      // Location
      final location = await _locationService.getCurrentLocation();
      // Check cache
      final cachedLat = storageService.read(currentLat);
      final cachedLng = storageService.read(currentLong);
      final cachedData = storageService.read(nearbyPlaces);

      if (cachedData != null &&
          cachedLat != null &&
          cachedLng != null &&
          _isSameLocation(
            location.latitude,
            location.longitude,
            cachedLat,
            cachedLng,
            thresholdInMeters: 500, // 500m radius
          )) {
        // Use cached data
        places.assignAll(
          (cachedData as List)
              .map((e) => NearbyPlaceModel.fromJson(e))
              .toList(),
        );

        filterePlaces.value =
            places
                .where(
                  (loc) => loc.tags.name != null && loc.tags.name!.isNotEmpty,
                )
                .toList();
      } else {
        // Fetch from API
        final fetchedElements = await NearbyPlacesService.fetchNearbyPlaces(
          location.latitude,
          location.longitude,
        );
        final fetchedPlaces =
            fetchedElements
                .map<NearbyPlaceModel>(
                  (e) => NearbyPlaceModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();

        places.assignAll(fetchedPlaces);
        filterePlaces.value =
            places
                .where(
                  (loc) => loc.tags.name != null && loc.tags.name!.isNotEmpty,
                )
                .toList();

        // Save to cache
        storageService.write(currentLat, location.latitude);
        storageService.write(currentLong, location.longitude);
        storageService.write(nearbyPlaces, fetchedPlaces);
      }
    } catch (e) {
      hasError.value = true;
      places.clear();
      print("Error loading nearby places: $e");
    } finally {
      isLoading.value = false;
    }
  }

  bool _isSameLocation(
    double lat1,
    double lng1,
    double lat2,
    double lng2, {
    double thresholdInMeters = 500, // 500 meters
  }) {
    final distance =
        calculateDistance(lat1, lng1, lat2, lng2) * 1000; // km → meters
    return distance < thresholdInMeters;
  }

  // calculating distance for each nearby place
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth radius in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // distance in km
  }

  double _deg2rad(double deg) => deg * pi / 180;

  @override
  void onInit() {
     ever(searchText, (_) {
      filterePlaces.value = places
          .where((loc) =>
              loc.tags.name != null &&
              loc.tags.name!
                  .toLowerCase()
                  .contains(searchText.value.toLowerCase()))
          .toList();
    });
    loadNearbyPlaces();
    super.onInit();
  }
}
