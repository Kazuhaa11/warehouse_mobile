import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/peminjaman_repository.dart';

sealed class PeminjamanState {}

class PeminjamanInitial extends PeminjamanState {}

class PeminjamanLoading extends PeminjamanState {}

class PeminjamanLoaded extends PeminjamanState {
  final List<Map<String, dynamic>> list;
  PeminjamanLoaded(this.list);
}

class PeminjamanError extends PeminjamanState {
  final String message;
  PeminjamanError(this.message);
}

class PeminjamanCubit extends Cubit<PeminjamanState> {
  final IPeminjamanRepository repo;
  PeminjamanCubit(this.repo) : super(PeminjamanInitial());

  Future<void> loadList({String? q}) async {
    emit(PeminjamanLoading());
    try {
      final data = await repo.getList(q: q);
      emit(PeminjamanLoaded(data));
    } catch (e) {
      emit(PeminjamanError(e.toString()));
    }
  }

  void reset() {
    emit(PeminjamanInitial());
  }
}
