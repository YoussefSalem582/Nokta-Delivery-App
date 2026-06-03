part of 'pending_sync_bloc.dart';

abstract class PendingSyncState extends Equatable {
  const PendingSyncState();
  
  @override
  List<Object?> get props => [];
}

class PendingSyncInitial extends PendingSyncState {
  const PendingSyncInitial();
}

class PendingSyncLoading extends PendingSyncState {
  const PendingSyncLoading();
}

class PendingSyncLoaded extends PendingSyncState {
  const PendingSyncLoaded({required this.items});
  
  final List<PendingSyncEntity> items;

  @override
  List<Object?> get props => [items];
}

class PendingSyncError extends PendingSyncState {
  const PendingSyncError(this.message);
  
  final String message;

  @override
  List<Object?> get props => [message];
}
