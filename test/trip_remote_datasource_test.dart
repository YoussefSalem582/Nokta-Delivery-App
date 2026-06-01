import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/network/api_headers.dart';
import 'package:delivery_app/features/trips/shared/data/datasources/trip_remote_datasource.dart';

void main() {
  group('TripRemoteDataSource', () {
    test('sends idempotency header and body key on requestTrip', () async {
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
                  'id': 'trip-server-1',
                  'pickupAddress': 'Maadi',
                  'dropoffAddress': 'Zamalek',
                  'pickupLat': 29.96,
                  'pickupLng': 31.25,
                  'dropoffLat': 30.06,
                  'dropoffLng': 31.22,
                  'status': 'requested',
                  'riderId': 'user-1',
                  'fare': 50,
                  'createdAt': '2026-06-01T10:00:00.000Z',
                  'updatedAt': '2026-06-01T10:00:00.000Z',
                },
              ),
            );
          },
        ),
      );

      final dataSource = TripRemoteDataSource(dio);
      await dataSource.requestTrip(
        {
          'pickupAddress': 'Maadi',
          'dropoffAddress': 'Zamalek',
          'pickupLat': 29.96,
          'pickupLng': 31.25,
          'dropoffLat': 30.06,
          'dropoffLng': 31.22,
          'fare': 50,
          'riderId': 'user-1',
        },
        idempotencyKey: 'client-key-123',
      );

      expect(capturedHeader, 'client-key-123');
    });
  });
}
