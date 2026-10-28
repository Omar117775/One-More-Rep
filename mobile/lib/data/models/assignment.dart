import '../../core/parsing.dart';

/// Exercise descriptor nested inside program exercises and logged sets.
class ExerciseInfo {
  const ExerciseInfo({
    required this.id,
    this.name = '',
    this.muscleGroup = '',
    this.equipment = '',
    this.instructions = '',
  });

  final Object? id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String instructions;

  factory ExerciseInfo.fromJson(dynamic raw) {
    if (raw is! Map) return const ExerciseInfo(id: null);
    return ExerciseInfo(
      id: raw['id'],
      name: raw['name']?.toString() ?? '',
      muscleGroup: raw['muscle_group']?.toString() ?? '',
      equipment: raw['equipment']?.toString() ?? '',
      instructions: raw['instructions']?.toString() ?? '',
    );
  }
}

/// A planned exercise on a program day with its target prescription.
class ProgramExercise {
  const ProgramExercise({
    required this.id,
    required this.exerciseId,
    this.sortOrder = 0,
    this.targetSets,
    this.targetRepsMin,
    this.targetRepsMax,
    this.targetWeightKg,
    this.restSeconds,
    required this.exercise,
  });

  final Object? id;
  final Object? exerciseId;
  final int sortOrder;
  final int? targetSets;
  final int? targetRepsMin;
  final int? targetRepsMax;
  final double? targetWeightKg;
  final int? restSeconds;
  final ExerciseInfo exercise;

  String get repsLabel {
    final min = targetRepsMin ?? 0;
    final max = targetRepsMax ?? 0;
    if (max > 0 && min > 0 && min != max) return '$min-$max';
    if (max > 0) return '$max';
    if (min > 0) return '$min';
    return '—';
  }

  factory ProgramExercise.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('program exercise');
    return ProgramExercise(
      id: raw['id'],
      exerciseId: raw['exercise_id'],
      sortOrder: parseInt(raw['sort_order']) ?? 0,
      targetSets: parseInt(raw['target_sets']),
      targetRepsMin: parseInt(raw['target_reps_min']),
      targetRepsMax: parseInt(raw['target_reps_max']),
      targetWeightKg: parseDecimal(raw['target_weight_kg']),
      restSeconds: parseInt(raw['rest_seconds']),
      exercise: ExerciseInfo.fromJson(raw['exercise']),
    );
  }
}

/// One day of the assigned workout program.
class ProgramDay {
  const ProgramDay({
    required this.id,
    required this.dayNumber,
    required this.name,
    required this.exercises,
  });

  final Object? id;
  final int dayNumber;
  final String name;
  final List<ProgramExercise> exercises;

  factory ProgramDay.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('program day');
    return ProgramDay(
      id: raw['id'],
      dayNumber: parseInt(raw['day_number']) ?? 0,
      name: raw['name']?.toString() ?? '',
      exercises: mapList(raw['exercises'], ProgramExercise.fromJson),
    );
  }
}

class ProgramSummary {
  const ProgramSummary({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = false,
    required this.days,
  });

  final Object? id;
  final String name;
  final String description;
  final bool isActive;
  final List<ProgramDay> days;

  int get totalExercises => days.fold(0, (acc, d) => acc + d.exercises.length);

  factory ProgramSummary.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('program');
    return ProgramSummary(
      id: raw['id'],
      name: raw['name']?.toString() ?? '',
      description: raw['description']?.toString() ?? '',
      isActive: parseBool(raw['is_active']),
      days: mapList(raw['days'], ProgramDay.fromJson),
    );
  }
}

/// Coach → trainee program assignment.
class Assignment {
  const Assignment({
    required this.id,
    required this.workoutProgramId,
    this.traineeId,
    this.assignedBy,
    this.startsOn,
    this.endsOn,
    required this.status,
    required this.program,
  });

  final Object? id;
  final Object? workoutProgramId;
  final Object? traineeId;
  final Object? assignedBy;
  final DateTime? startsOn;
  final DateTime? endsOn;
  final String status;
  final ProgramSummary program;

  bool get isActive => status == 'active';
  bool get isUpcoming => status == 'upcoming';
  bool get isEnded => status != 'active' && status != 'upcoming';

  factory Assignment.fromJson(dynamic raw) {
    if (raw is! Map) throw const FormatException('assignment');
    return Assignment(
      id: raw['id'],
      workoutProgramId: raw['workout_program_id'],
      traineeId: raw['trainee_id'],
      assignedBy: raw['assigned_by'],
      startsOn: parseDate(raw['starts_on']),
      endsOn: parseDate(raw['ends_on']),
      status: raw['status']?.toString() ?? '',
      program: ProgramSummary.fromJson(raw['program']),
    );
  }
}
