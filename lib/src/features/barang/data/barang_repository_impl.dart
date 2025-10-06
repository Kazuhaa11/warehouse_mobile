import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import 'barang_repository.dart';

class BarangRepositoryImpl implements IBarangRepository {
  final Dio _dio = ApiClient.instance.dio;

  @override
  Future<List<Map<String, dynamic>>> getBarangList({
    String? q,
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await _dio.get(
      Endpoints.barang,
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        'page': page,
        'per_page': perPage,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal Memuat Data Barang');
    }

    final list = res.data['data'] as List<dynamic>;
    return list.map<Map<String, dynamic>>((e) {
      final map = Map<String, dynamic>.from(e as Map);

      map['id'] = int.tryParse(map['id'].toString()) ?? 0;
      map['storage_id'] = map['storage_id'] != null
          ? int.tryParse(map['storage_id'].toString())
          : null;

      map['material'] = map['material']?.toString();
      map['material_description'] = map['material_description']?.toString();
      map['uom'] = map['uom']?.toString();
      map['plant'] = map['plant']?.toString();
      map['material_type'] = map['material_type']?.toString();
      map['material_group'] = map['material_group']?.toString();
      map['storage_location'] = map['storage_location']?.toString();

      return map;
    }).toList();
  }

  @override
  @override
  Future<Map<String, dynamic>> getBarangDetail(int id) async {
    final res = await _dio.get("${Endpoints.barang}/$id");
    if (res.statusCode != 200) {
      throw Exception("Barang Tidak Ditemukan");
    }

    final data = Map<String, dynamic>.from(res.data['data'] as Map);

    data['id'] = int.tryParse(data['id'].toString()) ?? 0;
    data['storage_id'] = data['storage_id'] != null
        ? int.tryParse(data['storage_id'].toString())
        : null;

    data['material'] = data['material']?.toString();
    data['material_description'] = data['material_description']?.toString();
    data['uom'] = data['uom']?.toString();
    data['plant'] = data['plant']?.toString();
    data['material_type'] = data['material_type']?.toString();
    data['material_group'] = data['material_group']?.toString();
    data['storage_location'] = data['storage_location']?.toString();

    final storageId = data['storage_id'];
    if (storageId != null) {
      try {
        final storage = await getStorageDetail(storageId);

        data['storage_name'] = storage['name'];
        data['zone'] = storage['zone'];
        data['rack'] = storage['rack'];
        data['bin'] = storage['bin'];
        data['path'] = storage['path'];
      } catch (e) {
        //
      }
    } else {
      //
    }
    return data;
  }

  @override
  Future<Map<String, dynamic>> getStorageDetail(int storageId) async {
    final res = await _dio.get("${Endpoints.storages}/$storageId");
    if (res.statusCode != 200) {
      throw Exception("Storage Tidak Ditemukan");
    }

    final data = Map<String, dynamic>.from(res.data['data'] as Map);

    data['id'] = int.tryParse(data['id'].toString()) ?? 0;
    data['zone'] = data['zone']?.toString();
    data['rack'] = data['rack']?.toString();
    data['bin'] = data['bin']?.toString();
    data['name'] = data['name']?.toString();
    data['path'] = data['path']?.toString();

    return data;
  }

  @override
  Future<Map<String, dynamic>> getBarangByMaterial(String material) async {
    final res = await _dio.get("${Endpoints.barang}?q=$material");
    if (res.statusCode != 200) {
      throw Exception("Barang Tidak Ditemukan");
    }
    final list = res.data['data'] as List<dynamic>;
    if (list.isEmpty) {
      throw Exception("Barang Tidak Ditemukan");
    }
    return Map<String, dynamic>.from(list.first as Map)
      ..update('id', (v) => int.tryParse(v.toString()) ?? 0)
      ..update(
        'storage_id',
        (v) => v != null ? int.tryParse(v.toString()) : null,
      );
  }
}
