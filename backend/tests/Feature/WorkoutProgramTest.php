<?php

namespace Tests\Feature;

use Laravel\Sanctum\Sanctum;
use Tests\Concerns\CreatesTrainingData;
use Tests\Concerns\CreatesUsers;

class WorkoutProgramTest extends FeatureTestCase
{
    use CreatesTrainingData;
    use CreatesUsers;

    private function payload(int $exerciseId): array
    {
        return [
            'name' => 'Hypertrophy Block',
            'description' => 'Four day upper/lower split.',
            'days' => [
                [
                    'day_number' => 1,
                    'name' => 'Upper',
                    'exercises' => [
                        [
                            'exercise_id' => $exerciseId,
                            'sort_order' => 1,
                            'target_sets' => 4,
                            'target_reps_min' => 8,
                            'target_reps_max' => 12,
                            'target_weight_kg' => 60,
                            'rest_seconds' => 90,
                        ],
                    ],
                ],
            ],
        ];
    }

    public function test_coach_creates_program_with_ordered_days_and_exercises(): void
    {
        $coach = $this->createCoach();
        $exercise = $this->makeExercise(['created_by' => $coach->id], $coach);

        Sanctum::actingAs($coach);

        $response = $this->postJson('/api/v1/coach/programs', $this->payload($exercise->id));

        $response->assertStatus(201)
            ->assertJsonPath('data.coach_id', $coach->id)
            ->assertJsonPath('data.days.0.name', 'Upper')
            ->assertJsonPath('data.days.0.exercises.0.exercise.id', $exercise->id)
            ->assertJsonPath('data.days.0.exercises.0.target_sets', 4);

        $this->assertDatabaseHas('audit_logs', [
            'actor_user_id' => $coach->id,
            'action' => 'workout_program.created',
        ]);
    }

    public function test_coach_updates_program_and_replaces_schedule(): void
    {
        $coach = $this->createCoach();
        $program = $this->makeProgram($coach);
        $exercise = $this->makeExercise(['created_by' => $coach->id], $coach);

        Sanctum::actingAs($coach);

        $payload = $this->payload($exercise->id);
        $payload['name'] = 'Updated Block';
        $payload['days'][0]['day_number'] = 3;
        $payload['days'][0]['name'] = 'Pull';

        $this->patchJson("/api/v1/coach/programs/{$program->id}", $payload)
            ->assertStatus(200)
            ->assertJsonPath('data.name', 'Updated Block')
            ->assertJsonPath('data.days.0.day_number', 3)
            ->assertJsonPath('data.days.0.name', 'Pull');

        $this->assertDatabaseHas('workout_program_days', [
            'workout_program_id' => $program->id,
            'day_number' => 3,
        ]);
        $this->assertDatabaseMissing('workout_program_days', [
            'workout_program_id' => $program->id,
            'day_number' => 1,
        ]);
    }

    public function test_coach_cannot_use_another_coachs_private_exercise(): void
    {
        $coach = $this->createCoach();
        $other = $this->createCoach();
        $private = $this->makeExercise([
            'created_by' => $other->id,
            'is_public' => false,
        ], $other);

        Sanctum::actingAs($coach);

        $this->postJson('/api/v1/coach/programs', $this->payload($private->id))
            ->assertStatus(422)
            ->assertJsonValidationErrors('days');
    }

    public function test_nested_validation_rejects_duplicates_and_invalid_rep_range(): void
    {
        $coach = $this->createCoach();
        $exercise = $this->makeExercise(['created_by' => $coach->id], $coach);
        $payload = $this->payload($exercise->id);
        $payload['days'][] = $payload['days'][0];
        $payload['days'][0]['exercises'][0]['target_reps_min'] = 15;
        $payload['days'][0]['exercises'][0]['target_reps_max'] = 10;

        Sanctum::actingAs($coach);

        $this->postJson('/api/v1/coach/programs', $payload)
            ->assertStatus(422)
            ->assertJsonValidationErrors([
                'days.1.day_number',
                'days.0.exercises.0.target_reps_max',
            ]);
    }

    public function test_coach_cannot_view_or_change_another_coachs_program(): void
    {
        $owner = $this->createCoach();
        $other = $this->createCoach();
        $program = $this->makeProgram($owner);

        Sanctum::actingAs($other);

        $this->getJson("/api/v1/coach/programs/{$program->id}")->assertStatus(404);
        $this->patchJson("/api/v1/coach/programs/{$program->id}", ['name' => 'Taken'])->assertStatus(404);
        $this->deleteJson("/api/v1/coach/programs/{$program->id}")->assertStatus(404);
    }

