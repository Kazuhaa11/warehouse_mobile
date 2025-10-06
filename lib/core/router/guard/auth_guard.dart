import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client.dart';
import '../../api/endpoints.dart';
import '../../storage/token_storage.dart';

class AuthGuard {
  static bool _checkedOnce = false;
  static bool _isValid = false;

  static FutureOr<String?> redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final access = await TokenStorage.instance.readAccess();
    final isLoggingIn = state.matchedLocation == '/login';

    if (access == null || access.isEmpty) {
      return isLoggingIn ? null : '/login';
    }

    if (!_checkedOnce) {
      try {
        final dio = ApiClient.instance.dio;
        await dio.get(Endpoints.me);
        _isValid = true;
      } catch (_) {
        _isValid = false;
      }
      _checkedOnce = true;
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
  }
}
