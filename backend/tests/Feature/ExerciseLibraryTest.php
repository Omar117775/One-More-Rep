<?php

namespace Tests\Feature;

use Laravel\Sanctum\Sanctum;
use Tests\Concerns\CreatesTrainingData;
use Tests\Concerns\CreatesUsers;

class ExerciseLibraryTest extends FeatureTestCase
{
    use CreatesTrainingData;
    use CreatesUsers;

    public function test_coach_creates_private_exercise_and_cannot_override_owner(): void
    {
        $coach = $this->createCoach();
        $other = $this->createCoach();
        Sanctum::actingAs($coach);

        $response = $this->postJson('/api/v1/coach/exercises', [
            'name' => 'Incline Press',
            'muscle_group' => 'chest',
            'equipment' => 'dumbbell',
            'instructions' => 'Press with control.',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.created_by', $coach->id)
            ->assertJsonPath('data.is_public', false);

        $this->assertDatabaseHas('audit_logs', [
            'actor_user_id' => $coach->id,
            'action' => 'exercise.created',
        ]);

        $this->postJson('/api/v1/coach/exercises', [
            'name' => 'Hijacked',
            'muscle_group' => 'back',
            'created_by' => $other->id,
        ])->assertStatus(422)->assertJsonValidationErrors('created_by');
    }

    public function test_coach_can_publish_and_update_own_exercise(): void
    {
        $coach = $this->createCoach();
        $exercise = $this->makeExercise(['created_by' => $coach->id, 'is_public' => false], $coach);
        Sanctum::actingAs($coach);

        $this->patchJson("/api/v1/coach/exercises/{$exercise->id}", [
            'is_public' => true,
            'name' => 'Bench Press',
        ])->assertStatus(200)
            ->assertJsonPath('data.is_public', true)
            ->assertJsonPath('data.name', 'Bench Press');

        $this->assertDatabaseHas('audit_logs', [
            'action' => 'exercise.updated',
            'entity_id' => $exercise->id,
        ]);
    }

    public function test_coach_cannot_change_another_coachs_exercise(): void
    {
        $owner = $this->createCoach();
        $other = $this->createCoach();
        $exercise = $this->makeExercise(['created_by' => $owner->id, 'is_public' => false], $owner);

        Sanctum::actingAs($other);

        $this->patchJson("/api/v1/coach/exercises/{$exercise->id}", ['name' => 'Changed'])
            ->assertStatus(404);
        $this->deleteJson("/api/v1/coach/exercises/{$exercise->id}")->assertStatus(404);
    }

    public function test_trainee_reads_only_public_and_assigned_private_exercises(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);

        $public = $this->makeExercise(['name' => 'Public Squat', 'is_public' => true]);
        $assigned = $this->makeExercise(['name' => 'Private Pull', 'is_public' => false, 'created_by' => $coach->id], $coach);
        $hidden = $this->makeExercise(['name' => 'Hidden Row', 'is_public' => false, 'created_by' => $coach->id], $coach);

        $program = $this->makeProgram($coach, $assigned);
        $this->makeAssignment($coach, $trainee, $program);

        Sanctum::actingAs($trainee);

        $response = $this->getJson('/api/v1/exercises?per_page=50')->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id')->all();

        $this->assertContains($public->id, $ids);
        $this->assertContains($assigned->id, $ids);
        $this->assertNotContains($hidden->id, $ids);

        $this->getJson("/api/v1/exercises/{$assigned->id}")->assertStatus(200);
        $this->getJson("/api/v1/exercises/{$hidden->id}")->assertStatus(403);
    }

    public function test_ended_assignment_revokes_private_exercise_access_for_trainee(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);

        $private = $this->makeExercise([
            'name' => 'Ended Program Drill',
            'is_public' => false,
            'created_by' => $coach->id,
        ], $coach);
        $program = $this->makeProgram($coach, $private);
        $assignment = $this->makeAssignment($coach, $trainee, $program);

        Sanctum::actingAs($trainee);
        $this->getJson("/api/v1/exercises/{$private->id}")->assertStatus(200);

        $assignment->update([
            'status' => 'ended',
            'ends_on' => now()->toDateString(),
        ]);

        $this->getJson("/api/v1/exercises/{$private->id}")->assertStatus(403);
        $ids = collect($this->getJson('/api/v1/exercises?per_page=50')->assertStatus(200)->json('data'))
            ->pluck('id')->all();
        $this->assertNotContains($private->id, $ids);
    }

