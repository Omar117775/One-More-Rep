import '../../core/parsing.dart';

/// Dated body-measurement record. History is append-only per product rules —
/// create/edit by date, never overwrite other dated records.
class ProgressEntry {
  const ProgressEntry({
    required this.id,
    this.traineeId,
    this.weightKg,
    this.bodyFatPercentage,
    this.waistCm,
    this.chestCm,
    this.armCm,
    required this.measuredOn,
  });

  final Object? id;
  final Object? traineeId;
  final double? weightKg;
  final double? bodyFatPercentage;
  final double? waistCm;
  final double? chestCm;
  final double? armCm;
  final DateTime measuredOn;

  bool get hasAnyMeasurement =>
      weightKg != null ||
      bodyFatPercentage != null ||
      waistCm != null ||
      chestCm != null ||
      armCm != null;

  factory ProgressEntry.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('progress entry');
    final measured = parseDate(raw['measured_on']);
    if (measured == null) throw const FormatException('progress measured_on');
    return ProgressEntry(
      id: raw['id'],
      traineeId: raw['trainee_id'],
      weightKg: parseDecimal(raw['weight_kg']),
      bodyFatPercentage: parseDecimal(raw['body_fat_percentage']),
      waistCm: parseDecimal(raw['waist_cm']),
      chestCm: parseDecimal(raw['chest_cm']),
      armCm: parseDecimal(raw['arm_cm']),
      measuredOn: measured,
    );
  }
}

/// Payload for POST/PATCH /trainee/progress.
Map<String, dynamic> buildProgressPayload({
  required DateTime measuredOn,
  double? weightKg,
  double? bodyFatPercentage,
  double? waistCm,
  double? chestCm,
  double? armCm,
}) {
  final measured = DateTime.utc(
    measuredOn.year,
    measuredOn.month,
    measuredOn.day,
  );
  return {
    'measured_on': formatDateYdm(measured),
    'weight_kg': ?weightKg,
    'body_fat_percentage': ?bodyFatPercentage,
    'waist_cm': ?waistCm,
    'chest_cm': ?chestCm,
    'arm_cm': ?armCm,
  };
}
