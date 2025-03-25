import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fleet_ease/api/trip_functions.dart';
import 'package:fleet_ease/api/vehicle_functions.dart';
import 'package:fleet_ease/api/driver_functions.dart';
import 'package:fleet_ease/models/vehicle_model.dart';
import 'package:fleet_ease/models/driver_model.dart';

class AddTripScreen extends ConsumerStatefulWidget {
  const AddTripScreen({super.key});

  @override
  ConsumerState<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends ConsumerState<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  String? managerId = SharedPrefsHelper.getUserId();
  String? selectedDriverId;
  String? selectedVehicleId;
  TextEditingController startLatitudeController = TextEditingController();
  TextEditingController startLongitudeController = TextEditingController();
  TextEditingController destLatitudeController = TextEditingController();
  TextEditingController destLongitudeController = TextEditingController();
  TextEditingController destAddressController = TextEditingController();
  DateTime? deadline;
  bool isLoading = true;
  List<DriverModel> drivers = [];
  List<VehicleModel> vehicles = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    drivers = await DriverApiService.getDriversByManager(managerId!);
    vehicles = await ApiService.getVehicles(managerId!);
    setState(() => isLoading = false);
  }

  void _submitTrip() async {
    if (!_formKey.currentState!.validate() ||
        selectedDriverId == null ||
        selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }
    _formKey.currentState!.save();

    // ✅ Convert input fields into usable data
    double startLatitude = double.tryParse(startLatitudeController.text) ?? 0;
    double startLongitude = double.tryParse(startLongitudeController.text) ?? 0;
    double destLatitude = double.tryParse(destLatitudeController.text) ?? 0;
    double destLongitude = double.tryParse(destLongitudeController.text) ?? 0;
    String destAddress = destAddressController.text.trim();

    final tripData = {
      "driverId": selectedDriverId,
      "vehicleId": selectedVehicleId,
      "startLocation": {
        "latitude": startLatitude,
        "longitude": startLongitude,
      },
      "destination": {
        "latitude": destLatitude,
        "longitude": destLongitude,
        "address": destAddress.isNotEmpty ? destAddress : null,
      },
      "deadline": deadline?.toIso8601String(),
    };

    final success = await TripApiService.createTrip(tripData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip created successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create trip")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Trip")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDriverId,
                      items: drivers.map((driver) {
                        return DropdownMenuItem(
                          value: driver.id,
                          child: Text(driver.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedDriverId = value),
                      decoration:
                          const InputDecoration(labelText: "Assign Driver"),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedVehicleId,
                      items: vehicles.map((vehicle) {
                        return DropdownMenuItem(
                          value: vehicle.id,
                          child: Text(
                              "${vehicle.make} - ${vehicle.licensePlateNumber}"),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedVehicleId = value),
                      decoration:
                          const InputDecoration(labelText: "Assign Vehicle"),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Start Location Fields
                    TextFormField(
                      controller: startLatitudeController,
                      decoration:
                          const InputDecoration(labelText: "Start Latitude"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Enter start latitude" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: startLongitudeController,
                      decoration:
                          const InputDecoration(labelText: "Start Longitude"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Enter start longitude" : null,
                    ),
                    const SizedBox(height: 10),

                    // ✅ Destination Fields
                    TextFormField(
                      controller: destLatitudeController,
                      decoration: const InputDecoration(
                          labelText: "Destination Latitude"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Enter destination latitude" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: destLongitudeController,
                      decoration: const InputDecoration(
                          labelText: "Destination Longitude"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Enter destination longitude" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: destAddressController,
                      decoration: const InputDecoration(
                          labelText: "Destination Address"),
                      validator: (value) =>
                          value!.isEmpty ? "Enter a destination address" : null,
                    ),
                    const SizedBox(height: 10),

                    // ✅ Deadline Picker
                    ListTile(
                      title: Text(deadline == null
                          ? "Select Deadline"
                          : "Deadline: ${DateFormat.yMMMd().format(deadline!)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() => deadline = pickedDate);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // ✅ Submit Button
                    ElevatedButton(
                      onPressed: _submitTrip,
                      child: const Text("Create Trip"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
