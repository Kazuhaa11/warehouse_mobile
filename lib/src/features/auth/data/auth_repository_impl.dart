import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<(String accessToken, String? refreshToken, Map<String, dynamic> user)> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(Endpoints.login, data: {'email': email, 'password': password});
    if (res.statusCode != 200) {
      throw Exception('Login gagal (${res.statusCode})');
    }

    final body = res.data as Map<String, dynamic>;
    final access = (body['access_token'] ?? '') as String;
    final refresh = body['refresh_token'] as String?;
    final user = (body['user'] ?? const {}) as Map<String, dynamic>;

    if (access.isEmpty) throw Exception('Token tidak ditemukan');

    await TokenStorage.instance.save(access: access, refresh: refresh);
    return (access, refresh, user);
  }

  @override
  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get(Endpoints.me);
    if (res.statusCode != 200) throw Exception('Gagal mengambil profil (${res.statusCode})');
    return (res.data ?? {}) as Map<String, dynamic>;
  }

  @override
  Future<void> logout({int? userId}) async {
    final refresh = await TokenStorage.instance.readRefresh();
    try {
      await _dio.post(Endpoints.logout, data: {
        if (userId != null) 'user_id': userId,
        if (refresh != null) 'refresh_token': refresh,
      });
    } catch (_) {
    } finally {
      await TokenStorage.instance.clear();
    }
  }
}
