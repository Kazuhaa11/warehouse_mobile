import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
      emit(LoginState.success(accessToken: access, user: user));
    } catch (e) {
      emit(LoginState.failure(e.toString()));
    }
  }
}
