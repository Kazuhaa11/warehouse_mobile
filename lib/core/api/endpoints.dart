class Endpoints {
  //auth
  static const login = '/api/v1/auth/login';
  static const refresh = '/api/v1/auth/refresh';
  static const logout = '/api/v1/auth/logout';
  static const me = '/api/v1/auth/me';

  //barang
  static const barang = '/api/v1/barang';

  //peminjaman
  static const peminjaman = '/api/v1/peminjaman';

  //storage
  static const storages = '/api/v1/storages';

  static const stockOpnameSessions = '/api/v1/stock-opname/sessions';
  static String stockOpnameDetail(int id) =>
      '/api/v1/stock-opname/sessions/$id';
  static String stockOpnameFinalize(int id) =>
      '/api/v1/stock-opname/sessions/$id/finalize';
  static String stockOpnameItems(int id) =>
      '/api/v1/stock-opname/sessions/$id/items';
  static String stockOpnameItemDetail(int sessionId, int itemId) =>
      '/api/v1/stock-opname/sessions/$sessionId/items/$itemId';
  static String stockOpnameImportItems(int sessionId) =>
      '/api/v1/stock-opname/sessions/$sessionId/items/import';
  static String stockOpnameRecap(int id) =>
      '/api/v1/stock-opname/sessions/$id/recap';
  static String stockOpnameDeleteItem(int sessionId, int itemId) =>
      '/api/v1/stock-opname/sessions/$sessionId/items/$itemId';
}
