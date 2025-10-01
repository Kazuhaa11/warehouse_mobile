abstract class IAuthRepository {
  Future<(String accessToken, String? refreshToken, Map<String, dynamic> user)> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> me();

  Future<void> logout({int? userId});
}
