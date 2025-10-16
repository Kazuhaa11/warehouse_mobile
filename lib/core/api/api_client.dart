import 'dart:async';
import 'package:dio/dio.dart';
import 'package:warehouse_mobile/core/router/guard/auth_guard.dart';
import '../storage/token_storage.dart';
import 'endpoints.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://172.16.84.114:8080',
  );

  final Dio _dio = Dio();
  Dio get dio => _dio;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  Future<void> _attachAccessHeader(RequestOptions options) async {
    final t = await TokenStorage.instance.readAccess();
    if (t != null && t.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $t';
    }
  }

  Future<bool> _tryRefresh() async {
    final refresh = await TokenStorage.instance.readRefresh();
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final res = await _dio.post(
        Endpoints.refresh,
        data: {'refresh_token': refresh},
      );

      if (res.statusCode == 200) {
        final body = res.data as Map<String, dynamic>;
        final newAccess = (body['access_token'] ?? '') as String;
        final newRefresh = body['refresh_token'] as String?;
        if (newAccess.isEmpty) return false;

        await TokenStorage.instance.save(
          access: newAccess,
          refresh: newRefresh ?? refresh,
        );
        return true;
      }
    } catch (e) {
      // ignore
    }
    return false;
  }

  void _setup() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    );

    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _attachAccessHeader(options);
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          final req = e.requestOptions;
          final status = e.response?.statusCode ?? 0;
          final isAuthRefreshCall = req.path.endsWith(Endpoints.refresh);

          if (status == 401 && !isAuthRefreshCall) {

            if (_isRefreshing) {
              await _refreshCompleter?.future;
            } else {
              _isRefreshing = true;
              _refreshCompleter = Completer<void>();

              final refreshed = await _tryRefresh();

              _isRefreshing = false;
              _refreshCompleter?.complete();
              _refreshCompleter = null;

              if (!refreshed) {
                await _forceLogout();
                return handler.reject(e);
              }
            }

            try {
              await _attachAccessHeader(req);
              final clone = await _dio.fetch(req);
              return handler.resolve(clone);
            } catch (err) {
              await _forceLogout();
              return handler.reject(err as DioException);
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  Future<void> _forceLogout() async {
    await TokenStorage.instance.clear();
    AuthGuard.reset();

    final nav = TokenStorage.navigatorKey.currentState;
    if (nav != null) {
      nav.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  static Future<void> init() async {
    instance._setup();
  }
}
