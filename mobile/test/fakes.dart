import 'package:mobile/data/models/analytics_summary.dart';
import 'package:mobile/data/models/assignment.dart';
import 'package:mobile/data/models/cardio_entry.dart';
import 'package:mobile/data/models/progress_entry.dart';
import 'package:mobile/data/models/workout_session.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/repositories/analytics_repository.dart';
import 'package:mobile/data/repositories/cardio_repository.dart';
import 'package:mobile/data/repositories/progress_repository.dart';
import 'package:mobile/data/repositories/train_repository.dart';

/// Simple in-memory fakes for repositories used in widget tests.
class FakeTrainRepository implements TrainRepository {
  FakeTrainRepository({
    this.assignmentsToReturn = const [],
    this.sessionsToReturn = const [],
  });

  List<Assignment> assignmentsToReturn;
  List<WorkoutSessionModel> sessionsToReturn;
  Object? lastUpdatedSessionId;
  String? lastUpdateNotes;
  List<Map<String, dynamic>>? lastUpdateSets;
  DateTime? lastUpdateCompletedAt;

  @override
  Future<List<Assignment>> assignments() async => assignmentsToReturn;

  @override
  Future<List<WorkoutSessionModel>> sessions() async => sessionsToReturn;

  @override
  Future<WorkoutSessionModel> createSession({
    required Object? assignmentId,
    required DateTime startedAt,
    DateTime? completedAt,
    String? notes,
    required List<Map<String, dynamic>> sets,
  }) => throw UnimplementedError();

  @override
  Future<bool> deleteSession(Object? sessionId) async => true;

  @override
  Future<WorkoutSessionModel> updateSession(
    Object? sessionId, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
    List<Map<String, dynamic>>? sets,
  }) async {
    lastUpdatedSessionId = sessionId;
    lastUpdateNotes = notes;
    lastUpdateSets = sets;
    lastUpdateCompletedAt = completedAt;
    WorkoutSessionModel? existing;
    for (final session in sessionsToReturn) {
      if (session.id == sessionId) existing = session;
    }
    final updatedSets = sets == null
        ? existing?.sets ?? const <SessionSet>[]
        : [
            for (final raw in sets)
              SessionSet(
                id: raw['id'],
                exerciseId: raw['exercise_id'],
                setNumber: (raw['set_number'] as num?)?.toInt() ?? 0,
                weightKg: (raw['weight_kg'] as num?)?.toDouble(),
                reps: (raw['reps'] as num?)?.toInt() ?? 0,
                isCompleted: raw['is_completed'] as bool? ?? true,
                exercise: _exerciseFor(existing, raw['exercise_id']),
              ),
          ];
    final updated = WorkoutSessionModel(
      id: sessionId,
      workoutAssignmentId: existing?.workoutAssignmentId,
      traineeId: existing?.traineeId,
      startedAt: startedAt ?? existing?.startedAt,
      completedAt: completedAt ?? existing?.completedAt,
      notes: notes ?? existing?.notes,
      sets: updatedSets,
    );
    sessionsToReturn = [
      for (final session in sessionsToReturn)
        if (session.id == sessionId) updated else session,
    ];
    return updated;
  }

  ExerciseInfo _exerciseFor(WorkoutSessionModel? session, Object? exerciseId) {
    for (final set in session?.sets ?? const <SessionSet>[]) {
      if (set.exerciseId == exerciseId) return set.exercise;
    }
    return ExerciseInfo(id: exerciseId);
  }
}

class FakeAnalyticsRepository implements AnalyticsRepository {
  FakeAnalyticsRepository({this.summary});

  AnalyticsSummary? summary;

  @override
  Future<AnalyticsSummary> fetch({
    required DateTime from,
    required DateTime to,
  }) async =>
      summary ??
      const AnalyticsSummary(
        from: null,
        to: null,
        workouts: WorkoutAnalytics(hasData: false),
        cardio: CardioAnalytics(hasData: false),
        body: BodyAnalytics(hasData: false),
      );
}

class FakeCardioRepository implements CardioRepository {
  FakeCardioRepository({this.entriesToReturn = const []});

  List<CardioEntry> entriesToReturn;

  @override
  Future<CardioEntry> create({
    required String activityType,
    required int durationSeconds,
    double? distanceKm,
    int? averageHeartRate,
    required DateTime performedAt,
  }) async {
    final created = CardioEntry(
      id: _nextId++,
      activityType: activityType,
      durationSeconds: durationSeconds,
      distanceKm: distanceKm,
      averageHeartRate: averageHeartRate,
      performedAt: performedAt,
    );
    entriesToReturn = [...entriesToReturn, created];
    return created;
  }

