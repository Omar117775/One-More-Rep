import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Compile-time override: `--dart-define=OMR_API_BASE_URL=…`
const _envBaseUrl = String.fromEnvironment('OMR_API_BASE_URL');

/// Resolves the default API base URL based on the runtime platform:
/// - Explicit dart-define override wins.
/// - Flutter Web → localhost.
/// - Android emulator → 10.0.2.2 (host loopback alias).
String get defaultApiBaseUrl {
  if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
  if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
  // Android emulator uses 10.0.2.2 to reach host; physical devices need LAN IP.
  return 'http://10.0.2.2:8000/api/v1';
}

/// Thin JSON REST client over [http.Client] with bearer-token auth,
/// request timeouts and typed [ApiException] parsing.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _http = client ?? http.Client(),
      baseUrl = (baseUrl ?? defaultApiBaseUrl).trim();

  final http.Client _http;
  String baseUrl;

  /// In-memory bearer token; set after sign-in, cleared at sign-out.
  String? authToken;

  Duration timeout = const Duration(seconds: 15);

  Uri _uri(String path, Map<String, String>? query) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse(
      '$baseUrl/$normalizedPath',
    ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);
  }

  bool get hasToken => authToken?.trim().isNotEmpty == true;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _execute(() => _http.get(_uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, {Object? body}) => _execute(
    () => _http.post(
      _uri(path, null),
      headers: _headers(withJson: true),
      body: jsonEncode(body ?? {}),
    ),
  );

  Future<dynamic> patch(String path, {Object? body}) => _execute(
    () => _http.patch(
      _uri(path, null),
      headers: _headers(withJson: true),
      body: jsonEncode(body ?? {}),
    ),
  );

  Future<dynamic> delete(String path) =>
      _execute(() => _http.delete(_uri(path, null), headers: _headers()));

  Map<String, String> _headers({bool withJson = false}) {
    final headers = {'Accept': 'application/json'};
    if (hasToken) headers['Authorization'] = 'Bearer $authToken';
    if (withJson) headers['Content-Type'] = 'application/json';
    return headers;
  }

  Future<dynamic> _execute(Future<http.Response> Function() send) async {
    http.Response response;
    try {
      response = await send().timeout(timeout);
    } on TimeoutException {
      throw ApiException.network('Request timed out. Check the API base URL.');
    } catch (e) {
      throw ApiException.network(
        'Could not reach the API. Check the API base URL and network.',
      );
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _mapError(response, decoded);
    }
    return decoded;
  }

  ApiException _mapError(http.Response response, dynamic decoded) {
    final message = decoded is Map && decoded['message'] is String
        ? decoded['message'] as String
        : 'Request failed (${response.statusCode})';
    final errors = <String, List<String>>{};
    if (decoded is Map && decoded['errors'] is Map) {
      (decoded['errors'] as Map).forEach((key, value) {
        if (key is String && value is List) {
          errors[key] = value.whereType<String>().toList();
        }
      });
    }
    return ApiException.server(
      message: message,
      statusCode: response.statusCode,
      fieldErrors: errors,
    );
  }
}
