import 'dart:convert';
import 'dart:io';
import 'package:fleet_ease/utils/secure_storage.dart';
import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  DateTime? _licenseExpiryDate;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _deactivateAccount(BuildContext context) async {
    try {
      final token = await SecureStorageService().getToken();
      final response = await http.delete(
        Uri.parse(
            "https://fleet-ease-backend.vercel.app/api/users/deactivate-account"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        await SharedPrefsHelper.saveAccountStatus("inactive"); // ✅ Update here
        setState(() {}); // ✅ Triggers UI refresh

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deactivated successfully.")),
        );
      } else {
        print("Failed to deactivate: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not deactivate account.")),
        );
      }
    } catch (e) {
      print("Error deactivating account: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong.")),
      );
    }
  }

  void _confirmDeactivate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deactivation"),
        content: const Text(
          "Are you sure you want to deactivate your account?\nThis cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Future.microtask(() => _deactivateAccount(context));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Deactivate"),
          ),
        ],
      ),
    );
  }

  void _loadUserData() async {
    _nameController.text = SharedPrefsHelper.getUserName() ?? "John Doe";
    _userType = SharedPrefsHelper.getUserAccountType();
    // Optional: preload expiry from backend if needed later
    setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _reactivateAccount() async {
    try {
      final token = await SecureStorageService().getToken();
      final response = await http.patch(
        Uri.parse(
            "https://fleet-ease-backend.vercel.app/api/users/reactivate-account"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        // Update status locally
        await SharedPrefsHelper.saveAccountStatus("active");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account reactivated successfully.")),
          );
          setState(() {}); // Refresh UI
        }
      } else {
        print("Failed to reactivate account: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reactivation failed.")),
        );
      }
    } catch (e) {
      print("Error reactivating account: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong.")),
      );
    }
  }

  Future<void> _uploadProfileData(BuildContext context) async {
    try {
      var uri = Uri.parse(
          "https://fleet-ease-backend.vercel.app/api/users/edit-profile");
      var request = http.MultipartRequest("POST", uri);
      final token = await SecureStorageService().getToken();
      request.headers["Authorization"] = "Bearer $token";

      if (_image != null) {
        var mimeType = lookupMimeType(_image!.path);
        request.files.add(await http.MultipartFile.fromPath(
          "file",
          _image!.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ));
      }

      request.fields["name"] = _nameController.text;
      if (_userType == "driver" && _licenseExpiryDate != null) {
        request.fields["licenseExpiryDate"] =
            _licenseExpiryDate!.toIso8601String();
      }

      final response = await request.send();
      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        String newUrl = responseData["newUrl"] ?? "";

        await SharedPrefsHelper.saveUsername(_nameController.text);
        if (newUrl.isNotEmpty) {
          await SharedPrefsHelper.saveProfilePhoto(newUrl);
        }

        if (context.mounted) Navigator.pop(context);
      } else {
        print("Failed to update profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  void _showDatePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _licenseExpiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _licenseExpiryDate = picked;
      });
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Take a Photo"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Choose from Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDriver = _userType == "driver";
    final isDeactivated = SharedPrefsHelper.getAccountStatus() == "inactive";

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () => _showImageSourceDialog(context),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (isDriver)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("License Expiry Date"),
                subtitle: Text(
                  _licenseExpiryDate != null
                      ? DateFormat.yMMMd().format(_licenseExpiryDate!)
                      : "Not selected",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _showDatePicker,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _uploadProfileData(context),
              child: const Text("Save Changes"),
            ),
            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 10),
            Text(
              "Danger Zone",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 10),
            if (isDeactivated)
              ElevatedButton.icon(
                icon: const Icon(Icons.replay),
                label: const Text("Reactivate Account"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _reactivateAccount,
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: const Text("Deactivate Account"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _confirmDeactivate(context),
              ),
          ],
        ),
      ),
    );
  }
}
