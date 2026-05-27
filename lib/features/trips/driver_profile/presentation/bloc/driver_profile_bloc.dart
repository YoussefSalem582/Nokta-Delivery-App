import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_driver_for_trip_usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'driver_profile_event.dart';
part 'driver_profile_state.dart';

class DriverProfileData extends Equatable {
  const DriverProfileData({
    required this.tripId,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.rating,
    this.vehicle,
  });

  final String tripId;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final double? rating;
  final String? vehicle;

  bool get hasPhone => phone != null && phone!.isNotEmpty;

  @override
  List<Object?> get props => [tripId, name, phone, avatarUrl, rating, vehicle];
}

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  DriverProfileBloc({
    required GetTripDetailUseCase getTripDetail,
    required GetDriverForTripUseCase getDriverForTrip,
  })  : _getTripDetail = getTripDetail,
        _getDriverForTrip = getDriverForTrip,
        super(const DriverProfileInitial()) {
    on<DriverProfileLoadRequested>(_onLoad);
  }

  final GetTripDetailUseCase _getTripDetail;
  final GetDriverForTripUseCase _getDriverForTrip;

  Future<void> _onLoad(
    DriverProfileLoadRequested event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(const DriverProfileLoading());

    final tripResult = await _getTripDetail(GetTripDetailParams(event.tripId));
    await tripResult.fold(
      (Failure failure) async => emit(DriverProfileError(failure.message)),
      (TripEntity trip) async {
        final name = trip.driverName;
        if (name == null || name.isEmpty) {
          emit(const DriverProfileError('call_no_driver'));
          return;
        }

        DriverEntity? driver;
        final driverResult = await _getDriverForTrip(
          GetDriverForTripParams(driverName: name),
        );
        driverResult.fold((_) {}, (value) => driver = value);

        emit(
          DriverProfileLoaded(
            profile: DriverProfileData(
              tripId: trip.id,
              name: name,
              phone: trip.driverPhone ?? driver?.phone,
              avatarUrl: trip.driverAvatarUrl,
              rating: trip.driverRating ?? driver?.rating,
              vehicle: trip.driverVehicle ?? driver?.vehicle,
            ),
          ),
        );
      },
    );
  }
}
