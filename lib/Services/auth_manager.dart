// lib/services/auth_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  // Menyimpan token dan detail pengguna setelah login/registrasi
  static Future<void> saveAuthData(String token, int userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userRoleKey, role);
  }

  // Mengambil token autentikasi
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Mengambil ID pengguna
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Mengambil peran pengguna
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Menghapus token dan detail pengguna saat logout
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }
}
