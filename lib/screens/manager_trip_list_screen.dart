import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_ease/api/trip_functions.dart';
import 'package:fleet_ease/models/trip_model.dart';
import 'package:fleet_ease/screens/add_trip_screen.dart';
import 'package:fleet_ease/screens/edit_trip_screen.dart';

class TripListScreen extends ConsumerStatefulWidget {
  const TripListScreen({super.key});

  @override
  ConsumerState<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends ConsumerState<TripListScreen> {
  List<TripModel> trips = [];
  bool isLoading = true;
  String? managerId = SharedPrefsHelper.getUserId();

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    setState(() => isLoading = true);
    final fetchedTrips = await TripApiService.getManagerTrips(managerId!);
    setState(() {
      trips = fetchedTrips;
      isLoading = false;
    });
  }

  void deleteTrip(String tripId) async {
    bool success = await TripApiService.deleteTrip(tripId);
    if (success) fetchTrips(); // Refresh after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Management")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trips.isEmpty
              ? const Center(child: Text("No trips available"))
              : ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return ExpansionTile(
                      title: Text("Trip #${index + 1} - ${trip.status}"),
                      subtitle: Text("Driver: ${trip.driverName}"),
                      children: [
                        ListTile(
                          title: Text("Vehicle: ${trip.licensePlateNumber}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Destination: ${trip.destination.address}"),
                              Text("Deadline: ${trip.deadline}"),
                              Text("Status: ${trip.status}"),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "edit") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditTripScreen(trip: trip)),
                                );
                              } else if (value == "delete") {
                                deleteTrip(trip.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: "edit",
                                child: Text("Edit Trip"),
                              ),
                              const PopupMenuItem(
                                value: "delete",
                                child: Text("Delete Trip"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTripScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
