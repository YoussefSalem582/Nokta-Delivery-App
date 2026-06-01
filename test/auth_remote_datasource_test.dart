import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_remote_datasource.dart';

void main() {
  group('AuthRemoteDataSource', () {
    test('parses login response envelope', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'success': true,
                  'messageKey': 'auth.login.success',
                  'data': {
                    'accessToken': 'access-123',
                    'refreshToken': 'refresh-456',
                    'user': {
                      'id': 'user-1',
                      'name': 'Ahmed',
                      'email': 'ahmed@nokta.app',
                      'phone': '+201012345678',
                      'walletBalance': 100,
                      'isDriverRegistered': false,
                    },
                  },
                },
              ),
            );
          },
        ),
      );

      final dataSource = AuthRemoteDataSource(dio);
      final session = await dataSource.login(
        email: 'ahmed@nokta.app',
        password: 'password',
      );

      expect(session.accessToken, 'access-123');
      expect(session.refreshToken, 'refresh-456');
      expect(session.user.id, 'user-1');
      expect(session.user.isLoggedIn, isTrue);
    });
    test('registers device token with backend', () async {
      Map<String, dynamic>? capturedBody;

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedBody = options.data as Map<String, dynamic>?;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'success': true,
                  'messageKey': 'common.success',
                  'data': {'registered': true},
                },
              ),
            );
          },
        ),
      );

      final dataSource = AuthRemoteDataSource(dio);
      await dataSource.registerDeviceToken(
        token: 'fcm-token-abc',
        platform: 'android',
      );

      expect(capturedBody?['token'], 'fcm-token-abc');
      expect(capturedBody?['platform'], 'android');
    });
  });
}
