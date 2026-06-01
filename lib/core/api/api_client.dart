import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../config/environment/env_config.dart';
import '../network/api_endpoints.dart';
import '../network/auth_interceptor.dart';
import '../network/mock_api_interceptor.dart';
import '../../features/auth/shared/data/datasources/auth_token_store.dart';

/// Dio wrapper with locale header and logging interceptors.
class ApiClient {
  ApiClient({
    required Talker talker,
    AuthTokenStore? tokenStore,
  }) : _talker = talker {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final interceptors = <Interceptor>[];

    if (EnvConfig.useMockApi) {
      interceptors.add(MockApiInterceptor());
    } else if (tokenStore != null) {
      interceptors.add(AuthInterceptor(tokenStore));
    }

    interceptors.add(
      TalkerDioLogger(
        talker: _talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: false,
          printResponseHeaders: false,
        ),
      ),
    );

    _dio.interceptors.addAll(interceptors);
  }

  final Talker _talker;
  late final Dio _dio;
  String _locale = 'en';

  Dio get dio => _dio;

  void setLocale(String languageCode) {
    _locale = languageCode;
    _dio.options.headers['Accept-Language'] = languageCode;
  }

  String get locale => _locale;

  bool get enableLogging => EnvConfig.enableLogging;
}

/// Legacy factory — prefer [ApiClient] via GetIt.
Dio createDioClient(Talker talker) => ApiClient(talker: talker).dio;
