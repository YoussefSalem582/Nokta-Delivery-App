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
      pickupAddress: pickup,
      dropoffAddress: dropoff,
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
      courierId: json['courierId'] as String?,
      customerId: json['customerId'] as String?,
    );
  }

  static OrderStatus _mapStatus(String status) {
    switch (status) {
      case 'assigned':
        return OrderStatus.assigned;
      case 'pickedUp':
        return OrderStatus.pickedUp;
      case 'inTransit':
        return OrderStatus.inTransit;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static String statusToApi(OrderStatus status) {
    return switch (status) {
      OrderStatus.assigned => 'assigned',
      OrderStatus.pickedUp => 'pickedUp',
      OrderStatus.inTransit => 'inTransit',
      OrderStatus.delivered => 'delivered',
      OrderStatus.cancelled => 'cancelled',
      _ => 'requested',
    };
  }
}
