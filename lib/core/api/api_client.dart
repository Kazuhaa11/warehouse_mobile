import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'endpoints.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  final _dio = Dio();
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
      final res = await _dio.post(Endpoints.refresh, data: {'refresh_token': refresh});
      if (res.statusCode == 200) {
        final body = res.data as Map<String, dynamic>;
        final newAccess = (body['access_token'] ?? '') as String;
        final newRefresh = body['refresh_token'] as String?;
        if (newAccess.isEmpty) return false;
        await TokenStorage.instance.save(access: newAccess, refresh: newRefresh ?? refresh);
        return true;
      }
    } catch (_) {

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
          handler.next(options);
        },
        onError: (e, handler) async {
          final req = e.requestOptions;
          final isAuthRefreshCall = req.path.endsWith(Endpoints.refresh);

          if (e.response?.statusCode == 401 && !isAuthRefreshCall) {
            if (_isRefreshing) {
              await _refreshCompleter?.future;
            } else {
              _isRefreshing = true;
              _refreshCompleter = Completer<void>();
              final ok = await _tryRefresh();
              _isRefreshing = false;
              _refreshCompleter?.complete();
              _refreshCompleter = null;

              if (!ok) {
                await TokenStorage.instance.clear();
                return handler.next(e);
              }
            }

            try {
              await _attachAccessHeader(req);
              final clone = await _dio.fetch(req);
              return handler.resolve(clone);
            } catch (err) {
              return handler.reject(err as DioException);
            }
          }

          handler.next(e);
        },
      ),
    );
  }

  static Future<void> init() async {
    instance._setup();
  }
}
