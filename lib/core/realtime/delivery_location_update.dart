import 'package:equatable/equatable.dart';

class DeliveryLocationUpdate extends Equatable {
  const DeliveryLocationUpdate({
    required this.deliveryId,
    required this.lat,
    required this.lng,
    this.heading,
    required this.updatedAt,
  });

  final String deliveryId;
  final double lat;
  final double lng;
  final double? heading;
  final DateTime updatedAt;

  factory DeliveryLocationUpdate.fromJson(Map<String, dynamic> json) {
    return DeliveryLocationUpdate(
      deliveryId: json['deliveryId'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      heading: json['heading'] != null
          ? (json['heading'] as num).toDouble()
          : null,
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  List<Object?> get props => [deliveryId, lat, lng, heading, updatedAt];
}
