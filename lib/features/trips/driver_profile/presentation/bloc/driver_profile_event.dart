part of 'driver_profile_bloc.dart';

abstract class DriverProfileEvent extends Equatable {
  const DriverProfileEvent();

  @override
  List<Object?> get props => [];
}

class DriverProfileLoadRequested extends DriverProfileEvent {
  const DriverProfileLoadRequested(this.tripId);

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}
