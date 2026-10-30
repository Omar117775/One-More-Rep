import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/parsing.dart';
import 'package:mobile/data/models/cardio_entry.dart';

/// Abstraction over the cardio history endpoint.
abstract class CardioRepository {
  Future<List<CardioEntry>> list();

  Future<CardioEntry> create({
    required String activityType,
    required int durationSeconds,
    double? distanceKm,
    int? averageHeartRate,
    required DateTime performedAt,
  });

  Future<CardioEntry> update(
    Object? id, {
    required String activityType,
    required int durationSeconds,
    double? distanceKm,
    int? averageHeartRate,
    required DateTime performedAt,
  });

  Future<void> delete(Object? id);
}

class ApiCardioRepository implements CardioRepository {
  ApiCardioRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<CardioEntry>> list() async {
    final all = <CardioEntry>[];
    var page = 1;
    while (true) {
      final body = await _client.get(
        '/trainee/cardio',
        query: {'per_page': '50', 'page': '$page'},
      );
      final entries = body is List
          ? body
          : body is Map && body['data'] is List
          ? body['data'] as List
          : [];
      all.addAll(mapList(entries, CardioEntry.fromJson));
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
  Future<CardioEntry> create({
    required String activityType,
    required int durationSeconds,
    double? distanceKm,
    int? averageHeartRate,
    required DateTime performedAt,
  }) async {
    final body = await _client.post(
      '/trainee/cardio',
      body: buildCardioPayload(
        activityType: activityType,
        durationSeconds: durationSeconds,
        distanceKm: distanceKm,
        averageHeartRate: averageHeartRate,
        performedAt: performedAt,
      ),
    );
    return CardioEntry.fromJson(_dataOf(body));
  }

  @override
  Future<CardioEntry> update(
    Object? id, {
    required String activityType,
    required int durationSeconds,
    double? distanceKm,
    int? averageHeartRate,
    required DateTime performedAt,
  }) async {
    final body = await _client.patch(
      '/trainee/cardio/$id',
      body: buildCardioPayload(
        activityType: activityType,
        durationSeconds: durationSeconds,
        distanceKm: distanceKm,
        averageHeartRate: averageHeartRate,
        performedAt: performedAt,
      ),
    );
    return CardioEntry.fromJson(_dataOf(body));
  }

  @override
  Future<void> delete(Object? id) => _client.delete('/trainee/cardio/$id');

  dynamic _dataOf(dynamic body) =>
      body is Map && body.containsKey('data') ? body['data'] : body;
}
