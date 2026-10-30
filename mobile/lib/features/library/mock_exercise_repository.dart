import 'exercise.dart';
import 'exercise_repository.dart';

/// MOCK DATA — Phase 5 stop-gap until the backend exercise library exists.
/// Static, English-only catalog (mock content localization is intentionally
/// skipped per the milestone brief). Swap for a `lib/data/` repository later.
class MockExerciseRepository implements ExerciseRepository {
  const MockExerciseRepository();

  static const List<Exercise> _exercises = [
    // Chest
    Exercise(
      id: 'chest-bench',
      name: 'Barbell Bench Press',
      group: ExerciseGroup.chest,
      equipment: 'Barbell',
      isCardio: false,
      instructions:
          'Lie on the bench with feet planted. Lower the bar to mid-chest '
          'with controlled elbows at 45°, then press up without locking '
          'hard. Keep the shoulder blades retracted throughout.',
      difficulty: ExerciseDifficulty.intermediate,
    ),
    Exercise(
      id: 'chest-incline-db',
      name: 'Incline Dumbbell Press',
      group: ExerciseGroup.chest,
      equipment: 'Dumbbell',
      isCardio: false,
      instructions:
          'Set the bench to 30–45°. Press the dumbbells up and slightly '
          'inward, then lower until elbows reach chest height. Avoid '
          'bouncing at the bottom.',
      difficulty: ExerciseDifficulty.intermediate,
    ),
    Exercise(
      id: 'chest-fly',
      name: 'Machine Chest Fly',
      group: ExerciseGroup.chest,
      equipment: 'Machine',
      isCardio: false,
      instructions:
          'Sit with back against the pad. Bring the handles together in a '
          'wide arc, squeeze for a beat, then return with control. Keep '
          'the range pain-free.',
      difficulty: ExerciseDifficulty.beginner,
    ),
    Exercise(
      id: 'chest-pushup',
      name: 'Push-Up',
      group: ExerciseGroup.chest,
      equipment: 'Bodyweight',
      isCardio: false,
      instructions:
          'Hands under shoulders, body in one line. Lower the chest to just '
          'above the floor, keep the core braced, then press back up. '
          'Scale with knee or incline variations.',
      difficulty: ExerciseDifficulty.beginner,
    ),

    // Back
    Exercise(
      id: 'back-deadlift',
      name: 'Deadlift',
      group: ExerciseGroup.back,
      equipment: 'Barbell',
      isCardio: false,
      instructions:
          'Hip-width stance, grip just outside the shins. Brace the core, '
          'push the floor away and stand tall with the bar in contact '
          'with the legs. Reset the setup each rep — never round the back.',
      difficulty: ExerciseDifficulty.advanced,
    ),
    Exercise(
      id: 'back-row',
      name: 'Barbell Row',
      group: ExerciseGroup.back,
      equipment: 'Barbell',
      isCardio: false,
      instructions:
          'Hinge to about 45° with a flat back. Row the bar to the lower '
          'ribs, squeezing the shoulder blades, then lower under control. '
          'Keep the torso angle steady.',
      difficulty: ExerciseDifficulty.intermediate,
    ),
    Exercise(
      id: 'back-pulldown',
      name: 'Lat Pulldown',
      group: ExerciseGroup.back,
      equipment: 'Machine',
      isCardio: false,
      instructions:
          'Grip the bar wider than shoulders. Pull the bar to the collarbone '
          'while driving the elbows down and back. Avoid swinging the torso.',
      difficulty: ExerciseDifficulty.beginner,
    ),
    Exercise(
      id: 'back-cable-row',
      name: 'Seated Cable Row',
      group: ExerciseGroup.back,
      equipment: 'Machine',
      isCardio: false,
      instructions:
          'Sit tall with a slight forward lean. Pull the handle to the '
          'stomach, hold a one-second squeeze at the back, then extend '
          'the arms without letting the shoulders round.',
      difficulty: ExerciseDifficulty.beginner,
    ),

    // Legs
    Exercise(
      id: 'legs-squat',
      name: 'Back Squat',
      group: ExerciseGroup.legs,
      equipment: 'Barbell',
      isCardio: false,
      instructions:
          'Bar on the upper traps, feet shoulder-width. Sit down between '
          'the heels until hip crease is below the knee, then drive '
          'through mid-foot to stand. Keep the chest up and knees tracking.',
      difficulty: ExerciseDifficulty.intermediate,
    ),
    Exercise(
      id: 'legs-press',
      name: 'Leg Press',
      group: ExerciseGroup.legs,
      equipment: 'Machine',
      isCardio: false,
      instructions:
          'Feet shoulder-width on the platform. Lower until knees reach '
          'about 90° without the lower back rounding off the pad, then '
          'press without locking the knees hard.',
      difficulty: ExerciseDifficulty.beginner,
    ),
    Exercise(
      id: 'legs-rdl',
      name: 'Romanian Deadlift',
      group: ExerciseGroup.legs,
      equipment: 'Barbell',
      isCardio: false,
      instructions:
          'Stand tall holding the bar in front of the thighs. Push the '
          'hips back with a slight knee bend until a strong hamstring '
          'stretch, then return to standing with a flat back.',
      difficulty: ExerciseDifficulty.intermediate,
    ),
    Exercise(
      id: 'legs-lunge',
      name: 'Walking Lunge',
      group: ExerciseGroup.legs,
      equipment: 'Dumbbell',
      isCardio: false,
      instructions:
          'Step forward into a long stride and lower until both knees are '
          'at about 90°. Push through the front heel to step through and '
          'alternate legs. Keep the torso upright.',
      difficulty: ExerciseDifficulty.beginner,
    ),

    // Shoulders
    Exercise(
      id: 'shoulders-ohp',
      name: 'Overhead Press',
      group: ExerciseGroup.shoulders,
      equipment: 'Barbell',
      isCardio: false,
      instructions:
          'Bar at collarbone, grip just outside shoulders. Press the bar '
          'overhead until stacked over the ears, then lower to the start. '
          'Keep the ribs down — no lower-back arch.',
      difficulty: ExerciseDifficulty.intermediate,
    ),
    Exercise(
      id: 'shoulders-lat-raise',
      name: 'Lateral Raise',
      group: ExerciseGroup.shoulders,
      equipment: 'Dumbbell',
      isCardio: false,
      instructions:
          'Arms at the sides with a slight elbow bend. Raise out to shoulder '
          'height, leading with the elbows, then lower slowly. Keep the '
          'traps relaxed.',
      difficulty: ExerciseDifficulty.beginner,
    ),
    Exercise(
      id: 'shoulders-face-pull',
      name: 'Face Pull',
      group: ExerciseGroup.shoulders,
      equipment: 'Cable',
      isCardio: false,
      instructions:
          'Set the rope at eye level. Pull toward the face while rotating '
          'the hands out, elbows high. Control the return — the goal is '
          'rear-delts and upper back, not heavy load.',
      difficulty: ExerciseDifficulty.beginner,
    ),
    Exercise(
      id: 'shoulders-arnold',
      name: 'Arnold Press',
      group: ExerciseGroup.shoulders,
      equipment: 'Dumbbell',
      isCardio: false,
      instructions:
          'Start with palms facing in at shoulder height. Rotate the palms '
          'out while pressing overhead, then reverse the path down. Move '
          'smoothly through the rotation.',
      difficulty: ExerciseDifficulty.intermediate,
    ),

    // Arms
    Exercise(
      id: 'arms-curl',
      name: 'Barbell Curl',
      group: ExerciseGroup.arms,
      equipment: 'Barbell',
      isCardio: false,
      instructions:
          'Elbows pinned to the ribs. Curl the bar up without swinging, '
          'squeeze at the top, then lower over two counts. Keep the wrists '
          'neutral.',
      difficulty: ExerciseDifficulty.beginner,
    ),
    Exercise(
      id: 'arms-hammer',
      name: 'Hammer Curl',
      group: ExerciseGroup.arms,
      equipment: 'Dumbbell',
      isCardio: false,
      instructions:
          'Palms facing each other throughout. Curl both dumbbells up, '
          'keeping the elbows still, then lower under control. Works the '
          'brachialis and forearms.',
      difficulty: ExerciseDifficulty.beginner,
    ),
    Exercise(
      id: 'arms-pushdown',
      name: 'Triceps Pushdown',
      group: ExerciseGroup.arms,
      equipment: 'Cable',
      isCardio: false,
      instructions:
          'Elbows stay locked at the sides. Extend the arms fully to push '
          'the bar or rope down, then resist the cable back up to chest '
          'height. No body English.',
      difficulty: ExerciseDifficulty.beginner,
    ),
    Exercise(
      id: 'arms-skullcrusher',
      name: 'Skull Crusher',
      group: ExerciseGroup.arms,
      equipment: 'Barbell',
      isCardio: false,
      instructions:
          'Lying on a bench, extend the bar over the chest. Bend the elbows '
          'to lower it just behind the forehead, then press back to full '
          'extension. Upper arms stay vertical.',
      difficulty: ExerciseDifficulty.intermediate,
    ),

    // Core
    Exercise(
      id: 'core-plank',
      name: 'Plank',
      group: ExerciseGroup.core,
      equipment: 'Bodyweight',
      isCardio: false,
      instructions:
          'Forearms down, elbows under shoulders. Hold one straight line '
          'from head to heels while bracing the abs and glutes. Breathe '
          'steadily and stop when form breaks.',
      difficulty: ExerciseDifficulty.beginner,
    ),
    Exercise(
      id: 'core-leg-raise',
      name: 'Hanging Leg Raise',
      group: ExerciseGroup.core,
      equipment: 'Bodyweight',
      isCardio: false,
      instructions:
          'Hang from the bar with active shoulders. Raise the legs (or '
          'knees) until hips fully flex, pause briefly, then lower without '
          'swinging.',
      difficulty: ExerciseDifficulty.intermediate,
    ),
    Exercise(
      id: 'core-twist',
      name: 'Russian Twist',
      group: ExerciseGroup.core,
      equipment: 'Bodyweight',
      isCardio: false,
      instructions:
          'Sit with heels down and a tall chest. Rotate the whole upper '
          'body side to side, keeping the abs engaged rather than just '
          'swinging the arms.',
      difficulty: ExerciseDifficulty.intermediate,
    ),
    Exercise(
      id: 'core-mountain',
      name: 'Mountain Climbers',
      group: ExerciseGroup.core,
      equipment: 'Bodyweight',
      isCardio: true,
      instructions:
          'From a high plank, drive the knees toward the chest one at a '
          'time at a steady rhythm. Keep the hips level and the pace '
          'consistent across the interval.',
      difficulty: ExerciseDifficulty.beginner,
    ),
  ];

  @override
  Future<List<Exercise>> exercises() async => _exercises;
}
