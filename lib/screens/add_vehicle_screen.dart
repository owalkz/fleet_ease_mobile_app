import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fleet_ease/api/vehicle_functions.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _fuelRateController = TextEditingController();

  String? _fuelType;
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    Map<String, dynamic> vehicleData = {
      "make": _makeController.text,
      "model": _modelController.text,
      "licensePlateNumber": _licenseController.text,
      "VIN": _vinController.text,
      "fuelType": _fuelType ?? "Petrol",
      "fuelConsumptionRate": double.tryParse(_fuelRateController.text) ?? 0,
      "mileage": int.tryParse(_mileageController.text) ?? 0,
      "inspectionStatus": true, // Default to true
    };

    bool success = await ApiService.createVehicle(vehicleData, _selectedImage);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle added successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add vehicle.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Vehicle")),
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
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(labelText: "Make"),
                validator: (value) =>
                    value!.isEmpty ? "Enter vehicle make" : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: "Model"),
                validator: (value) =>
                    value!.isEmpty ? "Enter vehicle model" : null,
              ),
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(labelText: "License Plate"),
                validator: (value) =>
                    value!.isEmpty ? "Enter license plate number" : null,
              ),
              TextFormField(
                controller: _vinController,
                decoration: const InputDecoration(labelText: "VIN"),
              ),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: "Mileage"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _fuelRateController,
                decoration:
                    const InputDecoration(labelText: "Fuel Rate (L/km)"),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: const InputDecoration(labelText: "Fuel Type"),
                items: ["Petrol", "Diesel", "Electric", "Hybrid"]
                    .map((fuel) =>
                        DropdownMenuItem(value: fuel, child: Text(fuel)))
                    .toList(),
                onChanged: (value) => setState(() => _fuelType = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitVehicle,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Add Vehicle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
