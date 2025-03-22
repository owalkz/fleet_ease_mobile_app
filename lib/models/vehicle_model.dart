class VehicleModel {
  VehicleModel({
    required this.id,
    required this.managerId,
    required this.make,
    required this.model,
    required this.licensePlateNumber,
    required this.vin,
    required this.fuelType,
    required this.fuelConsumptionRate,
    required this.mileage,
    required this.latestServiceDate,
    required this.nextServiceMileage,
    required this.inspectionStatus,
    required this.assignedDriverId,
    required this.assignedDriverName, // ✅ Added driver name
    required this.imageName,
    required this.imageUrl,
    required this.serviceDates,
    required this.insuranceExpiryDate,
    required this.status,
  });

  String id;
  String managerId;
  String make;
  String model;
  String licensePlateNumber;
  String vin;
  String fuelType;
  double fuelConsumptionRate;
  int mileage;
  DateTime latestServiceDate;
  int nextServiceMileage;
  bool inspectionStatus;
  String? assignedDriverId;
  String? assignedDriverName; // ✅ Store driver name
  String imageUrl;
  String imageName;
  List<DateTime> serviceDates;
  DateTime insuranceExpiryDate;
  String status;

  // ✅ Convert JSON to VehicleModel
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json["_id"] ?? "",
      managerId: json["managerId"] ?? "",
      make: json["make"] ?? "",
      model: json["model"] ?? "",
      licensePlateNumber: json["licensePlateNumber"] ?? "",
      vin: json["VIN"] ?? "",
      fuelType: json["fuelType"] ?? "Unknown",
      fuelConsumptionRate: (json["fuelConsumptionRate"] ?? 0).toDouble(),
      mileage: json["mileage"] ?? 0,
      latestServiceDate:
          DateTime.tryParse(json["lastServiceDate"] ?? "") ?? DateTime.now(),
      nextServiceMileage: json["nextServiceMileage"] ?? 0,
      inspectionStatus: json["inspectionStatus"] ?? false,
      assignedDriverId: json["assignedDriverId"] is String
          ? json["assignedDriverId"] // Direct ID
          : (json["assignedDriverId"] != null
              ? json["assignedDriverId"]["_id"] // Extract ID from object
              : null),
      assignedDriverName: json["assignedDriverId"] is Map<String, dynamic>
          ? json["assignedDriverId"]["name"] ?? null
          : null, // ✅ Extract name from nested object
      imageUrl: json["image"]?["url"] ?? "",
      imageName: json["image"]?["name"] ?? "",
      serviceDates: (json["serviceDates"] as List?)
              ?.map((date) => DateTime.tryParse(date) ?? DateTime.now())
              .toList() ??
          [],
      insuranceExpiryDate:
          DateTime.tryParse(json["insuranceExpiryDate"] ?? "") ??
              DateTime.now(),
      status: json["status"] ?? "Available",
    );
  }

  // ✅ Convert VehicleModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      "managerId": managerId,
      "make": make,
      "model": model,
      "licensePlateNumber": licensePlateNumber,
      "VIN": vin,
      "fuelType": fuelType,
      "fuelConsumptionRate": fuelConsumptionRate,
      "mileage": mileage,
      "lastServiceDate": latestServiceDate.toIso8601String(),
      "nextServiceMileage": nextServiceMileage,
      "inspectionStatus": inspectionStatus,
      "assignedDriverId": assignedDriverId,
      "assignedDriverName": assignedDriverName, // ✅ Include driver name
      "image": {"url": imageUrl, "name": imageName},
      "serviceDates":
          serviceDates.map((date) => date.toIso8601String()).toList(),
      "insuranceExpiryDate": insuranceExpiryDate.toIso8601String(),
      "status": status,
    };
  }
}
