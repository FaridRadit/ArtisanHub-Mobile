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

  // Constructor
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
    return product(
      id: json['id'] as int?,
      artisan_id: json['artisan_id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(), // Handle int or double from JSON
      currency: json['currency'] as String?,
      main_image_url: json['main_image_url'] as String?,
      category: json['category'] as String?,
      stock_quantity: json['stock_quantity'] as int?,
      is_available: json['is_available'] as bool?,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
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