  int _nextId = 1000;

  @override
  Future<bool> delete(Object? id) async {
    entriesToReturn = entriesToReturn.where((e) => e.id != id).toList();
    return true;
  }

  @override
  Future<List<CardioEntry>> list() async => entriesToReturn;

  @override
  Future<CardioEntry> update(
    Object? id, {
    required String activityType,
    required int durationSeconds,
    double? distanceKm,
    int? averageHeartRate,
    required DateTime performedAt,
  }) async {
    final updated = CardioEntry(
      id: id,
      activityType: activityType,
      durationSeconds: durationSeconds,
      distanceKm: distanceKm,
      averageHeartRate: averageHeartRate,
      performedAt: performedAt,
    );
    entriesToReturn = [
      for (final entry in entriesToReturn) entry.id == id ? updated : entry,
    ];
    return updated;
  }
}

class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository({this.entriesToReturn = const []});

  List<ProgressEntry> entriesToReturn;

  @override
  Future<ProgressEntry> create({
    required DateTime measuredOn,
    double? weightKg,
    double? bodyFatPercentage,
    double? waistCm,
    double? chestCm,
    double? armCm,
  }) async {
    final created = ProgressEntry(
      id: _nextProgressId++,
      weightKg: weightKg,
      bodyFatPercentage: bodyFatPercentage,
      waistCm: waistCm,
      chestCm: chestCm,
      armCm: armCm,
      measuredOn: measuredOn,
    );
    entriesToReturn = [...entriesToReturn, created];
    return created;
  }

  int _nextProgressId = 2000;

  @override
  Future<bool> delete(Object? id) async {
    entriesToReturn = entriesToReturn.where((e) => e.id != id).toList();
    return true;
  }

  @override
  Future<List<ProgressEntry>> list() async => entriesToReturn;

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
    final updated = ProgressEntry(
      id: id,
      weightKg: weightKg,
      bodyFatPercentage: bodyFatPercentage,
      waistCm: waistCm,
      chestCm: chestCm,
      armCm: armCm,
      measuredOn: measuredOn ?? DateTime.now(),
    );
    entriesToReturn = [
      for (final entry in entriesToReturn) entry.id == id ? updated : entry,
    ];
    return updated;
  }
}

/// Builds a test assignment mirroring the Laravel API contract, including
/// decimal-as-string fields to exercise the safe parsers.
Assignment testAssignment({
  int id = 1,
  String status = 'active',
  List<int> dayNumbers = const [1],
  String startsOn = '2026-01-01',
  String endsOn = '2026-12-31',
}) {
  return Assignment.fromJson({
    'id': id,
    'workout_program_id': 11,
    'trainee_id': 7,
    'assigned_by': 3,
    'starts_on': startsOn,
    'ends_on': endsOn,
    'status': status,
    'program': {
      'id': 11,
      'coach_id': 3,
      'name': 'Hypertrophy Base',
      'description': 'Four-week foundation block.',
      'is_active': true,
      'days': [
        for (final dayNumber in dayNumbers)
          {
            'id': 100 + dayNumber,
            'day_number': dayNumber,
            'name': 'Push Day $dayNumber',
            'exercises': [
              {
                'id': 1,
                'exercise_id': 501,
                'sort_order': 1,
                'target_sets': 4,
                'target_reps_min': 8,
                'target_reps_max': 12,
                'target_weight_kg': '42.5',
                'rest_seconds': 90,
                'exercise': {
                  'id': 501,
                  'name': 'Bench Press',
                  'muscle_group': 'chest',
                  'equipment': 'barbell',
                  'instructions':
                      'Lower to mid-chest, drive through the floor.',
                },
              },
            ],
          },
      ],
    },
  });
}

User testUser() => User(
  id: 7,
  name: 'Leonidas',
  email: 'test@example.com',
  roles: const ['trainee'],
);

WorkoutSessionModel testSession({String? completedAt, int setCount = 2}) =>
    WorkoutSessionModel.fromJson({
      'id': 9,
      'workout_assignment_id': 1,
      'trainee_id': 7,
      'started_at': '2026-05-20T18:30:00Z',
      'completed_at': completedAt,
      'notes': 'felt strong',
      'sets': [
        for (var i = 1; i <= setCount; i++)
          {
            'id': i,
            'exercise_id': 501,
            'set_number': i,
            'weight_kg': '42.5',
            'reps': 10,
            'is_completed': true,
            'exercise': {
              'id': 501,
              'name': 'Bench Press',
              'muscle_group': 'chest',
              'equipment': 'barbell',
              'instructions': '',
            },
          },
      ],
    });
