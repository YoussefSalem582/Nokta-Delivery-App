import 'package:hive/hive.dart';

enum OrderStatus {
  pending,
  inTransit,
  delivered,
  assigned,
  pickedUp,
  cancelled,
}

class OrderEntity extends HiveObject {
  OrderEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.courierId,
    this.customerId,
  });

  final String id;
  final String title;
  final double amount;
  final OrderStatus status;
  final DateTime createdAt;
  final String? pickupAddress;
  final String? dropoffAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? courierId;
  final String? customerId;

  bool get hasRouteCoordinates =>
      pickupLat != null &&
      pickupLng != null &&
      dropoffLat != null &&
      dropoffLng != null;

  bool get isActiveForCourier =>
      status == OrderStatus.assigned ||
      status == OrderStatus.pickedUp ||
      status == OrderStatus.inTransit;

  bool get isTrackableByCustomer =>
      status == OrderStatus.inTransit ||
      status == OrderStatus.pickedUp;

  OrderEntity copyWith({
    String? id,
    String? title,
    double? amount,
    OrderStatus? status,
    DateTime? createdAt,
    String? pickupAddress,
    String? dropoffAddress,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    String? courierId,
    String? customerId,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      courierId: courierId ?? this.courierId,
      customerId: customerId ?? this.customerId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        if (pickupAddress != null) 'pickupAddress': pickupAddress,
        if (dropoffAddress != null) 'dropoffAddress': dropoffAddress,
        if (pickupLat != null) 'pickupLat': pickupLat,
        if (pickupLng != null) 'pickupLng': pickupLng,
        if (dropoffLat != null) 'dropoffLat': dropoffLat,
        if (dropoffLng != null) 'dropoffLng': dropoffLng,
        if (courierId != null) 'courierId': courierId,
        if (customerId != null) 'customerId': customerId,
      };

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['id'] as String,
      title: json['title'] as String? ??
          '${json['pickupAddress'] ?? 'Pickup'} → ${json['dropoffAddress'] ?? 'Dropoff'}',
      amount: (json['amount'] as num? ?? json['fee'] as num?)?.toDouble() ?? 0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      pickupAddress: json['pickupAddress'] as String?,
      dropoffAddress: json['dropoffAddress'] as String?,
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
      courierId: json['courierId'] as String?,
      customerId: json['customerId'] as String?,
    );
  }
}
