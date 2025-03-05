import 'package:fleet_ease/providers/auth_provider.dart';
import 'package:flutter/material.dart';

import 'package:fleet_ease/utils/shared_preferences.dart';

import 'package:fleet_ease/widgets/common_widgets/profile_entry.dart';

import 'package:fleet_ease/screens/edit_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userNotifierProvider);

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.purpleAccent,
          ),
          const SizedBox(height: 40),
          ProfileEntry(displayText: SharedPrefsHelper.getUserName()!, displayIcon: Icons.person),
          const SizedBox(height: 10),
          ProfileEntry(
              displayText: SharedPrefsHelper.getUserEmail()!, displayIcon: Icons.mail),
          const SizedBox(height: 10),
          ProfileEntry(
              displayText: SharedPrefsHelper.getUserAccountType()!,
              displayIcon: Icons.account_box_sharp),
          const SizedBox(height: 60),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }
}
