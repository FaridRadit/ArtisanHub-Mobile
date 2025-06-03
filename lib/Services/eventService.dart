

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/eventModel.dart'; // Pastikan path model EventModel sudah benar
import 'auth_manager.dart';

class EventService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Mendapatkan semua acara
  Future<Map<String, dynamic>> getAllEvents({
    double? lat,
    double? lon,
    double? radius,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? q,
    int limit = 10,
    int offset = 0,
  }) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (lat != null) queryParams['lat'] = lat.toString();
    if (lon != null) queryParams['lon'] = lon.toString();
    if (radius != null) queryParams['radius'] = radius.toString();
    if (dateFrom != null) queryParams['date_from'] = dateFrom.toIso8601String().split('T')[0];
    if (dateTo != null) queryParams['date_to'] = dateTo.toIso8601String().split('T')[0];
    if (q != null) queryParams['q'] = q;

    final uri = Uri.parse('$_baseUrl/events').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      List<EventModel> events = (responseBody['data'] as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
      return {'success': true, 'message': responseBody['message'], 'data': events};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal mendapatkan daftar acara'};
    }
  }

  // Mendapatkan acara berdasarkan ID
  Future<Map<String, dynamic>> getEventById(int id) async {
    final url = Uri.parse('$_baseUrl/events/$id');
    final response = await http.get(url);

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': responseBody['message'], 'data': EventModel.fromJson(responseBody['data'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Acara tidak ditemukan'};
    }
  }

  // Membuat acara baru (hanya admin)
  Future<Map<String, dynamic>> createEvent({
    required String name,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    required String locationName,
    required String address,
    required double latitude,
    required double longitude,
    String? organizer,
    String? eventUrl,
    String? posterImageUrl,
  }) async {
    final url = Uri.parse('$_baseUrl/events');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final Map<String, dynamic> body = {
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String().split('T')[0], // Format ke YYYY-MM-DD
      'end_date': endDate.toIso8601String().split('T')[0],     // Format ke YYYY-MM-DD
      'location_name': locationName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'organizer': organizer,
      'event_url': eventUrl,
      'poster_image_url': posterImageUrl,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'message': responseBody['message'], 'data': EventModel.fromJson(responseBody['data'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal membuat acara'};
    }
  }

  // Memperbarui acara (hanya admin)
  Future<Map<String, dynamic>> updateEvent(int id, {
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? locationName,
    String? address,
    double? latitude,
    double? longitude,
    String? organizer,
    String? eventUrl,
    String? posterImageUrl,
  }) async {
    final url = Uri.parse('$_baseUrl/events/$id');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (startDate != null) updateData['start_date'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) updateData['end_date'] = endDate.toIso8601String().split('T')[0];
    if (locationName != null) updateData['location_name'] = locationName;
    if (address != null) updateData['address'] = address;
    if (latitude != null) updateData['latitude'] = latitude;
    if (longitude != null) updateData['longitude'] = longitude;
    if (organizer != null) updateData['organizer'] = organizer;
    if (eventUrl != null) updateData['event_url'] = eventUrl;
    if (posterImageUrl != null) updateData['poster_image_url'] = posterImageUrl;

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
      return {'success': true, 'message': responseBody['message'], 'data': EventModel.fromJson(responseBody['data'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal memperbarui acara'};
    }
  }

  // Menghapus acara (hanya admin)
  Future<Map<String, dynamic>> deleteEvent(int id) async {
    final url = Uri.parse('$_baseUrl/events/$id');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final response = await http.delete(
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
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal menghapus acara'};
    }
  }
}