    public function test_coach_assigns_program_only_to_actively_assigned_trainee(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);
        $program = $this->makeProgram($coach);

        Sanctum::actingAs($coach);

        $response = $this->postJson("/api/v1/coach/programs/{$program->id}/assignments", [
            'trainee_id' => $trainee->id,
            'starts_on' => now()->toDateString(),
            'ends_on' => now()->addMonth()->toDateString(),
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.trainee_id', $trainee->id)
            ->assertJsonPath('data.status', 'active')
            ->assertJsonPath('data.program.id', $program->id);

        $this->assertDatabaseHas('audit_logs', [
            'action' => 'workout_assignment.created',
        ]);
    }

    public function test_assignment_requires_active_relationship_and_valid_dates(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $program = $this->makeProgram($coach);

        Sanctum::actingAs($coach);

        $this->postJson("/api/v1/coach/programs/{$program->id}/assignments", [
            'trainee_id' => $trainee->id,
            'starts_on' => now()->toDateString(),
        ])->assertStatus(422)->assertJsonValidationErrors('trainee_id');

        $this->linkCoach($coach, $trainee);

        $this->postJson("/api/v1/coach/programs/{$program->id}/assignments", [
            'trainee_id' => $trainee->id,
            'starts_on' => now()->addDays(5)->toDateString(),
            'ends_on' => now()->toDateString(),
        ])->assertStatus(422)->assertJsonValidationErrors('ends_on');
    }

    public function test_duplicate_active_assignment_is_rejected_but_reassignment_after_end_is_allowed(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);
        $program = $this->makeProgram($coach);

        Sanctum::actingAs($coach);

        $body = [
            'trainee_id' => $trainee->id,
            'starts_on' => now()->toDateString(),
        ];

        $assignmentId = $this->postJson("/api/v1/coach/programs/{$program->id}/assignments", $body)
            ->assertStatus(201)
            ->json('data.id');

        $this->postJson("/api/v1/coach/programs/{$program->id}/assignments", $body)
            ->assertStatus(422)
            ->assertJsonValidationErrors('trainee_id');

        $this->postJson("/api/v1/coach/assignments/{$assignmentId}/end")
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'ended');

