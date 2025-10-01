import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final _secure = const FlutterSecureStorage();
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<void> save({required String access, String? refresh}) async {
    await _secure.write(key: _kAccess, value: access);
    if (refresh != null) {
      await _secure.write(key: _kRefresh, value: refresh);
    }
  }

  Future<String?> readAccess() => _secure.read(key: _kAccess);
  Future<String?> readRefresh() => _secure.read(key: _kRefresh);

  Future<void> clear() async {
    await _secure.delete(key: _kAccess);
    await _secure.delete(key: _kRefresh);
  }
}
