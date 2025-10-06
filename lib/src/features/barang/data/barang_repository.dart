abstract class IBarangRepository {
  Future<List<Map<String, dynamic>>> getBarangList({
    String? q,
    int page = 1,
    int perPage = 20,
  });
  Future<Map<String, dynamic>> getStorageDetail(int storageId);
  Future<Map<String, dynamic>> getBarangDetail(int id);
  Future<Map<String, dynamic>> getBarangByMaterial(String material);
}
