import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';

abstract final class SyncActionMapper {
  static const rideRequest = 'ride.request';
  static const deliveryCreate = 'delivery.create';

  static bool supportsBatchSync(SyncAction action) {
    return action == SyncAction.createTrip;
  }

  static Map<String, dynamic> toBackendAction(PendingSyncEntity item) {
    if (item.action != SyncAction.createTrip) {
      throw ArgumentError('Unsupported batch action: ${item.action}');
    }

    return {
      'clientActionId': item.id,
      'actionType': rideRequest,
      'payload': _rideRequestPayload(item),
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
}
