import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fleet_ease/api/trip_functions.dart';
import 'package:fleet_ease/api/vehicle_functions.dart';
import 'package:fleet_ease/api/driver_functions.dart';
import 'package:fleet_ease/models/vehicle_model.dart';
import 'package:fleet_ease/models/driver_model.dart';
import 'package:fleet_ease/models/trip_model.dart';

class EditTripScreen extends StatefulWidget {
  final TripModel trip;
  const EditTripScreen({super.key, required this.trip});

  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();

  String? managerId = SharedPrefsHelper.getUserId();
  String? selectedDriverId;
  String? selectedVehicleId;
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  DateTime? deadline;

  bool isLoading = true;
  List<DriverModel> drivers = [];
  List<VehicleModel> vehicles = [];

  @override
  void initState() {
    super.initState();
    selectedDriverId = widget.trip.driverId;
    selectedVehicleId = widget.trip.vehicleId;
    deadline = widget.trip.deadline;

    // ✅ Initialize controllers with existing destination data
    latitudeController.text = widget.trip.destination.latitude.toString();
    longitudeController.text = widget.trip.destination.longitude.toString();
    addressController.text = widget.trip.destination.address ?? "";

    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    drivers = await DriverApiService.getDriversByManager(managerId!);
    vehicles = await ApiService.getVehicles(managerId!);
    setState(() => isLoading = false);
  }

  void _updateTrip() async {
    if (!_formKey.currentState!.validate() ||
        selectedDriverId == null ||
        selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    // ✅ Parse the destination fields
    double latitude = double.tryParse(latitudeController.text) ?? 0;
    double longitude = double.tryParse(longitudeController.text) ?? 0;
    String address = addressController.text.trim();

    final updatedData = {
      "driverId": selectedDriverId,
      "vehicleId": selectedVehicleId,
      "destination": {
        "latitude": latitude,
        "longitude": longitude,
        "address": address.isNotEmpty ? address : null,
      },
      "deadline": deadline?.toIso8601String(),
    };

    final success =
        await TripApiService.updateTripDetails(widget.trip.id, updatedData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip updated successfully!")),
      );
      Navigator.pop(context, true); // ✅ Return success state
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update trip")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Trip")),
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
                    TextFormField(
                      controller: latitudeController,
                      decoration: const InputDecoration(
                          labelText: "Destination Latitude"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Enter latitude" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: longitudeController,
                      decoration: const InputDecoration(
                          labelText: "Destination Longitude"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Enter longitude" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                          labelText: "Destination Address"),
                      validator: (value) =>
                          value!.isEmpty ? "Enter a destination address" : null,
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text(deadline == null
                          ? "Select Deadline"
                          : "Deadline: ${DateFormat.yMMMd().format(deadline!)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: deadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() => deadline = pickedDate);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateTrip,
                      child: const Text("Save Changes"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
