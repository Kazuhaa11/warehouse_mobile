import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import 'stock_opname_repository.dart';

class StockOpnameRepositoryImpl implements IStockOpnameRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<Map<String, dynamic>>> getSessions() async {
    final res = await _dio.get(Endpoints.stockOpnameSessions);
    final body = res.data as Map<String, dynamic>;
    final data = (body['data'] ?? []) as List;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<Map<String, dynamic>> createSession(
    Map<String, dynamic> payload,
  ) async {
    final res = await _dio.post(Endpoints.stockOpnameSessions, data: payload);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final sessions = await getSessions();
      return {'message': '✅ Sesi berhasil dibuat', 'sessions': sessions};
    }

    throw Exception('Gagal membuat sesi (${res.statusCode})');
  }

  @override
  Future<Map<String, dynamic>> getSessionDetail(int id) async {
    final res = await _dio.get(Endpoints.stockOpnameDetail(id));
    final data = (res.data as Map<String, dynamic>)['data'] ?? {};
    return data;
  }

  @override
  Future<Map<String, dynamic>> addItem(
    int sessionId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _dio.post(
      Endpoints.stockOpnameItems(sessionId),
      data: payload,
    );
    return (res.data as Map<String, dynamic>)['data'] ?? {};
  }

  @override
  Future<Map<String, dynamic>> finalizeSession(int sessionId) async {
    final res = await _dio.post(Endpoints.stockOpnameFinalize(sessionId));
    return (res.data as Map<String, dynamic>)['data'] ?? {};
  }

  @override
  Future<List<Map<String, dynamic>>> recapSession(int sessionId) async {
    final res = await _dio.get(Endpoints.stockOpnameRecap(sessionId));
    final body = res.data as Map<String, dynamic>;
    final data = (body['data'] ?? []) as List;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> deleteItem(int sessionId, int itemId) async {
    await _dio.delete('/api/v1/stock-opname/$sessionId/item/$itemId');
  }
}
