<?php

namespace Tests\Feature;

use App\Enums\RoleName;
use App\Models\Role;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;

class AuthorizationTenantIsolationTest extends FeatureTestCase
{
    private function createUserWithRole(RoleName $role, array $attrs = []): User
    {
        $user = User::factory()->create(array_merge([
            'email_verified_at' => now(),
            'is_active' => true,
        ], $attrs));

        $user->roles()->attach(Role::where('name', $role->value)->first()->id);

        return $user->fresh(['roles']);
    }

    public function test_coach_can_list_only_assigned_trainees(): void
    {
        $coach = $this->createUserWithRole(RoleName::COACH);
        $trainee1 = $this->createUserWithRole(RoleName::TRAINEE);
        $trainee2 = $this->createUserWithRole(RoleName::TRAINEE);

        DB::table('coach_trainee_relationships')->insert([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee1->id,
            'relationship_type' => 'primary',
            'status' => 'active',
            'started_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs($coach);

        $response = $this->getJson('/api/v1/coach/trainees');
        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals($trainee1->id, $data[0]['id']);
    }

    public function test_coach_cannot_access_unassigned_trainee(): void
    {
        $coach = $this->createUserWithRole(RoleName::COACH);
        $trainee = $this->createUserWithRole(RoleName::TRAINEE);

        Sanctum::actingAs($coach);

        $response = $this->getJson("/api/v1/coach/trainees/{$trainee->id}");
        $response->assertStatus(403);
    }

    public function test_coach_cannot_access_another_coach_trainee(): void
    {
        $coach1 = $this->createUserWithRole(RoleName::COACH);
        $coach2 = $this->createUserWithRole(RoleName::COACH);
        $trainee = $this->createUserWithRole(RoleName::TRAINEE);

        DB::table('coach_trainee_relationships')->insert([
            'coach_id' => $coach1->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'active',
            'started_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs($coach2);

        $response = $this->getJson("/api/v1/coach/trainees/{$trainee->id}");
        $response->assertStatus(403);
    }

    public function test_coach_can_access_assigned_trainee(): void
    {
        $coach = $this->createUserWithRole(RoleName::COACH);
        $trainee = $this->createUserWithRole(RoleName::TRAINEE);

        DB::table('coach_trainee_relationships')->insert([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'active',
            'started_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs($coach);

        $response = $this->getJson("/api/v1/coach/trainees/{$trainee->id}");
        $response->assertStatus(200);
        $this->assertEquals($trainee->id, $response->json('data.id'));
    }

    public function test_trainee_cannot_access_coach_routes(): void
    {
        $trainee = $this->createUserWithRole(RoleName::TRAINEE);
        Sanctum::actingAs($trainee);

        $response = $this->getJson('/api/v1/coach/trainees');
        $response->assertStatus(403);
    }

    public function test_super_admin_can_list_users(): void
    {
        $admin = $this->createUserWithRole(RoleName::SUPER_ADMIN);
        $this->createUserWithRole(RoleName::TRAINEE);
        Sanctum::actingAs($admin);

        $response = $this->getJson('/api/v1/admin/users');
        $response->assertStatus(200);
        $this->assertGreaterThanOrEqual(2, count($response->json('data')));
    }

    public function test_coach_cannot_access_admin_users(): void
    {
        $coach = $this->createUserWithRole(RoleName::COACH);
        Sanctum::actingAs($coach);

        $response = $this->getJson('/api/v1/admin/users');
        $response->assertStatus(403);
    }

    public function test_unauthenticated_cannot_access_protected_routes(): void
    {
        $response = $this->getJson('/api/v1/coach/trainees');
        $response->assertStatus(401);
    }

    public function test_coach_cannot_access_non_trainee_through_trainee_route(): void
    {
        $coach = $this->createUserWithRole(RoleName::COACH);
        $otherCoach = $this->createUserWithRole(RoleName::COACH);

        // Even with a relationship row present, the target is not a trainee.
        DB::table('coach_trainee_relationships')->insert([
            'coach_id' => $coach->id,
            'trainee_id' => $otherCoach->id,
            'relationship_type' => 'primary',
            'status' => 'active',
            'started_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs($coach);

        $this->getJson("/api/v1/coach/trainees/{$otherCoach->id}")->assertStatus(403);
    }

    public function test_coach_list_excludes_non_trainee_relationships(): void
    {
        $coach = $this->createUserWithRole(RoleName::COACH);
        $trainee = $this->createUserWithRole(RoleName::TRAINEE);
        $otherCoach = $this->createUserWithRole(RoleName::COACH);

        foreach ([$trainee->id, $otherCoach->id] as $targetId) {
            DB::table('coach_trainee_relationships')->insert([
                'coach_id' => $coach->id,
                'trainee_id' => $targetId,
                'relationship_type' => 'primary',
                'status' => 'active',
                'started_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        Sanctum::actingAs($coach);

        $data = $this->getJson('/api/v1/coach/trainees')->assertStatus(200)->json('data');
        $this->assertCount(1, $data);
        $this->assertSame($trainee->id, $data[0]['id']);
    }

    public function test_inactive_trainee_is_not_accessible_by_coach(): void
    {
        $coach = $this->createUserWithRole(RoleName::COACH);
        $trainee = $this->createUserWithRole(RoleName::TRAINEE, ['is_active' => false]);

        DB::table('coach_trainee_relationships')->insert([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'active',
            'started_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        Sanctum::actingAs($coach);

        $this->getJson("/api/v1/coach/trainees/{$trainee->id}")->assertStatus(403);
    }
}
