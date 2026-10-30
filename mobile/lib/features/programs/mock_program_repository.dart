import 'program_repository.dart';
import 'workout_program.dart';

/// MOCK DATA — Phase 5 stop-gap until coach-published programs and the
/// subscription/enrollment flow exist on the backend. Static English catalog
/// (mock content localization is intentionally skipped per the brief).
/// Swap for a `lib/data/` repository later.
class MockProgramRepository implements ProgramRepository {
  const MockProgramRepository();

  static const List<WorkoutProgram> _programs = [
    WorkoutProgram(
      id: 'foundations-strength',
      name: 'Foundations of Strength',
      description:
          'Build a bulletproof base across the big lifts with simple '
          'progression and honest volume. Ideal first serious block.',
      weeks: 8,
      sessionsPerWeek: 3,
      level: ProgramLevel.beginner,
      tag: 'Strength',
      weeklySchedule: [
        'Day 1 — Squat focus + upper push assistance',
        'Day 2 — Hinge focus + upper pull assistance',
        'Day 3 — Full body repetition practice',
      ],
    ),
    WorkoutProgram(
      id: 'hypertrophy-engine',
      name: 'Hypertrophy Engine',
      description:
          'A classic upper/lower split tuned for growth: high-rep finishers, '
          'controlled eccentrics and enough recovery to keep progressing.',
      weeks: 12,
      sessionsPerWeek: 4,
      level: ProgramLevel.intermediate,
      tag: 'Hypertrophy',
      weeklySchedule: [
        'Day 1 — Upper push (chest / shoulders)',
        'Day 2 — Lower strength + calves',
        'Day 3 — Upper pull (back / biceps)',
        'Day 4 — Lower hypertrophy + core',
      ],
    ),
    WorkoutProgram(
      id: 'conditioning-acumen',
      name: 'Conditioning Acumen',
      description:
          'Engine-centred conditioning: intervals, circuits and steady '
          'state slots that sharpen the heart without wrecking the legs.',
      weeks: 6,
      sessionsPerWeek: 3,
      level: ProgramLevel.intermediate,
      tag: 'Conditioning',
      weeklySchedule: [
        'Day 1 — Interval sprints',
        'Day 2 — Full body strength circuit',
        'Day 3 — Steady state + core finisher',
      ],
    ),
    WorkoutProgram(
      id: 'fat-loss-sprint',
      name: 'Fat Loss Sprint',
      description:
          'A short, aggressive block pairing strength circuits with heart '
          'rate work and a simple daily step target.',
      weeks: 6,
      sessionsPerWeek: 4,
      level: ProgramLevel.beginner,
      tag: 'Fat loss',
      weeklySchedule: [
        'Day 1 — Strength circuit A',
        'Day 2 — Low-impact steady cardio',
        'Day 3 — Strength circuit B',
        'Day 4 — Intervals + core',
      ],
    ),
    WorkoutProgram(
      id: 'powerbuilders-path',
      name: "Powerbuilder's Path",
      description:
          'Heavy top sets followed by pump work across four sessions. For '
          'lifters who want the strength number and the size that backs it.',
      weeks: 14,
      sessionsPerWeek: 4,
      level: ProgramLevel.advanced,
      tag: 'Powerbuilding',
      weeklySchedule: [
        'Day 1 — Max effort lower',
        'Day 2 — Dynamic effort upper',
        'Day 3 — Hypertrophy lower',
        'Day 4 — Hypertrophy upper + arms',
      ],
    ),
    WorkoutProgram(
      id: 'endurance-base-builder',
      name: 'Endurance Base Builder',
      description:
          'Aerobic base building with disciplined pacing: zone-2 running, '
          'one tempo session and one long session weekly.',
      weeks: 10,
      sessionsPerWeek: 3,
      level: ProgramLevel.intermediate,
      tag: 'Endurance',
      weeklySchedule: [
        'Day 1 — Zone-2 run (easy pace)',
        'Day 2 — Tempo run + strides',
        'Day 3 — Long session (progressive)',
      ],
    ),
  ];

  @override
  Future<List<WorkoutProgram>> programs() async => _programs;
}
