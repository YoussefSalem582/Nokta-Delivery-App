part of 'delivery_tracking_bloc.dart';

abstract class DeliveryTrackingState extends Equatable {
  const DeliveryTrackingState();

  @override
  List<Object?> get props => [];
}

class DeliveryTrackingInitial extends DeliveryTrackingState {
  const DeliveryTrackingInitial();
}

class DeliveryTrackingLoading extends DeliveryTrackingState {
  const DeliveryTrackingLoading({this.deliveryId});

  final String? deliveryId;

  @override
  List<Object?> get props => [deliveryId];
}

class DeliveryTrackingActive extends DeliveryTrackingState {
  const DeliveryTrackingActive({
    required this.order,
    required this.route,
    required this.driverPosition,
    required this.driverBearing,
    required this.traveledRoute,
    required this.remainingRoute,
    required this.progress,
    required this.etaMinutes,
    required this.phase,
    required this.remainingDistanceKm,
    this.role = DeliveryTrackingRole.customer,
    this.isUpdating = false,
    this.currentManeuver,
    this.nextManeuver,
    this.estimatedArrival,
    this.destinationLabel,
  });

  final OrderEntity order;
  final List<LatLng> route;
  final LatLng driverPosition;
  final double driverBearing;
  final List<LatLng> traveledRoute;
  final List<LatLng> remainingRoute;
  final double progress;
  final int etaMinutes;
  final DeliveryTrackingPhase phase;
  final double remainingDistanceKm;
  final DeliveryTrackingRole role;
  final bool isUpdating;
  final RouteManeuver? currentManeuver;
  final RouteManeuver? nextManeuver;
  final DateTime? estimatedArrival;
  final String? destinationLabel;

  bool get canMarkPickedUp =>
      role == DeliveryTrackingRole.courier &&
      order.status == OrderStatus.assigned;

  bool get canStartTransit =>
      role == DeliveryTrackingRole.courier &&
      order.status == OrderStatus.pickedUp;

  bool get canMarkDelivered =>
      role == DeliveryTrackingRole.courier &&
      order.status == OrderStatus.inTransit;

  DeliveryTrackingActive copyWith({
    OrderEntity? order,
    List<LatLng>? route,
    LatLng? driverPosition,
    double? driverBearing,
    List<LatLng>? traveledRoute,
    List<LatLng>? remainingRoute,
    double? progress,
    int? etaMinutes,
    DeliveryTrackingPhase? phase,
    double? remainingDistanceKm,
    DeliveryTrackingRole? role,
    bool? isUpdating,
    RouteManeuver? currentManeuver,
    RouteManeuver? nextManeuver,
    DateTime? estimatedArrival,
    String? destinationLabel,
  }) {
    return DeliveryTrackingActive(
      order: order ?? this.order,
      route: route ?? this.route,
      driverPosition: driverPosition ?? this.driverPosition,
      driverBearing: driverBearing ?? this.driverBearing,
      traveledRoute: traveledRoute ?? this.traveledRoute,
      remainingRoute: remainingRoute ?? this.remainingRoute,
      progress: progress ?? this.progress,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      phase: phase ?? this.phase,
      remainingDistanceKm: remainingDistanceKm ?? this.remainingDistanceKm,
      role: role ?? this.role,
      isUpdating: isUpdating ?? this.isUpdating,
      currentManeuver: currentManeuver ?? this.currentManeuver,
      nextManeuver: nextManeuver ?? this.nextManeuver,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      destinationLabel: destinationLabel ?? this.destinationLabel,
    );
  }

  @override
  List<Object?> get props => [
        order.id,
        order.status,
        driverPosition,
        progress,
        etaMinutes,
        phase,
        role,
        isUpdating,
        currentManeuver,
        nextManeuver,
      ];
}

class DeliveryTrackingCompleted extends DeliveryTrackingState {
  const DeliveryTrackingCompleted({
    required this.order,
    required this.route,
    required this.driverPosition,
    required this.driverBearing,
    required this.traveledRoute,
    required this.remainingRoute,
    this.role = DeliveryTrackingRole.customer,
  });

  final OrderEntity order;
  final List<LatLng> route;
  final LatLng driverPosition;
  final double driverBearing;
  final List<LatLng> traveledRoute;
  final List<LatLng> remainingRoute;
  final DeliveryTrackingRole role;

  @override
  List<Object?> get props => [order.id, role];
}

class DeliveryTrackingError extends DeliveryTrackingState {
  const DeliveryTrackingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
