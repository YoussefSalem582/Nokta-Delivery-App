import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';

abstract final class SyncActionMapper {
  static const rideRequest = 'ride.request';
  static const deliveryCreate = 'delivery.create';

  static bool supportsBatchSync(SyncAction action) {
    return action == SyncAction.createTrip || action == SyncAction.createDelivery;
  }

  static Map<String, dynamic> toBackendAction(PendingSyncEntity item) {
    return switch (item.action) {
      SyncAction.createTrip => {
          'clientActionId': item.id,
          'actionType': rideRequest,
          'payload': _rideRequestPayload(item),
        },
      SyncAction.createDelivery => {
          'clientActionId': item.id,
          'actionType': deliveryCreate,
          'payload': _deliveryCreatePayload(item),
        },
      _ => throw ArgumentError('Unsupported batch action: ${item.action}'),
    };
  }

  static Map<String, dynamic> _rideRequestPayload(PendingSyncEntity item) {
    final payload = item.payload;

    return {
      'pickupAddress': payload['pickupAddress'],
      'dropoffAddress': payload['dropoffAddress'],
      'pickupLat': payload['pickupLat'],
      'pickupLng': payload['pickupLng'],
      'dropoffLat': payload['dropoffLat'],
      'dropoffLng': payload['dropoffLng'],
      if (payload['fare'] != null) 'fare': payload['fare'],
      if (payload['distanceKm'] != null) 'distanceKm': payload['distanceKm'],
      if (payload['etaMinutes'] != null) 'etaMinutes': payload['etaMinutes'],
      if (payload['paymentMethodKey'] != null)
        'paymentMethodKey': payload['paymentMethodKey'],
      if (payload['rideTierKey'] != null) 'rideTierKey': payload['rideTierKey'],
      'idempotencyKey': item.id,
    };
  }

  static Map<String, dynamic> _deliveryCreatePayload(PendingSyncEntity item) {
    final payload = item.payload;

    return {
      'pickupAddress': payload['pickupAddress'],
      'dropoffAddress': payload['dropoffAddress'],
      'pickupLat': payload['pickupLat'],
      'pickupLng': payload['pickupLng'],
      'dropoffLat': payload['dropoffLat'],
      'dropoffLng': payload['dropoffLng'],
      if (payload['fee'] != null) 'fee': payload['fee'],
      if (payload['packageNotes'] != null) 'packageNotes': payload['packageNotes'],
      'idempotencyKey': item.id,
    };
  }
}
