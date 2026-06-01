part of 'delivery_tracking_bloc.dart';

abstract class DeliveryTrackingEvent extends Equatable {
  const DeliveryTrackingEvent();

  @override
  List<Object?> get props => [];
}

class DeliveryTrackingLoadRequested extends DeliveryTrackingEvent {
  const DeliveryTrackingLoadRequested({
    required this.deliveryId,
    this.role = DeliveryTrackingRole.customer,
  });

  final String deliveryId;
  final DeliveryTrackingRole role;

  @override
  List<Object?> get props => [deliveryId, role];
}

class DeliveryTrackingTick extends DeliveryTrackingEvent {
  const DeliveryTrackingTick(this.now);

  final DateTime now;

  @override
  List<Object?> get props => [now];
}

class DeliveryTrackingLiveLocationReceived extends DeliveryTrackingEvent {
  const DeliveryTrackingLiveLocationReceived(this.update);

  final DeliveryLocationUpdate update;

  @override
  List<Object?> get props => [update];
}

class DeliveryTrackingStatusRequested extends DeliveryTrackingEvent {
  const DeliveryTrackingStatusRequested({
    required this.deliveryId,
    required this.status,
  });

  final String deliveryId;
  final OrderStatus status;

  @override
  List<Object?> get props => [deliveryId, status];
}

class DeliveryTrackingStopped extends DeliveryTrackingEvent {
  const DeliveryTrackingStopped();
}
