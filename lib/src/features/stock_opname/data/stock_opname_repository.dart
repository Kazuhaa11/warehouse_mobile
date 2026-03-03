abstract class IStockOpnameRepository {
  Future<List<Map<String, dynamic>>> getSessions();
  Future<Map<String, dynamic>> createSession(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> getSessionDetail(int id);
  Future<Map<String, dynamic>> addItem(int sessionId, Map<String, dynamic> payload);
  Future<Map<String, dynamic>> finalizeSession(int sessionId);
  Future<List<Map<String, dynamic>>> recapSession(int sessionId);
  Future<void> deleteItem(int sessionId, int itemId);
}
