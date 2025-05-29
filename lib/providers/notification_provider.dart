import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_ease/models/notification_model.dart';
import 'package:fleet_ease/api/notification_service.dart';

final notificationProvider =
    FutureProvider.family<List<NotificationModel>, Map<String, String>>(
        (ref, params) async {
  final userId = params['userId']!;
  final userType = params['userType']!;
  return await NotificationService.fetchNotifications(userId, userType);
});

final unreadNotificationCountProvider =
    Provider.family<int, List<NotificationModel>>((ref, notifications) {
  return notifications.where((n) => !n.read).length;
});
