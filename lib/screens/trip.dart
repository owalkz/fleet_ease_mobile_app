import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:fleet_ease/utils/trip_service.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  String? tripId;
  bool isTracking = false;

  Future<void> checkAndRequestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }
  }

  Future<Position?> getCurrentLocation() async {
    await checkAndRequestLocationPermission();
    return await Geolocator.getCurrentPosition();
  }

  void startTrip() async {
    Position? position = await getCurrentLocation();
    if (position == null) return;

    var response = await TripService.startTrip("67ab41b9e9bbf8b33c93171d",
        "67a99fb529f898638acc9a5d", position.latitude, position.longitude);
    if (response != null) {
      setState(() {
        tripId = SharedPrefsHelper.getTripId();
        isTracking = true;
      });

      // Ensure background service is running
      final service = FlutterBackgroundService();
      if (!(await service.isRunning())) {
        await service.startService();
      }
    }
  }

  void endTrip() async {
    print(tripId);
    if (tripId == null) return;
    await TripService.endTrip(tripId!);

    setState(() {
      isTracking = false;
      tripId = null;
    });

    // Stop background tracking service
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Tracking")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: isTracking ? null : startTrip,
            child: const Text("Start Trip"),
          ),
          ElevatedButton(
            onPressed:
                isTracking ? null : null, // No need for manual updates now
            child: const Text("Update Location (Auto)"),
          ),
          ElevatedButton(
            onPressed: isTracking ? endTrip : endTrip,
            child: const Text("End Trip"),
          ),
        ],
      ),
    );
  }
}
