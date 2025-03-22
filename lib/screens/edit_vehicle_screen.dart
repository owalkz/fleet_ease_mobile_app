import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fleet_ease/models/vehicle_model.dart';
import 'package:fleet_ease/api/vehicle_functions.dart';

class EditVehicleScreen extends StatefulWidget {
  final VehicleModel vehicle;
  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _licenseController;
  late TextEditingController _mileageController;

  String? _fuelType;
  File? _newImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.vehicle.make);
    _modelController = TextEditingController(text: widget.vehicle.model);
    _licenseController =
        TextEditingController(text: widget.vehicle.licensePlateNumber);
    _mileageController =
        TextEditingController(text: widget.vehicle.mileage.toString());
    _fuelType = widget.vehicle.fuelType;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _newImage = File(pickedFile.path));
    }
  }

  void _updateVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    Map<String, dynamic> updatedData = {
      "make": _makeController.text,
      "model": _modelController.text,
      "licensePlateNumber": _licenseController.text,
      "mileage": int.tryParse(_mileageController.text) ?? 0,
      "fuelType": _fuelType,
    };

    bool success = await ApiService.updateVehicle(
        widget.vehicle.id, updatedData, _newImage);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle updated successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update vehicle.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Vehicle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _newImage != null
                      ? FileImage(_newImage!)
                      : NetworkImage(widget.vehicle.imageUrl) as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(controller: _makeController, decoration: const InputDecoration(labelText: "Make")),
              TextFormField(controller: _modelController, decoration: const InputDecoration(labelText: "Model")),
              TextFormField(controller: _licenseController, decoration: const InputDecoration(labelText: "License Plate")),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateVehicle,
                child: _isLoading ? const CircularProgressIndicator() : const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
