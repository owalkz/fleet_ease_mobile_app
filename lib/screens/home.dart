import 'package:flutter/material.dart';

import 'package:fleet_ease/screens/auth.dart';
import 'package:fleet_ease/widgets/common_widgets/profile.dart';
import 'package:fleet_ease/utils/secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userType});

  final String userType;

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    Text('Jobs Page'),
    Text('Vehicles Page'),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FleetEase'),
        actions: [
          IconButton(
            onPressed: () {
              SecureStorageService().deleteUserData();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => AuthScreen()));
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
            label: widget.userType == 'manager' ? 'Vehicles' : 'My Vehicle',
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
