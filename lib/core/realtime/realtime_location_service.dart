import 'dart:async';

import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/realtime/ride_location_update.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_token_store.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:talker_flutter/talker_flutter.dart';

/// Subscribes to NestJS `/realtime` ride location broadcasts.
class RealtimeLocationService {
  RealtimeLocationService({
    required AuthTokenStore tokenStore,
    required Talker talker,
  })  : _tokenStore = tokenStore,
        _talker = talker;

  final AuthTokenStore _tokenStore;
  final Talker _talker;

  io.Socket? _socket;
  StreamController<RideLocationUpdate>? _controller;
  String? _activeRideId;

  Stream<RideLocationUpdate> watchRide(String rideId) {
    if (!EnvConfig.usesRealBackend || !_tokenStore.hasAccessToken) {
      return const Stream.empty();
    }

    _controller?.close();
    _controller = StreamController<RideLocationUpdate>.broadcast();
    _activeRideId = rideId;

    unawaited(_connectAndJoin(rideId));

    return _controller!.stream;
  }

  Future<void> _connectAndJoin(String rideId) async {
    try {
      await disconnect();

      final token = _tokenStore.accessToken;
      if (token == null || token.isEmpty) return;

      _socket = io.io(
        '${EnvConfig.realtimeBaseUrl}/realtime',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      _socket!
        ..onConnect((_) {
          _talker.info('[Realtime] Connected — joining ride $rideId');
          _socket!.emit('joinRide', {'rideId': rideId});
        })
        ..on('rideLocation', _handleRideLocation)
        ..onDisconnect((_) {
          _talker.info('[Realtime] Disconnected');
        })
        ..onConnectError((error) {
          _talker.warning('[Realtime] Connect error: $error');
        })
        ..connect();
    } catch (e, st) {
      _talker.handle(e, st, '[Realtime] Failed to connect');
    }
  }

  void _handleRideLocation(dynamic raw) {
    if (raw is! Map) return;

    try {
      final update = RideLocationUpdate.fromJson(
        Map<String, dynamic>.from(raw),
      );

      if (_activeRideId != null && update.rideId != _activeRideId) return;
      _controller?.add(update);
    } catch (e, st) {
      _talker.handle(e, st, '[Realtime] Invalid rideLocation payload');
    }
  }

  Future<void> disconnect() async {
    _activeRideId = null;
    _socket?.off('rideLocation');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    await _controller?.close();
    _controller = null;
  }
}
