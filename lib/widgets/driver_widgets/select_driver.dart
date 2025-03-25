import 'package:flutter/material.dart';
import 'package:fleet_ease/api/driver_functions.dart';
import 'package:fleet_ease/api/vehicle_functions.dart';
import 'package:fleet_ease/models/driver_model.dart';

class AssignDriverDialog extends StatefulWidget {
  final String vehicleId;
  final Function onDriverAssigned;

  const AssignDriverDialog({
    super.key,
    required this.vehicleId,
    required this.onDriverAssigned,
  });

  @override
  State<AssignDriverDialog> createState() => _AssignDriverDialogState();
}

class _AssignDriverDialogState extends State<AssignDriverDialog> {
  List<DriverModel> drivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    final fetchedDrivers = await DriverApiService.getAvailableDrivers();
    setState(() {
      drivers = fetchedDrivers;
      isLoading = false;
    });
  }

  void assignDriver(String driverId) async {
    bool success = await ApiService.assignDriver(widget.vehicleId, driverId);
    if (success) {
      widget.onDriverAssigned();
      Navigator.pop(context); // Close modal after assignment
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Assign Driver"),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: double.maxFinite,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300), // ✅ Fix
                child: ListView.builder(
                  shrinkWrap: true, // ✅ Fix
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: driver.profilePhotoUrl.isNotEmpty
                            ? NetworkImage(driver.profilePhotoUrl)
                            : const AssetImage('assets/profile_placeholder.png')
                                as ImageProvider,
                      ),
                      title: Text(driver.name),
                      subtitle: Text(driver.emailAddress),
                      trailing: IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => assignDriver(driver.id),
                      ),
                    );
                  },
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
