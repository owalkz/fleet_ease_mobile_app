import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fleet_ease/models/trip_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TripDetailsScreen extends StatelessWidget {
  final TripModel trip;
  final String userType; // "manager" or "driver"

  const TripDetailsScreen({
    super.key,
    required this.trip,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 📍 Destination
            _buildDetailTile(
              "Destination",
              trip.destination.address ?? "Unknown Location",
              Icons.location_on,
            ),

            // 🚗 Vehicle
            _buildDetailTile(
              "Vehicle",
              "${trip.vehicleMake ?? "Unknown"} - ${trip.licensePlateNumber ?? "N/A"}",
              Icons.directions_car,
            ),

            // 👤 Driver (Only visible to managers)
            if (userType == "manager")
              _buildDetailTile(
                "Driver",
                "${trip.driverName ?? "Unknown"} (${trip.driverEmail ?? "N/A"})",
                Icons.person,
              ),

            // ⏳ Timeline
            _buildDetailTile(
              "Start Time",
              trip.startTime != null
                  ? DateFormat.yMMMd().add_jm().format(trip.startTime!)
                  : "Not Started",
              Icons.access_time,
            ),
            _buildDetailTile(
              "Deadline",
              DateFormat.yMMMd().add_jm().format(trip.deadline),
              Icons.timer,
            ),
            _buildDetailTile(
              "End Time",
              trip.endTime != null
                  ? DateFormat.yMMMd().add_jm().format(trip.endTime!)
                  : "Ongoing",
              Icons.stop_circle,
            ),

            // 📏 Distance Traveled
            _buildDetailTile(
              "Distance Traveled",
              "${trip.distanceTraveled.toStringAsFixed(2)} km",
              Icons.timeline,
            ),

            // ⚠️ Harsh Events (Braking, Acceleration, Cornering)
            if (trip.speedLogs.isNotEmpty) _buildEventLogs(trip.speedLogs),

            // 🗺 Map Section (Optional)
            if (trip.startLocation.latitude != 0 && trip.endLocation != null)
              _buildMapSection(),
          ],
        ),
      ),
    );
  }

  // 🔹 General Detail Tile
  Widget _buildDetailTile(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  // ⚠️ Harsh Events Log
  Widget _buildEventLogs(List<SpeedLog> logs) {
    List<SpeedLog> events =
        logs.where((log) => log.eventType.isNotEmpty).toList();
    return events.isEmpty
        ? const SizedBox()
        : Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),
                  title: Text("Harsh Driving Events",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...events.map((log) => ListTile(
                      title: Text(log.eventType),
                      subtitle: Text(
                          "${DateFormat.yMMMd().add_jm().format(log.timestamp)}"),
                      leading: const Icon(Icons.speed, color: Colors.orange),
                    )),
              ],
            ),
          );
  }

  Widget _buildMapSection() {
    final LatLng start = LatLng(
      trip.startLocation.latitude,
      trip.startLocation.longitude,
    );

    final LatLng? end = trip.endLocation != null
        ? LatLng(trip.endLocation!.latitude, trip.endLocation!.longitude)
        : null;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: Icon(Icons.map, color: Colors.green),
            title: Text("Trip Route",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: start,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: start,
                      child: const Icon(Icons.location_on,
                          color: Colors.blue, size: 30),
                    ),
                    if (end != null)
                      Marker(
                        point: end,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 30),
                      ),
                  ],
                ),
                if (end != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [start, end],
                        color: Colors.blueAccent,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
