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
  const PendingSyncLoaded({required this.items, this.justSynced = false});

  final List<PendingSyncEntity> items;

  /// True when this state is the result of a manual retry finishing, so the
  /// UI can surface a "synced" confirmation toast once.
  final bool justSynced;

  @override
  List<Object?> get props => [items, justSynced];
}

class PendingSyncError extends PendingSyncState {
  const PendingSyncError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
