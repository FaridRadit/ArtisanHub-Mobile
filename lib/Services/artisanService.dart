// lib/services/artisanService.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/artisanModel.dart'; // Pastikan path model artisan sudah benar
import 'auth_manager.dart';

class ArtisanService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Mendapatkan semua profil pengrajin
  Future<Map<String, dynamic>> getAllArtisans({
    double? lat,
    double? lon,
    double? radius,
    String? category,
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
    if (category != null) queryParams['category'] = category;
    if (q != null) queryParams['q'] = q;

    final uri = Uri.parse('$_baseUrl/artisans').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      List<artisan> artisans = (responseBody['data'] as List)
          .map((json) => artisan.fromJson(json))
          .toList();
      return {'success': true, 'message': responseBody['message'], 'data': artisans};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal mendapatkan daftar pengrajin'};
    }
  }

  // Mendapatkan profil pengrajin berdasarkan ID
  Future<Map<String, dynamic>> getArtisanById(int id) async {
    final url = Uri.parse('$_baseUrl/artisans/$id');
    final response = await http.get(url);

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': responseBody['message'], 'data': artisan.fromJson(responseBody['data'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Pengrajin tidak ditemukan'};
    }
  }

  // Membuat profil pengrajin baru
  Future<Map<String, dynamic>> createArtisanProfile({
    String? bio,
    required String expertiseCategory,
    required String address,
    required double latitude,
    required double longitude,
    Map<String, String>? operationalHours,
    String? contactEmail,
    String? contactPhone,
    String? websiteUrl,
    Map<String, String>? socialMediaLinks,
  }) async {
    final url = Uri.parse('$_baseUrl/artisans');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final Map<String, dynamic> body = {
      'expertise_category': expertiseCategory,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (bio != null) body['bio'] = bio;
    if (operationalHours != null) body['operational_hours'] = operationalHours;
    if (contactEmail != null) body['contact_email'] = contactEmail;
    if (contactPhone != null) body['contact_phone'] = contactPhone;
    if (websiteUrl != null) body['website_url'] = websiteUrl;
    if (socialMediaLinks != null) body['social_media_links'] = socialMediaLinks;

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
      return {'success': true, 'message': responseBody['message'], 'data': artisan.fromJson(responseBody['data'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal membuat profil pengrajin'};
    }
  }

  // Memperbarui profil pengrajin
  Future<Map<String, dynamic>> updateArtisanProfile(int id, {
    String? bio,
    String? expertiseCategory,
    String? address,
    double? latitude,
    double? longitude,
    Map<String, String>? operationalHours,
    String? contactEmail,
    String? contactPhone,
    String? websiteUrl,
    Map<String, String>? socialMediaLinks,
  }) async {
    final url = Uri.parse('$_baseUrl/artisans/$id');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final Map<String, dynamic> updateData = {};
    if (bio != null) updateData['bio'] = bio;
    if (expertiseCategory != null) updateData['expertise_category'] = expertiseCategory;
    if (address != null) updateData['address'] = address;
    if (latitude != null) updateData['latitude'] = latitude;
    if (longitude != null) updateData['longitude'] = longitude;
    if (operationalHours != null) updateData['operational_hours'] = operationalHours;
    if (contactEmail != null) updateData['contact_email'] = contactEmail;
    if (contactPhone != null) updateData['contact_phone'] = contactPhone;
    if (websiteUrl != null) updateData['website_url'] = websiteUrl;
    if (socialMediaLinks != null) updateData['social_media_links'] = socialMediaLinks;

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
      return {'success': true, 'message': responseBody['message'], 'data': artisan.fromJson(responseBody['data'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal memperbarui profil pengrajin'};
    }
  }

  // Menghapus profil pengrajin
  Future<Map<String, dynamic>> deleteArtisanProfile(int id) async {
    final url = Uri.parse('$_baseUrl/artisans/$id');
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
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal menghapus profil pengrajin'};
    }
  }
}
