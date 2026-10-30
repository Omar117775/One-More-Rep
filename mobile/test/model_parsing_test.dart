import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/parsing.dart';
import 'package:mobile/data/models/analytics_summary.dart';
import 'package:mobile/data/models/workout_session.dart';

import 'fakes.dart';

void main() {
  group('assignment parsing', () {
    test(
      'parses decimal strings and Y-m-d dates from contract payload',
      () async {
        final assignment = testAssignment();
        expect(assignment.status, 'active');
        expect(assignment.startsOn, isNotNull);
        expect(assignment.startsOn!.year, 2026);
        expect(assignment.program.days, hasLength(1));
        final exercise = assignment.program.days.first.exercises.single;
        expect(exercise.targetWeightKg, 42.5);
        expect(exercise.targetSets, 4);
        expect(exercise.targetRepsMin, 8);
        expect(exercise.targetRepsMax, 12);
        expect(exercise.repsLabel, '8-12');
        expect(assignment.program.totalExercises, 1);
      },
    );

    test('sorts active assignments before ended ones', () {
      final active = testAssignment(id: 1);
      final ended = testAssignment(id: 2, status: 'ended');
      expect(active.isActive, isTrue);
      expect(ended.isEnded, isTrue);
      expect(ended.isActive, isFalse);
    });
  });

  group('session parsing', () {
    test('parses sets with decimal weight strings and computes volume', () {
      final session = testSession(completedAt: '2026-05-20T19:10:00Z');
      expect(session.sets, hasLength(2));
      expect(session.sets.first.weightKg, 42.5);
      expect(session.isCompleted, isTrue);
      expect(session.volume, closeTo(850, 0.001));
      expect(session.completedSets, 2);
      expect(session.totalSets, 2);
    });

    test('in-progress session has null completed_at', () {
      final session = testSession();
      expect(session.completedAt, isNull);
      expect(session.isCompleted, isFalse);
    });

    test('payload builders omit empty values and keep required ones', () {
      final payload = buildSessionPayload(
        assignmentId: 1,
        startedAt: DateTime.utc(2026, 5, 20, 18, 30),
        sets: [
          buildSetPayload(
            exerciseId: 501,
            setNumber: 1,
            reps: 10,
            weightKg: 42.5,
            isCompleted: true,
          ),
          buildSetPayload(exerciseId: 501, setNumber: 2, reps: 8),
        ],
      );
      expect(payload['assignment_id'], 1);
      expect((payload['started_at'] as String).contains('2026-05-20'), isTrue);
      expect(payload.containsKey('completed_at'), isFalse);
      expect(payload['sets'], hasLength(2));
      final first = (payload['sets'] as List).first as Map<String, dynamic>;
      expect(first['weight_kg'], 42.5);
      final second = (payload['sets'] as List)[1] as Map<String, dynamic>;
      expect(second.containsKey('weight_kg'), isFalse);
      expect(second['reps'], 8);
    });
  });

  group('analytics parsing', () {
    test(
      'parses weekly volume (string decimals), body series and has_data flags',
      () {
        final summary = AnalyticsSummary.fromJson({
          'from': '2026-04-21',
          'to': '2026-05-21',
          'workouts': {
            'has_data': true,
            'sessions': 4,
            'completed_sessions': 3,
            'sets': 12,
            'completed_sets': 10,
            'reps': 110,
            'volume_kg': '1230.5',
            'weekly': [
              {
                'week_start': '2026-04-27',
                'sessions': 2,
                'completed_sessions': 2,
                'sets': 6,
                'completed_sets': 6,
                'reps': 60,
                'volume_kg': '660.0',
              },
              {
                'week_start': '2026-05-04',
                'sessions': 2,
                'completed_sessions': 1,
                'sets': 6,
                'completed_sets': 4,
                'reps': 50,
                'volume_kg': '570.5',
              },
            ],
          },
          'cardio': {
            'has_data': false,
            'sessions': 0,
            'duration_seconds': 0,
            'distance_km': null,
            'weekly': [],
          },
          'body': {
            'has_data': true,
            'series': [
              {
                'id': 3,
                'measured_on': '2026-05-01',
                'weight_kg': '84.2',
                'body_fat_percentage': null,
                'waist_cm': 80.5,
                'chest_cm': null,
                'arm_cm': null,
              },
            ],
          },
        });

        expect(summary.workouts.hasData, isTrue);
        expect(summary.workouts.volumeKg, closeTo(1230.5, 0.001));
        expect(summary.workouts.weekly, hasLength(2));
        expect(summary.workouts.weekly.last.volumeKg, closeTo(570.5, 0.001));
        expect(summary.cardio.hasData, isFalse);
        expect(summary.body.hasData, isTrue);
        expect(summary.body.series.single.weightKg, closeTo(84.2, 0.001));
        expect(summary.body.series.single.bodyFatPercentage, isNull);
      },
    );

    test(
      'missing analytics sections fall back to has_data:false without throwing',
      () {
        final summary = AnalyticsSummary.fromJson({
          'from': '2026-04-21',
          'to': '2026-05-21',
        });
        expect(summary.workouts.hasData, isFalse);
        expect(summary.cardio.hasData, isFalse);
        expect(summary.body.hasData, isFalse);
        expect(summary.body.series, isEmpty);
      },
    );
  });

  group('parsing helpers', () {
    test('parseDecimal handles strings, numbers, commas and invalid input', () {
      expect(parseDecimal('42.5'), 42.5);
      expect(parseDecimal(3), 3.0);
      expect(parseDecimal('3,5'), 3.5);
      expect(parseDecimal(''), isNull);
      expect(parseDecimal('abc'), isNull);
      expect(parseDecimal(null), isNull);
    });

    test('parseDate handles Y-m-d, ISO and null', () {
      final date = parseDate('2026-05-20');
      expect(date, DateTime.utc(2026, 5, 20));
      expect(
        parseDate('2026-05-20T18:30:00Z'),
        DateTime.utc(2026, 5, 20, 18, 30),
      );
      expect(parseDate(null), isNull);
      expect(parseDate(''), isNull);
    });

    test('formatDateYdm renders zero-padded Y-m-d', () {
      expect(formatDateYdm(DateTime.utc(2026, 5, 9)), '2026-05-09');
      expect(formatDateYdm(null), isNull);
    });
  });
}
