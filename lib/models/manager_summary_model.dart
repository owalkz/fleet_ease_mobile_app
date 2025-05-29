class ManagerSummary {
  final int totalDrivers;
  final int totalVehicles;
  final int totalTrips;
  final int activeTrips;
  final int completedTrips;
  final int pendingTrips;
  final int availableVehicles;
  final int inUseVehicles;

  ManagerSummary({
    required this.totalDrivers,
    required this.totalVehicles,
    required this.totalTrips,
    required this.activeTrips,
    required this.completedTrips,
    required this.pendingTrips,
    required this.availableVehicles,
    required this.inUseVehicles,
  });

  factory ManagerSummary.fromJson(Map<String, dynamic> json) {
    return ManagerSummary(
      totalDrivers: json['totalDrivers'] ?? 0,
      totalVehicles: json['totalVehicles'] ?? 0,
      totalTrips: json['totalTrips'] ?? 0,
      activeTrips: json['activeTrips'] ?? 0,
      completedTrips: json['completedTrips'] ?? 0,
      pendingTrips: json['pendingTrips'] ?? 0,
      availableVehicles: json['availableVehicles'] ?? 0,
      inUseVehicles: json['inUseVehicles'] ?? 0,
    );
  }
}
