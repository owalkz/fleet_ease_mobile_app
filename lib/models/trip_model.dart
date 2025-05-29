import 'vehicle_model.dart';
import 'driver_model.dart';

class TripModel {
  final String id;
  final String managerId;
  final String driverId;
  final String driverName;
  final String driverEmail;
  final String vehicleId;
  final String vehicleMake;
  final String vehicleModel;
  final String licensePlateNumber;
  final LocationModel startLocation;
  final LocationModel? endLocation;
  final DestinationModel destination;
  final DateTime deadline;
  final DateTime? startTime;
  final DateTime? endTime;
  final double distanceTraveled;
  final List<SpeedLog> speedLogs;
  final String status;
  final VehicleModel? vehicle;
  final DriverModel? driver;

  TripModel({
    required this.id,
    required this.managerId,
    required this.driverId,
    required this.driverName,
    required this.driverEmail,
    required this.vehicleId,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.licensePlateNumber,
    required this.startLocation,
    this.endLocation,
    required this.destination,
    required this.deadline,
    this.startTime,
    this.endTime,
    required this.distanceTraveled,
    required this.speedLogs,
    required this.status,
    this.vehicle,
    this.driver,
  });

  // ✅ Convert JSON to TripModel
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json["_id"] ?? "",
      managerId: json["managerId"] ?? "",
      driverId: json["driverId"]?["_id"] ?? "",
      driverName: json["driverId"]?["name"] ?? "Unknown",
      driverEmail: json["driverId"]?["emailAddress"] ?? "Unknown",
      vehicleId: json["vehicleId"]?["_id"] ?? "",
      vehicleMake: json["vehicleId"]?["make"] ?? "Unknown",
      vehicleModel: json["vehicleId"]?["model"] ?? "Unknown",
      licensePlateNumber: json["vehicleId"]?["licensePlateNumber"] ?? "Unknown",
      startLocation: LocationModel.fromJson(json["startLocation"]),
      endLocation: json["endLocation"] != null
          ? LocationModel.fromJson(json["endLocation"])
          : null,
      destination: DestinationModel.fromJson(json["destination"]),
      deadline: DateTime.parse(json["deadline"]),
      startTime:
          json["startTime"] != null ? DateTime.parse(json["startTime"]) : null,
      endTime: json["endTime"] != null ? DateTime.parse(json["endTime"]) : null,
      distanceTraveled: (json["distanceTraveled"] ?? 0).toDouble(),
      speedLogs: (json["speedLogs"] as List?)
              ?.map((log) => SpeedLog.fromJson(log))
              .toList() ??
          [],
      status: json["status"] ?? "pending",
      vehicle: json["vehicle"] != null
          ? VehicleModel.fromJson(json["vehicle"])
          : null,
      driver:
          json["driver"] != null ? DriverModel.fromJson(json["driver"]) : null,
    );
  }

  // ✅ Convert TripModel to JSON
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "managerId": managerId,
      "driverId": driverId,
      "driver": {"name": driverName, "emailAddress": driverEmail},
      "vehicleId": vehicleId,
      "vehicle": {
        "make": vehicleMake,
        "model": vehicleModel,
        "licensePlateNumber": licensePlateNumber,
      },
      "startLocation": startLocation.toJson(),
      "endLocation": endLocation?.toJson(),
      "destination": destination.toJson(),
      "deadline": deadline.toIso8601String(),
      "startTime": startTime?.toIso8601String(),
      "endTime": endTime?.toIso8601String(),
      "distanceTraveled": distanceTraveled,
      "speedLogs": speedLogs.map((log) => log.toJson()).toList(),
      "status": status,
      "vehicle": vehicle?.toJson(),
      "driver": driver?.toJson(),
    };
  }
}

// ✅ Model for Start & End Locations
class LocationModel {
  final double latitude;
  final double longitude;

  LocationModel({required this.latitude, required this.longitude});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {"latitude": latitude, "longitude": longitude};
  }
}

// ✅ Model for Destination
class DestinationModel {
  final double latitude;
  final double longitude;
  final String? address;

  DestinationModel(
      {required this.latitude, required this.longitude, this.address});

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
      address: json["address"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
    };
  }
}

// ✅ Model for Speed Logs
class SpeedLog {
  final DateTime timestamp;
  final double speed;
  final double? latitude;
  final double? longitude;
  final String eventType;

  SpeedLog({
    required this.timestamp,
    required this.speed,
    this.latitude,
    this.longitude,
    required this.eventType,
  });

  factory SpeedLog.fromJson(Map<String, dynamic> json) {
    return SpeedLog(
      timestamp: DateTime.parse(json["timestamp"]),
      speed: (json["speed"] ?? 0).toDouble(),
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      eventType: json["eventType"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "timestamp": timestamp.toIso8601String(),
      "speed": speed,
      "latitude": latitude,
      "longitude": longitude,
      "eventType": eventType,
    };
  }
}
