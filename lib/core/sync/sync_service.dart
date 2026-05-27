import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:delivery_app/core/architecture/repositories/order_repository.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/utils/constants.dart';

class SyncService {
  SyncService({
    required TripRepository tripRepository,
    required OrderRepository orderRepository,
    required Connectivity connectivity,
    required Talker talker,
  })  : _tripRepository = tripRepository,
        _orderRepository = orderRepository,
        _connectivity = connectivity,
        _talker = talker;

  final TripRepository _tripRepository;
  final OrderRepository _orderRepository;
  final Connectivity _connectivity;
  final Talker _talker;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult>? _lastResult;

  Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      AppConstants.workmanagerUniqueName,
      AppConstants.workmanagerTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );

    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivity);
    _talker.info('[SyncService] Initialized with WorkManager + connectivity listener');
  }

  Future<void> _onConnectivity(List<ConnectivityResult> result) async {
    final wasOffline = _lastResult?.contains(ConnectivityResult.none) ?? false;
    final isOnline = !result.contains(ConnectivityResult.none);
    _lastResult = result;

    if (wasOffline && isOnline) {
      _talker.info('[SyncService] Reconnected — draining pending sync');
      await syncAll();
    }
  }

  Future<void> syncAll() async {
    await _tripRepository.syncPendingChanges();
    await _orderRepository.getOrders(forceRefresh: true);
    _talker.info('[SyncService] Sync complete');
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background sync relies on foreground reconnect in demo;
    // full Hive re-init in isolate is omitted for template simplicity.
    return Future.value(true);
  });
}
