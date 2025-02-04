class VehicleModel {
  VehicleModel({
    required this.make,
    required this.licensePlateNumber,
    required this.mileage,
    required this.inspectionStatus,
    required this.latestServiceDate,
    required this.image,
    required this.serviceDates,
  });

  String make;
  String licensePlateNumber;
  int mileage;
  bool inspectionStatus;
  DateTime latestServiceDate;
  String image;
  List<DateTime> serviceDates;
}
