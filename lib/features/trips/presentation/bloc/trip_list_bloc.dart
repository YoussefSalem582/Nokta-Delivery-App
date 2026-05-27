import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';

part 'trip_list_event.dart';
part 'trip_list_state.dart';

class TripListBloc extends Bloc<TripListEvent, TripListState> {
  TripListBloc({
    required TripRepository repository,
    required Connectivity connectivity,
  })  : _repository = repository,
        _connectivity = connectivity,
        super(const TripListInitial()) {
    on<TripListLoadRequested>(_onLoad);
    on<TripListRefreshRequested>(_onRefresh);
  }

  final TripRepository _repository;
  final Connectivity _connectivity;

  Future<void> _onLoad(
    TripListLoadRequested event,
    Emitter<TripListState> emit,
  ) async {
    emit(const TripListLoading());
    final connectivity = await _connectivity.checkConnectivity();
    final isOffline = connectivity.contains(ConnectivityResult.none);
    try {
      final cached = _repository.getCachedTrips();
      if (cached.isNotEmpty) {
        emit(TripListLoaded(trips: cached, isOffline: isOffline));
      }
      final trips = await _repository.getTrips();
      emit(TripListLoaded(trips: trips, isOffline: isOffline));
    } catch (e) {
      emit(TripListError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    TripListRefreshRequested event,
    Emitter<TripListState> emit,
  ) async {
    final current = state;
    if (current is TripListLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    try {
      final trips = await _repository.getTrips(forceRefresh: true);
      final connectivity = await _connectivity.checkConnectivity();
      emit(
        TripListLoaded(
          trips: trips,
          isOffline: connectivity.contains(ConnectivityResult.none),
        ),
      );
    } catch (e) {
      emit(TripListError(e.toString()));
    }
  }
}
