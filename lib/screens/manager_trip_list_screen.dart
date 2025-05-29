import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_ease/api/trip_functions.dart';
import 'package:fleet_ease/models/trip_model.dart';
import 'package:fleet_ease/screens/add_trip_screen.dart';
import 'package:fleet_ease/screens/edit_trip_screen.dart';
import 'package:fleet_ease/screens/trip_details_screen.dart';

class TripListScreen extends ConsumerStatefulWidget {
  const TripListScreen({super.key});

  @override
  ConsumerState<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends ConsumerState<TripListScreen> {
  List<TripModel> trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    setState(() => isLoading = true);
    final fetchedTrips = await TripApiService.getManagerTrips();
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
    return Stack(
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : trips.isEmpty
                ? const Center(child: Text("No trips available"))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text("Trip #${index + 1} - ${trip.status}"),
                          subtitle: Text("Driver: ${trip.driverName}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripDetailsScreen(
                                  trip: trip,
                                  userType: "manager",
                                ),
                              ),
                            );
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "edit") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditTripScreen(trip: trip),
                                  ),
                                ).then((_) => fetchTrips());
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
                      );
                    },
                  ),
        // Floating Action Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTripScreen()),
            ).then((_) => fetchTrips()),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
