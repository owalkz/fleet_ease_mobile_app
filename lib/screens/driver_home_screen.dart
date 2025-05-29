import 'package:flutter/material.dart';
import 'package:fleet_ease/api/trip_functions.dart';
import 'package:fleet_ease/models/driver_trip_summary_model.dart';
import 'package:fleet_ease/models/trip_summary_model.dart';
import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:fleet_ease/widgets/driver_widgets/trip_chart.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  List<TripSummaryData> tripData = [];
  DriverTripSummary? summary;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllDriverData();
  }

  Future<void> loadAllDriverData() async {
    setState(() => isLoading = true);
    final driverId = SharedPrefsHelper.getUserId();
    if (driverId == null) return;

    try {
      final summaryData = await TripApiService.fetchDriverTripSummary(driverId);
      final tripDataResponse =
          await TripApiService.getTripSummaryOverTime(driverId);

      setState(() {
        summary = summaryData;
        tripData = tripDataResponse;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading driver dashboard data: $e");
      setState(() => isLoading = false);
    }
  }

  Widget buildStatCard(String title, String value, IconData icon,
      {Color? color}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.blue),
        title: Text(title),
        subtitle: Text(value, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: loadAllDriverData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Trip Summary",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                buildStatCard("Total Trips", "${summary?.totalTrips ?? 0}",
                    Icons.list_alt),
                buildStatCard("Pending Trips", "${summary?.pendingTrips ?? 0}",
                    Icons.pending_actions,
                    color: Colors.orange),
                buildStatCard("Active Trips", "${summary?.activeTrips ?? 0}",
                    Icons.directions_car,
                    color: Colors.blue),
                buildStatCard("Completed Trips",
                    "${summary?.completedTrips ?? 0}", Icons.check_circle,
                    color: Colors.green),
                buildStatCard(
                    "Total Distance",
                    "${summary?.totalDistance.toStringAsFixed(2)} km",
                    Icons.route,
                    color: Colors.purple),
                const SizedBox(height: 10),
                tripData.isEmpty
                    ? const Text("No trip data available.")
                    : TripChart(data: tripData),
              ],
            ),
          );
  }
}
