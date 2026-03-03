import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_mobile/core/router/guard/auth_guard.dart';
import '../storage/token_storage.dart';
import 'endpoints.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final Dio _dio = Dio();
  Dio get dio => _dio;

  String? _serverIp;
  String? get currentServerIp => _serverIp;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('server_ip') ?? "";

    await instance._setBaseUrl(ip);
  }

  Future<void> setServerIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ip.trim());

    await _setBaseUrl(ip.trim());
  }

  String _buildBaseUrl(String ip) {
    return "http://$ip/warehouse-new/public/";
  }

  bool _isValidHost(String ip) {
    return ip == "localhost" || ip.contains(".");
  }

  Future<void> _setBaseUrl(String ip) async {
    _serverIp = ip;

    if (!_isValidHost(ip)) {
      _applyOptions(null);
      return;
    }

    final url = _buildBaseUrl(ip);
    _applyOptions(url);
  }

  void _applyOptions(String? baseUrl) {
    final safeUrl = baseUrl ?? "http://localhost:8080/";

    _dio.options = BaseOptions(
      baseUrl: safeUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
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
        final data = res.data as Map<String, dynamic>;
        final newAccess = (data['access_token'] ?? '') as String;
        final newRefresh = data['refresh_token'] as String?;

        if (newAccess.isEmpty) return false;

        await TokenStorage.instance.save(
          access: newAccess,
          refresh: newRefresh ?? refresh,
        );

        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<void> _forceLogout() async {
    await TokenStorage.instance.clear();
    AuthGuard.reset();
  }
}
