import 'package:talker_flutter/talker_flutter.dart';
import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/cache/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/sync/app_data_coordinator.dart';
import 'package:delivery_app/core/sync/sync_action_mapper.dart';
import 'package:delivery_app/core/sync/sync_remote_datasource.dart';
import 'package:delivery_app/features/trips/shared/data/datasources/trip_local_datasource.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

/// Sends eligible offline actions to POST /v1/sync/actions in one batch.
class SyncBatchHandler {
  SyncBatchHandler({
    required PendingSyncLocalDataSource pendingSync,
    required SyncRemoteDataSource syncRemote,
    required TripLocalDataSource tripLocal,
    required AppDataCoordinator coordinator,
    required Talker talker,
  })  : _pendingSync = pendingSync,
        _syncRemote = syncRemote,
        _tripLocal = tripLocal,
        _coordinator = coordinator,
        _talker = talker;

  final PendingSyncLocalDataSource _pendingSync;
  final SyncRemoteDataSource _syncRemote;
  final TripLocalDataSource _tripLocal;
  final AppDataCoordinator _coordinator;
  final Talker _talker;

  Future<void> syncEligibleActions() async {
    if (!EnvConfig.usesRealBackend) return;

    final batchItems = _pendingSync
        .getAll()
        .where((item) => SyncActionMapper.supportsBatchSync(item.action))
        .toList();

    if (batchItems.isEmpty) return;

    try {
      final actions = batchItems.map(SyncActionMapper.toBackendAction).toList();
      final results = await _syncRemote.syncActionsBatch(actions);

      for (final result in results) {
        await _applyResult(result);
      }

      _coordinator.notifyTripDataChanged();
      _talker.info('[SyncBatch] Processed ${results.length} queued ride requests');
    } catch (e, st) {
      _talker.handle(e, st, '[SyncBatch] Batch sync failed');
    }
  }

  Future<void> _applyResult(Map<String, dynamic> result) async {
    final clientActionId = result['clientActionId'] as String?;
    final status = result['status'] as String?;

    if (clientActionId == null || status == null) return;

    if (status == 'processed' || status == 'duplicate') {
      final response = result['response'];
      if (response is Map<String, dynamic>) {
        await _tripLocal.delete(clientActionId);
        await _tripLocal.save(
          TripEntity.fromJson(response).copyWith(isPendingSync: false),
        );
      }
      await _pendingSync.remove(clientActionId);
      _talker.info('[SyncBatch] Applied $clientActionId ($status)');
      return;
    }

    if (status == 'failed') {
      final item = _findPendingItem(clientActionId);
      if (item != null) {
        await _pendingSync.enqueueOrReplace(
          item.copyWith(retryCount: item.retryCount + 1),
        );
      }
    }
  }

  PendingSyncEntity? _findPendingItem(String id) {
    for (final item in _pendingSync.getAll()) {
      if (item.id == id) return item;
    }
    return null;
  }
}
