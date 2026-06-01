import 'package:dio/dio.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

class SyncRemoteDataSource {
  SyncRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> reconcile() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.syncReconcile);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> syncActions(
    List<Map<String, dynamic>> actions,
  ) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.syncActions,
      data: {'actions': actions},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> syncActionsBatch(
    List<Map<String, dynamic>> actions,
  ) async {
    if (actions.isEmpty) return [];

    final response = await syncActions(actions);
    final data = response['data'] as Map<String, dynamic>? ?? response;
    final results = data['results'] as List<dynamic>? ?? const [];

    return results.map((entry) => entry as Map<String, dynamic>).toList();
  }

  /// Applies server active ride onto local cache when present.
  Future<TripEntity?> parseActiveRide(Map<String, dynamic> reconcile) async {
    final active = reconcile['activeRide'];
    if (active == null) return null;
    if (active is! Map<String, dynamic>) return null;
    return TripEntity.fromJson(active);
  }
}
