part of 'trip_list_bloc.dart';

abstract class TripListEvent extends Equatable {
  const TripListEvent();
  @override
  List<Object?> get props => [];
}

class TripListLoadRequested extends TripListEvent {
  const TripListLoadRequested();
}

class TripListRefreshRequested extends TripListEvent {
  const TripListRefreshRequested();
}

/// Re-reads trips from Hive without a loading state or remote force-refresh.
class TripListCacheSyncRequested extends TripListEvent {
  const TripListCacheSyncRequested();
}
