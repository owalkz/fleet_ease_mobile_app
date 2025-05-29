import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fleet_ease/models/notification_model.dart';
import 'package:fleet_ease/utils/secure_storage.dart';

class NotificationService {
  static const String baseUrl =
      "https://fleet-ease-backend.vercel.app/api/notifications";

  static Future<List<NotificationModel>> fetchNotifications(
      String userId, String userType) async {
    final token = await SecureStorageService().getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/?type=$userType&userId=$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load notifications");
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    final token = await SecureStorageService().getToken();

    await http.patch(
      Uri.parse("$baseUrl/$notificationId/read"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  static Future<void> deleteNotification(String notificationId) async {
    final token = await SecureStorageService().getToken();

    await http.delete(
      Uri.parse("$baseUrl/$notificationId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
}
