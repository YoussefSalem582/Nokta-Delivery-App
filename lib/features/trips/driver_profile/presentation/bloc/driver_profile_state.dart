part of 'driver_profile_bloc.dart';

abstract class DriverProfileState extends Equatable {
  const DriverProfileState();

  @override
  List<Object?> get props => [];
}

class DriverProfileInitial extends DriverProfileState {
  const DriverProfileInitial();
}

class DriverProfileLoading extends DriverProfileState {
  const DriverProfileLoading();
}

class DriverProfileLoaded extends DriverProfileState {
  const DriverProfileLoaded({required this.profile});

  final DriverProfileData profile;

  @override
  List<Object?> get props => [profile];
}

class DriverProfileError extends DriverProfileState {
  const DriverProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
