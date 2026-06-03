import 'package:flutter/foundation.dart';

/// Build-time configuration via --dart-define.
abstract final class EnvConfig {
  /// When true (default), all API traffic is handled by [MockApiInterceptor].
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  static const String _apiBaseUrlEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Real Nokta backend base URL (includes `/api` prefix).
  /// Android emulator: `http://10.0.2.2:8000/api`
  /// Web / iOS simulator / desktop: `http://127.0.0.1:8000/api`
  static String get apiBaseUrl {
    if (_apiBaseUrlEnv.isNotEmpty) {
      return _apiBaseUrlEnv;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  /// When true, driver endpoints use mock paths. Default is false (use real backend).
  static const bool useMockDriverApi = bool.fromEnvironment(
    'USE_MOCK_DRIVER_API',
    defaultValue: false,
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static const String nominatimBaseUrl = String.fromEnvironment(
    'NOMINATIM_BASE_URL',
    defaultValue: 'https://nominatim.openstreetmap.org',
  );

  static bool get usesRealBackend => !useMockApi;

  static bool get usesRealDriverApi => !useMockApi && !useMockDriverApi;

  /// Socket.io server origin (NestJS gateway namespace `/realtime`).
  static String get realtimeBaseUrl {
    if (apiBaseUrl.endsWith('/api')) {
      return apiBaseUrl.substring(0, apiBaseUrl.length - 4);
    }
    return apiBaseUrl;
  }
}
