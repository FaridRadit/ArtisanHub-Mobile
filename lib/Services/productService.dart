// lib/services/productService.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/productModel.dart'; // Menggunakan 'models' bukan 'model'
import 'auth_manager.dart';

class ProductService {
  final String _baseUrl = ApiConfig.baseUrl;

  // Mendapatkan semua produk
  Future<Map<String, dynamic>> getAllProducts({
    String? category,
    String? q,
    int? artisanId,
    int limit = 10,
    int offset = 0,
  }) async {
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (category != null) queryParams['category'] = category;
    if (q != null) queryParams['q'] = q;

    // Perbaikan: Konversi artisanId ke string sebelum menambahkannya ke queryParams
    // Backend Anda di `getAllProducts` productController.js menerima artisanId sebagai query parameter
    if (artisanId != null) queryParams['artisanId'] = artisanId.toString();

    final uri = Uri.parse('$_baseUrl/products').replace(queryParameters: queryParams);
    
    // Untuk getAllProducts, token mungkin tidak selalu diperlukan jika endpoint ini publik.
    // Namun, jika backend Anda memerlukan autentikasi untuk semua produk, tambahkan header Authorization.
    final token = await AuthManager.getAuthToken();
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(uri, headers: headers);

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      List<product> products = (responseBody['data'] as List)
          .map((json) => product.fromJson(json))
          .toList();
      return {'success': true, 'message': responseBody['message'], 'data': products};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal mendapatkan daftar produk'};
    }
  }

  // Mendapatkan produk berdasarkan ID
  Future<Map<String, dynamic>> getProductById(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    final token = await AuthManager.getAuthToken(); // Asumsi endpoint ini mungkin memerlukan token
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(url, headers: headers);

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': responseBody['message'], 'data': product.fromJson(responseBody['data'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Produk tidak ditemukan'};
    }
  }

  // Membuat produk baru
  Future<Map<String, dynamic>> createProduct(int artisanId, {
    required String name,
    String? description,
    required double price,
    required String currency,
    String? mainImageUrl,
    String? category,
    int? stockQuantity,
    bool? isAvailable,
  }) async {
    // URL sudah benar: /api/products/:artisan_id
    final url = Uri.parse('$_baseUrl/products/$artisanId');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final Map<String, dynamic> body = {
      'name': name,
      'price': price,
      'currency': currency,
    };
    if (description != null) body['description'] = description;
    if (mainImageUrl != null) body['main_image_url'] = mainImageUrl;
    if (category != null) body['category'] = category;
    if (stockQuantity != null) body['stock_quantity'] = stockQuantity;
    if (isAvailable != null) body['is_available'] = isAvailable;

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
      return {'success': true, 'message': responseBody['message'], 'data': product.fromJson(responseBody['data'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal membuat produk'};
    }
  }

  // Memperbarui produk
  Future<Map<String, dynamic>> updateProduct(int id, {
    String? name,
    String? description,
    double? price,
    String? currency,
    String? mainImageUrl,
    String? category,
    int? stockQuantity,
    bool? isAvailable,
  }) async {
    // URL sudah benar: /api/products/:id
    final url = Uri.parse('$_baseUrl/products/$id');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    final Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (price != null) updateData['price'] = price;
    if (currency != null) updateData['currency'] = currency;
    if (mainImageUrl != null) updateData['main_image_url'] = mainImageUrl;
    if (category != null) updateData['category'] = category;
    if (stockQuantity != null) updateData['stock_quantity'] = stockQuantity;
    if (isAvailable != null) updateData['is_available'] = isAvailable;

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
      return {'success': true, 'message': responseBody['message'], 'data': product.fromJson(responseBody['data'])};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal memperbarui produk'};
    }
  }

  // Menghapus produk
  Future<Map<String, dynamic>> deleteProduct(int id) async {
    // URL sudah benar: /api/products/:id
    final url = Uri.parse('$_baseUrl/products/$id');
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
      return {'success': false, 'message': responseBody['message'] ?? 'Gagal menghapus produk'};
    }
  }
}