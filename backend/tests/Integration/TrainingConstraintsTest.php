<?php

namespace Tests\Integration;

use App\Models\CardioSession;
use App\Models\Exercise;
use App\Models\User;
use App\Models\WorkoutAssignment;
use App\Models\WorkoutDayExercise;
use App\Models\WorkoutProgram;
use App\Models\WorkoutProgramDay;
use App\Models\WorkoutSession;
use App\Models\WorkoutSet;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class TrainingConstraintsTest extends IntegrationTestCase
{
    private function makeUser(string $email): User
    {
        return User::factory()->create([
            'email' => $email,
            'email_verified_at' => now(),
            'is_active' => true,
        ]);
    }

    private function makeExercise(User $coach, array $overrides = []): Exercise
    {
        return Exercise::create(array_merge([
            'created_by' => $coach->id,
            'name' => 'Back Squat',
            'muscle_group' => 'legs',
            'equipment' => 'barbell',
            'is_public' => true,
        ], $overrides));
    }

    /**
     * @return array{program: WorkoutProgram, day: WorkoutProgramDay, dayExercise: WorkoutDayExercise, exercise: Exercise}
     */
    private function makeProgram(User $coach): array
    {
        $exercise = $this->makeExercise($coach);
        $program = WorkoutProgram::create([
            'coach_id' => $coach->id,
            'name' => 'Strength',
            'is_active' => true,
        ]);
        $day = WorkoutProgramDay::create([
            'workout_program_id' => $program->id,
            'day_number' => 1,
            'name' => 'Legs',
        ]);
        $dayExercise = WorkoutDayExercise::create([
            'workout_program_day_id' => $day->id,
            'exercise_id' => $exercise->id,
            'sort_order' => 0,
            'target_sets' => 3,
            'target_reps_min' => 5,
            'target_reps_max' => 8,
        ]);

        return compact('program', 'day', 'dayExercise', 'exercise');
    }

    private function makeAssignment(User $coach, User $trainee, WorkoutProgram $program, array $overrides = []): WorkoutAssignment
    {
        return WorkoutAssignment::create(array_merge([
            'workout_program_id' => $program->id,
            'trainee_id' => $trainee->id,
            'assigned_by' => $coach->id,
            'starts_on' => now()->toDateString(),
            'status' => 'active',
        ], $overrides));
    }

    public function test_exercise_enum_constraints_are_enforced(): void
    {
        $coach = $this->makeUser('coach-exercise-enum@example.com');

        $this->expectException(QueryException::class);

        $this->makeExercise($coach, ['muscle_group' => 'wings']);
    }

    public function test_equipment_enum_constraint_is_enforced(): void
    {
        $coach = $this->makeUser('coach-equipment-enum@example.com');

        $this->expectException(QueryException::class);

        $this->makeExercise($coach, ['equipment' => 'spaceship']);
    }

    public function test_duplicate_program_day_number_is_rejected(): void
    {
        $coach = $this->makeUser('coach-day-duplicate@example.com');
        $context = $this->makeProgram($coach);

        $this->expectException(QueryException::class);

        WorkoutProgramDay::create([
            'workout_program_id' => $context['program']->id,
            'day_number' => 1,
            'name' => 'Duplicate',
        ]);
    }

    public function test_day_number_range_and_duplicate_sort_order_are_enforced(): void
    {
        $coach = $this->makeUser('coach-day-range@example.com');
        $context = $this->makeProgram($coach);

        try {
            WorkoutProgramDay::create([
                'workout_program_id' => $context['program']->id,
                'day_number' => 9,
                'name' => 'Invalid',
            ]);
            $this->fail('Expected day number constraint violation.');
        } catch (QueryException) {
            $this->assertTrue(true);
        }

        $this->expectException(QueryException::class);

        WorkoutDayExercise::create([
            'workout_program_day_id' => $context['day']->id,
            'exercise_id' => $context['exercise']->id,
            'sort_order' => 0,
            'target_sets' => 3,
            'target_reps_min' => 5,
            'target_reps_max' => 8,
        ]);
    }

    public function test_rep_range_constraint_is_enforced(): void
    {
        $coach = $this->makeUser('coach-rep-range@example.com');
        $context = $this->makeProgram($coach);
        $exercise = $this->makeExercise($coach);

        $this->expectException(QueryException::class);

        WorkoutDayExercise::create([
            'workout_program_day_id' => $context['day']->id,
            'exercise_id' => $exercise->id,
            'sort_order' => 1,
            'target_sets' => 3,
            'target_reps_min' => 12,
            'target_reps_max' => 6,
        ]);
    }

    public function test_active_assignment_is_unique_per_program_and_trainee(): void
    {
        $coach = $this->makeUser('coach-assignment-unique@example.com');
        $trainee = $this->makeUser('trainee-assignment-unique@example.com');
        $context = $this->makeProgram($coach);
        $this->makeAssignment($coach, $trainee, $context['program']);

        $this->expectException(QueryException::class);

        $this->makeAssignment($coach, $trainee, $context['program']);
    }

    public function test_ended_assignment_allows_reassignment_and_requires_end_date(): void
    {
        $coach = $this->makeUser('coach-assignment-ended@example.com');
        $trainee = $this->makeUser('trainee-assignment-ended@example.com');
        $context = $this->makeProgram($coach);

        $ended = $this->makeAssignment($coach, $trainee, $context['program'], [
            'status' => 'ended',
            'ends_on' => now()->toDateString(),
        ]);

        $active = $this->makeAssignment($coach, $trainee, $context['program']);

        $this->assertNotSame($ended->id, $active->id);

        $otherTrainee = $this->makeUser('trainee-assignment-no-end@example.com');

        $this->expectException(QueryException::class);

        $this->makeAssignment($coach, $otherTrainee, $context['program'], ['status' => 'ended']);
    }

    public function test_workout_set_unique_and_range_constraints_are_enforced(): void
    {
        $coach = $this->makeUser('coach-set-unique@example.com');
        $trainee = $this->makeUser('trainee-set-unique@example.com');
        $context = $this->makeProgram($coach);
        $assignment = $this->makeAssignment($coach, $trainee, $context['program']);
        $session = WorkoutSession::create([
            'workout_assignment_id' => $assignment->id,
            'trainee_id' => $trainee->id,
            'started_at' => now()->subHour(),
            'completed_at' => now(),
        ]);

        WorkoutSet::create([
            'workout_session_id' => $session->id,
            'exercise_id' => $context['exercise']->id,
            'set_number' => 1,
            'weight_kg' => 60,
            'reps' => 5,
        ]);

        try {
            WorkoutSet::create([
                'workout_session_id' => $session->id,
                'exercise_id' => $context['exercise']->id,
                'set_number' => 1,
                'weight_kg' => 60,
                'reps' => 5,
            ]);
            $this->fail('Expected duplicate set constraint violation.');
        } catch (QueryException) {
            $this->assertTrue(true);
        }

        $this->expectException(QueryException::class);

        WorkoutSet::create([
            'workout_session_id' => $session->id,
            'exercise_id' => $context['exercise']->id,
            'set_number' => 2,
            'weight_kg' => 1001,
            'reps' => 0,
        ]);
    }

    public function test_session_completion_before_start_is_rejected(): void
    {
        $coach = $this->makeUser('coach-session-time@example.com');
        $trainee = $this->makeUser('trainee-session-time@example.com');
        $context = $this->makeProgram($coach);
        $assignment = $this->makeAssignment($coach, $trainee, $context['program']);

        $this->expectException(QueryException::class);

        WorkoutSession::create([
            'workout_assignment_id' => $assignment->id,
            'trainee_id' => $trainee->id,
            'started_at' => now(),
            'completed_at' => now()->subHour(),
        ]);
    }

    public function test_cardio_constraints_and_cascade_are_enforced(): void
    {
        $trainee = $this->makeUser('trainee-cardio-cascade@example.com');

        CardioSession::create([
            'trainee_id' => $trainee->id,
            'activity_type' => 'running',
            'duration_seconds' => 1800,
            'distance_km' => 5,
            'average_heart_rate' => 145,
            'performed_at' => now(),
        ]);

        $this->assertSame(1, DB::table('cardio_sessions')->count());
        $trainee->delete();
        $this->assertSame(0, DB::table('cardio_sessions')->count());
    }

    public function test_cardio_range_constraints_are_enforced(): void
    {
        $trainee = $this->makeUser('trainee-cardio-invalid@example.com');

        try {
            DB::table('cardio_sessions')->insert([
                'trainee_id' => $trainee->id,
                'activity_type' => 'teleporting',
                'duration_seconds' => 1800,
                'performed_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $this->fail('Expected cardio activity constraint violation.');
        } catch (QueryException) {
            $this->assertTrue(true);
        }

        $this->expectException(QueryException::class);

        DB::table('cardio_sessions')->insert([
            'trainee_id' => $trainee->id,
            'activity_type' => 'running',
            'duration_seconds' => 0,
            'distance_km' => -1,
            'average_heart_rate' => 300,
            'performed_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function test_referenced_exercise_and_assigned_program_cannot_be_deleted(): void
    {
        $coach = $this->makeUser('coach-restrict@example.com');
        $trainee = $this->makeUser('trainee-restrict@example.com');
        $context = $this->makeProgram($coach);
        $this->makeAssignment($coach, $trainee, $context['program']);

        try {
            $context['exercise']->delete();
            $this->fail('Expected exercise restrict violation.');
        } catch (QueryException) {
            $this->assertTrue(true);
        }

        $this->expectException(QueryException::class);

        $context['program']->delete();
    }
}
