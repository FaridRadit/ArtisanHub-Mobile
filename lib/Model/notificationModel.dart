
// notificationModel.dart

class NotificationModel {
  int? id;
  int? user_id;
  String? type;
  String? title;
  String? message;
  int? target_id; // Assuming target_id is an integer (e.g., ID of a product, order, etc.)
  bool? is_read;
  DateTime? sent_at;

  NotificationModel({
    this.id,
    this.user_id,
    this.type,
    this.title,
    this.message,
    this.target_id,
    this.is_read,
    this.sent_at,
  });

  // Factory constructor to create a NotificationModel instance from a JSON Map
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      user_id: json['user_id'] as int?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      target_id: json['target_id'] as int?,
      is_read: json['is_read'] as bool?,
      sent_at: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
    );
  }

  // Method to convert a NotificationModel instance to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'type': type,
      'title': title,
      'message': message,
      'target_id': target_id,
      'is_read': is_read,
      'sent_at': sent_at?.toIso8601String(), // Convert DateTime to ISO 8601 string
    };
  }
}