<?php

namespace Tests\Concerns;

use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Models\CardioSession;
use App\Models\CoachTraineeRelationship;
use App\Models\Exercise;
use App\Models\User;
use App\Models\WorkoutAssignment;
use App\Models\WorkoutDayExercise;
use App\Models\WorkoutProgram;
use App\Models\WorkoutProgramDay;
use App\Models\WorkoutSession;
use App\Models\WorkoutSet;
use Carbon\CarbonImmutable;

trait CreatesTrainingData
{
    public function linkCoach(
        User $coach,
        User $trainee,
        string $status = 'active',
        string $type = 'primary',
    ): CoachTraineeRelationship {
        return CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => $type,
            'status' => $status,
            'started_at' => now(),
            'responded_at' => now(),
            'ended_at' => $status === 'ended' ? now() : null,
        ]);
    }

    public function makeExercise(array $overrides = [], ?User $creator = null): Exercise
    {
        return Exercise::create(array_merge([
            'created_by' => $creator?->id,
            'name' => 'Barbell Bench Press',
            'muscle_group' => 'chest',
            'equipment' => 'barbell',
            'instructions' => 'Controlled press.',
            'is_public' => true,
        ], $overrides));
    }

    public function makeProgram(User $coach, ?Exercise $exercise = null, array $overrides = []): WorkoutProgram
    {
        $exercise ??= $this->makeExercise(['created_by' => $coach->id]);

        $program = WorkoutProgram::create(array_merge([
            'coach_id' => $coach->id,
            'name' => 'Foundation Strength',
            'description' => 'Three day foundation block.',
            'is_active' => true,
        ], $overrides));

        $day = WorkoutProgramDay::create([
            'workout_program_id' => $program->id,
            'day_number' => 1,
            'name' => 'Push',
        ]);

        WorkoutDayExercise::create([
            'workout_program_day_id' => $day->id,
            'exercise_id' => $exercise->id,
            'sort_order' => 0,
            'target_sets' => 3,
            'target_reps_min' => 8,
            'target_reps_max' => 12,
            'target_weight_kg' => 60,
            'rest_seconds' => 90,
        ]);

        return $program->fresh()->load('days.exercises.exercise');
    }

    public function makeAssignment(
        User $coach,
        User $trainee,
        WorkoutProgram $program,
        array $overrides = [],
    ): WorkoutAssignment {
        return WorkoutAssignment::create(array_merge([
            'workout_program_id' => $program->id,
            'trainee_id' => $trainee->id,
            'assigned_by' => $coach->id,
            'starts_on' => now()->subWeek()->toDateString(),
            'ends_on' => now()->addWeek()->toDateString(),
            'status' => WorkoutAssignmentStatus::ACTIVE,
        ], $overrides));
    }

    public function makeSession(
        User $trainee,
        WorkoutAssignment $assignment,
        array $overrides = [],
        array $sets = [],
    ): WorkoutSession {
        $session = WorkoutSession::create(array_merge([
            'workout_assignment_id' => $assignment->id,
            'trainee_id' => $trainee->id,
            'started_at' => now()->subHour(),
            'completed_at' => now(),
            'notes' => null,
        ], $overrides));

        if ($sets === []) {
            $exerciseId = $assignment->program->days->first()->exercises->first()->exercise_id;
            $sets = [
                ['exercise_id' => $exerciseId, 'set_number' => 1, 'weight_kg' => 60, 'reps' => 10, 'is_completed' => true],
            ];
        }

        foreach ($sets as $set) {
            WorkoutSet::create([
                'workout_session_id' => $session->id,
                'exercise_id' => $set['exercise_id'],
                'set_number' => $set['set_number'],
                'weight_kg' => $set['weight_kg'] ?? null,
                'reps' => $set['reps'],
                'is_completed' => $set['is_completed'] ?? true,
            ]);
        }

        return $session->fresh()->load('sets.exercise');
    }

    public function makeCardio(User $trainee, array $overrides = []): CardioSession
    {
        return CardioSession::create(array_merge([
            'trainee_id' => $trainee->id,
            'activity_type' => 'running',
            'duration_seconds' => 1800,
            'distance_km' => 5.25,
            'average_heart_rate' => 145,
            'performed_at' => CarbonImmutable::now()->subHour(),
        ], $overrides));
    }
}
