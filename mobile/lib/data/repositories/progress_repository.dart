import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/parsing.dart';
import 'package:mobile/data/models/progress_entry.dart';

/// Abstraction over the P4 progress (body measurement) endpoint.
abstract class ProgressRepository {
  Future<List<ProgressEntry>> list();

  Future<ProgressEntry> create({
    required DateTime measuredOn,
    double? weightKg,
    double? bodyFatPercentage,
    double? waistCm,
    double? chestCm,
    double? armCm,
  });

  Future<ProgressEntry> update(
    Object? id, {
    DateTime? measuredOn,
    double? weightKg,
    double? bodyFatPercentage,
    double? waistCm,
    double? chestCm,
    double? armCm,
  });

  Future<void> delete(Object? id);
}

class ApiProgressRepository implements ProgressRepository {
  ApiProgressRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ProgressEntry>> list() async {
    final all = <ProgressEntry>[];
    var page = 1;
    while (true) {
      final body = await _client.get(
        '/trainee/progress',
        query: {'per_page': '50', 'page': '$page'},
      );
      final entries = body is List
          ? body
          : body is Map && body['data'] is List
          ? body['data'] as List
          : [];
      all.addAll(mapList(entries, ProgressEntry.fromJson));
      final meta = body is Map && body['meta'] is Map
          ? body['meta'] as Map
          : null;
      final raw = meta?['last_page'];
      final lastPage = raw is num
          ? raw.toInt()
          : raw is String
          ? int.tryParse(raw)
          : null;
      if (lastPage == null || page >= lastPage || page >= 10) break;
      page++;
    }
    return all;
  }

  @override
  Future<ProgressEntry> create({
    required DateTime measuredOn,
    double? weightKg,
    double? bodyFatPercentage,
    double? waistCm,
    double? chestCm,
    double? armCm,
  }) async {
    final body = await _client.post(
      '/trainee/progress',
      body: buildProgressPayload(
        measuredOn: measuredOn,
        weightKg: weightKg,
        bodyFatPercentage: bodyFatPercentage,
        waistCm: waistCm,
        chestCm: chestCm,
        armCm: armCm,
      ),
    );
    return ProgressEntry.fromJson(_dataOf(body));
  }

  @override
  Future<ProgressEntry> update(
    Object? id, {
    DateTime? measuredOn,
    double? weightKg,
    double? bodyFatPercentage,
    double? waistCm,
    double? chestCm,
    double? armCm,
  }) async {
    // Update is a full replacement of the editable measurement values: an
    // explicit null clears a field, while omitted keys would silently keep the
    // previous value. The form validates that at least one value remains.
    final payload = <String, dynamic>{
      if (measuredOn != null)
        'measured_on': formatDateYdm(
          DateTime.utc(measuredOn.year, measuredOn.month, measuredOn.day),
        ),
      'weight_kg': weightKg,
      'body_fat_percentage': bodyFatPercentage,
      'waist_cm': waistCm,
      'chest_cm': chestCm,
      'arm_cm': armCm,
    };
    final body = await _client.patch('/trainee/progress/$id', body: payload);
    return ProgressEntry.fromJson(_dataOf(body));
  }

  @override
  Future<void> delete(Object? id) => _client.delete('/trainee/progress/$id');

  dynamic _dataOf(dynamic body) =>
      body is Map && body.containsKey('data') ? body['data'] : body;
}
