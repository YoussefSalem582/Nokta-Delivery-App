part of 'driver_call_bloc.dart';

abstract class DriverCallState extends Equatable {
  const DriverCallState();

  @override
  List<Object?> get props => [];
}

class DriverCallInitial extends DriverCallState {
  const DriverCallInitial();
}

class DriverCallLoading extends DriverCallState {
  const DriverCallLoading();
}

class DriverCallConnecting extends DriverCallState {
  const DriverCallConnecting({
    required this.trip,
    required this.isMuted,
    required this.isSpeakerOn,
  });

  final TripEntity trip;
  final bool isMuted;
  final bool isSpeakerOn;

  DriverCallConnecting copyWith({
    TripEntity? trip,
    bool? isMuted,
    bool? isSpeakerOn,
  }) {
    return DriverCallConnecting(
      trip: trip ?? this.trip,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }

  @override
  List<Object?> get props => [trip, isMuted, isSpeakerOn];
}

class DriverCallActive extends DriverCallState {
  const DriverCallActive({
    required this.trip,
    required this.elapsedSeconds,
    required this.isMuted,
    required this.isSpeakerOn,
  });

  final TripEntity trip;
  final int elapsedSeconds;
  final bool isMuted;
  final bool isSpeakerOn;

  DriverCallActive copyWith({
    TripEntity? trip,
    int? elapsedSeconds,
    bool? isMuted,
    bool? isSpeakerOn,
  }) {
    return DriverCallActive(
      trip: trip ?? this.trip,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }

  @override
  List<Object?> get props => [trip, elapsedSeconds, isMuted, isSpeakerOn];
}

class DriverCallEndedState extends DriverCallState {
  const DriverCallEndedState({required this.trip});

  final TripEntity trip;

  @override
  List<Object?> get props => [trip];
}

class DriverCallError extends DriverCallState {
  const DriverCallError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
