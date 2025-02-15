import 'dart:convert';
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
          "startLocation": {"latitude": lat, "longitude": lon}
        }),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error starting trip: $e");
    }
    return null;
  }

  // Update trip location & speed
  static Future<void> updateTrip(
      String tripId, double speed, double lat, double lon) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/update-trip/$tripId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"speed": speed, "latitude": lat, "longitude": lon}),
      );
    } catch (e) {
      print("Error updating trip: $e");
    }
  }

  // End the trip
  static Future<void> endTrip(String tripId) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/end-trip/$tripId"),
        headers: {"Content-Type": "application/json"},
      );
    } catch (e) {
      print("Error ending trip: $e");
    }
  }
}
