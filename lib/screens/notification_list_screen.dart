import 'package:flutter/material.dart';
import 'package:fleet_ease/models/notification_model.dart';
import 'package:fleet_ease/api/notification_service.dart';

class NotificationListScreen extends StatefulWidget {
  final String userId;
  final String userType;

  const NotificationListScreen({
    Key? key,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;

  Future<List<NotificationModel>> _fetchNotifications() async {
    try {
      final data = await NotificationService.fetchNotifications(
        widget.userId,
        widget.userType,
      );
      return data;
    } catch (e) {
      print('Error in _fetchNotifications: $e');
      rethrow;
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await NotificationService.markAsRead(notificationId);
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  Future<void> _deleteNotification(String notificationId) async {
    await NotificationService.deleteNotification(notificationId);
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteNotification(notification.id),
                child: ListTile(
                  tileColor: notification.read
                      ? Colors.white
                      : Colors.blue.withValues(alpha: 26),
                  title: Text(
                    notification.message,
                    style: TextStyle(
                      color:
                          notification.read ? Colors.black : Colors.blue[900],
                    ),
                  ),
                  onTap: () {
                    if (!notification.read) {
                      _markAsRead(notification.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
