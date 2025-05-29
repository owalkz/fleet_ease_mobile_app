class NotificationModel {
  final String id;
  final String message;
  final bool read;

  NotificationModel({
    required this.id,
    required this.message,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      message: json['message'],
      read: json['read'] ?? false,
    );
  }
}
