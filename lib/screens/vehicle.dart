import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:fleet_ease/api/vehicle_functions.dart';
import 'package:fleet_ease/models/vehicle_model.dart';
import 'package:fleet_ease/screens/add_vehicle_screen.dart';
import 'package:fleet_ease/screens/edit_vehicle_screen.dart';
import 'package:fleet_ease/widgets/driver_widgets/select_driver.dart';

class VehicleListScreen extends ConsumerStatefulWidget {
  final String userType;
  const VehicleListScreen({super.key, required this.userType});

  @override
  ConsumerState<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends ConsumerState<VehicleListScreen> {
  List<VehicleModel> vehicles = [];
  bool isLoading = true;
  String? userId = SharedPrefsHelper.getUserId();
  String? userType = SharedPrefsHelper.getUserAccountType();

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    setState(() => isLoading = true);
    if (userId == null) return;

    final fetchedVehicles = await ApiService.getVehicles(userId!);
    setState(() {
      vehicles = fetchedVehicles;
      isLoading = false;
    });
  }

  void deleteVehicle(String vehicleId) async {
    bool success = await ApiService.deleteVehicle(vehicleId);
    if (success) fetchVehicles();
  }

  void assignDriver(String vehicleId) async {
    String sampleDriverId = "driver123";
    bool success = await ApiService.assignDriver(vehicleId, sampleDriverId);
    if (success) fetchVehicles();
  }

  void unassignDriver(String vehicleId) async {
    bool success = await ApiService.unassignDriver(vehicleId);
    if (success) fetchVehicles();
  }

  void showAssignDriverDialog(String vehicleId) {
    showDialog(
      context: context,
      builder: (context) => AssignDriverDialog(
        vehicleId: vehicleId,
        onDriverAssigned: fetchVehicles,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : vehicles.isEmpty
                ? const Center(child: Text("No vehicles available"))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: vehicle.imageUrl.isNotEmpty
                                ? NetworkImage(vehicle.imageUrl)
                                : const AssetImage('assets/placeholder.png')
                                    as ImageProvider,
                          ),
                          title: Text("${vehicle.make} ${vehicle.model}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: ${vehicle.status}"),
                              if (vehicle.assignedDriverId != null)
                                Text(
                                    "Assigned to: ${vehicle.assignedDriverName}"),
                            ],
                          ),
                          trailing: userType == "manager"
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == "delete") {
                                      deleteVehicle(vehicle.id);
                                    } else if (value == "assign") {
                                      showAssignDriverDialog(vehicle.id);
                                    } else if (value == "unassign") {
                                      unassignDriver(vehicle.id);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: "assign",
                                      child: Text("Assign Driver"),
                                    ),
                                    PopupMenuItem(
                                      value: "unassign",
                                      child: Text("Unassign Driver"),
                                    ),
                                    PopupMenuItem(
                                      value: "delete",
                                      child: Text("Delete Vehicle"),
                                    ),
                                  ],
                                )
                              : null,
                          onTap: () {
                            if (userType == "manager") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditVehicleScreen(vehicle: vehicle),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
        if (userType == "manager")
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddVehicleScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}
