import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app/core/constants/storage_keys.dart';

class AuthTokenStore {
  AuthTokenStore(this._prefs);

  final SharedPreferences _prefs;

  String? get accessToken => _prefs.getString(StorageKeys.accessToken);

  String? get refreshToken => _prefs.getString(StorageKeys.refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(StorageKeys.accessToken, accessToken);
    await _prefs.setString(StorageKeys.refreshToken, refreshToken);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(StorageKeys.accessToken);
    await _prefs.remove(StorageKeys.refreshToken);
  }

  bool get hasAccessToken =>
      accessToken != null && accessToken!.isNotEmpty;
}
