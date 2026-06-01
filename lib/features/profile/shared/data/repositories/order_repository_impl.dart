import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/cache/datasources/cache_metadata_local_datasource.dart';
import 'package:delivery_app/core/cache/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/features/profile/shared/data/datasources/delivery_remote_datasource.dart';
import 'package:delivery_app/features/profile/shared/data/datasources/order_local_datasource.dart';
import 'package:delivery_app/features/profile/shared/data/datasources/order_remote_datasource.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/features/profile/shared/domain/repositories/order_repository.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/utils/cache_freshness.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderLocalDataSource local,
    required OrderRemoteDataSource remote,
    required DeliveryRemoteDataSource deliveryRemote,
    required PendingSyncLocalDataSource pendingSync,
    required CacheMetadataLocalDataSource cacheMetadata,
    required NetworkStatus networkStatus,
    required Talker talker,
  })  : _local = local,
        _remote = remote,
        _deliveryRemote = deliveryRemote,
        _pendingSync = pendingSync,
        _cacheMetadata = cacheMetadata,
        _networkStatus = networkStatus,
        _talker = talker;

  final OrderLocalDataSource _local;
  final OrderRemoteDataSource _remote;
  final DeliveryRemoteDataSource _deliveryRemote;
  final PendingSyncLocalDataSource _pendingSync;
  final CacheMetadataLocalDataSource _cacheMetadata;
  final NetworkStatus _networkStatus;
  final Talker _talker;
  final _uuid = const Uuid();

  @override
  List<OrderEntity> getCachedOrders() => _local.getAll();

  @override
  Future<List<OrderEntity>> getOrders({bool forceRefresh = false}) async {
    final cached = _local.getAll();
    final lastFetched = _cacheMetadata.getLastFetched(CacheKeys.orders);

    if (!forceRefresh &&
        cached.isNotEmpty &&
        (!await _networkStatus.isOnline ||
            CacheFreshness.isFresh(lastFetched))) {
      return cached;
    }

    if (!await _networkStatus.isOnline) return cached;

    try {
      final remote = await _remote.fetchOrders();
      await _local.saveAll(remote);
      await _cacheMetadata.markFetched(CacheKeys.orders);
      return _local.getAll();
    } on DioException catch (e, st) {
      _talker.handle(e, st, '[OrderRepo] Using cached orders');
      return cached;
    }
  }

  @override
  Future<OrderEntity> createDelivery({
    required String pickupAddress,
    required String dropoffAddress,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required double fee,
    String? packageNotes,
  }) async {
    final optimisticId = _uuid.v4();
    final now = DateTime.now();
    final optimisticOrder = OrderEntity(
      id: optimisticId,
      title: '$pickupAddress → $dropoffAddress',
      amount: fee,
      status: OrderStatus.pending,
      createdAt: now,
    );

    final payload = {
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'fee': fee,
      if (packageNotes != null) 'packageNotes': packageNotes,
    };

    await _local.save(optimisticOrder);
    await _pendingSync.enqueueOrReplace(
      PendingSyncEntity(
        id: optimisticId,
        action: SyncAction.createDelivery,
        payload: payload,
        createdAt: now,
      ),
    );

    if (EnvConfig.usesRealBackend && await _networkStatus.isOnline) {
      try {
        final remote = await _deliveryRemote.createDelivery(
          payload,
          idempotencyKey: optimisticId,
        );
        await _local.delete(optimisticId);
        await _local.save(remote);
        await _pendingSync.remove(optimisticId);
        await _cacheMetadata.markFetched(CacheKeys.orders);
        return remote;
      } on DioException catch (e, st) {
        _talker.handle(e, st, '[OrderRepo] Delivery queued for sync');
      }
    }

    return optimisticOrder;
  }

  @override
  Future<void> syncPendingChanges() async {
    if (!await _networkStatus.isOnline) return;

    for (final item in _pendingSync.getAll()) {
      if (item.action != SyncAction.createDelivery) continue;

      try {
        final remote = await _deliveryRemote.createDelivery(
          item.payload,
          idempotencyKey: item.id,
        );
        await _local.delete(item.id);
        await _local.save(remote);
        await _pendingSync.remove(item.id);
        _talker.info('[OrderRepo] Synced pending delivery ${item.id}');
      } catch (e, st) {
        _talker.handle(e, st, '[OrderRepo] Failed to sync delivery ${item.id}');
        await _pendingSync.enqueueOrReplace(
          item.copyWith(retryCount: item.retryCount + 1),
        );
      }
    }

    await getOrders(forceRefresh: true);
  }
}
