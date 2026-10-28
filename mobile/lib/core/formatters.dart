import 'package:intl/intl.dart';

/// Locale-aware formatting helpers (Latin digits 'en', Arabic-Indic under 'ar').

NumberFormat _numberFormat(String locale, {int? digits, int minDigits = 0}) {
  return NumberFormat.decimalPatternDigits(
    locale: locale == 'ar' ? 'ar' : 'en',
    decimalDigits: digits,
  );
}

/// Formats a number with up to [maxDigits] decimals, trailing zeros trimmed.
String formatDecimal(double? value, {
  required String locale,
  int maxDigits = 1,
  String fallback = '—',
}) {
  if (value == null) return fallback;
  final format = _numberFormat(locale, digits: maxDigits, minDigits: 0);
  var text = format.format(value);
  if (text.contains(RegExp('[.,]'))) {
    text = text.replaceFirst(RegExp(r'(0+)$'), '').replaceFirst(RegExp(r'[.,]$'), '');
  }
  return text;
}

String formatInteger(num? value, {required String locale, String fallback = '0'}) {
  if (value == null) return fallback;
  return _numberFormat(locale).format(value);
}

String formatDate(DateTime? date, {required String locale}) {
  if (date == null) return '—';
  return DateFormat.yMMMd(locale == 'ar' ? 'ar' : 'en').format(date);
}

DateTime? _stripDate(DateTime d) {
  if (d.isUtc) {
    final local = d.toLocal();
    return local;
  }
  return d;
}

String formatDateTime(DateTime? date, {required String locale}) {
  if (date == null) return '—';
  final localDate = date.isUtc ? _stripDate(date) ?? date : date;
  final fmt = DateFormat.yMMMd(locale == 'ar' ? 'ar' : 'en');
  final time = DateFormat.Hm(locale == 'ar' ? 'ar' : 'en').format(localDate);
  return '${fmt.format(localDate)} · $time';
}

String formatWeekLabel(DateTime date, {required String locale}) =>
    DateFormat.MMMd(locale == 'ar' ? 'ar' : 'en').format(date);

/// Formats seconds as a short human duration: "12h 30m", "45m", "30s".
String formatSecondsCompact(int? seconds, {required String locale}) {
  if (seconds == null || seconds <= 0) return '0m';
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  if (hours > 0) {
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }
  if (minutes > 0) return '${minutes}m';
  return '${seconds}s';
}
