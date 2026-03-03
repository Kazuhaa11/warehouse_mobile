import 'dart:async';
import '../../api/api_client.dart';
import '../../api/endpoints.dart';
import '../../storage/token_storage.dart';

class AuthGuard {
  static bool _checkedOnce = false;
  static bool _isValid = false;
  static bool _isChecking = false;

  static void reset() {
    _checkedOnce = false;
    _isValid = false;
    _isChecking = false;
  }

  static FutureOr<String?> redirectState(state) async {
    final access = await TokenStorage.instance.readAccess();
    final role = await TokenStorage.instance.readRole();

    final isLogin = state.matchedLocation == '/login';
    final isAdminRoute = state.matchedLocation.startsWith('/admin');

    if (access == null || access.isEmpty) {
      return isLogin ? null : '/login';
    }

    if (_isChecking) return null;

    if (!_checkedOnce) {
      _isChecking = true;
      try {
        final res = await ApiClient.instance.dio.get(Endpoints.me);
        _isValid = res.statusCode == 200;
      } catch (_) {
        _isValid = false;
      } finally {
        _checkedOnce = true;
        _isChecking = false;
      }
    }

    if (!_isValid) {
      reset();
      await TokenStorage.instance.clear();
      return '/login';
    }

    if (isLogin) {
      if (role == 'admin' || role == 'super_admin') return '/admin';
      return '/home';
    }

    if (isAdminRoute && role != 'admin' && role != 'super_admin') {
      return '/home';
    }

    return null;
  }
}
