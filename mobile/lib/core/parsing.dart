/// Safe parsing helpers for API payloads where decimals may arrive as
/// strings or numbers and dates as ISO strings or `Y-m-d` strings.
library;

/// Parses a decimal sent as a number or a (possibly quoted) string.
double? parseDecimal(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  if (raw is String) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned) ?? double.tryParse(cleaned.replaceAll(',', '.'));
  }
  return null;
}

int? parseInt(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toInt();
  if (raw is String) {
    final parsed = double.tryParse(raw.trim());
    return parsed?.toInt();
  }
  return null;
}

bool parseBool(Object? raw) {
  if (raw is bool) return raw;
  if (raw is num) return raw != 0;
  if (raw is String) {
    final v = raw.trim().toLowerCase();
    if (v == 'true' || v == '1') return true;
  }
  return false;
}

/// Parses ISO-8601 datetimes as well as plain `Y-m-d` dates.
DateTime? parseDate(Object? raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  if (raw is! String) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;
  // Plain Y-m-d: parse in UTC to avoid TZ shifting the calendar date.
  if (value.length == 10 && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    final parts = value.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }
  return DateTime.tryParse(value.replaceFirst(' ', 'T')) ?? DateTime.tryParse(value);
}

String? formatDateYdm(DateTime? date) {
  if (date == null) return null;
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Safely maps a raw JSON array to typed models; skips malformed entries.
List<R> mapList<R>(dynamic raw, R Function(dynamic) mapper) {
  if (raw is! List) return [];
  final result = <R>[];
  for (final item in raw) {
    try {
      result.add(mapper(item));
    } on FormatException {
      // skip invalid entries rather than failing the whole list
    }
  }
  return result;
}
