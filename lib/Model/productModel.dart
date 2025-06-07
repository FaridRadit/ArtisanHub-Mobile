// lib/models/product.dart

import 'package:flutter/material.dart'; // Hanya jika Anda menggunakan Material/Cupertino di model, jika tidak bisa dihapus

class product {
  int? id;
  int? artisan_id;
  String? name;
  String? description;
  double? price;
  String? currency;
  String? main_image_url;
  String? category;
  int? stock_quantity;
  bool? is_available;
  DateTime? created_at;
  DateTime? updated_at;

  product({
    this.id,
    this.artisan_id,
    this.name,
    this.description,
    this.price,
    this.currency,
    this.main_image_url,
    this.category,
    this.stock_quantity,
    this.is_available,
    this.created_at,
    this.updated_at,
  });

  // Factory constructor for creating a Product instance from JSON
  factory product.fromJson(Map<String, dynamic> json) {
    
    // Helper function to parse numeric values that might come as String or num
    double? parseToDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseToInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt(); // Handle double to int conversion
      return null;
    }

    return product(
      id: json['id'] as int?,
      artisan_id: parseToInt(json['artisan_id']), // Menggunakan helper untuk artisan_id
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: parseToDouble(json['price']), // Menggunakan helper untuk parsing yang lebih tangguh
      currency: json['currency'] as String?,
      main_image_url: json['main_image_url'] as String?,
      category: json['category'] as String?,
      stock_quantity: parseToInt(json['stock_quantity']), // Menggunakan helper untuk parsing yang lebih tangguh
      is_available: json['is_available'] as bool?,
      created_at: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) // Menggunakan toString() untuk memastikan string
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) // Menggunakan toString() untuk memastikan string
          : null,
    );
  }

  // Method to convert a Product instance to JSON
  Map<String, dynamic> toJson() {
    return {
  
      'id': id,
      'artisan_id': artisan_id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'main_image_url': main_image_url,
      'category': category,
      'stock_quantity': stock_quantity,
      'is_available': is_available,
      'created_at': created_at?.toIso8601String(), // Convert DateTime to ISO 8601 string
      'updated_at': updated_at?.toIso8601String(), // Convert DateTime to ISO 8601 string
    };
  }
}
