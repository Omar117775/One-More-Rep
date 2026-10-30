/// Typed API exception surfaced from the ApiClient so repositories and
/// screens can differentiate network/config failures from server errors.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.kind,
    this.statusCode,
    this.fieldErrors = const {},
  });

  /// Transport-level failure (timeout, DNS, connection refused).
  const ApiException.network(this.message)
    : kind = ApiExceptionKind.network,
      statusCode = null,
      fieldErrors = const {};

  const ApiException.server({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  }) : kind = ApiExceptionKind.server;

  final String message;
  final ApiExceptionKind kind;
  final int? statusCode;

  /// 422-style field validation errors keyed by field name.
  final Map<String, List<String>> fieldErrors;

  bool get isNetwork => kind == ApiExceptionKind.network;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidation => statusCode == 422;
  bool get isNotFound => statusCode == 404;

  String get firstFieldError => fieldErrors.isEmpty
      ? message
      : fieldErrors.values.expand((e) => e).join(' ');

  @override
  String toString() =>
      'ApiException(${kind.name}${statusCode != null ? '/$statusCode' : ''}): $message';
}

enum ApiExceptionKind { network, server }
