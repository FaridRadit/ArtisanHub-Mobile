// lib/models/artisan.dart

import 'userModel.dart';
import 'package:latlong2/latlong.dart';

// Re-defining LocationPoint as it's used within artisan
class LocationPoint {
  String? type;
  List<double>? coordinates;

  LocationPoint({
    this.type,
    this.coordinates,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e is num ? e.toDouble() : double.tryParse(e.toString()) ?? 0.0)) // Robust parsing for coordinates
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class artisan {
  int? id;
  int? user_id;
  String? bio;
  String? expertise_category;
  String? address;
  double? latitude;
  double? longitude;
  LocationPoint? location_point;
  Map<String, String>? operational_hours;
  String? contact_email;
  String? contact_phone;
  String? website_url;
  Map<String, String>? social_media_links;
  double? avg_rating;
  int? total_reviews;
  bool? is_verified;
  DateTime? created_at;
  DateTime? updated_at;
  User? user;

  artisan({
    this.id,
    this.user_id,
    this.bio,
    this.expertise_category,
    this.address,
    this.latitude,
    this.longitude,
    this.location_point,
    this.operational_hours,
    this.contact_email,
    this.contact_phone,
    this.website_url,
    this.social_media_links,
    this.avg_rating,
    this.total_reviews,
    this.is_verified,
    this.created_at,
    this.updated_at,
    this.user,
  });

  factory artisan.fromJson(Map<String, dynamic> json) {
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

    return artisan(
      id: json['id'] as int?,
      user_id: json['user_id'] as int?,
      bio: json['bio'] as String?,
      expertise_category: json['expertise_category'] as String?,
      address: json['address'] as String?,
      latitude: parseToDouble(json['latitude']), // Menggunakan helper
      longitude: parseToDouble(json['longitude']), // Menggunakan helper
      location_point: json['location_point'] != null
          ? LocationPoint.fromJson(json['location_point'] as Map<String, dynamic>)
          : null,
      operational_hours: (json['operational_hours'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as String)),
      contact_email: json['contact_email'] as String?,
      contact_phone: json['contact_phone'] as String?,
      website_url: json['website_url'] as String?,
      social_media_links: (json['social_media_links'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as String)),
      avg_rating: parseToDouble(json['avg_rating']), // Menggunakan helper
      total_reviews: parseToInt(json['total_reviews']), // Menggunakan helper
      is_verified: json['is_verified'] as bool?,
      created_at: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) // Gunakan toString() untuk memastikan string
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) // Gunakan toString() untuk memastikan string
          : null,
      user: json['User'] != null
          ? User.fromJson(json['User'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'bio': bio,
      'expertise_category': expertise_category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'location_point': location_point?.toJson(),
      'operational_hours': operational_hours,
      'contact_email': contact_email,
      'contact_phone': contact_phone,
      'website_url': website_url,
      'social_media_links': social_media_links,
      'avg_rating': avg_rating,
      'total_reviews': total_reviews,
      'is_verified': is_verified,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
      'User': user?.toJson(),
    };
  }
}
