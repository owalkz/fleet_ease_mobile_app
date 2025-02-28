import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:fleet_ease/app_theme.dart';
import 'package:fleet_ease/screens/auth.dart';
import 'package:fleet_ease/utils/trip_service.dart'; // Import trip service
import 'package:fleet_ease/utils/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefsHelper.init();
  await requestNotificationPermission();
  createNotificationChannel();
  await initializeService();
  runApp(const ProviderScope(child: MyApp()));
}

void createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "fleet_tracking_channel", // SAME as in `initializeService`
    "Fleet Tracking",
    description: "This channel is used for trip tracking notifications.",
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  print("Initializing background service...");

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: "fleet_tracking_channel",
      initialNotificationTitle: "FleetEase Tracking",
      initialNotificationContent: "Tracking is active",
      foregroundServiceNotificationId: 1001,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
  print("✅ Background service started!");
}

// iOS background execution
bool onIosBackground(ServiceInstance service) {
  return true;
}

// Function to get current location
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("Location services are disabled.");
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permissions are denied.");
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("Location permissions are permanently denied.");
    return null;
  }

  return await Geolocator.getCurrentPosition();
}

// Background execution for Android & iOS
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print("🚀 onStart function triggered!");

  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      print("⛔ Service stopped manually.");
      service.stopSelf();
    });
  }

  // ✅ Load trip ID at service start
  final prefs = await SharedPrefsHelper.getPreferences();
  String? tripId = prefs.getString(SharedPrefsHelper.keyTripId);
  if (tripId == null) {
    print("❌ No active trip found. Stopping service.");
    service.stopSelf(); // ✅ Stops service if no trip is active
    return;
  }

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    print("⏳ Timer is running...");

    if (service is AndroidServiceInstance &&
        !(await service.isForegroundService())) {
      print("⚠️ Service is not in foreground. Stopping execution.");
      return;
    }

    String? currentTripId = prefs.getString(SharedPrefsHelper.keyTripId);
    print("🔍 Trip ID retrieved: $currentTripId");

    if (currentTripId == null) {
      print("❌ No active trip. Stopping timer.");
      timer.cancel(); // ✅ Stop timer when no active trip
      return;
    }

    Position? position = await getCurrentLocation();
    if (position != null) {
      print("📍 Tracking Position: $position");

      await TripService.updateTrip(
          currentTripId, position.speed, position.latitude, position.longitude);
      print("✅ Trip updated successfully.");
    }
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FleetEase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthScreen(),
    );
  }
}
