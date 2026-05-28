import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Picks a demo driver start point near pickup, away from dropoff, within approach ETA.
class DriverPlacement {
  DriverPlacement._();

  static const maxApproachMinutes = 8;
  static const maxApproachSeconds = maxApproachMinutes * 60;
  static const avgUrbanSpeedMps = 8.33; // ~30 km/h

  /// Straight-line budget so road distance/time stays under 8 min on average.
  static const roadFactor = 0.72;
  static const minPickupDistanceMeters = 450;
  static const minDropoffSeparationMeters = 700;

  static const _distance = Distance();

  static double maxStraightLineMeters({double scale = 1.0}) =>
      maxApproachSeconds * avgUrbanSpeedMps * roadFactor * scale;

  /// Deterministic pseudo-random start for a trip (same seed → same driver position).
  static LatLng randomStartNearPickup({
    required LatLng pickup,
    required LatLng dropoff,
    required String seed,
    double maxDistanceScale = 1.0,
  }) {
    final random = math.Random(seed.hashCode);
    final maxMeters = maxStraightLineMeters(scale: maxDistanceScale);
    final pickupToDropoff = _distance(pickup, dropoff);

    for (var attempt = 0; attempt < 32; attempt++) {
      final bearing = random.nextDouble() * 360;
      final range = (maxMeters - minPickupDistanceMeters).clamp(200, maxMeters);
      final meters =
          minPickupDistanceMeters + random.nextDouble() * range;

      final candidate = _distance.offset(pickup, meters, bearing);
      final toPickup = _distance(candidate, pickup);
      final toDropoff = _distance(candidate, dropoff);

      if (toPickup < minPickupDistanceMeters) continue;
      if (toPickup > maxMeters) continue;
      if (toDropoff < minDropoffSeparationMeters) continue;
      if (pickupToDropoff > 300 &&
          (toDropoff / pickupToDropoff) < 0.35 &&
          toDropoff < pickupToDropoff * 0.5) {
        continue;
      }

      return candidate;
    }

    return _fallbackStart(pickup: pickup, dropoff: dropoff, seed: seed);
  }

  static int estimateApproachMinutes(double distanceMeters) {
    return (distanceMeters / avgUrbanSpeedMps / 60).ceil().clamp(1, maxApproachMinutes);
  }

  static LatLng _fallbackStart({
    required LatLng pickup,
    required LatLng dropoff,
    required String seed,
  }) {
    final random = math.Random('${seed}_fallback'.hashCode);
    final bearingToDropoff = _distance.bearing(pickup, dropoff);
    final awayBearing = (bearingToDropoff + 90 + random.nextDouble() * 180) % 360;
    final meters = minPickupDistanceMeters +
        random.nextDouble() *
            (maxStraightLineMeters(scale: 0.65) - minPickupDistanceMeters);
    return _distance.offset(pickup, meters, awayBearing);
  }
}
