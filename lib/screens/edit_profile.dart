import 'dart:convert';
import 'dart:io';
import 'package:fleet_ease/utils/secure_storage.dart';
import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _image; // Store selected image

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load existing user data
  }

  void _loadUserData() async {
    _nameController.text = "John Doe"; // Replace with actual stored name
    setState(() {}); // Update UI
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

  Future<void> _uploadProfileData(BuildContext context) async {
    try {
      var uri = Uri.parse(
          "https://fleet-ease-backend.vercel.app/api/users/edit-profile");
      var request = http.MultipartRequest("POST", uri);
      final token = await SecureStorageService().getToken();

      // Attach Authorization header
      request.headers["Authorization"] = "Bearer $token";

      // Attach image if selected
      if (_image != null) {
        var mimeType = lookupMimeType(_image!.path);
        request.files.add(await http.MultipartFile.fromPath(
          "file",
          _image!.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ));
      }

      // Attach name
      request.fields["name"] = _nameController.text;
      String? name = request.fields["name"];

      var response = await request.send();
      if (response.statusCode == 201) {
        // Convert StreamedResponse to String
        String responseBody = await response.stream.bytesToString();
        // Decode JSON
        var responseData = json.decode(responseBody);

        // Extract `newUrl`
        String newUrl = responseData["newUrl"];
        await SharedPrefsHelper.saveProfilePhoto(newUrl);
        await SharedPrefsHelper.saveUsername(name!);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        print("Failed to update profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            ElevatedButton(
              onPressed: () => _uploadProfileData(context),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
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
}
