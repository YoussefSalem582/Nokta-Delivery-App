import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/features/driver/shared/data/datasources/driver_profile_remote_datasource.dart';

void main() {
  group('DriverProfileRemoteDataSource', () {
    test('parses driver profile response', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'driver-1',
                  'name': 'Karim',
                  'email': 'karim@nokta.app',
                  'phone': '+201012345678',
                  'walletBalance': 0,
                  'isDriverRegistered': true,
                  'driverProfile': {
                    'phone': '+201012345678',
                    'vehicleType': 'sedan',
                    'vehicleMakeModel': 'Toyota Corolla',
                    'licensePlate': 'ABC 123',
                    'registeredAt': '2026-06-01T10:00:00.000Z',
                    'termsAccepted': true,
                  },
                },
              ),
            );
          },
        ),
      );

      final dataSource = DriverProfileRemoteDataSource(dio);
      final user = await dataSource.fetchProfile();

      expect(user.id, 'driver-1');
      expect(user.isDriverRegistered, isTrue);
      expect(user.driverProfile?.vehicleMakeModel, 'Toyota Corolla');
    });
  });
}
