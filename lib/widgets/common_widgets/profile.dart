import 'package:flutter/material.dart';

import 'package:fleet_ease/widgets/common_widgets/profile_entry.dart';
import 'package:fleet_ease/utils/secure_storage.dart';

import 'package:fleet_ease/screens/edit_profile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = '';
  String _email = '';
  String _accountType = '';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final name = await SecureStorageService().getUserName();
    final email = await SecureStorageService().getEmailAddress();
    final accountType = await SecureStorageService().getUserType();

    setState(() {
      _name = name!;
      _email = email!;
      _accountType = accountType!;
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.purpleAccent,
            ),
            const SizedBox(
              height: 40,
            ),
            ProfileEntry(displayText: _name, displayIcon: Icons.person),
            const SizedBox(
              height: 10,
            ),
            ProfileEntry(displayText: _email, displayIcon: Icons.mail),
            const SizedBox(
              height: 10,
            ),
            ProfileEntry(
                displayText: _accountType,
                displayIcon: Icons.account_box_sharp),
            const SizedBox(
              height: 60,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
              icon: Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
          ],
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
