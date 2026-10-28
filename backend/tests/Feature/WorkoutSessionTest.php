<?php

namespace Tests\Feature;

use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Models\Exercise;
use App\Models\User;
use App\Models\WorkoutAssignment;
use App\Models\WorkoutProgram;
use Laravel\Sanctum\Sanctum;
use Tests\Concerns\CreatesTrainingData;
use Tests\Concerns\CreatesUsers;

class WorkoutSessionTest extends FeatureTestCase
{
    use CreatesTrainingData;
    use CreatesUsers;

    /**
     * @return array{coach: User, trainee: User, program: WorkoutProgram, assignment: WorkoutAssignment, exercise: Exercise}
     */
    private function context(): array
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);
        $program = $this->makeProgram($coach);
        $assignment = $this->makeAssignment($coach, $trainee, $program);
        $exercise = $program->days->first()->exercises->first()->exercise;

        return compact('coach', 'trainee', 'program', 'assignment', 'exercise');
    }

    private function payload(int $assignmentId, int $exerciseId, array $overrides = []): array
    {
        return array_merge([
            'assignment_id' => $assignmentId,
            'started_at' => now()->subHours(2)->toIso8601String(),
            'completed_at' => now()->subHour()->toIso8601String(),
            'notes' => 'Felt strong.',
            'sets' => [
                [
                    'exercise_id' => $exerciseId,
                    'set_number' => 1,
                    'weight_kg' => 60,
                    'reps' => 10,
                    'is_completed' => true,
                ],
                [
                    'exercise_id' => $exerciseId,
                    'set_number' => 2,
                    'weight_kg' => 60,
                    'reps' => 8,
                    'is_completed' => true,
                ],
            ],
        ], $overrides);
    }

    public function test_trainee_creates_session_with_sets_for_assigned_program(): void
    {
        $context = $this->context();
        Sanctum::actingAs($context['trainee']);

        $response = $this->postJson('/api/v1/trainee/sessions', $this->payload(
            $context['assignment']->id,
            $context['exercise']->id,
        ));

        $response->assertStatus(201)
            ->assertJsonPath('data.workout_assignment_id', $context['assignment']->id)
            ->assertJsonPath('data.sets.0.exercise_id', $context['exercise']->id)
            ->assertJsonCount(2, 'data.sets');

        $this->assertDatabaseHas('workout_sets', [
            'exercise_id' => $context['exercise']->id,
            'reps' => 10,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'workout_session.created',
            'actor_user_id' => $context['trainee']->id,
        ]);
    }

    public function test_trainee_cannot_set_session_owner_via_payload(): void
    {
        $context = $this->context();
        $other = $this->createTrainee();
        Sanctum::actingAs($context['trainee']);

        $payload = $this->payload($context['assignment']->id, $context['exercise']->id, [
            'trainee_id' => $other->id,
            'workout_assignment_id' => 999,
        ]);

        $this->postJson('/api/v1/trainee/sessions', $payload)
            ->assertStatus(422)
            ->assertJsonValidationErrors(['trainee_id', 'workout_assignment_id']);
    }

    public function test_session_rejects_exercise_outside_program(): void
    {
        $context = $this->context();
        $outsider = $this->makeExercise(['is_public' => true, 'name' => 'Outsider']);
        Sanctum::actingAs($context['trainee']);

        $this->postJson('/api/v1/trainee/sessions', $this->payload(
            $context['assignment']->id,
            $outsider->id,
        ))->assertStatus(422)->assertJsonValidationErrors('sets.0.exercise_id');
    }

    public function test_session_must_fall_within_assignment_dates_and_active_status(): void
    {
        $context = $this->context();
        $context['assignment']->update([
            'starts_on' => now()->toDateString(),
            'ends_on' => now()->addMonth()->toDateString(),
        ]);

        Sanctum::actingAs($context['trainee']);

        $payload = $this->payload($context['assignment']->id, $context['exercise']->id, [
            'started_at' => now()->subDay()->toIso8601String(),
            'completed_at' => null,
        ]);

        $this->postJson('/api/v1/trainee/sessions', $payload)
            ->assertStatus(422)
            ->assertJsonValidationErrors('started_at');

        $context['assignment']->update([
            'status' => WorkoutAssignmentStatus::ENDED,
            'ends_on' => now()->toDateString(),
        ]);

        $payload['started_at'] = now()->subHour()->toIso8601String();
        $this->postJson('/api/v1/trainee/sessions', $payload)
            ->assertStatus(422)
            ->assertJsonValidationErrors('assignment_id');
    }

    public function test_session_rejects_inactive_program(): void
    {
        $context = $this->context();
        $context['program']->update(['is_active' => false]);
        Sanctum::actingAs($context['trainee']);

        $this->postJson('/api/v1/trainee/sessions', $this->payload(
            $context['assignment']->id,
            $context['exercise']->id,
        ))->assertStatus(422)->assertJsonValidationErrors('assignment_id');
    }

    public function test_session_rejects_duplicate_set_numbers_and_invalid_values(): void
    {
        $context = $this->context();
        Sanctum::actingAs($context['trainee']);

        $payload = $this->payload($context['assignment']->id, $context['exercise']->id);
        $payload['sets'][1]['set_number'] = 1;
        $payload['sets'][1]['reps'] = 0;
        $payload['sets'][1]['weight_kg'] = 1001;

        $this->postJson('/api/v1/trainee/sessions', $payload)
            ->assertStatus(422)
            ->assertJsonValidationErrors([
                'sets.1.set_number',
                'sets.1.reps',
                'sets.1.weight_kg',
            ]);
    }

    public function test_completion_cannot_precede_start(): void
    {
        $context = $this->context();
        Sanctum::actingAs($context['trainee']);

        $payload = $this->payload($context['assignment']->id, $context['exercise']->id, [
            'started_at' => now()->subHour()->toIso8601String(),
            'completed_at' => now()->subHours(2)->toIso8601String(),
        ]);

        $this->postJson('/api/v1/trainee/sessions', $payload)
            ->assertStatus(422)
            ->assertJsonValidationErrors('completed_at');
    }

    public function test_trainee_lists_only_own_sessions(): void
    {
        $context = $this->context();
        $otherTrainee = $this->createTrainee();
        $otherAssignment = $this->makeAssignment($context['coach'], $otherTrainee, $context['program']);
        $own = $this->makeSession($context['trainee'], $context['assignment']);
        $other = $this->makeSession($otherTrainee, $otherAssignment);

        Sanctum::actingAs($context['trainee']);

        $response = $this->getJson('/api/v1/trainee/sessions')->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertSame($own->id, $response->json('data.0.id'));

        $this->getJson("/api/v1/trainee/sessions/{$other->id}")->assertStatus(404);
        $this->getJson("/api/v1/trainee/sessions/{$own->id}")->assertStatus(200);
    }

    public function test_trainee_updates_and_deletes_own_session(): void
    {
        $context = $this->context();
        $session = $this->makeSession($context['trainee'], $context['assignment']);
        Sanctum::actingAs($context['trainee']);

        $this->patchJson("/api/v1/trainee/sessions/{$session->id}", [
            'completed_at' => now()->toIso8601String(),
            'notes' => 'Updated.',
            'sets' => [
                [
                    'exercise_id' => $context['exercise']->id,
                    'set_number' => 1,
                    'weight_kg' => 65,
                    'reps' => 6,
                    'is_completed' => true,
                ],
            ],
        ])->assertStatus(200)
            ->assertJsonPath('data.notes', 'Updated.')
            ->assertJsonCount(1, 'data.sets')
            ->assertJsonPath('data.sets.0.reps', 6);

        $this->assertDatabaseCount('workout_sets', 1);

        $this->deleteJson("/api/v1/trainee/sessions/{$session->id}")->assertStatus(204);
        $this->assertDatabaseMissing('workout_sessions', ['id' => $session->id]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'workout_session.deleted']);
    }

    public function test_trainee_cannot_access_another_trainees_session(): void
    {
        $context = $this->context();
        $otherTrainee = $this->createTrainee();
        $otherAssignment = $this->makeAssignment($context['coach'], $otherTrainee, $context['program']);
        $session = $this->makeSession($otherTrainee, $otherAssignment);

        Sanctum::actingAs($context['trainee']);

        $this->getJson("/api/v1/trainee/sessions/{$session->id}")->assertStatus(404);
        $this->patchJson("/api/v1/trainee/sessions/{$session->id}", ['notes' => 'No'])->assertStatus(404);
        $this->deleteJson("/api/v1/trainee/sessions/{$session->id}")->assertStatus(404);
    }

    public function test_coach_reads_only_assigned_trainee_sessions(): void
    {
        $context = $this->context();
        $session = $this->makeSession($context['trainee'], $context['assignment']);
        $unassigned = $this->createTrainee();
        $unassignedAssignment = $this->makeAssignment($context['coach'], $unassigned, $context['program']);
        $hiddenSession = $this->makeSession($unassigned, $unassignedAssignment);
        $otherTrainee = $this->createTrainee();

        Sanctum::actingAs($context['coach']);

        $this->getJson("/api/v1/coach/trainees/{$context['trainee']->id}/workouts")
            ->assertStatus(200)
            ->assertJsonPath('data.0.id', $session->id);
        $this->getJson("/api/v1/coach/trainees/{$context['trainee']->id}/workouts/{$session->id}")
            ->assertStatus(200);
        $this->getJson("/api/v1/coach/trainees/{$context['trainee']->id}/workouts/{$hiddenSession->id}")
            ->assertStatus(404);
        $this->getJson("/api/v1/coach/trainees/{$otherTrainee->id}/workouts")
            ->assertStatus(403);
    }

    public function test_coach_cannot_create_a_trainee_session(): void
    {
        $context = $this->context();
        Sanctum::actingAs($context['coach']);

        $this->postJson('/api/v1/trainee/sessions', $this->payload(
            $context['assignment']->id,
            $context['exercise']->id,
        ))->assertStatus(403);
    }

    public function test_session_creation_requires_an_active_coaching_relationship(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee, 'ended');
        $program = $this->makeProgram($coach);
        $assignment = $this->makeAssignment($coach, $trainee, $program);
        $exercise = $program->days->first()->exercises->first()->exercise;

        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/sessions', $this->payload(
            $assignment->id,
            $exercise->id,
        ))->assertStatus(422)->assertJsonValidationErrors('assignment_id');

        $this->assertDatabaseCount('workout_sessions', 0);
    }

    public function test_second_coach_cannot_read_another_coachs_private_program_or_exercise_details(): void
    {
        $owner = $this->createCoach();
        $secondCoach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($owner, $trainee);
        $this->linkCoach($secondCoach, $trainee, 'active', 'secondary');

        $privateExercise = $this->makeExercise([
            'created_by' => $owner->id,
            'is_public' => false,
            'instructions' => 'Owner-only coaching cue.',
        ], $owner);
        $program = $this->makeProgram($owner, $privateExercise);
        $assignment = $this->makeAssignment($owner, $trainee, $program);
        $session = $this->makeSession($trainee, $assignment);

        Sanctum::actingAs($owner);
        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/workouts/{$session->id}")
            ->assertStatus(200)
            ->assertJsonPath('data.assignment.program.id', $program->id)
            ->assertJsonPath('data.sets.0.exercise.instructions', 'Owner-only coaching cue.');

        Sanctum::actingAs($secondCoach);
        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/workouts/{$session->id}")
            ->assertStatus(200)
            ->assertJsonPath('data.sets.0.exercise_id', $privateExercise->id)
            ->assertJsonMissingPath('data.assignment')
            ->assertJsonMissingPath('data.sets.0.exercise');

        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/workouts")
            ->assertStatus(200)
            ->assertJsonMissingPath('data.0.assignment')
            ->assertJsonMissingPath('data.0.sets.0.exercise');
    }
}
