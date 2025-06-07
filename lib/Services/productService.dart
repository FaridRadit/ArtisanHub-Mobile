// lib/services/productService.dart

import 'dart:convert';
import 'package:artisanhub11/Model/artisanModel.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../model/productModel.dart';
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

    if (artisanId != null) queryParams['artisanId'] = artisanId.toString();

    final uri = Uri.parse('$_baseUrl/products').replace(queryParameters: queryParams);
    final token = await AuthManager.getAuthToken();
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('DEBUG: getAllProducts URL: $uri');
    print('DEBUG: getAllProducts Headers: $headers');

    final response = await http.get(uri, headers: headers);

    print('DEBUG: getAllProducts Status Code: ${response.statusCode}');
    print('DEBUG: getAllProducts Response Body: ${response.body}');

    try {
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        List<product> products = (responseBody['data'] as List)
            .map((json) => product.fromJson(json))
            .toList();
        return {'success': true, 'message': responseBody['message'], 'data': products};
      } else {
        return {'success': false, 'message': responseBody['message'] ?? 'Gagal mendapatkan daftar produk'};
      }
    } catch (e) {
      print('ERROR: Failed to parse JSON in getAllProducts: $e');
      print('Raw response body: ${response.body}');
      return {'success': false, 'message': 'Kesalahan format respons dari server.'};
    }
  }

  // Mendapatkan produk berdasarkan ID
  Future<Map<String, dynamic>> getProductById(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    final token = await AuthManager.getAuthToken();
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('DEBUG: getProductById URL: $url');
    print('DEBUG: getProductById Headers: $headers');

    final response = await http.get(url, headers: headers);

    print('DEBUG: getProductById Status Code: ${response.statusCode}');
    print('DEBUG: getProductById Response Body: ${response.body}');

    try {
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseBody['message'], 'data': product.fromJson(responseBody['data'])};
      } else {
        return {'success': false, 'message': responseBody['message'] ?? 'Produk tidak ditemukan'};
      }
    } catch (e) {
      print('ERROR: Failed to parse JSON in getProductById: $e');
      print('Raw response body: ${response.body}');
      return {'success': false, 'message': 'Kesalahan format respons dari server.'};
    }
  }

  // Membuat produk baru
  Future<Map<String, dynamic>> createProduct(int artisanId, { // Mengubah artisanId menjadi int
    String? name,
    String? description,
    double? price,
    String? currency,
    String? mainImageUrl,
    String? category,
    int? stockQuantity,
    bool? isAvailable,
  }) async {
    final url = Uri.parse('$_baseUrl/products'); 
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    // Membangun body data untuk request
    final Map<String, dynamic> requestBody = {
      'artisan_id': artisanId, // Menggunakan artisanId yang diterima
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'main_image_url': mainImageUrl,
      'category': category,
      'stock_quantity': stockQuantity,
      'is_available': isAvailable,
    };
    
    // Hapus null values dari requestBody sebelum encode
    requestBody.removeWhere((key, value) => value == null);

    print('DEBUG: createProduct URL: $url');
    print('DEBUG: createProduct Token: $token');
    print('DEBUG: createProduct Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody), // Meng-encode Map requestBody
    );

    print('DEBUG: createProduct Status Code: ${response.statusCode}');
    print('DEBUG: createProduct Response Body: ${response.body}');

    try {
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': responseBody['message'], 'data': product.fromJson(responseBody['data'])};
      } else {
        return {'success': false, 'message': responseBody['message'] ?? 'Gagal membuat produk'};
      }
    } catch (e) {
      print('ERROR: Failed to parse JSON in createProduct: $e');
      print('Raw response body: ${response.body}');
      return {'success': false, 'message': 'Kesalahan format respons dari server.'};
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

    print('DEBUG: updateProduct URL: $url');
    print('DEBUG: updateProduct Token: $token');
    print('DEBUG: updateProduct Request Body: ${jsonEncode(updateData)}');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updateData),
    );

    print('DEBUG: updateProduct Status Code: ${response.statusCode}');
    print('DEBUG: updateProduct Response Body: ${response.body}');

    try {
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseBody['message'], 'data': product.fromJson(responseBody['data'])};
      } else {
        return {'success': false, 'message': responseBody['message'] ?? 'Gagal memperbarui produk'};
      }
    } catch (e) {
      print('ERROR: Failed to parse JSON in updateProduct: $e');
      print('Raw response body: ${response.body}');
      return {'success': false, 'message': 'Kesalahan format respons dari server.'};
    }
  }

  // Menghapus produk
  Future<Map<String, dynamic>> deleteProduct(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    final token = await AuthManager.getAuthToken();

    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan. Mohon login.'};
    }

    print('DEBUG: deleteProduct URL: $url');
    print('DEBUG: deleteProduct Token: $token');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('DEBUG: deleteProduct Status Code: ${response.statusCode}');
    print('DEBUG: deleteProduct Response Body: ${response.body}');

    try {
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseBody['message']};
      } else {
        return {'success': false, 'message': responseBody['message'] ?? 'Gagal menghapus produk'};
      }
    } catch (e) {
      print('ERROR: Failed to parse JSON in deleteProduct: $e');
      print('Raw response body: ${response.body}');
      return {'success': false, 'message': 'Kesalahan format respons dari server.'};
    }
  }
}
