import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';

abstract class StockOpnameState {}

class StockOpnameInitial extends StockOpnameState {}

class StockOpnameLoading extends StockOpnameState {}

class StockOpnameLoaded extends StockOpnameState {
  final List<dynamic> sessions;
  StockOpnameLoaded(this.sessions);
}

class StockOpnameError extends StockOpnameState {
  final String message;
  StockOpnameError(this.message);
}

class StockOpnameCreated extends StockOpnameState {
  final String message;
  StockOpnameCreated(this.message);
}

class StockOpnameCubit extends Cubit<StockOpnameState> {
  final Dio _dio = ApiClient.instance.dio;
  StockOpnameCubit() : super(StockOpnameInitial());

  Future<void> fetchSessions() async {
    emit(StockOpnameLoading());
    try {
      final res = await _dio.get(Endpoints.stockOpnameSessions);
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final data = res.data['data'] ?? [];
        emit(StockOpnameLoaded(data));
      } else {
        emit(StockOpnameError('Gagal memuat sesi.'));
      }
    } catch (e) {
      emit(StockOpnameError(e.toString()));
    }
  }

  Future<void> createSession(String note, String? scheduledAt) async {
    emit(StockOpnameLoading());
    try {
      final res = await _dio.post(
        Endpoints.stockOpnameSessions,
        data: {'note': note, 'scheduled_at': scheduledAt},
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        Future.microtask(() {
          emit(StockOpnameCreated('✅ Sesi berhasil dibuat'));
        });
        await Future.delayed(const Duration(milliseconds: 300));
        final listRes = await _dio.get(Endpoints.stockOpnameSessions);

        if (listRes.statusCode == 200 && listRes.data is Map<String, dynamic>) {
          final data = listRes.data['data'] ?? [];
          emit(StockOpnameLoaded(data));
        } else {
          emit(
            StockOpnameError(
              'Sesi berhasil dibuat, tapi gagal memuat ulang daftar.',
            ),
          );
        }
      } else {
        emit(StockOpnameError('Gagal membuat sesi (code ${res.statusCode})'));
      }
    } catch (e) {
      emit(StockOpnameError('Terjadi kesalahan: $e'));
    }
  }
}
