import 'package:delivery_app/core/utils/driver_placement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const pickup = LatLng(30.0, 31.0);
  const dropoff = LatLng(30.02, 31.02);

  test('same seed produces the same driver start', () {
    final a = DriverPlacement.randomStartNearPickup(
      pickup: pickup,
      dropoff: dropoff,
      seed: 'trip-123',
    );
    final b = DriverPlacement.randomStartNearPickup(
      pickup: pickup,
      dropoff: dropoff,
      seed: 'trip-123',
    );

    expect(a.latitude, b.latitude);
    expect(a.longitude, b.longitude);
  });

  test('different seeds usually produce different driver starts', () {
    final a = DriverPlacement.randomStartNearPickup(
      pickup: pickup,
      dropoff: dropoff,
      seed: 'trip-a',
    );
    final b = DriverPlacement.randomStartNearPickup(
      pickup: pickup,
      dropoff: dropoff,
      seed: 'trip-b',
    );

    expect(a.latitude == b.latitude && a.longitude == b.longitude, isFalse);
  });

  test('driver start is near pickup and away from dropoff', () {
    const distance = Distance();
    final start = DriverPlacement.randomStartNearPickup(
      pickup: pickup,
      dropoff: dropoff,
      seed: 'trip-near',
    );

    expect(distance(start, pickup), greaterThan(DriverPlacement.minPickupDistanceMeters));
    expect(
      distance(start, pickup),
      lessThan(DriverPlacement.maxStraightLineMeters() * 1.05),
    );
    expect(distance(start, dropoff), greaterThan(DriverPlacement.minDropoffSeparationMeters));
    expect(distance(start, dropoff), greaterThan(distance(start, pickup) * 0.5));
  });

  test('estimated straight-line approach is at most 8 minutes', () {
    const distance = Distance();
    final start = DriverPlacement.randomStartNearPickup(
      pickup: pickup,
      dropoff: dropoff,
      seed: 'trip-eta',
    );

    final meters = distance(start, pickup);
    final minutes = DriverPlacement.estimateApproachMinutes(meters);

    expect(minutes, lessThanOrEqualTo(DriverPlacement.maxApproachMinutes));
  });
}
