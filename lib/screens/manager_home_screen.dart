import 'package:flutter/material.dart';
import 'package:fleet_ease/api/trip_functions.dart';
import 'package:fleet_ease/models/manager_summary_model.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  ManagerSummary? summary;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    final data = await TripApiService.getManagerSummary();
    setState(() {
      summary = data;
      isLoading = false;
    });
  }

  Widget buildStatCard(String label, String value, IconData icon,
      {Color? color}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.blue),
        title: Text(label),
        subtitle: Text(value, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchSummary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text("Fleet Overview",
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 10),
                buildStatCard("Total Drivers", "${summary!.totalDrivers}",
                    Icons.person),
                buildStatCard("Total Vehicles", "${summary!.totalVehicles}",
                    Icons.directions_car),
                buildStatCard("Total Trips", "${summary!.totalTrips}",
                    Icons.list_alt),
                buildStatCard("Active Trips", "${summary!.activeTrips}",
                    Icons.directions_run, color: Colors.orange),
                buildStatCard("Completed Trips", "${summary!.completedTrips}",
                    Icons.check_circle, color: Colors.green),
                buildStatCard("Pending Trips", "${summary!.pendingTrips}",
                    Icons.schedule, color: Colors.grey),
                buildStatCard("Available Vehicles",
                    "${summary!.availableVehicles}", Icons.local_shipping),
                buildStatCard("In Use Vehicles", "${summary!.inUseVehicles}",
                    Icons.local_taxi),
              ],
            ),
          );
  }
}
