<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Laravel\Sanctum\Sanctum;

class RoleEnforcementTest extends FeatureTestCase
{
    private function makeUser(string $role, array $attrs = []): User
    {
        $user = User::factory()->create(array_merge([
            'email_verified_at' => now(),
            'is_active' => true,
        ], $attrs));

        $user->roles()->attach(Role::where('name', $role)->first()->id);

        return $user->fresh(['roles']);
    }

    public function test_inactive_user_is_blocked_and_token_revoked(): void
    {
        $user = $this->makeUser('trainee', ['is_active' => false]);
        $token = $user->createToken('mobile')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer '.$token)->getJson('/api/v1/auth/me');

        $response->assertStatus(403);
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_unverified_coach_cannot_access_verified_coach_routes(): void
    {
        $coach = $this->makeUser('coach', ['email_verified_at' => null]);

        Sanctum::actingAs($coach);

        $this->getJson('/api/v1/coach/trainees')->assertStatus(403);
    }

    public function test_verified_coach_can_access_coach_routes(): void
    {
        $coach = $this->makeUser('coach');

        Sanctum::actingAs($coach);

        $this->getJson('/api/v1/coach/trainees')->assertStatus(200);
    }

    public function test_unverified_super_admin_cannot_access_admin_routes(): void
    {
        $admin = $this->makeUser('super_admin', ['email_verified_at' => null]);

        Sanctum::actingAs($admin);

        $this->getJson('/api/v1/admin/users')->assertStatus(403);
    }

    public function test_trainee_cannot_access_admin_routes(): void
    {
        $trainee = $this->makeUser('trainee');

        Sanctum::actingAs($trainee);

        $this->getJson('/api/v1/admin/users')->assertStatus(403);
        $this->getJson('/api/v1/admin/audit-logs')->assertStatus(403);
    }

    public function test_coach_cannot_access_admin_audit_logs(): void
    {
        $coach = $this->makeUser('coach');

        Sanctum::actingAs($coach);

        $this->getJson('/api/v1/admin/audit-logs')->assertStatus(403);
    }

    public function test_super_admin_is_denied_coach_only_routes(): void
    {
        // Documented policy: coach routes are for the coach role.
        // Super admins operate through the /admin endpoints.
        $admin = $this->makeUser('super_admin');

        Sanctum::actingAs($admin);

        $this->getJson('/api/v1/coach/trainees')->assertStatus(403);
    }

    public function test_user_without_any_role_is_denied_role_scoped_routes(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
            'is_active' => true,
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/coach/trainees')->assertStatus(403);
        $this->getJson('/api/v1/admin/users')->assertStatus(403);
    }

    public function test_trainee_can_access_own_profile_but_not_admin_routes(): void
    {
        $trainee = $this->makeUser('trainee');

        Sanctum::actingAs($trainee);

        $this->getJson('/api/v1/profile')->assertStatus(200);
        $this->getJson('/api/v1/admin/users')->assertStatus(403);
    }
}
