import '../../core/parsing.dart';
import 'assignment.dart';

/// One logged set of a workout session.
class SessionSet {
  const SessionSet({
    required this.id,
    this.exerciseId,
    required this.setNumber,
    this.weightKg,
    required this.reps,
    this.isCompleted = false,
    required this.exercise,
  });

  final Object? id;
  final Object? exerciseId;
  final int setNumber;
  final double? weightKg;
  final int reps;
  final bool isCompleted;
  final ExerciseInfo exercise;

  double get volume => (weightKg ?? 0) * reps;

  factory SessionSet.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('session set');
    return SessionSet(
      id: raw['id'],
      exerciseId: raw['exercise_id'],
      setNumber: parseInt(raw['set_number']) ?? 0,
      weightKg: parseDecimal(raw['weight_kg']),
      reps: parseInt(raw['reps']) ?? 0,
      isCompleted: parseBool(raw['is_completed']),
      exercise: ExerciseInfo.fromJson(raw['exercise']),
    );
  }
}

/// Trainee workout session with its sets.
class WorkoutSessionModel {
  const WorkoutSessionModel({
    required this.id,
    this.workoutAssignmentId,
    this.traineeId,
    this.startedAt,
    this.completedAt,
    this.notes,
    required this.sets,
  });

  final Object? id;
  final Object? workoutAssignmentId;
  final Object? traineeId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final List<SessionSet> sets;

  bool get isCompleted => completedAt != null;

  double get volume => sets.fold(0, (acc, s) => acc + s.volume);
  int get totalSets => sets.length;
  int get completedSets => sets.where((s) => s.isCompleted).length;

  factory WorkoutSessionModel.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('workout session');
    return WorkoutSessionModel(
      id: raw['id'],
      workoutAssignmentId: raw['workout_assignment_id'],
      traineeId: raw['trainee_id'],
      startedAt: parseDate(raw['started_at']),
      completedAt: parseDate(raw['completed_at']),
      notes: raw['notes']?.toString(),
      sets: mapList(raw['sets'], SessionSet.fromJson),
    );
  }
}

/// Payload body for POST /trainee/sessions.
Map<String, dynamic> buildSessionPayload({
  required Object? assignmentId,
  required DateTime startedAt,
  DateTime? completedAt,
  String? notes,
  required List<Map<String, dynamic>> sets,
}) {
  return {
    'assignment_id': assignmentId,
    'started_at': startedAt.toIso8601String(),
    if (completedAt != null) 'completed_at': completedAt.toIso8601String(),
    if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    'sets': sets,
  };
}

/// Builds one set payload; [weightKg] omitted when null/invalid.
Map<String, dynamic> buildSetPayload({
  required Object? exerciseId,
  required int setNumber,
  required int reps,
  double? weightKg,
  bool isCompleted = false,
}) {
  return {
    'exercise_id': exerciseId,
    'set_number': setNumber,
    'weight_kg': ?weightKg,
    'reps': reps,
    'is_completed': isCompleted,
  };
}
