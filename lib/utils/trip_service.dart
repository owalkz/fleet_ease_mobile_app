import 'dart:convert';
import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TripService {
  static const String baseUrl =
      "https://fleet-ease-backend.vercel.app/api/trips"; // Update this

  // Start a trip
  static Future<Map<String, dynamic>?> startTrip(
      String driverId, String vehicleId, double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/start-trip"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "driverId": driverId,
          "vehicleId": vehicleId,
          "startLocation": {"latitude": lat, "longitude": lon},
        }),
      );
      if (response.statusCode == 201) {
        final res = await jsonDecode(response.body);
        SharedPrefsHelper.saveTripDetails(res["trip"]["_id"]);
        return res;
      }
    } catch (e) {
      print("Error starting trip: $e");
    }
    return null;
  }

  // Update trip location & speed
  static Future<void> updateTrip(String tripId, double speed, double lat,
      double lon, String eventType) async {
    try {
      print("This has been called");
      print(tripId);
      await http.put(
        Uri.parse("$baseUrl/update-trip/$tripId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "speed": speed,
          "latitude": lat,
          "longitude": lon,
          "eventType": eventType
        }),
      );
    } catch (e) {
      print("Error updating trip: $e");
    }
  }

  // End the trip
  static Future<void> endTrip(String tripId) async {
    try {
      SharedPrefsHelper.clearTripDetails();
      await http.put(
        Uri.parse("$baseUrl/end-trip/$tripId"),
        headers: {"Content-Type": "application/json"},
      );
    } catch (e) {
      print("Error ending trip: $e");
    }
  }
}
