<?php

namespace Tests\Feature;

use App\Enums\Enums\RelationshipStatus;
use App\Enums\Enums\RelationshipType;
use App\Models\CoachTraineeRelationship;
use Laravel\Sanctum\Sanctum;
use Tests\Concerns\CreatesTrainingData;
use Tests\Concerns\CreatesUsers;

class RelationshipApprovalTest extends FeatureTestCase
{
    use CreatesTrainingData;
    use CreatesUsers;

    private function pending(int $coachId, int $traineeId, RelationshipType $type = RelationshipType::PRIMARY): CoachTraineeRelationship
    {
        return CoachTraineeRelationship::create([
            'coach_id' => $coachId,
            'trainee_id' => $traineeId,
            'relationship_type' => $type,
            'status' => RelationshipStatus::PENDING,
        ]);
    }

    private function active(int $coachId, int $traineeId, RelationshipType $type = RelationshipType::PRIMARY): CoachTraineeRelationship
    {
        return CoachTraineeRelationship::create([
            'coach_id' => $coachId,
            'trainee_id' => $traineeId,
            'relationship_type' => $type,
            'status' => RelationshipStatus::ACTIVE,
            'started_at' => now(),
            'responded_at' => now(),
        ]);
    }

    public function test_coach_can_list_and_approve_addressed_request(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->pending($coach->id, $trainee->id);

        Sanctum::actingAs($coach);

        $list = $this->getJson('/api/v1/coach/requests')->assertStatus(200);
        $this->assertCount(1, $list->json('data'));
        $this->assertSame($relationship->id, $list->json('data.0.id'));

        $response = $this->postJson("/api/v1/coach/requests/{$relationship->id}/approve")
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'active');

        $this->assertNotNull($response->json('data.started_at'));
        $this->assertNotNull($response->json('data.responded_at'));

