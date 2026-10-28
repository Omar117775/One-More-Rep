<?php

namespace Tests\Feature;

use App\Enums\Enums\RelationshipStatus;
use App\Models\BodyMeasurement;
use App\Models\CoachTraineeRelationship;
use Laravel\Sanctum\Sanctum;
use Tests\Concerns\CreatesUsers;

class ProgressRecordTest extends FeatureTestCase
{
    use CreatesUsers;

    private function assign(int $coachId, int $traineeId): void
    {
        CoachTraineeRelationship::create([
            'coach_id' => $coachId,
            'trainee_id' => $traineeId,
            'relationship_type' => 'primary',
            'status' => RelationshipStatus::ACTIVE,
            'started_at' => now(),
            'responded_at' => now(),
        ]);
    }

    private function measurement(int $traineeId, array $overrides = []): BodyMeasurement
    {
        return BodyMeasurement::create(array_merge([
            'trainee_id' => $traineeId,
            'weight_kg' => 82.5,
            'body_fat_percentage' => 18.2,
            'waist_cm' => 84.0,
            'chest_cm' => 104.0,
            'arm_cm' => 36.5,
            'measured_on' => now()->subDay()->toDateString(),
        ], $overrides));
    }

    public function test_trainee_can_create_a_dated_progress_record(): void
    {
        $trainee = $this->createTrainee();
        Sanctum::actingAs($trainee);

        $response = $this->postJson('/api/v1/trainee/progress', [
            'measured_on' => now()->toDateString(),
            'weight_kg' => 80.25,
            'body_fat_percentage' => 17.5,
            'waist_cm' => 82,
            'chest_cm' => 102,
            'arm_cm' => 36,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.trainee_id', $trainee->id)
            ->assertJsonPath('data.weight_kg', '80.25');

        $this->assertDatabaseHas('body_measurements', [
            'trainee_id' => $trainee->id,
        ]);
        $this->assertSame(
            now()->toDateString(),
            BodyMeasurement::where('trainee_id', $trainee->id)->firstOrFail()->measured_on->toDateString(),
        );
        $this->assertDatabaseHas('audit_logs', [
            'actor_user_id' => $trainee->id,
            'action' => 'body_measurement.created',
        ]);
    }

    public function test_trainee_cannot_set_the_owner_via_payload(): void
    {
        $trainee = $this->createTrainee();
        $other = $this->createTrainee();

        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/progress', [
            'trainee_id' => $other->id,
            'measured_on' => now()->toDateString(),
            'weight_kg' => 80,
        ])->assertStatus(422)->assertJsonValidationErrors('trainee_id');

        $this->assertDatabaseCount('body_measurements', 0);
    }

