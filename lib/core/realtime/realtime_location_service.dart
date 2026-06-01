import 'dart:async';

import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/realtime/delivery_location_update.dart';
import 'package:delivery_app/core/realtime/ride_location_update.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_token_store.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:talker_flutter/talker_flutter.dart';

/// Socket.io client for NestJS `/realtime` ride and delivery location events.
class RealtimeLocationService {
  RealtimeLocationService({
    required AuthTokenStore tokenStore,
    required Talker talker,
  })  : _tokenStore = tokenStore,
        _talker = talker;

  final AuthTokenStore _tokenStore;
  final Talker _talker;

  io.Socket? _socket;
  bool _manualDisconnect = false;

  StreamController<RideLocationUpdate>? _rideController;
  StreamController<DeliveryLocationUpdate>? _deliveryController;

  String? _activeRideId;
  String? _activeDeliveryId;

  Stream<RideLocationUpdate> watchRide(String rideId) {
    if (!EnvConfig.usesRealBackend || !_tokenStore.hasAccessToken) {
      return const Stream.empty();
    }

    _rideController?.close();
    _rideController = StreamController<RideLocationUpdate>.broadcast();
    _activeRideId = rideId;

    unawaited(_ensureConnected(joinRideId: rideId));

    return _rideController!.stream;
  }

  Stream<DeliveryLocationUpdate> watchDelivery(String deliveryId) {
    if (!EnvConfig.usesRealBackend || !_tokenStore.hasAccessToken) {
      return const Stream.empty();
    }

    _deliveryController?.close();
    _deliveryController =
        StreamController<DeliveryLocationUpdate>.broadcast();
    _activeDeliveryId = deliveryId;

    unawaited(_ensureConnected(joinDeliveryId: deliveryId));

    return _deliveryController!.stream;
  }

  Future<void> joinRideRoom(String rideId) async {
    if (!EnvConfig.usesRealBackend || !_tokenStore.hasAccessToken) return;

    _activeRideId = rideId;
    await _ensureConnected(joinRideId: rideId);
  }

  Future<void> joinDeliveryRoom(String deliveryId) async {
    if (!EnvConfig.usesRealBackend || !_tokenStore.hasAccessToken) return;

    _activeDeliveryId = deliveryId;
    await _ensureConnected(joinDeliveryId: deliveryId);
  }

  void publishRideLocation({
    required String rideId,
    required double lat,
    required double lng,
    double? heading,
  }) {
    if (!EnvConfig.usesRealBackend || _socket?.connected != true) return;

    _socket!.emit('publishRideLocation', {
      'rideId': rideId,
      'lat': lat,
      'lng': lng,
      if (heading != null) 'heading': heading,
    });
  }

  void publishDeliveryLocation({
    required String deliveryId,
    required double lat,
    required double lng,
    double? heading,
  }) {
    if (!EnvConfig.usesRealBackend || _socket?.connected != true) return;

    _socket!.emit('publishDeliveryLocation', {
      'deliveryId': deliveryId,
      'lat': lat,
      'lng': lng,
      if (heading != null) 'heading': heading,
    });
  }

  Future<void> _ensureConnected({
    String? joinRideId,
    String? joinDeliveryId,
  }) async {
    if (joinRideId != null) _activeRideId = joinRideId;
    if (joinDeliveryId != null) _activeDeliveryId = joinDeliveryId;

    final token = _tokenStore.accessToken;
    if (token == null || token.isEmpty) return;

    if (_socket?.connected == true) {
      _rejoinRooms();
      return;
    }

    _manualDisconnect = false;

    if (_socket == null) {
      _socket = io.io(
        '${EnvConfig.realtimeBaseUrl}/realtime',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(12)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(10000)
            .setAuth({'token': token})
            .build(),
      );

      _socket!
        ..onConnect((_) {
          _talker.info('[Realtime] Connected');
          _rejoinRooms();
        })
        ..on('rideLocation', _handleRideLocation)
        ..on('deliveryLocation', _handleDeliveryLocation)
        ..onDisconnect((_) {
          if (!_manualDisconnect) {
            _talker.info('[Realtime] Disconnected — retrying with backoff');
          }
        })
        ..onConnectError((error) {
          _talker.warning('[Realtime] Connect error: $error');
        })
        ..onReconnect((attempt) {
          _talker.info('[Realtime] Reconnected after $attempt attempt(s)');
          _rejoinRooms();
        });
    }

    _socket!.connect();
  }

  void _rejoinRooms() {
    if (_activeRideId != null) {
      _socket?.emit('joinRide', {'rideId': _activeRideId});
    }
    if (_activeDeliveryId != null) {
      _socket?.emit('joinDelivery', {'deliveryId': _activeDeliveryId});
    }
  }

  void _handleRideLocation(dynamic raw) {
    if (raw is! Map) return;

    try {
      final update = RideLocationUpdate.fromJson(
        Map<String, dynamic>.from(raw),
      );

      if (_activeRideId != null && update.rideId != _activeRideId) return;
      _rideController?.add(update);
    } catch (e, st) {
      _talker.handle(e, st, '[Realtime] Invalid rideLocation payload');
    }
  }

  void _handleDeliveryLocation(dynamic raw) {
    if (raw is! Map) return;

    try {
      final update = DeliveryLocationUpdate.fromJson(
        Map<String, dynamic>.from(raw),
      );

      if (_activeDeliveryId != null &&
          update.deliveryId != _activeDeliveryId) {
        return;
      }
      _deliveryController?.add(update);
    } catch (e, st) {
      _talker.handle(e, st, '[Realtime] Invalid deliveryLocation payload');
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _activeRideId = null;
    _activeDeliveryId = null;
    _socket?.off('rideLocation');
    _socket?.off('deliveryLocation');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    await _rideController?.close();
    await _deliveryController?.close();
    _rideController = null;
    _deliveryController = null;
  }
}
