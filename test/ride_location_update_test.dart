import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/realtime/ride_location_update.dart';

void main() {
  group('RideLocationUpdate', () {
    test('parses backend rideLocation payload', () {
      final update = RideLocationUpdate.fromJson({
        'rideId': 'trip-1',
        'driverId': 'driver-1',
        'lat': 30.05,
        'lng': 31.24,
        'heading': 90,
        'updatedAt': '2026-06-01T12:00:00.000Z',
      });

      expect(update.rideId, 'trip-1');
      expect(update.lat, 30.05);
      expect(update.lng, 31.24);
      expect(update.heading, 90);
    });
  });
}
