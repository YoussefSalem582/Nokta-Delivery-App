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
}
