class TripSummaryData {
  final DateTime date;
  final int tripCount;
  final double distance;

  TripSummaryData({
    required this.date,
    required this.tripCount,
    required this.distance,
  });

  factory TripSummaryData.fromJson(Map<String, dynamic> json) {
    return TripSummaryData(
      date: DateTime.parse(json['date']),
      tripCount: json['tripCount'],
      distance: (json['distance'] as num).toDouble(),
    );
  }
}
