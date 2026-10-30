import 'package:mobile/core/api_client.dart';
import 'package:mobile/core/parsing.dart';
import 'package:mobile/data/models/assignment.dart';
import 'package:mobile/data/models/workout_session.dart';
import 'package:mobile/data/repositories/pagination_helper.dart';

/// Abstraction over assignments + workout sessions.
abstract class TrainRepository {
  Future<List<Assignment>> assignments();

  Future<List<WorkoutSessionModel>> sessions();

  Future<WorkoutSessionModel> createSession({
    required Object? assignmentId,
    required DateTime startedAt,
    DateTime? completedAt,
    String? notes,
    required List<Map<String, dynamic>> sets,
  });

  Future<WorkoutSessionModel> updateSession(
    Object? sessionId, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
    List<Map<String, dynamic>>? sets,
  });

  Future<bool> deleteSession(Object? sessionId);
}

class ApiTrainRepository implements TrainRepository {
  ApiTrainRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Assignment>> assignments() =>
      fetchAssignmentPages(_client, '/trainee/assignments');

  @override
  Future<List<WorkoutSessionModel>> sessions() async {
    final all = <WorkoutSessionModel>[];
    var page = 1;
    while (true) {
      final body = await _client.get(
        '/trainee/sessions',
        query: {'per_page': '50', 'page': '$page'},
      );
      final entries = body is List
          ? body
          : body is Map && body['data'] is List
          ? body['data'] as List
          : [];
      all.addAll(mapList(entries, WorkoutSessionModel.fromJson));
      final lastPage = _lastPage(body);
      if (lastPage == null || page >= lastPage || page >= 10) break;
      page++;
    }
    return all;
  }

  int? _lastPage(dynamic body) {
    if (body is! Map) return null;
    final meta = body['meta'] is Map ? body['meta'] as Map : null;
    final raw = meta?['last_page'];
    return raw is num
        ? raw.toInt()
        : raw is String
        ? int.tryParse(raw)
        : null;
  }

  @override
  Future<WorkoutSessionModel> createSession({
    required Object? assignmentId,
    required DateTime startedAt,
    DateTime? completedAt,
    String? notes,
    required List<Map<String, dynamic>> sets,
  }) async {
    final payload = buildSessionPayload(
      assignmentId: assignmentId,
      startedAt: startedAt,
      completedAt: completedAt,
      notes: notes,
      sets: sets,
    );
    final body = await _client.post('/trainee/sessions', body: payload);
    return WorkoutSessionModel.fromJson(_dataOf(body));
  }

  @override
  Future<WorkoutSessionModel> updateSession(
    Object? sessionId, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
    List<Map<String, dynamic>>? sets,
  }) async {
    final payload = <String, dynamic>{
      if (startedAt != null) 'started_at': startedAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt.toIso8601String(),
      'notes': ?notes,
      'sets': ?sets,
    };
    final body = await _client.patch(
      '/trainee/sessions/$sessionId',
      body: payload,
    );
    return WorkoutSessionModel.fromJson(_dataOf(body));
  }

  @override
  Future<bool> deleteSession(Object? sessionId) async {
    await _client.delete('/trainee/sessions/$sessionId');
    return true;
  }

  dynamic _dataOf(dynamic body) =>
      body is Map && body.containsKey('data') ? body['data'] : body;
}
