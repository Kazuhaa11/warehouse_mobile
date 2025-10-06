import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';

class ProfileCubit extends Cubit<Map<String, dynamic>?> {
  final IAuthRepository _repo;

  ProfileCubit(this._repo) : super(null);

  Future<void> loadProfile() async {
    try {
      final user = await _repo.me();
      emit(user);
    } catch (e) {
      emit(null);
    }
  }

  Future<void> logout(int? userId) async {
    try {
      await _repo.logout(userId: userId);
    } catch (_) {}
    emit(null);
  }
}
