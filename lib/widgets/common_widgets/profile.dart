import 'package:flutter/material.dart';
import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:fleet_ease/screens/edit_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilePhoto = SharedPrefsHelper.getUserProfilePhoto();
    final name = SharedPrefsHelper.getUserName() ?? "User Name";
    final email = SharedPrefsHelper.getUserEmail() ?? "user@example.com";
    final accountType =
        SharedPrefsHelper.getUserAccountType() ?? "Account Type";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue.withOpacity(0.2),
            backgroundImage:
                profilePhoto != null ? NetworkImage(profilePhoto) : null,
            child: profilePhoto == null
                ? const Icon(Icons.person, size: 60, color: Colors.blue)
                : null,
          ),
          const SizedBox(height: 20),
          Text(name, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 5),
          Text(email, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 5),
          Text(
            accountType,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
