import 'package:dio/dio.dart';
import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_local_datasource.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_remote_datasource.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_token_store.dart';
import 'package:delivery_app/core/cache/datasources/cache_metadata_local_datasource.dart';
import 'package:delivery_app/core/constants/app_constants.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/core/network/mock_session_context.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/utils/cache_freshness.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDataSource local,
    required Dio dio,
    required CacheMetadataLocalDataSource cacheMetadata,
    required NetworkStatus networkStatus,
    required AuthRemoteDataSource remote,
    required AuthTokenStore tokenStore,
    Future<void> Function()? onDeviceTokenSync,
  })  : _local = local,
        _dio = dio,
        _cacheMetadata = cacheMetadata,
        _networkStatus = networkStatus,
        _remote = remote,
        _tokenStore = tokenStore,
        _onDeviceTokenSync = onDeviceTokenSync;

  final AuthLocalDataSource _local;
  final Dio _dio;
  final CacheMetadataLocalDataSource _cacheMetadata;
  final NetworkStatus _networkStatus;
  final AuthRemoteDataSource _remote;
  final AuthTokenStore _tokenStore;
  final Future<void> Function()? _onDeviceTokenSync;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    if (EnvConfig.usesRealBackend && await _networkStatus.isOnline) {
      try {
        final session = await _remote.login(email: email, password: password);
        await _tokenStore.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
        await _local.saveUser(session.user);
        MockSessionContext.setUserId(session.user.id);
        await _cacheMetadata.markFetched(CacheKeys.profile);
        await _onDeviceTokenSync?.call();
        return session.user;
      } on DioException {
        rethrow;
      }
    }

    return _mockLogin(email: email);
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (EnvConfig.usesRealBackend && await _networkStatus.isOnline) {
      final session = await _remote.register(
        name: name,
        email: email,
        password: password,
        phone: '+201000000000',
      );
      await _tokenStore.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      await _local.saveUser(session.user);
      MockSessionContext.setUserId(session.user.id);
      await _cacheMetadata.markFetched(CacheKeys.profile);
      await _onDeviceTokenSync?.call();
      return session.user;
    }

    final user = await _mockLogin(email: email);
    final registered = user.copyWith(name: name, email: email);
    await _local.saveUser(registered);
    return registered;
  }

  @override
  Future<void> logout() async {
    if (EnvConfig.usesRealBackend && await _networkStatus.isOnline) {
      try {
        await _remote.logout(refreshToken: _tokenStore.refreshToken);
      } on DioException {
        // Clear local session even if remote logout fails.
      }
    }
    await _tokenStore.clearTokens();
    MockSessionContext.clear();
    await _local.clearUser();
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    if (EnvConfig.usesRealBackend && await _networkStatus.isOnline) {
      await _remote.requestPasswordReset(email: email);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  @override
  Future<UserEntity?> getCurrentUser() async => _local.getCurrentUser();

  @override
  UserEntity? get cachedUser => _local.getCurrentUser();

  @override
  bool isLoggedIn() {
    final user = _local.getCurrentUser();
    if (EnvConfig.usesRealBackend) {
      return (user?.isLoggedIn ?? false) && _tokenStore.hasAccessToken;
    }
    return user?.isLoggedIn ?? false;
  }

  @override
  Future<UserEntity> getProfile({bool forceRefresh = false}) async {
    final cached = _local.getCurrentUser();
    final lastFetched = _cacheMetadata.getLastFetched(CacheKeys.profile);

    if (cached != null &&
        !forceRefresh &&
        (!await _networkStatus.isOnline ||
            CacheFreshness.isFresh(lastFetched, cacheKey: CacheKeys.profile))) {
      return cached;
    }

    if (await _networkStatus.isOnline) {
      try {
        final UserEntity user;
        if (EnvConfig.usesRealBackend && _tokenStore.hasAccessToken) {
          user = (await _remote.fetchProfile())
              .copyWith(isLoggedIn: cached?.isLoggedIn ?? true);
        } else {
          final response = await _dio.get<dynamic>(ApiEndpoints.profile);
          user = UserEntity.fromJson(response.data as Map<String, dynamic>)
              .copyWith(isLoggedIn: cached?.isLoggedIn ?? true);
        }
        await _local.saveUser(user);
        await _cacheMetadata.markFetched(CacheKeys.profile);
        MockSessionContext.setUserId(user.id);
        return user;
      } on DioException {
        if (cached != null) return cached;
      }
    }

    return cached ??
        UserEntity(
          id: 'guest',
          name: 'Guest',
          email: AppConstants.guestEmail,
          phone: '',
          walletBalance: 0,
          isLoggedIn: false,
        );
  }

  @override
  Future<UserEntity> updateWalletBalance(double amount) async {
    final user = await getProfile();
    final updated = user.copyWith(walletBalance: user.walletBalance + amount);
    await _local.saveUser(updated);
    return updated;
  }

  @override
  Future<UserEntity> updateProfile({required String name}) async {
    final user = await getProfile();
    final updated = user.copyWith(name: name);
    await _local.saveUser(updated);
    return updated;
  }

  Future<UserEntity> _mockLogin({required String email}) async {
    UserEntity user;
    if (await _networkStatus.isOnline) {
      try {
        final response = await _dio.get<dynamic>(ApiEndpoints.profile);
        user = UserEntity.fromJson(response.data as Map<String, dynamic>)
            .copyWith(email: email, isLoggedIn: true);
        await _cacheMetadata.markFetched(CacheKeys.profile);
      } on DioException {
        user = UserEntity(
          id: 'local-user',
          name: 'Demo User',
          email: email,
          phone: '+201000000000',
          walletBalance: 250,
          isLoggedIn: true,
        );
      }
    } else {
      user = UserEntity(
        id: 'local-user',
        name: 'Demo User',
        email: email,
        phone: '+201000000000',
        walletBalance: 250,
        isLoggedIn: true,
      );
    }

    await _local.saveUser(user);
    MockSessionContext.setUserId(user.id);
    return user;
  }
}
