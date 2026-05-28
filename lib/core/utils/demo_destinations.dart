import 'package:latlong2/latlong.dart';

/// Demo dropoff coordinates offset from the user's current position.
class DemoDestinations {
  DemoDestinations._();

  static const maxOsrmDistanceMeters = 500000;

  /// Max straight-line distance before snapping mock driver GPS to near pickup.
  static const maxDriverPickupDistanceMeters = 5000;

  /// Demo driver start ~1.5 km from pickup for the approach leg.
  static LatLng driverNearPickup({
    required double pickupLat,
    required double pickupLng,
  }) {
    return LatLng(pickupLat + 0.012, pickupLng + 0.008);
  }

  /// Keeps mock catalog driver coords when close; otherwise snaps near pickup.
  static LatLng normalizeDriverForTracking({
    required LatLng driver,
    required LatLng pickup,
  }) {
    const distance = Distance();
    if (distance(driver, pickup) <= maxDriverPickupDistanceMeters) {
      return driver;
    }
    return driverNearPickup(
      pickupLat: pickup.latitude,
      pickupLng: pickup.longitude,
    );
  }

  static LatLng nearPickup({
    required double pickupLat,
    required double pickupLng,
    String key = 'default',
  }) {
    return switch (key) {
      'home' => LatLng(pickupLat + 0.012, pickupLng + 0.008),
      'work' => LatLng(pickupLat + 0.006, pickupLng + 0.018),
      'airport' => LatLng(pickupLat - 0.015, pickupLng + 0.022),
      _ => LatLng(pickupLat + 0.01, pickupLng + 0.01),
    };
  }

  static String labelKey(String key) => switch (key) {
        'home' => 'quick_home',
        'work' => 'quick_work',
        'airport' => 'quick_airport',
        _ => 'search_destination',
      };
}
