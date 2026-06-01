/// Build-time configuration via --dart-define.
abstract final class EnvConfig {
  /// When true (default), all API traffic is handled by [MockApiInterceptor].
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  /// Real Nokta backend base URL (includes `/api` prefix).
  /// Android emulator: `http://10.0.2.2:3000/api`
  /// iOS simulator / desktop: `http://localhost:3000/api`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  /// When true (default), driver endpoints use mock paths unless [useMockApi] is false.
  static const bool useMockDriverApi = bool.fromEnvironment(
    'USE_MOCK_DRIVER_API',
    defaultValue: true,
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
}
