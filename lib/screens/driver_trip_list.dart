import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fleet_ease/api/trip_functions.dart';
import 'package:fleet_ease/models/trip_model.dart';
import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  List<TripModel> pendingTrips = [];
  List<TripModel> activeTrips = [];
  List<TripModel> completedTrips = [];
  bool isLoading = true;
  String? driverId;

  @override
  void initState() {
    super.initState();
    loadTrips();
  }

  Future<double?> _showMileageInputDialog() async {
    final controller = TextEditingController();
    double? result;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Final Mileage"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "e.g. 18250"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text;
              final parsed = double.tryParse(text);
              if (parsed != null && parsed > 0) {
                result = parsed;
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid mileage")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );

    return result;
  }

  Future<void> loadTrips() async {
    setState(() => isLoading = true);
    driverId = SharedPrefsHelper.getUserId();
    if (driverId == null) {
      setState(() => isLoading = false);
      return;
    }

    final fetchedTrips = await TripApiService.getDriverTrips(driverId!);
    setState(() {
      pendingTrips =
          fetchedTrips.where((trip) => trip.status == "pending").toList();
      activeTrips =
          fetchedTrips.where((trip) => trip.status == "active").toList();
      completedTrips = fetchedTrips
          .where((trip) => trip.status == "completed")
          .toList(); // 👈 Ensure your backend uses "completed"
      isLoading = false;
    });
  }

  void _startTrip(String tripId) async {
    bool success = await TripApiService.startTrip(tripId);
    if (success) {
      await SharedPrefsHelper.saveTripDetails(tripId);
      final service = FlutterBackgroundService();

      if (!(await service.isRunning())) {
        await service.startService();
      }

      loadTrips();
    }
  }

  void _endTrip(String tripId) async {
    double? mileage = await _showMileageInputDialog();

    if (mileage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mileage is required to end the trip.")),
      );
      return;
    }

    bool success = await TripApiService.endTrip(tripId, mileage);
    if (success) {
      await SharedPrefsHelper.clearTripDetails();
      final service = FlutterBackgroundService();
      service.invoke('stopService');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trip ended successfully")),
        );
      }

      loadTrips();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to end trip")),
        );
      }
    }
  }

  void _openNavigation(double latitude, double longitude) async {
    String url = "google.navigation:q=$latitude,$longitude&mode=d";
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open navigation app")),
      );
    }
  }

  Widget _buildTripCard(TripModel trip,
      {required bool isActive, bool isCompleted = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text("Destination: ${trip.destination.address ?? "Unknown"}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Vehicle: ${trip.vehicle?.make ?? "Unknown"} - ${trip.vehicle?.licensePlateNumber ?? "N/A"}"),
            Text("Deadline: ${DateFormat.yMMMd().format(trip.deadline)}"),
            Text("Status: ${trip.status}"),
          ],
        ),
        trailing: isCompleted
            ? null
            : isActive
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.navigation, color: Colors.blue),
                        onPressed: () => _openNavigation(
                            trip.destination.latitude,
                            trip.destination.longitude),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop_circle, color: Colors.red),
                        onPressed: () => _endTrip(trip.id),
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.play_circle, color: Colors.green),
                    onPressed: () => _startTrip(trip.id),
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: loadTrips,
            child: ListView(
              children: [
                if (pendingTrips.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Pending Trips",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...pendingTrips
                      .map((trip) => _buildTripCard(trip, isActive: false)),
                ],
                if (activeTrips.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Active Trips",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...activeTrips
                      .map((trip) => _buildTripCard(trip, isActive: true)),
                ],
                if (completedTrips.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Completed Trips",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...completedTrips.map((trip) =>
                      _buildTripCard(trip, isActive: false, isCompleted: true)),
                ],
                if (pendingTrips.isEmpty &&
                    activeTrips.isEmpty &&
                    completedTrips.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No trips assigned"),
                    ),
                  ),
              ],
            ),
          );
  }
}
