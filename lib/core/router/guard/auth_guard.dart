import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client.dart';
import '../../api/endpoints.dart';
import '../../storage/token_storage.dart';

class AuthGuard {
  static bool _checkedOnce = false;
  static bool _isValid = false;
  static bool _isChecking = false;

  static FutureOr<String?> redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final access = await TokenStorage.instance.readAccess();
    final isLoggingIn = state.matchedLocation == '/login';

    if (access == null || access.isEmpty) {
      return isLoggingIn ? null : '/login';
    }

    if (_isChecking) return null;

    if (!_checkedOnce) {
      _isChecking = true;
      try {
        final dio = ApiClient.instance.dio;
        final res = await dio.get(Endpoints.me);

        if (res.statusCode == 200) {
          _isValid = true;
        } else {
          _isValid = false;
        }
      } catch (e) {
        _isValid = false;
      } finally {
        _isChecking = false;
        _checkedOnce = true;
      }
    }

    if (!_isValid) {
      await TokenStorage.instance.clear();
      return '/login';
    }

    if (isLoggingIn) {
      return '/home';
    }
    return null;
  }

  static void reset() {
    _checkedOnce = false;
    _isValid = false;
    _isChecking = false;
  }
}
