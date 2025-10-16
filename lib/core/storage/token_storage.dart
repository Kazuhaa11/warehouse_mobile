import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  Future<void> save({required String access, String? refresh, String? role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    if (refresh != null && refresh.isNotEmpty) {
      await prefs.setString('refresh_token', refresh);
    }
    if (role != null && role.isNotEmpty) {
      await prefs.setString('role', role);
    }
  }

  Future<String?> readAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> readRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<String?> readRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
