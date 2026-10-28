import '../../core/parsing.dart';

/// Cardio history entry (tracked separately from resistance training).
class CardioEntry {
  const CardioEntry({
    required this.id,
    this.traineeId,
    required this.activityType,
    required this.durationSeconds,
    this.distanceKm,
    this.averageHeartRate,
    required this.performedAt,
  });

  final Object? id;
  final Object? traineeId;
  final String activityType;

  /// Duration always in seconds per the API contract; UI presents minutes.
  final int durationSeconds;
  final double? distanceKm;
  final int? averageHeartRate;
  final DateTime? performedAt;

  factory CardioEntry.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('cardio entry');
    return CardioEntry(
      id: raw['id'],
      traineeId: raw['trainee_id'],
      activityType: raw['activity_type']?.toString() ?? '',
      durationSeconds: parseInt(raw['duration_seconds']) ?? 0,
      distanceKm: parseDecimal(raw['distance_km']),
      averageHeartRate: parseInt(raw['average_heart_rate']),
      performedAt: parseDate(raw['performed_at']),
    );
  }
}

/// Payload for POST/PATCH /trainee/cardio.
Map<String, dynamic> buildCardioPayload({
  required String activityType,
  required int durationSeconds,
  double? distanceKm,
  int? averageHeartRate,
  required DateTime performedAt,
}) {
  return {
    'activity_type': activityType,
    'duration_seconds': durationSeconds,
    if (distanceKm != null && distanceKm > 0) 'distance_km': distanceKm,
    if (averageHeartRate != null && averageHeartRate > 0) 'average_heart_rate': averageHeartRate,
    'performed_at': performedAt.toIso8601String(),
  };
}
