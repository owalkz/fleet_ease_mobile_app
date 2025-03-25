import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fleet_ease/models/driver_model.dart';
import 'package:fleet_ease/utils/secure_storage.dart';

class DriverApiService {
  static const String baseUrl =
      "https://fleet-ease-backend.vercel.app/api/drivers";

  // ✅ Helper function to get Bearer Token
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await SecureStorageService().getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ✅ Fetch all drivers under a manager
  static Future<List<DriverModel>> getDriversByManager(String managerId) async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse("$baseUrl/$managerId"), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => DriverModel.fromJson(data)).toList();
      } else {
        throw Exception("Failed to load drivers");
      }
    } catch (e) {
      print("Error fetching drivers: $e");
      return [];
    }
  }

  // ✅ Fetch available drivers (those who are currently not assigned)
  static Future<List<DriverModel>> getAvailableDrivers() async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse("$baseUrl/available"), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => DriverModel.fromJson(data)).toList();
      } else {
        throw Exception("Failed to fetch available drivers");
      }
    } catch (e) {
      print("Error fetching available drivers: $e");
      return [];
    }
  }

  // ✅ Fetch unassigned drivers (drivers who have no manager yet)
  static Future<List<DriverModel>> getUnassignedDrivers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => DriverModel.fromJson(data)).toList();
      } else {
        throw Exception("Failed to fetch unassigned drivers");
      }
    } catch (e) {
      print("Error fetching unassigned drivers: $e");
      return [];
    }
  }

  // ✅ Assign Driver to Manager
  static Future<bool> addDriverToCompany(String driverId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/add"),
        headers: headers,
        body: jsonEncode({"driverId": driverId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error assigning driver: $e");
      return false;
    }
  }

  // ✅ Remove Driver from Manager's Company
  static Future<bool> removeDriver(String driverId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/remove"),
        headers: headers,
        body: jsonEncode({"driverId": driverId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error removing driver: $e");
      return false;
    }
  }

  // ✅ Fetch the assigned vehicle for a driver
  static Future<Map<String, dynamic>?> getDriverVehicle(String driverId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
          Uri.parse("$baseUrl/assigned-vehicle/$driverId"),
          headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("message") &&
            data["message"] == "No vehicle assigned") {
          return null;
        }
        return data;
      } else {
        throw Exception("Failed to fetch assigned vehicle");
      }
    } catch (e) {
      print("Error fetching assigned vehicle: $e");
      return null;
    }
  }
}
