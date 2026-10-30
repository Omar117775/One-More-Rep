import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/parsing.dart';
import 'package:mobile/data/models/assignment.dart';

/// Fetches all pages of a paginated assignment endpoint (hard cap of 10 pages
/// guards against a broken meta payload).
Future<List<Assignment>> fetchAssignmentPages(
  ApiClient client,
  String path,
) async {
  final all = <Assignment>[];
  var page = 1;
  while (true) {
    final body = await client.get(
      path,
      query: {'per_page': '50', 'page': '$page'},
    );
    final entries = _extractEntries(body);
    all.addAll(mapList(entries, Assignment.fromJson));
    final lastPage = _extractLastPage(body);
    if (lastPage == null || page >= lastPage || page >= 10) break;
    page++;
  }
  return all;
}

List<dynamic> _extractEntries(dynamic body) {
  if (body is List) return body;
  if (body is Map && body['data'] is List) return body['data'] as List;
  return [];
}

int? _extractLastPage(dynamic body) {
  if (body is! Map) return null;
  final meta = body['meta'] is Map ? body['meta'] as Map : null;
  final links = body['links'] is Map ? body['links'] as Map : null;
  for (final source in [meta, links]) {
    if (source == null) continue;
    final raw = source['last_page'];
    final value = raw is num
        ? raw.toInt()
        : raw is String
        ? int.tryParse(raw)
        : null;
    if (value != null) return value;
  }
  return null;
}
