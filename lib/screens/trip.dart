import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fleet_ease/utils/trip_service.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});
  @override
  State<TripScreen> createState() {
    return _TripScreenState();
  }
}

class _TripScreenState extends State<TripScreen> {
  String? tripId;
  bool isTracking = false;

  Future<void> checkAndRequestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Notify user to enable location
      print("Location services are disabled.");
      return;
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
          "Location permissions are permanently denied. Please enable manually.");
      return;
    }
  }

  Future<Position?> getCurrentLocation() async {
    await checkAndRequestLocationPermission(); // Ensure permission is granted
    return await Geolocator.getCurrentPosition();
  }

  void startTrip() async {
    Position? position = await getCurrentLocation();
    if (position == null) return;
    print(position);

    var response = await TripService.startTrip(
        "driver123", "vehicle456", position.latitude, position.longitude);
    if (response != null) {
      setState(() {
        tripId = response["trip"]["_id"];
        isTracking = true;
      });
    }
  }

  void updateTrip() async {
    print("clicked");
    // if (tripId == null) return;
    Position? position = await getCurrentLocation();
    if (position == null) return;
    double speed = position.speed * 3.6; // Convert m/s to km/h
    print("The speed is ${speed}");
    await TripService.updateTrip(
        tripId!, speed, position.latitude, position.longitude);
  }

  void endTrip() async {
    if (tripId == null) return;
    await TripService.endTrip(tripId!);
    setState(() {
      isTracking = false;
      tripId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trip Tracking")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: isTracking ? null : startTrip,
            child: Text("Start Trip"),
          ),
          ElevatedButton(
            onPressed: isTracking ? updateTrip : updateTrip,
            child: Text("Update Location"),
          ),
          ElevatedButton(
            onPressed: isTracking ? endTrip : null,
            child: Text("End Trip"),
          ),
        ],
      ),
    );
  }
}
