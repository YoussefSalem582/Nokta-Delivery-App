part of 'pending_sync_bloc.dart';

abstract class PendingSyncEvent extends Equatable {
  const PendingSyncEvent();

  @override
  List<Object> get props => [];
}

class PendingSyncLoadRequested extends PendingSyncEvent {
  const PendingSyncLoadRequested();
}

class PendingSyncRetryRequested extends PendingSyncEvent {
  const PendingSyncRetryRequested();
}

class PendingSyncClearRequested extends PendingSyncEvent {
  const PendingSyncClearRequested();
}

class PendingSyncRemoveItemRequested extends PendingSyncEvent {
  const PendingSyncRemoveItemRequested(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}
