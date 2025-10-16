import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';

abstract class StockOpnameDetailState {}

class StockOpnameDetailInitial extends StockOpnameDetailState {}

class StockOpnameDetailLoading extends StockOpnameDetailState {}

class StockOpnameDetailLoaded extends StockOpnameDetailState {
  final Map<String, dynamic> data;
  StockOpnameDetailLoaded(this.data);
}

class StockOpnameDetailFinalized extends StockOpnameDetailState {
  final String message;
  StockOpnameDetailFinalized(this.message);
}

class StockOpnameDetailError extends StockOpnameDetailState {
  final String message;
  StockOpnameDetailError(this.message);
}

class StockOpnameDetailCubit extends Cubit<StockOpnameDetailState> {
  final Dio _dio = ApiClient.instance.dio;

  StockOpnameDetailCubit() : super(StockOpnameDetailInitial());

  Future<void> fetchDetail(int sessionId) async {
    emit(StockOpnameDetailLoading());
    try {
      final res = await _dio.get(Endpoints.stockOpnameDetail(sessionId));
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final data = res.data['data'] ?? {};
        emit(StockOpnameDetailLoaded(data));
      } else {
        emit(StockOpnameDetailError('Gagal memuat data'));
      }
    } catch (e) {
      emit(StockOpnameDetailError(e.toString()));
    }
  }

  Future<void> finalizeSession(int sessionId) async {
    try {
      final res = await _dio.post(Endpoints.stockOpnameFinalize(sessionId));
      if (res.statusCode == 200) {
        emit(StockOpnameDetailFinalized(' Sesi berhasil difinalisasi'));
        await fetchDetail(sessionId);
      } else {
        emit(StockOpnameDetailError('Gagal finalisasi'));
      }
    } catch (e) {
      emit(StockOpnameDetailError(e.toString()));
    }
  }
}
