<?php

namespace Tests\Feature;

use App\Enums\Enums\RelationshipStatus;
use App\Enums\Enums\RelationshipType;
use App\Models\CoachTraineeRelationship;
use App\Models\Role;
use App\Models\User;
use Laravel\Sanctum\Sanctum;
use Tests\Concerns\CreatesUsers;

class RelationshipRequestTest extends FeatureTestCase
{
    use CreatesUsers;

    private function pending(User $coach, User $trainee, RelationshipType $type = RelationshipType::PRIMARY): CoachTraineeRelationship
    {
        return CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => $type,
            'status' => RelationshipStatus::PENDING,
        ]);
    }

    private function active(User $coach, User $trainee, RelationshipType $type = RelationshipType::PRIMARY): CoachTraineeRelationship
    {
        return CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => $type,
            'status' => RelationshipStatus::ACTIVE,
            'started_at' => now(),
        ]);
    }

    public function test_trainee_can_request_a_coach(): void
    {
        $trainee = $this->createTrainee();
        $coach = $this->createCoach();

        Sanctum::actingAs($trainee);

        $response = $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $coach->id]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'pending')
            ->assertJsonPath('data.relationship_type', 'primary')
            ->assertJsonPath('data.coach_id', $coach->id)
            ->assertJsonPath('data.trainee_id', $trainee->id)
            ->assertJsonPath('data.started_at', null);

        $this->assertDatabaseHas('coach_trainee_relationships', [
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'status' => 'pending',
        ]);

        $this->assertDatabaseHas('audit_logs', [
            'actor_user_id' => $trainee->id,
            'action' => 'coach_relationship.requested',
        ]);
    }

    public function test_trainee_cannot_request_self_even_with_coach_role(): void
    {
        $user = $this->createCoach();
        $user->roles()->attach(Role::where('name', 'trainee')->firstOrCreate(['name' => 'trainee'])->id);

        Sanctum::actingAs($user->fresh(['roles']));

        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $user->id])
            ->assertStatus(422)
            ->assertJsonValidationErrors('coach_id');
    }

    public function test_trainee_cannot_request_a_non_coach_target(): void
    {
        $trainee = $this->createTrainee();
        $otherTrainee = $this->createTrainee();

        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $otherTrainee->id])
            ->assertStatus(422)
            ->assertJsonValidationErrors('coach_id');
    }

    public function test_trainee_cannot_request_inactive_or_unverified_coach(): void
    {
        $trainee = $this->createTrainee();
        $inactive = $this->createCoach(['is_active' => false]);
        $unverified = $this->createCoach(['email_verified_at' => null]);

        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $inactive->id])
            ->assertStatus(422);
        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $unverified->id])
            ->assertStatus(422);
    }

    public function test_duplicate_pending_request_is_rejected(): void
    {
        $trainee = $this->createTrainee();
        $coach = $this->createCoach();
        $this->pending($coach, $trainee);

        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $coach->id])
            ->assertStatus(422)
            ->assertJsonValidationErrors('coach_id');

        $this->assertDatabaseCount('coach_trainee_relationships', 1);
    }

    public function test_request_when_active_pair_exists_is_rejected(): void
    {
        $trainee = $this->createTrainee();
        $coach = $this->createCoach();
        $this->active($coach, $trainee);

        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $coach->id])
            ->assertStatus(422);
    }

    public function test_primary_conflicts_are_rejected_but_secondary_is_allowed(): void
    {
        $trainee = $this->createTrainee();
        $primary = $this->createCoach();
        $secondary = $this->createCoach();
        $this->active($primary, $trainee);

        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $secondary->id])
            ->assertStatus(422)
            ->assertJsonValidationErrors('relationship_type');

        $this->postJson('/api/v1/trainee/relationships', [
            'coach_id' => $secondary->id,
            'relationship_type' => 'secondary',
        ])->assertStatus(201);
    }

    public function test_only_one_pending_primary_request_is_allowed(): void
    {
        $trainee = $this->createTrainee();
        $coachA = $this->createCoach();
        $coachB = $this->createCoach();
        $this->pending($coachA, $trainee);

        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $coachB->id])
            ->assertStatus(422);

        $this->postJson('/api/v1/trainee/relationships', [
            'coach_id' => $coachB->id,
            'relationship_type' => 'secondary',
        ])->assertStatus(201);
    }

    public function test_client_cannot_set_privileged_relationship_fields(): void
    {
        $trainee = $this->createTrainee();
        $coach = $this->createCoach();

        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/relationships', [
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'status' => 'active',
            'started_at' => now()->toDateTimeString(),
            'role' => 'coach',
        ])->assertStatus(422);

        $this->assertDatabaseCount('coach_trainee_relationships', 0);
    }

    public function test_unauthenticated_request_is_rejected(): void
    {
        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => 1])->assertStatus(401);
        $this->getJson('/api/v1/trainee/relationships')->assertStatus(401);
    }

    public function test_coach_and_super_admin_cannot_use_trainee_relationship_routes(): void
    {
        $coach = $this->createCoach();
        $admin = $this->createSuperAdmin();

        Sanctum::actingAs($coach);
        $this->getJson('/api/v1/trainee/relationships')->assertStatus(403);
        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $coach->id])->assertStatus(403);

        Sanctum::actingAs($admin);
        $this->getJson('/api/v1/trainee/relationships')->assertStatus(403);
    }

    public function test_trainee_lists_only_own_relationships(): void
    {
        $trainee = $this->createTrainee();
        $other = $this->createTrainee();
        $coachA = $this->createCoach();
        $coachB = $this->createCoach();
        $this->pending($coachA, $trainee);
        $this->pending($coachB, $other);

        Sanctum::actingAs($trainee);

        $response = $this->getJson('/api/v1/trainee/relationships')->assertStatus(200);
        $data = $response->json('data');

        $this->assertCount(1, $data);
        $this->assertSame($trainee->id, $data[0]['trainee_id']);
        $this->assertArrayNotHasKey('email', $data[0]['coach']);
    }

    public function test_trainee_cannot_view_or_cancel_another_trainee_request(): void
    {
        $trainee = $this->createTrainee();
        $other = $this->createTrainee();
        $coach = $this->createCoach();
        $relationship = $this->pending($coach, $other);

        Sanctum::actingAs($trainee);

        $this->getJson("/api/v1/trainee/relationships/{$relationship->id}")->assertStatus(404);
        $this->postJson("/api/v1/trainee/relationships/{$relationship->id}/cancel")->assertStatus(404);
    }

    public function test_trainee_can_cancel_own_pending_request_once(): void
    {
        $trainee = $this->createTrainee();
        $coach = $this->createCoach();
        $relationship = $this->pending($coach, $trainee);

        Sanctum::actingAs($trainee);

        $this->postJson("/api/v1/trainee/relationships/{$relationship->id}/cancel")
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'cancelled');

        $this->assertDatabaseHas('coach_trainee_relationships', [
            'id' => $relationship->id,
            'status' => 'cancelled',
            'responded_at' => null,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'coach_relationship.cancelled',
            'entity_id' => $relationship->id,
        ]);

        $this->postJson("/api/v1/trainee/relationships/{$relationship->id}/cancel")->assertStatus(422);
    }

    public function test_trainee_cannot_cancel_active_relationship(): void
    {
        $trainee = $this->createTrainee();
        $coach = $this->createCoach();
        $relationship = $this->active($coach, $trainee);

        Sanctum::actingAs($trainee);

        $this->postJson("/api/v1/trainee/relationships/{$relationship->id}/cancel")->assertStatus(422);
    }

    public function test_trainee_can_end_active_relationship_and_request_again(): void
    {
        $trainee = $this->createTrainee();
        $coach = $this->createCoach();
        $relationship = $this->active($coach, $trainee);

        Sanctum::actingAs($trainee);

        $this->postJson("/api/v1/trainee/relationships/{$relationship->id}/end")
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'ended');

        $this->assertNotNull($relationship->fresh()->ended_at);

        $this->postJson("/api/v1/trainee/relationships/{$relationship->id}/end")->assertStatus(422);

        $this->postJson('/api/v1/trainee/relationships', ['coach_id' => $coach->id])->assertStatus(201);
    }

    public function test_trainee_cannot_end_another_trainee_relationship(): void
    {
        $trainee = $this->createTrainee();
        $other = $this->createTrainee();
        $coach = $this->createCoach();
        $relationship = $this->active($coach, $other);

        Sanctum::actingAs($trainee);

        $this->postJson("/api/v1/trainee/relationships/{$relationship->id}/end")->assertStatus(404);
    }

    public function test_coach_directory_hides_inactive_coaches_and_emails(): void
    {
        $trainee = $this->createTrainee();
        $coach = $this->createCoach();
        $inactive = $this->createCoach(['is_active' => false]);
        $unverified = $this->createCoach(['email_verified_at' => null]);

        Sanctum::actingAs($trainee);

        $response = $this->getJson('/api/v1/coaches')->assertStatus(200);
        $ids = array_column($response->json('data'), 'id');

        $this->assertContains($coach->id, $ids);
        $this->assertNotContains($inactive->id, $ids);
        $this->assertNotContains($unverified->id, $ids);
        $this->assertArrayNotHasKey('email', $response->json('data.0'));

        $this->getJson("/api/v1/coaches/{$inactive->id}")->assertStatus(404);
        $this->getJson("/api/v1/coaches/{$unverified->id}")->assertStatus(404);
        $this->getJson("/api/v1/coaches/{$trainee->id}")->assertStatus(404);
    }

    public function test_coach_directory_requires_authentication(): void
    {
        $this->getJson('/api/v1/coaches')->assertStatus(401);
    }
}
