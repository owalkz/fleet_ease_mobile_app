import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fleet_ease/models/trip_model.dart';
import 'package:fleet_ease/utils/secure_storage.dart';

class TripApiService {
  static const String baseUrl =
      "https://fleet-ease-backend.vercel.app/api/trips";

  // ✅ Helper function to get Bearer Token
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await SecureStorageService().getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ✅ Create Trip (Manager assigns a trip to a driver)
  static Future<bool> createTrip(Map<String, dynamic> tripData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/create-trip"),
        headers: headers,
        body: jsonEncode(tripData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error creating trip: $e");
      return false;
    }
  }

  // ✅ Start Trip (Driver starts the assigned trip)
  static Future<bool> startTrip(String tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(Uri.parse("$baseUrl/start-trip/$tripId"),
          headers: headers);

      return response.statusCode == 200;
    } catch (e) {
      print("Error starting trip: $e");
      return false;
    }
  }

  // ✅ Update Trip (Tracking updates, speed, events)
  static Future<bool> updateTrip(String tripId, double speed, double lat,
      double lon, String eventType) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/update-trip/$tripId"),
        headers: headers,
        body: jsonEncode({
          "speed": speed,
          "latitude": lat,
          "longitude": lon,
          "eventType": eventType
        }),
      );
      if (response.statusCode == 200)
        return true;
      else
        return false;
    } catch (e) {
      print("Error updating trip: $e");
      return false;
    }
  }

  // ✅ End Trip (Driver completes the trip)
  static Future<bool> endTrip(String tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse("$baseUrl/end-trip/$tripId"),
          headers: headers);

      return response.statusCode == 200;
    } catch (e) {
      print("Error ending trip: $e");
      return false;
    }
  }

  // ✅ Update Trip Details (Manager modifies trip before start)
  static Future<bool> updateTripDetails(
      String tripId, Map<String, dynamic> updateData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/update/$tripId"),
        headers: headers,
        body: jsonEncode(updateData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating trip details: $e");
      return false;
    }
  }

  // ✅ Delete Trip (Manager deletes a pending trip)
  static Future<bool> deleteTrip(String tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse("$baseUrl/delete/$tripId"),
          headers: headers);

      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting trip: $e");
      return false;
    }
  }

  // ✅ Fetch Trips Assigned to a Manager
  static Future<List<TripModel>> getManagerTrips(String managerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("$baseUrl/manager/$managerId"),
          headers: headers);

      if (response.statusCode == 200) {
        print(response.body);
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => TripModel.fromJson(data)).toList();
      } else {
        throw Exception("Failed to fetch manager trips");
      }
    } catch (e) {
      print("Error fetching manager trips: $e");
      return [];
    }
  }

  // ✅ Fetch Active Trips Assigned to a Driver
  static Future<List<TripModel>> getDriverTrips(String driverId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("$baseUrl/driver/$driverId"),
          headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => TripModel.fromJson(data)).toList();
      } else {
        throw Exception("Failed to fetch driver trips");
      }
    } catch (e) {
      print("Error fetching driver trips: $e");
      return [];
    }
  }

  // ✅ Fetch Completed Trips (Both Driver & Manager)
  static Future<List<TripModel>> getCompletedTrips(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("$baseUrl/completed/$userId"),
          headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => TripModel.fromJson(data)).toList();
      } else {
        throw Exception("Failed to fetch completed trips");
      }
    } catch (e) {
      print("Error fetching completed trips: $e");
      return [];
    }
  }

  // ✅ Fetch Pending Trips for a Manager
  static Future<List<TripModel>> getPendingTrips(String managerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("$baseUrl/pending/$managerId"),
          headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => TripModel.fromJson(data)).toList();
      } else {
        throw Exception("Failed to fetch pending trips");
      }
    } catch (e) {
      print("Error fetching pending trips: $e");
      return [];
    }
  }

  // ✅ Fetch Trips Approaching Deadline (Manager View)
  static Future<List<TripModel>> getTripsApproachingDeadline(
      String managerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/approaching-deadline/$managerId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => TripModel.fromJson(data)).toList();
      } else {
        throw Exception("Failed to fetch approaching deadline trips");
      }
    } catch (e) {
      print("Error fetching trips approaching deadline: $e");
      return [];
    }
  }
}
