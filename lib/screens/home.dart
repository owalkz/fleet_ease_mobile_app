import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fleet_ease/screens/trip.dart';
import 'package:fleet_ease/screens/vehicle.dart';
import 'package:fleet_ease/providers/auth_provider.dart';
import 'package:fleet_ease/screens/auth.dart';
import 'package:fleet_ease/widgets/common_widgets/profile.dart';
import 'package:fleet_ease/utils/secure_storage.dart';
import 'package:fleet_ease/utils/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.userType});

  final String userType; 

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      Text('Home Page'),
      TripScreen(),
      VehicleListScreen(userType: widget.userType),
      Profile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('FleetEase'),
        actions: [
          IconButton(
            onPressed: () async {
              ref.watch(userNotifierProvider.notifier).unsetUserDetails();
              SecureStorageService().deleteUserData();
              SharedPrefsHelper.clearUserDetails();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => AuthScreen()));
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(widget.userType == 'manager' ? Icons.people : Icons.work),
            label: widget.userType == 'manager' ? 'Drivers' : 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: SharedPrefsHelper.getUserAccountType() == 'manager'
                ? 'Vehicles'
                : 'My Vehicle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