        $this->postJson("/api/v1/coach/programs/{$program->id}/assignments", $body)
            ->assertStatus(201);
    }

    public function test_coach_cannot_assign_another_coachs_program(): void
    {
        $owner = $this->createCoach();
        $other = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($other, $trainee);
        $program = $this->makeProgram($owner);

        Sanctum::actingAs($other);

        $this->postJson("/api/v1/coach/programs/{$program->id}/assignments", [
            'trainee_id' => $trainee->id,
            'starts_on' => now()->toDateString(),
        ])->assertStatus(404);
    }

    public function test_program_with_assignment_history_cannot_be_deleted(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);
        $program = $this->makeProgram($coach);
        $this->makeAssignment($coach, $trainee, $program);
        $assignment = $program->assignments()->firstOrFail();
        $assignment->update(['status' => 'ended', 'ends_on' => now()->toDateString()]);

        Sanctum::actingAs($coach);

        $this->deleteJson("/api/v1/coach/programs/{$program->id}")
            ->assertStatus(422)
            ->assertJsonValidationErrors('program');

        $this->assertDatabaseHas('workout_programs', ['id' => $program->id]);
    }

    public function test_trainee_sees_only_own_assignments(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $otherTrainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);
        $this->linkCoach($coach, $otherTrainee);

        $program = $this->makeProgram($coach);
        $own = $this->makeAssignment($coach, $trainee, $program);
        $other = $this->makeAssignment($coach, $otherTrainee, $program);

        Sanctum::actingAs($trainee);

        $response = $this->getJson('/api/v1/trainee/assignments')->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertSame($own->id, $response->json('data.0.id'));

        $this->getJson("/api/v1/trainee/assignments/{$other->id}")->assertStatus(404);
        $this->getJson("/api/v1/trainee/assignments/{$own->id}")
            ->assertStatus(200)
            ->assertJsonPath('data.program.days.0.exercises.0.exercise.id', $program->days->first()->exercises->first()->exercise_id);
    }

    public function test_trainee_cannot_manage_coach_programs(): void
    {
        $trainee = $this->createTrainee();
        $coach = $this->createCoach();
        $program = $this->makeProgram($coach);

        Sanctum::actingAs($trainee);

        $this->getJson('/api/v1/coach/programs')->assertStatus(403);
        $this->postJson("/api/v1/coach/programs/{$program->id}/assignments", [])->assertStatus(403);
    }

    public function test_sort_order_is_unique_within_each_day_not_across_the_program(): void
    {
        $coach = $this->createCoach();
        $exercise = $this->makeExercise(['created_by' => $coach->id], $coach);
        $payload = $this->payload($exercise->id);

        $secondDay = $payload['days'][0];
        $secondDay['day_number'] = 2;
        $secondDay['name'] = 'Lower';
        $payload['days'][] = $secondDay;

        Sanctum::actingAs($coach);

        $this->postJson('/api/v1/coach/programs', $payload)
            ->assertStatus(201)
            ->assertJsonCount(2, 'data.days')
            ->assertJsonPath('data.days.1.exercises.0.sort_order', 1);

        $duplicate = $payload;
        $duplicate['days'][0]['exercises'][] = $payload['days'][0]['exercises'][0];
        $duplicate['days'][0]['exercises'][1]['sort_order'] = 1;

        $this->postJson('/api/v1/coach/programs', $duplicate)
            ->assertStatus(422)
            ->assertJsonValidationErrors('days.0.exercises.1.sort_order');
    }

    public function test_program_schedule_cannot_be_replaced_after_assignment_history_exists(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);
        $program = $this->makeProgram($coach);
        $this->makeAssignment($coach, $trainee, $program);
        $exercise = $program->days->first()->exercises->first()->exercise;

        Sanctum::actingAs($coach);

        $payload = $this->payload($exercise->id);
        $payload['days'][0]['name'] = 'Replacement';

        $this->patchJson("/api/v1/coach/programs/{$program->id}", $payload)
            ->assertStatus(422)
            ->assertJsonValidationErrors('days');

        $this->assertDatabaseHas('workout_program_days', [
            'workout_program_id' => $program->id,
            'name' => 'Push',
        ]);

        $this->patchJson("/api/v1/coach/programs/{$program->id}", ['name' => 'Renamed Block'])
            ->assertStatus(200)
            ->assertJsonPath('data.name', 'Renamed Block')
            ->assertJsonPath('data.days.0.name', 'Push');
    }

    public function test_nested_exercise_is_redacted_after_public_exercise_becomes_private(): void
    {
        $owner = $this->createCoach();
        $other = $this->createCoach();
        $exercise = $this->makeExercise([
            'created_by' => $owner->id,
            'is_public' => true,
            'instructions' => 'Initially shared cue.',
        ], $owner);
        $program = $this->makeProgram($other, $exercise);

        Sanctum::actingAs($other);
        $this->getJson("/api/v1/coach/programs/{$program->id}")
            ->assertStatus(200)
            ->assertJsonPath('data.days.0.exercises.0.exercise.id', $exercise->id);

        Sanctum::actingAs($owner);
        $this->patchJson("/api/v1/coach/exercises/{$exercise->id}", ['is_public' => false])
            ->assertStatus(200);

        Sanctum::actingAs($other);
        $this->getJson("/api/v1/coach/programs/{$program->id}")
            ->assertStatus(200)
            ->assertJsonPath('data.days.0.exercises.0.exercise_id', $exercise->id)
            ->assertJsonMissingPath('data.days.0.exercises.0.exercise');
    }

    public function test_coach_cannot_end_another_coachs_assignment_or_one_after_relationship_ends(): void
    {
        $owner = $this->createCoach();
        $other = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->linkCoach($owner, $trainee);
        $program = $this->makeProgram($owner);
        $assignment = $this->makeAssignment($owner, $trainee, $program);

        Sanctum::actingAs($other);
        $this->postJson("/api/v1/coach/assignments/{$assignment->id}/end")->assertStatus(404);

        $relationship->update([
            'status' => 'ended',
            'ended_at' => now(),
        ]);

        Sanctum::actingAs($owner);
        $this->getJson('/api/v1/coach/assignments')->assertStatus(200)->assertJsonCount(0, 'data');
        $this->postJson("/api/v1/coach/assignments/{$assignment->id}/end")->assertStatus(404);
    }
}
