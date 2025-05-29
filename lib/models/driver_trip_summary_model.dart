class DriverTripSummary {
  final int totalTrips;
  final int pendingTrips;
  final int activeTrips;
  final int completedTrips;
  final double totalDistance;

  DriverTripSummary({
    required this.totalTrips,
    required this.pendingTrips,
    required this.activeTrips,
    required this.completedTrips,
    required this.totalDistance,
  });

  factory DriverTripSummary.fromJson(Map<String, dynamic> json) {
    return DriverTripSummary(
      totalTrips: json['totalTrips'],
      pendingTrips: json['pendingTrips'],
      activeTrips: json['activeTrips'],
      completedTrips: json['completedTrips'],
      totalDistance: (json['totalDistance'] as num).toDouble(),
    );
  }
}