        $this->assertDatabaseHas('coach_trainee_relationships', [
            'id' => $relationship->id,
            'status' => 'active',
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'actor_user_id' => $coach->id,
            'action' => 'coach_relationship.approved',
        ]);
    }

    public function test_coach_cannot_see_or_approve_request_addressed_to_another_coach(): void
    {
        $coach = $this->createCoach();
        $otherCoach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->pending($otherCoach->id, $trainee->id);

        Sanctum::actingAs($coach);

        $this->getJson('/api/v1/coach/requests')->assertStatus(200)->assertJsonCount(0, 'data');
        $this->getJson("/api/v1/coach/requests/{$relationship->id}")->assertStatus(404);
        $this->postJson("/api/v1/coach/requests/{$relationship->id}/approve")->assertStatus(404);
        $this->postJson("/api/v1/coach/requests/{$relationship->id}/reject")->assertStatus(404);
    }

    public function test_trainee_and_super_admin_cannot_review_requests(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->pending($coach->id, $trainee->id);

        Sanctum::actingAs($trainee);
        $this->getJson('/api/v1/coach/requests')->assertStatus(403);
        $this->postJson("/api/v1/coach/requests/{$relationship->id}/approve")->assertStatus(403);

        $admin = $this->createSuperAdmin();
        Sanctum::actingAs($admin);
        $this->getJson('/api/v1/coach/requests')->assertStatus(403);
        $this->postJson("/api/v1/coach/requests/{$relationship->id}/approve")->assertStatus(403);
    }

    public function test_repeated_approval_is_rejected(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->pending($coach->id, $trainee->id);

        Sanctum::actingAs($coach);

        $this->postJson("/api/v1/coach/requests/{$relationship->id}/approve")->assertStatus(200);
        $this->postJson("/api/v1/coach/requests/{$relationship->id}/approve")->assertStatus(422);
    }

    public function test_coach_can_reject_pending_request_once(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->pending($coach->id, $trainee->id);

        Sanctum::actingAs($coach);

        $this->postJson("/api/v1/coach/requests/{$relationship->id}/reject")
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'rejected');

        $this->assertNotNull($relationship->fresh()->responded_at);
        $this->assertNotNull($relationship->fresh()->ended_at);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'coach_relationship.rejected',
            'entity_id' => $relationship->id,
        ]);

        $this->postJson("/api/v1/coach/requests/{$relationship->id}/approve")->assertStatus(422);
        $this->postJson("/api/v1/coach/requests/{$relationship->id}/reject")->assertStatus(422);
    }

    public function test_cannot_reject_an_active_relationship(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->active($coach->id, $trainee->id);

        Sanctum::actingAs($coach);

        $this->postJson("/api/v1/coach/requests/{$relationship->id}/reject")->assertStatus(422);
    }

    public function test_approval_conflicting_with_existing_active_primary_is_rejected(): void
    {
        $coachA = $this->createCoach();
        $coachB = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->active($coachA->id, $trainee->id);
        $pending = $this->pending($coachB->id, $trainee->id);

        Sanctum::actingAs($coachB);

        $this->postJson("/api/v1/coach/requests/{$pending->id}/approve")
            ->assertStatus(422)
            ->assertJsonValidationErrors('status');

        $this->assertDatabaseHas('coach_trainee_relationships', ['id' => $pending->id, 'status' => 'pending']);
    }

    public function test_approval_conflicting_with_existing_active_pair_is_rejected(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->active($coach->id, $trainee->id, RelationshipType::SECONDARY);
        $pending = $this->pending($coach->id, $trainee->id, RelationshipType::PRIMARY);

        Sanctum::actingAs($coach);

        $this->postJson("/api/v1/coach/requests/{$pending->id}/approve")->assertStatus(422);
    }

    public function test_coach_can_end_active_relationship_once(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->active($coach->id, $trainee->id);

        Sanctum::actingAs($coach);

        $this->postJson("/api/v1/coach/relationships/{$relationship->id}/end")
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'ended');

        $this->assertDatabaseHas('audit_logs', [
            'actor_user_id' => $coach->id,
            'action' => 'coach_relationship.ended',
        ]);

        $this->postJson("/api/v1/coach/relationships/{$relationship->id}/end")->assertStatus(422);
    }

    public function test_other_coach_cannot_end_relationship(): void
    {
        $coach = $this->createCoach();
        $otherCoach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->active($coach->id, $trainee->id);

        Sanctum::actingAs($otherCoach);

        $this->postJson("/api/v1/coach/relationships/{$relationship->id}/end")->assertStatus(404);
    }

    public function test_trainee_can_end_active_relationship(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->active($coach->id, $trainee->id);

        Sanctum::actingAs($trainee);

        $this->postJson("/api/v1/trainee/relationships/{$relationship->id}/end")
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'ended');
    }

    public function test_ending_relationship_ends_active_training_assignments_and_revokes_coach_access(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->active($coach->id, $trainee->id);
        $program = $this->makeProgram($coach);
        $assignment = $this->makeAssignment($coach, $trainee, $program);

        Sanctum::actingAs($trainee);

        $this->postJson("/api/v1/trainee/relationships/{$relationship->id}/end")
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'ended');

        $assignment->refresh();

        $this->assertSame('ended', $assignment->status->value);
        $this->assertNotNull($assignment->ends_on);
        $this->assertDatabaseHas('audit_logs', [
            'actor_user_id' => $trainee->id,
            'action' => 'workout_assignment.ended',
            'entity_id' => $assignment->id,
        ]);

        Sanctum::actingAs($coach);

        $this->getJson('/api/v1/coach/assignments')
            ->assertStatus(200)
            ->assertJsonCount(0, 'data');
        $this->postJson("/api/v1/coach/assignments/{$assignment->id}/end")
            ->assertStatus(404);
    }

    public function test_cannot_end_a_pending_request(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $relationship = $this->pending($coach->id, $trainee->id);

        Sanctum::actingAs($coach);

        $this->postJson("/api/v1/coach/relationships/{$relationship->id}/end")->assertStatus(422);
        $this->assertDatabaseHas('coach_trainee_relationships', [
            'id' => $relationship->id,
            'status' => 'pending',
        ]);
    }

    public function test_coach_client_list_is_scoped_and_paginated(): void
    {
        $coach = $this->createCoach();
        $otherCoach = $this->createCoach();
        $assigned = $this->createTrainee();
        $second = $this->createTrainee();
        $notAssigned = $this->createTrainee();

        $this->active($coach->id, $assigned->id);
        $this->active($coach->id, $second->id, RelationshipType::SECONDARY);
        $this->active($otherCoach->id, $notAssigned->id);

        Sanctum::actingAs($coach);

        $response = $this->getJson('/api/v1/coach/trainees?per_page=1')->assertStatus(200);

        $this->assertCount(1, $response->json('data'));
        $this->assertSame(2, $response->json('meta.total'));
        $this->assertSame(2, $response->json('meta.last_page'));
        $this->assertSame(1, $response->json('meta.per_page'));
    }

    public function test_coach_trainee_endpoints_do_not_expose_sensitive_fields(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->active($coach->id, $trainee->id);

        Sanctum::actingAs($coach);

        $item = $this->getJson('/api/v1/coach/trainees')->assertStatus(200)->json('data.0');
        $this->assertSame(['id', 'name', 'is_active'], array_keys($item));
        $this->assertArrayNotHasKey('email', $item);
        $this->assertArrayNotHasKey('roles', $item);
        $this->assertArrayNotHasKey('trainee_profile', $item);
        $this->assertArrayNotHasKey('last_login_at', $item);

        $detail = $this->getJson("/api/v1/coach/trainees/{$trainee->id}")->assertStatus(200)->json('data');
        $this->assertSame(['id', 'name', 'is_active'], array_keys($detail));
        $this->assertArrayNotHasKey('email', $detail);
        $this->assertArrayNotHasKey('roles', $detail);
        $this->assertArrayNotHasKey('trainee_profile', $detail);
        $this->assertArrayNotHasKey('last_login_at', $detail);
    }

    public function test_unauthenticated_coach_routes_are_rejected(): void
    {
        $this->getJson('/api/v1/coach/requests')->assertStatus(401);
        $this->postJson('/api/v1/coach/requests/1/approve')->assertStatus(401);
        $this->getJson('/api/v1/coach/relationships')->assertStatus(401);
    }
}
