class User {
  int? id;
  String? username;
  String? email;
  String? fullName;
  String? role;
  String? phone_number;
  String? profile_picture_url;
  DateTime? created_at;
  DateTime? updated_at;
  String? password_hash; 

  User({
    this.id,
    this.username,
    this.email,
    this.fullName,
    this.role,
    this.phone_number,
    this.profile_picture_url,
    this.created_at,
    this.updated_at,
    this.password_hash,
  });

  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      role: json['role'] as String?,
      phone_number: json['phone_number'] as String?,
      profile_picture_url: json['profile_picture_url'] as String?,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      
      password_hash: json['password_hash'] as String?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone_number': phone_number,
      'profile_picture_url': profile_picture_url,
      'created_at': created_at?.toIso8601String(), // Convert DateTime to ISO 8601 string
      'updated_at': updated_at?.toIso8601String(), // Convert DateTime to ISO 8601 string
      'password_hash': password_hash,
    };
  }
}