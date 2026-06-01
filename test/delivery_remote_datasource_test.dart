import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/network/api_headers.dart';
import 'package:delivery_app/features/profile/shared/data/datasources/delivery_remote_datasource.dart';

void main() {
  group('DeliveryRemoteDataSource', () {
    test('creates delivery with idempotency header', () async {
      String? capturedHeader;

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedHeader =
                options.headers[ApiHeaders.idempotencyKey] as String?;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'id': 'delivery-1',
                  'pickupAddress': 'Maadi',
                  'dropoffAddress': 'Zamalek',
                  'fee': 35,
                  'status': 'requested',
                  'createdAt': '2026-06-01T10:00:00.000Z',
                },
              ),
            );
          },
        ),
      );

      final dataSource = DeliveryRemoteDataSource(dio);
      final order = await dataSource.createDelivery(
        {
          'pickupAddress': 'Maadi',
          'dropoffAddress': 'Zamalek',
          'pickupLat': 29.96,
          'pickupLng': 31.25,
          'dropoffLat': 30.06,
          'dropoffLng': 31.22,
          'fee': 35,
        },
        idempotencyKey: 'client-delivery-1',
      );

      expect(capturedHeader, 'client-delivery-1');
      expect(order.id, 'delivery-1');
      expect(order.title, 'Maadi → Zamalek');
    });
  });
}