    public function test_ended_relationship_revokes_private_exercise_access_even_with_stale_active_assignment(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->linkCoach($coach, $trainee);

        $private = $this->makeExercise([
            'name' => 'Revoked Program Drill',
            'is_public' => false,
            'created_by' => $coach->id,
        ], $coach);
        $program = $this->makeProgram($coach, $private);
        $this->makeAssignment($coach, $trainee, $program);

        $relationship->update([
            'status' => 'ended',
            'ended_at' => now(),
        ]);

        Sanctum::actingAs($trainee);

        $this->getJson("/api/v1/exercises/{$private->id}")->assertStatus(403);
        $ids = collect($this->getJson('/api/v1/exercises?per_page=50')->assertStatus(200)->json('data'))
            ->pluck('id')->all();
        $this->assertNotContains($private->id, $ids);
    }

    public function test_coach_library_contains_public_and_own_private_exercises(): void
    {
        $coach = $this->createCoach();
        $other = $this->createCoach();
        $public = $this->makeExercise(['name' => 'Public Deadlift', 'is_public' => true], $other);
        $own = $this->makeExercise(['name' => 'Own Curl', 'is_public' => false, 'created_by' => $coach->id], $coach);
        $hidden = $this->makeExercise(['name' => 'Other Curl', 'is_public' => false, 'created_by' => $other->id], $other);

        Sanctum::actingAs($coach);

        $ids = collect($this->getJson('/api/v1/exercises?per_page=50')->assertStatus(200)->json('data'))
            ->pluck('id')->all();

        $this->assertContains($public->id, $ids);
        $this->assertContains($own->id, $ids);
        $this->assertNotContains($hidden->id, $ids);
    }

    public function test_library_validation_and_filters(): void
    {
        $coach = $this->createCoach();
        $this->makeExercise(['name' => 'Cable Fly', 'muscle_group' => 'chest', 'equipment' => 'cable'], null);
        $this->makeExercise(['name' => 'Cable Row', 'muscle_group' => 'back', 'equipment' => 'cable'], null);

        Sanctum::actingAs($coach);

        $this->getJson('/api/v1/exercises?search=fly&muscle_group=chest&equipment=cable')
            ->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Cable Fly');

        $this->postJson('/api/v1/coach/exercises', [
            'name' => 'X',
            'muscle_group' => 'unknown',
            'equipment' => 'spaceship',
        ])->assertStatus(422)
            ->assertJsonValidationErrors(['name', 'muscle_group', 'equipment']);
    }

    public function test_used_exercise_cannot_be_deleted(): void
    {
        $coach = $this->createCoach();
        $program = $this->makeProgram($coach);
        $exercise = $program->days->first()->exercises->first()->exercise;

        Sanctum::actingAs($coach);

        $this->deleteJson("/api/v1/coach/exercises/{$exercise->id}")
            ->assertStatus(422)
            ->assertJsonValidationErrors('exercise');

        $this->assertDatabaseHas('exercises', ['id' => $exercise->id]);
    }

    public function test_public_exercise_show_is_available_to_trainees_and_admin_is_forbidden(): void
    {
        $exercise = $this->makeExercise(['is_public' => true]);
        $trainee = $this->createTrainee();
        $admin = $this->createSuperAdmin();

        Sanctum::actingAs($trainee);
        $this->getJson("/api/v1/exercises/{$exercise->id}")->assertStatus(200);

        Sanctum::actingAs($admin);
        $this->getJson('/api/v1/exercises')->assertStatus(403);
    }

    public function test_unauthenticated_library_request_is_rejected(): void
    {
        $this->getJson('/api/v1/exercises')->assertStatus(401);
    }
}
