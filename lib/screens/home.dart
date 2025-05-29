import 'package:fleet_ease/screens/driver_management.dart';
import 'package:fleet_ease/screens/manager_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fleet_ease/screens/driver_trip_list.dart';
import 'package:fleet_ease/screens/manager_trip_list_screen.dart';
import 'package:fleet_ease/screens/driver_home_screen.dart';
import 'package:fleet_ease/screens/vehicle.dart';
import 'package:fleet_ease/screens/driver_vehicle_screen.dart';
import 'package:fleet_ease/providers/auth_provider.dart';
import 'package:fleet_ease/screens/auth.dart';
import 'package:fleet_ease/widgets/common_widgets/profile.dart';
import 'package:fleet_ease/utils/secure_storage.dart';
import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:fleet_ease/screens/notification_list_screen.dart';
import 'package:fleet_ease/models/notification_model.dart';
import 'package:fleet_ease/api/notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.userType});

  final String userType;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? userId;
  String? userType;
  int _selectedIndex = 0;
  bool isLoading = true;
  List<NotificationModel> notifications = [];
  int unreadCount = 0;
  bool isNotificationLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final id = SharedPrefsHelper.getUserId();
    final type = SharedPrefsHelper.getUserAccountType();

    setState(() {
      userId = id;
      userType = type;
    });

    await _fetchNotifications(); // fetch after setting user info

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchNotifications() async {
    if (userId == null || userType == null) return;

    setState(() {
      isNotificationLoading = true;
    });

    try {
      final fetched =
          await NotificationService.fetchNotifications(userId!, userType!);
      final unread = fetched.where((n) => !n.read).length;

      setState(() {
        notifications = fetched;
        unreadCount = unread;
        isNotificationLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      setState(() {
        isNotificationLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userId == null || userType == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isManager = userType == 'manager';
    final List<String> pageTitles = isManager
        ? ['Home', 'Trips', 'Drivers', 'Vehicles', 'Profile']
        : ['Home', 'Jobs', 'Vehicle', 'Profile'];

    final List<Widget> widgetOptions = isManager
        ? [
            ManagerHomeScreen(),
            TripListScreen(),
            DriverManagementScreen(),
            VehicleListScreen(userType: userType!),
            Profile(),
          ]
        : [
            DriverHomeScreen(),
            DriverTripsScreen(),
            DriverVehicleScreen(),
            Profile(),
          ];

    final navItems = isManager
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Trips'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Drivers'),
            BottomNavigationBarItem(
                icon: Icon(Icons.directions_car), label: 'Vehicles'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(
                icon: Icon(Icons.directions_car), label: 'Vehicle'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_selectedIndex]),
        actions: [
          isNotificationLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => NotificationListScreen(
                            userId: userId!,
                            userType: userType!,
                          ),
                        ));
                        await _fetchNotifications(); // refresh on return
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
          IconButton(
            onPressed: () async {
              ref.invalidate(userNotifierProvider); // Reset the provider fully
              await SecureStorageService().deleteUserData();
              await SharedPrefsHelper.clearUserDetails();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
