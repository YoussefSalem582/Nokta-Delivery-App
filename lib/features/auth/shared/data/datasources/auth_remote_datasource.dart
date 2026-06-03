import 'package:dio/dio.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserEntity user;
  final String accessToken;
  final String refreshToken;
}

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );
    return _parseSession(response.data);
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.authRegister,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      },
    );
    return _parseSession(response.data);
  }

  Future<void> logout({String? refreshToken}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.authLogout,
      data: refreshToken != null ? {'refreshToken': refreshToken} : null,
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.authForgotPassword,
      data: {'email': email},
    );
  }

  Future<UserEntity> fetchProfile() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.profile);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid profile response',
      );
    }
    return UserEntity.fromJson(data);
  }

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await _dio.post<dynamic>(
      ApiEndpoints.authDeviceToken,
      data: {'token': token, 'platform': platform},
    );
  }

  AuthSession _parseSession(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.authLogin),
        message: 'Invalid auth response',
      );
    }

    final data = raw['data'] as Map<String, dynamic>? ?? raw;
    final userJson = data['user'] as Map<String, dynamic>?;
    final tokens = data['tokens'] as Map<String, dynamic>?;
    
    final accessToken = (tokens != null ? tokens['access_token'] : data['accessToken']) as String?;
    final refreshToken = (tokens != null ? tokens['refresh_token'] : data['refreshToken']) as String?;

    if (userJson == null || accessToken == null || refreshToken == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.authLogin),
        message: 'Missing auth tokens in response',
      );
    }

    return AuthSession(
      user: UserEntity.fromJson(userJson).copyWith(isLoggedIn: true),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
