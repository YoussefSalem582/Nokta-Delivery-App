import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/core/cache/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/sync/sync_service.dart';

part 'pending_sync_event.dart';
part 'pending_sync_state.dart';

class PendingSyncBloc extends Bloc<PendingSyncEvent, PendingSyncState> {
  PendingSyncBloc({
    required PendingSyncLocalDataSource pendingSync,
    required SyncService syncService,
  })  : _pendingSync = pendingSync,
        _syncService = syncService,
        super(const PendingSyncInitial()) {
    on<PendingSyncLoadRequested>(_onLoad);
    on<PendingSyncRetryRequested>(_onRetry);
    on<PendingSyncClearRequested>(_onClear);
    on<PendingSyncRemoveItemRequested>(_onRemoveItem);
  }

  final PendingSyncLocalDataSource _pendingSync;
  final SyncService _syncService;

  Future<void> _onLoad(
    PendingSyncLoadRequested event,
    Emitter<PendingSyncState> emit,
  ) async {
    emit(const PendingSyncLoading());
    try {
      final items = _pendingSync.getAll();
      emit(PendingSyncLoaded(items: items));
    } catch (e) {
      emit(PendingSyncError(e.toString()));
    }
  }

  Future<void> _onRetry(
    PendingSyncRetryRequested event,
    Emitter<PendingSyncState> emit,
  ) async {
    emit(const PendingSyncLoading());
    await _syncService.syncAll();
    add(const PendingSyncLoadRequested());
  }

  Future<void> _onClear(
    PendingSyncClearRequested event,
    Emitter<PendingSyncState> emit,
  ) async {
    await _pendingSync.clear();
    add(const PendingSyncLoadRequested());
  }

  Future<void> _onRemoveItem(
    PendingSyncRemoveItemRequested event,
    Emitter<PendingSyncState> emit,
  ) async {
    await _pendingSync.remove(event.id);
    add(const PendingSyncLoadRequested());
  }
}
