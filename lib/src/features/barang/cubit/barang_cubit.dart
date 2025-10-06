import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/barang_repository.dart';

sealed class BarangState {}

class BarangInitial extends BarangState {}

class BarangLoading extends BarangState {}

class BarangLoaded extends BarangState {
  final List<Map<String, dynamic>> list;
  BarangLoaded(this.list);
}

class BarangError extends BarangState {
  final String message;
  BarangError(this.message);
}

class BarangCubit extends Cubit<BarangState> {
  final IBarangRepository repo;

  BarangCubit(this.repo) : super(BarangInitial());

  Future<void> loadBarang({String? q}) async {
    emit(BarangLoading());
    try {
      final rows = await repo.getBarangList(q: q);
      emit(BarangLoaded(rows));
    } catch (e) {
      emit(BarangError(e.toString()));
    }
  }

  void reset() {
    emit(BarangInitial());
  }
}
