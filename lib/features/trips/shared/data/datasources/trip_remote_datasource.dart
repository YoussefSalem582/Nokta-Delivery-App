import 'package:dio/dio.dart';
import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/core/network/api_headers.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

class TripRemoteDataSource {
  TripRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TripEntity>> fetchTrips() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.trips);
    final responseData = response.data;
    final list = responseData is Map<String, dynamic>
        ? (responseData['data'] as List<dynamic>?) ?? []
        : responseData as List<dynamic>;
    return list
        .map((e) => TripEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TripEntity?> fetchActiveTrip() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.tripsActive);
    final data = response.data;
    if (data == null) return null;
    if (data is Map<String, dynamic> && data.isEmpty) return null;
    return TripEntity.fromJson(data as Map<String, dynamic>);
  }

  Future<TripEntity> fetchTripById(String id) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.tripById(id));
    return TripEntity.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TripEntity> requestTrip(
    Map<String, dynamic> body, {
    String? idempotencyKey,
  }) async {
    final payload = Map<String, dynamic>.from(body);
    if (EnvConfig.usesRealBackend && idempotencyKey != null) {
      payload['idempotencyKey'] = idempotencyKey;
    }

    final response = await _dio.post<dynamic>(
      ApiEndpoints.requestTrip,
      data: payload,
      options: idempotencyKey != null
          ? idempotencyOptions(idempotencyKey)
          : null,
    );
    return TripEntity.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TripEntity> updateStatus(String id, TripStatus status) async {
    final response = await _dio.patch<dynamic>(
      ApiEndpoints.tripStatus(id),
      data: {'status': status.name},
    );
    final data = response.data as Map<String, dynamic>;

    if (data.containsKey('pickupAddress')) {
      return TripEntity.fromJson(data);
    }

    return TripEntity(
      id: data['id'] as String? ?? id,
      pickupAddress: '',
      dropoffAddress: '',
      pickupLat: 0,
      pickupLng: 0,
      dropoffLat: 0,
      dropoffLng: 0,
      status: TripStatus.values.firstWhere((e) => e.name == data['status']),
      fare: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  Future<Map<String, dynamic>> estimateFare(Map<String, dynamic> body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.estimateFare,
      data: body,
    );
    final raw = response.data as Map<String, dynamic>;
    return raw['data'] as Map<String, dynamic>? ?? raw;
  }
}
