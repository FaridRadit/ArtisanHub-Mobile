

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/userModel.dart'; 
import 'auth_manager.dart';

class UserService {
  final String _authBaseUrl = ApiConfig.baseAuthUrl;

  Future<Map<String, dynamic>> registerUser(String username, String email, String password, {String? fullName, String? phoneNumber, String? profilePictureUrl, String? role}) async {
    final url = Uri.parse('$_authBaseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'profile_picture_url': profilePictureUrl,
        'role': role,
      }),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 201) {
      // Simpan token dan detail pengguna setelah registrasi berhasil
      await AuthManager.saveAuthData(
        responseBody['token'],
        responseBody['userId'],
        responseBody['role'],
      );
      return {'success': true, 'message': responseBody['message'], 'token': responseBody['token'], 'userId': responseBody['userId'], 'role': responseBody['role']};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Registrasi gagal'};
    }
  }

  // Login Pengguna
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$_authBaseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      // Simpan token dan detail pengguna setelah login berhasil
      await AuthManager.saveAuthData(
        responseBody['token'],
        responseBody['userId'],
        responseBody['role'],
      );
      return {'success': true, 'message': responseBody['message'], 'token': responseBody['token'], 'userId': responseBody['userId'], 'role': responseBody['role']};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Login gagal'};
    }
  }

  // Logout Pengguna
  Future<Map<String, dynamic>> logoutUser() async {
    final url = Uri.parse('$_authBaseUrl/logout');
    final token = await AuthManager.getAuthToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      await AuthManager.clearAuthData(); // Hapus data autentikasi
      return {'success': true, 'message': responseBody['message']};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Logout gagal'};
    }
  }

  // Mendapatkan Profil Pengguna
  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('$_authBaseUrl/profile');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'user': User.fromJson(responseBody['user'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal mendapatkan profil'};
    }
  }

  // Memperbarui Profil Pengguna
  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? email,
    String? password,
    String? fullName,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    final url = Uri.parse('$_authBaseUrl/profile');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final Map<String, dynamic> updateData = {};
    if (username != null) updateData['username'] = username;
    if (email != null) updateData['email'] = email;
    if (password != null) updateData['password'] = password;
    if (fullName != null) updateData['full_name'] = fullName;
    if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
    if (profilePictureUrl != null) updateData['profile_picture_url'] = profilePictureUrl;

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updateData),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': responseBody['message']};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal memperbarui profil'};
    }
  }
}
