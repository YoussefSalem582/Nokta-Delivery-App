part of 'driver_call_bloc.dart';

abstract class DriverCallEvent extends Equatable {
  const DriverCallEvent();

  @override
  List<Object?> get props => [];
}

class DriverCallStarted extends DriverCallEvent {
  const DriverCallStarted(this.tripId);

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

class DriverCallConnected extends DriverCallEvent {
  const DriverCallConnected();
}

class DriverCallTick extends DriverCallEvent {
  const DriverCallTick();
}

class DriverCallMuteToggled extends DriverCallEvent {
  const DriverCallMuteToggled();
}

class DriverCallSpeakerToggled extends DriverCallEvent {
  const DriverCallSpeakerToggled();
}

class DriverCallEnded extends DriverCallEvent {
  const DriverCallEnded();
}
