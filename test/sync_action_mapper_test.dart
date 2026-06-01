import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/sync/sync_action_mapper.dart';

void main() {
  group('SyncActionMapper', () {
    test('maps createTrip pending item to ride.request batch action', () {
      final item = PendingSyncEntity(
        id: 'client-action-1',
        action: SyncAction.createTrip,
        payload: {
          'pickupAddress': 'Maadi',
          'dropoffAddress': 'Zamalek',
          'pickupLat': 29.96,
          'pickupLng': 31.25,
          'dropoffLat': 30.06,
          'dropoffLng': 31.22,
          'fare': 50,
          'rideTierKey': 'ride_economy',
        },
        createdAt: DateTime.parse('2026-06-01T10:00:00.000Z'),
      );

      final action = SyncActionMapper.toBackendAction(item);

      expect(action['clientActionId'], 'client-action-1');
      expect(action['actionType'], SyncActionMapper.rideRequest);
      expect(action['payload'], {
        'pickupAddress': 'Maadi',
        'dropoffAddress': 'Zamalek',
        'pickupLat': 29.96,
        'pickupLng': 31.25,
        'dropoffLat': 30.06,
        'dropoffLng': 31.22,
        'fare': 50,
        'rideTierKey': 'ride_economy',
        'idempotencyKey': 'client-action-1',
      });
    });

    test('supports batch sync only for createTrip', () {
      expect(SyncActionMapper.supportsBatchSync(SyncAction.createTrip), isTrue);
      expect(
        SyncActionMapper.supportsBatchSync(SyncAction.updateTripStatus),
        isFalse,
      );
    });
  });
}
