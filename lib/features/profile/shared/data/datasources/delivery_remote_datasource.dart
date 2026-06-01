import 'package:dio/dio.dart';
import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/core/network/api_headers.dart';
import 'package:delivery_app/features/profile/shared/data/mappers/delivery_order_mapper.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';

class DeliveryRemoteDataSource {
  DeliveryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<OrderEntity> createDelivery(
    Map<String, dynamic> body, {
    String? idempotencyKey,
  }) async {
    final payload = Map<String, dynamic>.from(body);
    if (EnvConfig.usesRealBackend && idempotencyKey != null) {
      payload['idempotencyKey'] = idempotencyKey;
    }

    final response = await _dio.post<dynamic>(
      ApiEndpoints.deliveries,
      data: payload,
      options: idempotencyKey != null
          ? idempotencyOptions(idempotencyKey)
          : null,
    );

    return DeliveryOrderMapper.fromDeliveryJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<OrderEntity>> fetchDeliveries() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.deliveries);
    final list = response.data as List<dynamic>;
    return list
        .map(
          (e) => DeliveryOrderMapper.fromDeliveryJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<OrderEntity> fetchDeliveryById(String id) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.deliveryById(id));
    return DeliveryOrderMapper.fromDeliveryJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<OrderEntity> updateStatus(String id, OrderStatus status) async {
    final response = await _dio.patch<dynamic>(
      ApiEndpoints.deliveryStatus(id),
      data: {'status': DeliveryOrderMapper.statusToApi(status)},
    );
    return DeliveryOrderMapper.fromDeliveryJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> updateLocation({
    required String id,
    required double lat,
    required double lng,
    double? heading,
  }) async {
    await _dio.patch<dynamic>(
      ApiEndpoints.deliveryLocation(id),
      data: {
        'lat': lat,
        'lng': lng,
        if (heading != null) 'heading': heading,
      },
    );
  }

  Future<Map<String, dynamic>> fetchTracking(String id) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.deliveryTracking(id),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
