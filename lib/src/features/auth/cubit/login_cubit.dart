import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';
import '../data/auth_repository_impl.dart';

part 'login_cubit.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.success({
    required String accessToken,
    required Map<String, dynamic> user,
  }) = _Success;
  const factory LoginState.failure(String message) = _Failure;
}

class LoginCubit extends Cubit<LoginState> {
  final IAuthRepository _repo;

  LoginCubit({IAuthRepository? repo})
    : _repo = repo ?? AuthRepositoryImpl(),
      super(const LoginState.initial());

  Future<void> login(String email, String password) async {
    emit(const LoginState.loading());

    try {
      final (access, refresh, user) = await _repo.login(
        email: email,
        password: password,
      );

      final role = (user['role'] ?? '').toString().toLowerCase();

      const allowedRoles = ['mobile', 'admin'];

      if (!allowedRoles.contains(role)) {
        emit(
          LoginState.failure(
            'Role "$role" tidak diizinkan. Hanya admin atau mobile yang diperbolehkan.',
          ),
        );
        return;
      }

      emit(LoginState.success(accessToken: access, user: user));
    } on DioException catch (e) {
      String message = 'Gagal login.';

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        } else if (e.response?.statusCode == 401) {
          message = 'Email atau password salah.';
        } else if (e.response?.statusCode == 403) {
          message = 'Akses ditolak. Anda tidak memiliki izin.';
        } else if (e.response?.statusCode == 500) {
          message = 'Terjadi kesalahan pada server.';
        } else {
          message = 'Login gagal (${e.response?.statusCode}).';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        message = 'Koneksi ke server gagal. Periksa koneksi internet Anda.';
      } else if (e.type == DioExceptionType.badResponse) {
        message = 'Respon server tidak valid.';
      } else {
        message = 'Tidak dapat terhubung ke server.';
      }

      emit(LoginState.failure(message));
    } catch (e) {
      emit(
        LoginState.failure(
          'Terjadi kesalahan yang tidak terduga: ${e.toString()}',
        ),
      );
    }
  }
}
