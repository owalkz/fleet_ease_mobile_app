import 'package:flutter/material.dart';
import 'package:fleet_ease/api/vehicle_functions.dart';
import 'package:fleet_ease/models/vehicle_model.dart';
import 'package:fleet_ease/utils/shared_preferences.dart';

class DriverVehicleScreen extends StatefulWidget {
  const DriverVehicleScreen({super.key});

  @override
  State<DriverVehicleScreen> createState() => _DriverVehicleScreenState();
}

class _DriverVehicleScreenState extends State<DriverVehicleScreen> {
  VehicleModel? assignedVehicle;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssignedVehicle();
  }

  Future<void> fetchAssignedVehicle() async {
    setState(() => isLoading = true);
    final driverId = SharedPrefsHelper.getUserId();
    if (driverId == null) return;

    final vehicle = await ApiService.getVehicle();
    setState(() {
      assignedVehicle = vehicle;
      isLoading = false;
    });
  }

  Widget buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: vehicle.imageUrl.isNotEmpty
                    ? NetworkImage(vehicle.imageUrl)
                    : const AssetImage("assets/placeholder.png")
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            buildInfoRow("Make & Model", "${vehicle.make} ${vehicle.model}"),
            buildInfoRow("License Plate", vehicle.licensePlateNumber),
            buildInfoRow("Fuel Type", vehicle.fuelType),
            buildInfoRow("Mileage", "${vehicle.mileage} km"),
            buildInfoRow(
                "Fuel Consumption", "${vehicle.fuelConsumptionRate} L/km"),
            buildInfoRow("Status", vehicle.status),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : assignedVehicle == null
            ? const Center(
                child: Text(
                  "No vehicle assigned yet.",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : RefreshIndicator(
                onRefresh: fetchAssignedVehicle,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [buildVehicleCard(assignedVehicle!)],
                ),
              );
  }
}
