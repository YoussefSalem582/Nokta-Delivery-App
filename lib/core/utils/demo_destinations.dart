import 'package:delivery_app/features/home/ride_request/domain/entities/demo_place.dart';
import 'package:latlong2/latlong.dart';

/// Demo dropoff coordinates offset from the user's current position.
class DemoDestinations {
  DemoDestinations._();

  static const maxOsrmDistanceMeters = 500000;
  static const maxSearchResults = 6;

  static const places = [
    DemoPlace(
      id: 'city_mall',
      nameKey: 'place_city_mall',
      subtitleKey: 'place_city_mall_subtitle',
      destinationKey: 'default',
      iconKey: 'mall',
    ),
    DemoPlace(
      id: 'home',
      nameKey: 'quick_home',
      subtitleKey: 'place_home_subtitle',
      destinationKey: 'home',
      iconKey: 'home',
    ),
    DemoPlace(
      id: 'work',
      nameKey: 'quick_work',
      subtitleKey: 'place_work_subtitle',
      destinationKey: 'work',
      iconKey: 'work',
    ),
    DemoPlace(
      id: 'airport',
      nameKey: 'quick_airport',
      subtitleKey: 'place_airport_subtitle',
      destinationKey: 'airport',
      iconKey: 'airport',
    ),
    DemoPlace(
      id: 'nile_city',
      nameKey: 'place_nile_city',
      subtitleKey: 'place_nile_city_subtitle',
      destinationKey: 'nile_city',
      iconKey: 'mall',
    ),
    DemoPlace(
      id: 'downtown',
      nameKey: 'place_downtown',
      subtitleKey: 'place_downtown_subtitle',
      destinationKey: 'downtown',
      iconKey: 'city',
    ),
    DemoPlace(
      id: 'university',
      nameKey: 'place_university',
      subtitleKey: 'place_university_subtitle',
      destinationKey: 'university',
      iconKey: 'school',
    ),
    DemoPlace(
      id: 'hospital',
      nameKey: 'place_hospital',
      subtitleKey: 'place_hospital_subtitle',
      destinationKey: 'hospital',
      iconKey: 'hospital',
    ),
  ];

  static LatLng nearPickup({
    required double pickupLat,
    required double pickupLng,
    String key = 'default',
  }) {
    return switch (key) {
      'home' => LatLng(pickupLat + 0.012, pickupLng + 0.008),
      'work' => LatLng(pickupLat + 0.006, pickupLng + 0.018),
      'airport' => LatLng(pickupLat - 0.015, pickupLng + 0.022),
      'nile_city' => LatLng(pickupLat + 0.008, pickupLng + 0.014),
      'downtown' => LatLng(pickupLat + 0.004, pickupLng + 0.012),
      'university' => LatLng(pickupLat + 0.018, pickupLng + 0.005),
      'hospital' => LatLng(pickupLat - 0.008, pickupLng + 0.011),
      _ => LatLng(pickupLat + 0.01, pickupLng + 0.01),
    };
  }

  static String labelKey(String key) => switch (key) {
        'home' => 'quick_home',
        'work' => 'quick_work',
        'airport' => 'quick_airport',
        'default' => 'place_city_mall',
        'nile_city' => 'place_nile_city',
        'downtown' => 'place_downtown',
        'university' => 'place_university',
        'hospital' => 'place_hospital',
        _ => 'search_destination',
      };

  static DemoPlace? placeForDestinationKey(String key) {
    for (final place in places) {
      if (place.destinationKey == key) return place;
    }
    return null;
  }

  static List<DemoPlace> searchPlaces(
    String query, {
    required String Function(String key) labelFor,
  }) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return places.take(maxSearchResults).toList();
    }

    final matches = places.where((place) {
      final name = labelFor(place.nameKey).toLowerCase();
      final subtitle = place.subtitleKey != null
          ? labelFor(place.subtitleKey!).toLowerCase()
          : '';
      return name.contains(normalized) || subtitle.contains(normalized);
    });

    return matches.take(maxSearchResults).toList();
  }
}
