abstract class IPeminjamanRepository {
  Future<List<Map<String, dynamic>>> getList({
    String? q,
    int page,
    int perPage,
  });

  Future<Map<String, dynamic>> getDetail(int id);
  Future<Map<String, dynamic>> createPeminjaman(Map<String, dynamic> payload);
}
