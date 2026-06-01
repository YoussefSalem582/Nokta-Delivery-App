import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';

abstract final class DeliveryOrderMapper {
  static OrderEntity fromDeliveryJson(Map<String, dynamic> json) {
    final pickup = json['pickupAddress'] as String? ?? 'Pickup';
    final dropoff = json['dropoffAddress'] as String? ?? 'Dropoff';
    final statusRaw = json['status'] as String? ?? 'requested';

    return OrderEntity(
      id: json['id'] as String,
      title: '$pickup → $dropoff',
      amount: (json['fee'] as num?)?.toDouble() ?? 0,
      status: _mapStatus(statusRaw),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static OrderStatus _mapStatus(String status) {
    switch (status) {
      case 'pickedUp':
      case 'inTransit':
        return OrderStatus.inTransit;
      case 'delivered':
        return OrderStatus.delivered;
      default:
        return OrderStatus.pending;
    }
  }
}
