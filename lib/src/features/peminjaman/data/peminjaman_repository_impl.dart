import 'package:dio/dio.dart';
import 'package:warehouse_mobile/core/api/api_client.dart';
import 'package:warehouse_mobile/core/api/endpoints.dart';
import 'peminjaman_repository.dart';
import 'dart:convert';

class PeminjamanRepositoryImpl implements IPeminjamanRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  @override
  Future<List<Map<String, dynamic>>> getList({
    String? q,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.peminjaman,
        queryParameters: {
          if (q != null && q.isNotEmpty) 'q': q,
          'page': page,
          'per_page': perPage,
        },
      );

      if (res.statusCode == 200) {
        final raw = res.data;
        final Map<String, dynamic> body = raw is String
            ? jsonDecode(raw) as Map<String, dynamic>
            : raw as Map<String, dynamic>;

        final list = body['data'] as List<dynamic>;
        return list.map<Map<String, dynamic>>((e) {
          final map = Map<String, dynamic>.from(e as Map);

          map['id'] = int.tryParse(map['id'].toString()) ?? 0;
          map['peminjam_id'] =
              (map['peminjam_id'] != null &&
                  map['peminjam_id'].toString().isNotEmpty)
              ? int.tryParse(map['peminjam_id'].toString())
              : null;

          map['nomor'] = map['nomor']?.toString();
          map['tanggal'] = map['tanggal']?.toString();
          map['status'] = map['status']?.toString();
          map['note'] = map['note']?.toString();
          map['peminjam_username'] = map['peminjam_username']?.toString();
          map['plants'] = map['plants']?.toString();

          return map;
        }).toList();
      }
      throw Exception('Gagal load list peminjaman (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception('Error request list: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getDetail(int id) async {
    try {
      final res = await _dio.get('${Endpoints.peminjaman}/$id');

      if (res.statusCode == 200) {
        final raw = res.data;
        final Map<String, dynamic> body = raw is String
            ? jsonDecode(raw) as Map<String, dynamic>
            : raw as Map<String, dynamic>;

        final data = Map<String, dynamic>.from(body['data'] as Map);

        if (data['header'] != null) {
          final header = Map<String, dynamic>.from(data['header'] as Map);
          header['id'] = int.tryParse(header['id'].toString()) ?? 0;
          header['peminjam_id'] = int.tryParse(
            header['peminjam_id'].toString(),
          );
          header['nomor'] = header['nomor']?.toString();
          header['tanggal'] = header['tanggal']?.toString();
          header['jatuh_tempo'] = header['jatuh_tempo']?.toString();
          header['status'] = header['status']?.toString();
          header['note'] = header['note']?.toString();
          header['peminjam_username'] = header['peminjam_username']?.toString();
          header['plants'] = header['plants']?.toString();
          data['header'] = header;
        }

        if (data['items'] != null) {
          final items = (data['items'] as List).map((it) {
            final m = Map<String, dynamic>.from(it as Map);
            m['id'] = int.tryParse(m['id'].toString()) ?? 0;
            m['barang_id'] = int.tryParse(m['barang_id'].toString());
            m['material'] = m['material']?.toString();
            m['qty'] = double.tryParse(m['qty'].toString()) ?? 0;
            m['uom'] = m['uom']?.toString();
            m['storage_location'] = m['storage_location']?.toString();
            return m;
          }).toList();
          data['items'] = items;
        }

        return data;
      }
      throw Exception('Gagal load detail peminjaman (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception('Error request detail: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> createPeminjaman(
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.post(Endpoints.peminjaman, data: payload);

      if (res.statusCode == 200) {
        final raw = res.data;
        final Map<String, dynamic> body = raw is String
            ? jsonDecode(raw)
            : Map<String, dynamic>.from(raw);
        return body['data'] ?? {};
      }
      throw Exception('Gagal create peminjaman (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception('Error create peminjaman: ${e.message}');
    }
  }
}
