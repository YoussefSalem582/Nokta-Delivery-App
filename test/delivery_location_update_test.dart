import 'package:delivery_app/core/realtime/delivery_location_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryLocationUpdate', () {
    test('parses backend deliveryLocation payload', () {
      final update = DeliveryLocationUpdate.fromJson({
        'deliveryId': 'delivery-1',
        'lat': 30.05,
        'lng': 31.24,
        'heading': 180,
        'updatedAt': '2026-06-01T12:00:00.000Z',
      });

      expect(update.deliveryId, 'delivery-1');
      expect(update.lat, 30.05);
      expect(update.lng, 31.24);
      expect(update.heading, 180);
    });

    test('allows missing heading', () {
      final update = DeliveryLocationUpdate.fromJson({
        'deliveryId': 'delivery-2',
        'lat': 29.9,
        'lng': 31.1,
      });

      expect(update.heading, isNull);
      expect(update.updatedAt, isA<DateTime>());
    });
  });
}
