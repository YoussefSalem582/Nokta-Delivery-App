import 'package:equatable/equatable.dart';

class RideLocationUpdate extends Equatable {
  const RideLocationUpdate({
    required this.rideId,
    required this.lat,
    required this.lng,
    this.heading,
    required this.updatedAt,
  });

  final String rideId;
  final double lat;
  final double lng;
  final double? heading;
  final DateTime updatedAt;

  factory RideLocationUpdate.fromJson(Map<String, dynamic> json) {
    return RideLocationUpdate(
      rideId: json['rideId'] as String,
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
  List<Object?> get props => [rideId, lat, lng, heading, updatedAt];
}
