import 'package:dio/dio.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_token_store.dart';

/// Attaches JWT access token to outgoing requests.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStore);

  final AuthTokenStore _tokenStore;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenStore.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