    public function test_progress_validation_rejects_empty_future_and_out_of_range_values(): void
    {
        $trainee = $this->createTrainee();
        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/progress', [
            'measured_on' => now()->toDateString(),
        ])->assertStatus(422)->assertJsonValidationErrors('measurements');

        $this->postJson('/api/v1/trainee/progress', [
            'measured_on' => now()->addDay()->toDateString(),
            'weight_kg' => 80,
        ])->assertStatus(422)->assertJsonValidationErrors('measured_on');

        $this->postJson('/api/v1/trainee/progress', [
            'measured_on' => now()->toDateString(),
            'weight_kg' => 900,
            'body_fat_percentage' => 101,
        ])->assertStatus(422);
    }

    public function test_trainee_lists_only_own_records_newest_first(): void
    {
        $trainee = $this->createTrainee();
        $other = $this->createTrainee();
        $older = $this->measurement($trainee->id, ['measured_on' => now()->subWeek()->toDateString()]);
        $newer = $this->measurement($trainee->id, ['measured_on' => now()->toDateString()]);
        $this->measurement($other->id);

        Sanctum::actingAs($trainee);

        $response = $this->getJson('/api/v1/trainee/progress')->assertStatus(200);

        $this->assertCount(2, $response->json('data'));
        $this->assertSame($newer->id, $response->json('data.0.id'));
        $this->assertSame($older->id, $response->json('data.1.id'));
        $this->assertSame(2, $response->json('meta.total'));
    }

    public function test_trainee_can_view_update_and_delete_own_record(): void
    {
        $trainee = $this->createTrainee();
        $record = $this->measurement($trainee->id);

        Sanctum::actingAs($trainee);

        $this->getJson("/api/v1/trainee/progress/{$record->id}")
            ->assertStatus(200)
            ->assertJsonPath('data.id', $record->id);

        $this->patchJson("/api/v1/trainee/progress/{$record->id}", ['weight_kg' => 79.5])
            ->assertStatus(200)
            ->assertJsonPath('data.weight_kg', '79.50');
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'body_measurement.updated',
            'entity_id' => $record->id,
        ]);

        $this->deleteJson("/api/v1/trainee/progress/{$record->id}")->assertStatus(204);
        $this->assertDatabaseMissing('body_measurements', ['id' => $record->id]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'body_measurement.deleted']);
    }

    public function test_update_cannot_clear_all_measurement_values(): void
    {
        $trainee = $this->createTrainee();
        $record = $this->measurement($trainee->id, [
            'weight_kg' => 80,
            'body_fat_percentage' => null,
            'waist_cm' => null,
            'chest_cm' => null,
            'arm_cm' => null,
        ]);

        Sanctum::actingAs($trainee);

        $this->patchJson("/api/v1/trainee/progress/{$record->id}", ['weight_kg' => null])
            ->assertStatus(422)
            ->assertJsonValidationErrors('measurements');
    }

    public function test_trainee_cannot_access_another_trainees_record(): void
    {
        $trainee = $this->createTrainee();
        $other = $this->createTrainee();
        $record = $this->measurement($other->id);

        Sanctum::actingAs($trainee);

        $this->getJson("/api/v1/trainee/progress/{$record->id}")->assertStatus(404);
        $this->patchJson("/api/v1/trainee/progress/{$record->id}", ['weight_kg' => 70])->assertStatus(404);
        $this->deleteJson("/api/v1/trainee/progress/{$record->id}")->assertStatus(404);
    }

    public function test_records_preserve_history_for_the_same_date(): void
    {
        $trainee = $this->createTrainee();
        Sanctum::actingAs($trainee);

        $date = now()->toDateString();

        $this->postJson('/api/v1/trainee/progress', ['measured_on' => $date, 'weight_kg' => 80])->assertStatus(201);
        $this->postJson('/api/v1/trainee/progress', ['measured_on' => $date, 'weight_kg' => 81])->assertStatus(201);

        $this->assertDatabaseCount('body_measurements', 2);
    }

    public function test_coach_can_read_assigned_trainee_progress(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->assign($coach->id, $trainee->id);
        $record = $this->measurement($trainee->id);

        Sanctum::actingAs($coach);

        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/progress")
            ->assertStatus(200)
            ->assertJsonPath('data.0.id', $record->id);

        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/progress/{$record->id}")
            ->assertStatus(200)
            ->assertJsonPath('data.id', $record->id);
    }

    public function test_coach_cannot_read_unassigned_or_ended_trainee_progress(): void
    {
        $coach = $this->createCoach();
        $unassigned = $this->createTrainee();
        $ended = $this->createTrainee();
        $record = $this->measurement($unassigned->id);

        CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $ended->id,
            'relationship_type' => 'primary',
            'status' => RelationshipStatus::ENDED,
            'started_at' => now()->subMonth(),
            'responded_at' => now()->subMonth(),
            'ended_at' => now(),
        ]);

        Sanctum::actingAs($coach);

        $this->getJson("/api/v1/coach/trainees/{$unassigned->id}/progress")->assertStatus(403);
        $this->getJson("/api/v1/coach/trainees/{$unassigned->id}/progress/{$record->id}")->assertStatus(403);
        $this->getJson("/api/v1/coach/trainees/{$ended->id}/progress")->assertStatus(403);
    }

    public function test_coach_progress_route_rejects_measurement_from_another_trainee(): void
    {
        $coach = $this->createCoach();
        $assigned = $this->createTrainee();
        $other = $this->createTrainee();
        $this->assign($coach->id, $assigned->id);
        $otherRecord = $this->measurement($other->id);

        Sanctum::actingAs($coach);

        $this->getJson("/api/v1/coach/trainees/{$assigned->id}/progress/{$otherRecord->id}")->assertStatus(404);
    }

    public function test_coach_cannot_mutate_progress(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->assign($coach->id, $trainee->id);
        $record = $this->measurement($trainee->id);

        Sanctum::actingAs($coach);

        $this->postJson("/api/v1/coach/trainees/{$trainee->id}/progress", ['measured_on' => now()->toDateString(), 'weight_kg' => 80])
            ->assertStatus(405);
        $this->patchJson("/api/v1/coach/trainees/{$trainee->id}/progress/{$record->id}", ['weight_kg' => 80])
            ->assertStatus(405);
        $this->deleteJson("/api/v1/coach/trainees/{$trainee->id}/progress/{$record->id}")
            ->assertStatus(405);
    }

    public function test_trainee_cannot_use_coach_progress_routes_and_super_admin_is_denied(): void
    {
        $trainee = $this->createTrainee();
        $record = $this->measurement($trainee->id);

        Sanctum::actingAs($trainee);
        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/progress")->assertStatus(403);

        $admin = $this->createSuperAdmin();
        Sanctum::actingAs($admin);
        $this->getJson('/api/v1/trainee/progress')->assertStatus(403);
        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/progress")->assertStatus(403);
        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/progress/{$record->id}")->assertStatus(403);
    }

    public function test_progress_routes_require_authentication(): void
    {
        $this->getJson('/api/v1/trainee/progress')->assertStatus(401);
        $this->postJson('/api/v1/trainee/progress', ['measured_on' => now()->toDateString(), 'weight_kg' => 80])->assertStatus(401);
        $this->getJson('/api/v1/coach/trainees/1/progress')->assertStatus(401);
    }
}
