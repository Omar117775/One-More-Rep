<?php

namespace Tests\Feature;

use App\Models\CoachProfile;
use App\Models\Role;
use App\Models\TraineeProfile;
use App\Models\User;
use Laravel\Sanctum\Sanctum;

class ProfileTest extends FeatureTestCase
{
    private function makeUser(string $role, array $attrs = []): User
    {
        $user = User::factory()->create(array_merge([
            'email_verified_at' => now(),
            'is_active' => true,
        ], $attrs));

        $user->roles()->attach(Role::where('name', $role)->first()->id);

        if ($role === 'trainee') {
            TraineeProfile::firstOrCreate(['user_id' => $user->id]);
        }

        if ($role === 'coach') {
            CoachProfile::firstOrCreate(['user_id' => $user->id]);
        }

        return $user->fresh(['roles']);
    }

    public function test_profile_requires_authentication(): void
    {
        $this->getJson('/api/v1/profile')->assertStatus(401);
        $this->patchJson('/api/v1/profile', ['name' => 'X'])->assertStatus(401);
    }

    public function test_trainee_can_view_own_profile(): void
    {
        $trainee = $this->makeUser('trainee', ['email' => 'trainee@example.com']);
        Sanctum::actingAs($trainee);

        $response = $this->getJson('/api/v1/profile');
        $response->assertStatus(200);
        $this->assertSame('trainee@example.com', $response->json('data.email'));
        $this->assertContains('trainee', $response->json('data.roles'));
    }

    public function test_trainee_can_update_base_and_trainee_fields(): void
    {
        $trainee = $this->makeUser('trainee');
        Sanctum::actingAs($trainee);

        $response = $this->patchJson('/api/v1/profile', [
            'name' => 'Updated Name',
            'locale' => 'ar',
            'date_of_birth' => '1995-05-10',
            'sex' => 'male',
            'height_cm' => 180.5,
            'initial_weight_kg' => 82.5,
        ]);

        $response->assertStatus(200);
        $this->assertSame('Updated Name', $response->json('data.name'));
        $this->assertSame('ar', $response->json('data.locale'));

        $this->assertDatabaseHas('users', ['id' => $trainee->id, 'name' => 'Updated Name', 'locale' => 'ar']);
        $this->assertDatabaseHas('trainee_profiles', ['user_id' => $trainee->id, 'sex' => 'male']);
    }

    public function test_coach_can_update_coach_fields(): void
    {
        $coach = $this->makeUser('coach');
        Sanctum::actingAs($coach);

        $response = $this->patchJson('/api/v1/profile', [
            'display_name' => 'Coach Rex',
            'bio' => 'Strength coach',
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('coach_profiles', ['user_id' => $coach->id, 'display_name' => 'Coach Rex']);
    }

    public function test_trainee_cannot_set_coach_only_fields(): void
    {
        $trainee = $this->makeUser('trainee');
        Sanctum::actingAs($trainee);

        // Coach-only fields submitted by a trainee are ignored by role-scoped update logic.
        $response = $this->patchJson('/api/v1/profile', [
            'display_name' => 'Impostor Coach',
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('coach_profiles', ['user_id' => $trainee->id]);
    }

    public function test_coach_cannot_set_trainee_only_fields(): void
    {
        $coach = $this->makeUser('coach');
        Sanctum::actingAs($coach);

        $response = $this->patchJson('/api/v1/profile', [
            'height_cm' => 170,
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseMissing('trainee_profiles', ['user_id' => $coach->id]);
    }

    public function test_profile_update_rejects_privilege_escalation_fields(): void
    {
        $trainee = $this->makeUser('trainee');
        Sanctum::actingAs($trainee);

        foreach ([
            ['role' => 'super_admin'],
            ['roles' => ['super_admin']],
            ['is_active' => false],
            ['is_super_admin' => true],
            ['email_verified_at' => now()->toDateTimeString()],
            ['email' => 'attacker@example.com'],
            ['user_id' => 999],
        ] as $payload) {
            $this->patchJson('/api/v1/profile', $payload)->assertStatus(422);
        }

        $trainee->refresh()->load('roles');
        $this->assertTrue($trainee->isTrainee());
        $this->assertFalse($trainee->isSuperAdmin());
        $this->assertTrue($trainee->is_active);
    }

    public function test_profile_update_validates_input(): void
    {
        $trainee = $this->makeUser('trainee');
        Sanctum::actingAs($trainee);

        $this->patchJson('/api/v1/profile', ['locale' => 'fr'])->assertStatus(422);
        $this->patchJson('/api/v1/profile', ['height_cm' => 999])->assertStatus(422);
        $this->patchJson('/api/v1/profile', ['date_of_birth' => now()->addDay()->toDateString()])->assertStatus(422);
    }

    public function test_super_admin_can_view_own_profile(): void
    {
        $admin = $this->makeUser('super_admin');
        Sanctum::actingAs($admin);

        $response = $this->getJson('/api/v1/profile');
        $response->assertStatus(200);
        $this->assertContains('super_admin', $response->json('data.roles'));
    }
}
