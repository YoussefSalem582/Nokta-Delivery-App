import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Link-type connectivity only; Wi‑Fi without internet may still report online.
class NetworkStatus {
  NetworkStatus(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> get isOnline async {
    if (kIsWeb) return true;
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Stream<bool> get onOnlineChanged async* {
    if (kIsWeb) {
      yield true;
      return;
    }
    yield await isOnline;
    await for (final result in _connectivity.onConnectivityChanged) {
      yield !result.contains(ConnectivityResult.none);
    }
  }
}
