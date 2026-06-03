import 'package:hive/hive.dart';

enum SyncAction {
  createTrip,
  updateTripStatus,
  registerDriver,
  acceptTripOffer,
  updateDriverAvailability,
  updateDriverLocation,
  createDelivery,
}

class PendingSyncEntity extends HiveObject {
  PendingSyncEntity({
    required this.id,
    required this.action,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttemptAt,
  });

  final String id;
  final SyncAction action;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptAt;

  PendingSyncEntity copyWith({int? retryCount, DateTime? lastAttemptAt}) {
    return PendingSyncEntity(
      id: id,
      action: action,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }
}
