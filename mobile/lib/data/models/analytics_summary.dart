import '../../core/parsing.dart';

/// Aggregate analytics for a date range (P4 backend), with explicit
/// `has_data` flags — missing data is never faked as zeros in the UI.
class AnalyticsSummary {
  const AnalyticsSummary({
    required this.from,
    required this.to,
    required this.workouts,
    required this.cardio,
    required this.body,
  });

  final DateTime? from;
  final DateTime? to;
  final WorkoutAnalytics workouts;
  final CardioAnalytics cardio;
  final BodyAnalytics body;

  factory AnalyticsSummary.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('analytics');
    return AnalyticsSummary(
      from: parseDate(raw['from']),
      to: parseDate(raw['to']),
      workouts: WorkoutAnalytics.fromJson(raw['workouts']),
      cardio: CardioAnalytics.fromJson(raw['cardio']),
      body: BodyAnalytics.fromJson(raw['body']),
    );
  }
}

class WorkoutAnalytics {
  const WorkoutAnalytics({
    required this.hasData,
    this.sessions = 0,
    this.completedSessions = 0,
    this.sets = 0,
    this.completedSets = 0,
    this.reps = 0,
    this.volumeKg = 0,
    this.weekly = const [],
  });

  final bool hasData;
  final int sessions;
  final int completedSessions;
  final int sets;
  final int completedSets;
  final int reps;
  final double volumeKg;
  final List<WorkoutWeek> weekly;

  factory WorkoutAnalytics.fromJson(dynamic raw) {
    if (raw is! Map) return const WorkoutAnalytics(hasData: false);
    return WorkoutAnalytics(
      hasData: parseBool(raw['has_data']),
      sessions: parseInt(raw['sessions']) ?? 0,
      completedSessions: parseInt(raw['completed_sessions']) ?? 0,
      sets: parseInt(raw['sets']) ?? 0,
      completedSets: parseInt(raw['completed_sets']) ?? 0,
      reps: parseInt(raw['reps']) ?? 0,
      volumeKg: parseDecimal(raw['volume_kg']) ?? 0,
      weekly: mapList(raw['weekly'], WorkoutWeek.fromJson),
    );
  }
}

class WorkoutWeek {
  const WorkoutWeek({
    required this.weekStart,
    this.sessions = 0,
    this.completedSessions = 0,
    this.sets = 0,
    this.completedSets = 0,
    this.reps = 0,
    this.volumeKg = 0,
  });

  final DateTime weekStart;
  final int sessions;
  final int completedSessions;
  final int sets;
  final int completedSets;
  final int reps;
  final double volumeKg;

  factory WorkoutWeek.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('workout week');
    final start = parseDate(raw['week_start']);
    if (start == null) throw const FormatException('week_start');
    return WorkoutWeek(
      weekStart: start,
      sessions: parseInt(raw['sessions']) ?? 0,
      completedSessions: parseInt(raw['completed_sessions']) ?? 0,
      sets: parseInt(raw['sets']) ?? 0,
      completedSets: parseInt(raw['completed_sets']) ?? 0,
      reps: parseInt(raw['reps']) ?? 0,
      volumeKg: parseDecimal(raw['volume_kg']) ?? 0,
    );
  }
}

class CardioAnalytics {
  const CardioAnalytics({
    required this.hasData,
    this.sessions = 0,
    this.durationSeconds = 0,
    this.distanceKm = 0,
    this.weekly = const [],
  });

  final bool hasData;
  final int sessions;
  final int durationSeconds;
  final double distanceKm;
  final List<CardioWeek> weekly;

  factory CardioAnalytics.fromJson(dynamic raw) {
    if (raw is! Map) return const CardioAnalytics(hasData: false);
    return CardioAnalytics(
      hasData: parseBool(raw['has_data']),
      sessions: parseInt(raw['sessions']) ?? 0,
      durationSeconds: parseInt(raw['duration_seconds']) ?? 0,
      distanceKm: parseDecimal(raw['distance_km']) ?? 0,
      weekly: mapList(raw['weekly'], CardioWeek.fromJson),
    );
  }
}

class CardioWeek {
  const CardioWeek({
    required this.weekStart,
    this.sessions = 0,
    this.durationSeconds = 0,
    this.distanceKm = 0,
  });

  final DateTime weekStart;
  final int sessions;
  final int durationSeconds;
  final double distanceKm;

  factory CardioWeek.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('cardio week');
    final start = parseDate(raw['week_start']);
    if (start == null) throw const FormatException('week_start');
    return CardioWeek(
      weekStart: start,
      sessions: parseInt(raw['sessions']) ?? 0,
      durationSeconds: parseInt(raw['duration_seconds']) ?? 0,
      distanceKm: parseDecimal(raw['distance_km']) ?? 0,
    );
  }
}

class BodyAnalytics {
  const BodyAnalytics({required this.hasData, this.series = const []});

  final bool hasData;
  final List<BodyPoint> series;

  factory BodyAnalytics.fromJson(dynamic raw) {
    if (raw is! Map) return const BodyAnalytics(hasData: false);
    return BodyAnalytics(
      hasData: parseBool(raw['has_data']),
      series: mapList(raw['series'], BodyPoint.fromJson),
    );
  }
}

/// One measured body data point; values are individually nullable.
class BodyPoint {
  const BodyPoint({
    required this.measuredOn,
    this.weightKg,
    this.bodyFatPercentage,
    this.waistCm,
    this.chestCm,
    this.armCm,
  });

  final DateTime measuredOn;
  final double? weightKg;
  final double? bodyFatPercentage;
  final double? waistCm;
  final double? chestCm;
  final double? armCm;

  factory BodyPoint.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('body point');
    return BodyPoint(
      measuredOn: parseDate(raw['measured_on']) ?? DateTime.now().toUtc(),
      weightKg: parseDecimal(raw['weight_kg']),
      bodyFatPercentage: parseDecimal(raw['body_fat_percentage']),
      waistCm: parseDecimal(raw['waist_cm']),
      chestCm: parseDecimal(raw['chest_cm']),
      armCm: parseDecimal(raw['arm_cm']),
    );
  }
}
