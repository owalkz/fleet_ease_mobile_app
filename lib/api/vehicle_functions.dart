import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:fleet_ease/models/vehicle_model.dart';
import 'package:fleet_ease/utils/secure_storage.dart'; // Import token storage

class ApiService {
  static const String baseUrl =
      "https://fleet-ease-backend.vercel.app/api/vehicles";

  // ✅ Helper function to get Bearer Token
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await SecureStorageService().getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ✅ Fetch Vehicles (Manager sees all, Driver sees assigned)
  static Future<List<VehicleModel>> getVehicles(String managerId) async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse("$baseUrl/$managerId"), headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => VehicleModel.fromJson(data)).toList();
      } else {
        throw Exception("Failed to load vehicles");
      }
    } catch (e) {
      print("Error fetching vehicles: $e");
      return [];
    }
  }

  // ✅ Fetch Vehicle (Manager sees all, Driver sees assigned)
  static Future<VehicleModel?> getVehicle() async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse("$baseUrl/vehicle"), headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return VehicleModel.fromJson(jsonData);
      } else {
        throw Exception("Failed to load vehicle");
      }
    } catch (e) {
      print("Error fetching vehicle: $e");
      return null;
    }
  }

  // ✅ Create Vehicle (With Image Upload)
  static Future<bool> createVehicle(
      Map<String, dynamic> vehicleData, File? imageFile) async {
    try {
      var request =
          http.MultipartRequest("POST", Uri.parse("$baseUrl/create-vehicle"));
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Attach vehicle details
      vehicleData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Attach image if provided
      if (imageFile != null) {
        var mimeType = lookupMimeType(imageFile.path);
        request.files.add(await http.MultipartFile.fromPath(
          "file",
          imageFile.path,
          contentType: mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType("image", "jpeg"),
        ));
      }

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print("Error creating vehicle: $e");
      return false;
    }
  }

  // ✅ Update Vehicle (With Image Replacement)
  static Future<bool> updateVehicle(String vehicleId,
      Map<String, dynamic> updatedData, File? imageFile) async {
    try {
      var request =
          http.MultipartRequest("PUT", Uri.parse("$baseUrl/$vehicleId"));
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Attach updated data
      updatedData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Attach new image if provided
      if (imageFile != null) {
        var mimeType = lookupMimeType(imageFile.path);
        request.files.add(await http.MultipartFile.fromPath(
          "file",
          imageFile.path,
          contentType: mimeType != null
              ? MediaType.parse(mimeType)
              : MediaType("image", "jpeg"),
        ));
      }

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating vehicle: $e");
      return false;
    }
  }

  // ✅ Delete Vehicle
  static Future<bool> deleteVehicle(String vehicleId) async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.delete(Uri.parse("$baseUrl/$vehicleId"), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting vehicle: $e");
      return false;
    }
  }

  // ✅ Assign Driver to Vehicle
  static Future<bool> assignDriver(String vehicleId, String driverId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/assign"),
        headers: headers,
        body: jsonEncode({"vehicleId": vehicleId, "driverId": driverId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error assigning driver: $e");
      return false;
    }
  }

  // ✅ Unassign Driver from Vehicle
  static Future<bool> unassignDriver(String vehicleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/unassign"),
        headers: headers,
        body: jsonEncode({"vehicleId": vehicleId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error unassigning driver: $e");
      return false;
    }
  }
}
