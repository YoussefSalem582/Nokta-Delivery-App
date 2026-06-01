import 'package:dio/dio.dart';
import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/features/profile/shared/data/mappers/delivery_order_mapper.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';

class OrderRemoteDataSource {
  OrderRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<OrderEntity>> fetchOrders() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.orders);
    final list = response.data as List<dynamic>;

    if (EnvConfig.usesRealBackend) {
      return list
          .map(
            (e) => DeliveryOrderMapper.fromDeliveryJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    return list
        .map((e) => OrderEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
