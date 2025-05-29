import 'dart:convert';

class DriverModel {
  final String id;
  final String name;
  final String accountType;
  final String emailAddress;
  final bool isAssigned;
  final String accountStatus;
  final DateTime? licenseExpiryDate;
  final String profilePhotoUrl;

  DriverModel({
    required this.id,
    required this.name,
    required this.accountType,
    required this.emailAddress,
    required this.isAssigned,
    required this.accountStatus,
    this.licenseExpiryDate,
    required this.profilePhotoUrl,
  });

  // ✅ Convert JSON to DriverModel (For API response)
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json["_id"],
      name: json["name"],
      accountType: json["accountType"],
      emailAddress: json["emailAddress"],
      isAssigned: json["isAssigned"],
      accountStatus: json["accountStatus"],
      licenseExpiryDate: json["licenseExpiryDate"] != null
          ? DateTime.parse(json["licenseExpiryDate"])
          : null,
      profilePhotoUrl: json["profilePhoto"]["url"] ?? "",
    );
  }

  // ✅ Convert DriverModel to JSON (For API request)
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "accountType": accountType,
      "emailAddress": emailAddress,
      "isAssigned": isAssigned,
      "accountStatus": accountStatus,
      "licenseExpiryDate": licenseExpiryDate?.toIso8601String(),
      "profilePhoto": {
        "url": profilePhotoUrl,
      },
    };
  }

  // ✅ Helper: Convert JSON list to a list of DriverModel
  static List<DriverModel> fromJsonList(String jsonString) {
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((json) => DriverModel.fromJson(json)).toList();
  }
}
