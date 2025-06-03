

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/notificationModel.dart'; // Pastikan path model NotificationModel sudah benar
import 'auth_manager.dart';

class NotificationService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Mendaftarkan atau memperbarui device token untuk notifikasi push
  Future<Map<String, dynamic>> registerDeviceToken(String deviceToken, String platform) async {
    final url = Uri.parse('$_baseUrl/notifications/register-token');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'device_token': deviceToken,
        'platform': platform,
      }),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'message': responseBody['message']};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal mendaftarkan/memperbarui token'};
    }
  }

  // Mendapatkan daftar notifikasi untuk pengguna yang sedang login
  Future<Map<String, dynamic>> getNotifications({
    int limit = 10,
    int offset = 0,
    bool? isRead,
  }) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (isRead != null) queryParams['is_read'] = isRead.toString();

    final uri = Uri.parse('$_baseUrl/notifications').replace(queryParameters: queryParams);
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      List<NotificationModel> notifications = (responseBody['data'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      return {'success': true, 'message': responseBody['message'], 'data': notifications};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal mendapatkan notifikasi'};
    }
  }

  // Menandai notifikasi sebagai sudah dibaca
  Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    final url = Uri.parse('$_baseUrl/notifications/$notificationId/read');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': responseBody['message']};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal menandai notifikasi sebagai sudah dibaca'};
    }
  }
}
