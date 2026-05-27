import 'dart:async';

import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'driver_call_event.dart';
part 'driver_call_state.dart';

class DriverCallBloc extends Bloc<DriverCallEvent, DriverCallState> {
  DriverCallBloc({
    required GetTripDetailUseCase getTripDetail,
  }) : _getTripDetail = getTripDetail,
       super(const DriverCallInitial()) {
    on<DriverCallStarted>(_onStarted);
    on<DriverCallConnected>(_onConnected);
    on<DriverCallTick>(_onTick);
    on<DriverCallMuteToggled>(_onMuteToggled);
    on<DriverCallSpeakerToggled>(_onSpeakerToggled);
    on<DriverCallEnded>(_onEnded);
  }

  final GetTripDetailUseCase _getTripDetail;
  Timer? _connectTimer;
  Timer? _durationTimer;

  Future<void> _onStarted(
    DriverCallStarted event,
    Emitter<DriverCallState> emit,
  ) async {
    emit(const DriverCallLoading());

    final result = await _getTripDetail(GetTripDetailParams(event.tripId));
    await result.fold(
      (Failure failure) async => emit(DriverCallError(failure.message)),
      (TripEntity trip) async {
        if (trip.driverName == null || trip.driverName!.isEmpty) {
          emit(const DriverCallError('call_no_driver'));
          return;
        }

        emit(
          DriverCallConnecting(
            trip: trip,
            isMuted: false,
            isSpeakerOn: false,
          ),
        );

        _connectTimer?.cancel();
        _connectTimer = Timer(const Duration(seconds: 2), () {
          add(const DriverCallConnected());
        });
      },
    );
  }

  void _onConnected(DriverCallConnected event, Emitter<DriverCallState> emit) {
    final current = state;
    if (current is! DriverCallConnecting) return;

    emit(
      DriverCallActive(
        trip: current.trip,
        elapsedSeconds: 0,
        isMuted: current.isMuted,
        isSpeakerOn: current.isSpeakerOn,
      ),
    );

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const DriverCallTick());
    });
  }

  void _onTick(DriverCallTick event, Emitter<DriverCallState> emit) {
    final current = state;
    if (current is! DriverCallActive) return;

    emit(
      current.copyWith(elapsedSeconds: current.elapsedSeconds + 1),
    );
  }

  void _onMuteToggled(
    DriverCallMuteToggled event,
    Emitter<DriverCallState> emit,
  ) {
    final current = state;
    if (current is DriverCallConnecting) {
      emit(current.copyWith(isMuted: !current.isMuted));
    } else if (current is DriverCallActive) {
      emit(current.copyWith(isMuted: !current.isMuted));
    }
  }

  void _onSpeakerToggled(
    DriverCallSpeakerToggled event,
    Emitter<DriverCallState> emit,
  ) {
    final current = state;
    if (current is DriverCallConnecting) {
      emit(current.copyWith(isSpeakerOn: !current.isSpeakerOn));
    } else if (current is DriverCallActive) {
      emit(current.copyWith(isSpeakerOn: !current.isSpeakerOn));
    }
  }

  void _onEnded(DriverCallEnded event, Emitter<DriverCallState> emit) {
    _connectTimer?.cancel();
    _durationTimer?.cancel();

    final current = state;
    if (current is DriverCallConnecting) {
      emit(DriverCallEndedState(trip: current.trip));
    } else if (current is DriverCallActive) {
      emit(DriverCallEndedState(trip: current.trip));
    }
  }

  @override
  Future<void> close() {
    _connectTimer?.cancel();
    _durationTimer?.cancel();
    return super.close();
  }
}
