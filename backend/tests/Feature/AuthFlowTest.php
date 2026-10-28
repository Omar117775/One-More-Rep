<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
use Laravel\Sanctum\Sanctum;

class AuthFlowTest extends FeatureTestCase
{
    private function makeTrainee(array $attrs = []): User
    {
        $user = User::factory()->create(array_merge([
            'email_verified_at' => now(),
            'is_active' => true,
        ], $attrs));

        $user->roles()->attach(Role::where('name', 'trainee')->first()->id);

        return $user;
    }

    public function test_register_creates_trainee_with_profile_and_token(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
            'device_name' => 'mobile',
        ]);

        $response->assertStatus(201);
        $data = $response->json();
        $token = $data['token'] ?? ($data['data']['token'] ?? null);
        $this->assertNotEmpty($token);
        $this->assertDatabaseHas('users', ['email' => 'test@example.com']);
        $userId = $data['user']['id'] ?? ($data['data']['user']['id'] ?? null);
        $this->assertNotNull($userId);
        $this->assertDatabaseHas('trainee_profiles', ['user_id' => $userId]);
    }

    public function test_register_assigns_only_trainee_role(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Test User',
            'email' => 'testrole@example.com',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
        ]);

        $response->assertStatus(201);
        $user = User::where('email', 'testrole@example.com')->firstOrFail();
        $user->load('roles');
        $this->assertTrue($user->isTrainee());
        $this->assertFalse($user->isCoach());
        $this->assertFalse($user->isSuperAdmin());
    }

    public function test_register_rejects_role_injection(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Test User',
            'email' => 'test2@example.com',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
            'role' => 'super_admin',
        ]);

        $response->assertStatus(422);
        $this->assertDatabaseMissing('users', ['email' => 'test2@example.com']);
    }

    public function test_register_rejects_duplicate_email_case_insensitive(): void
    {
        User::factory()->create(['email' => 'dupe@example.com']);

        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Dupe',
            'email' => 'DUPE@example.com',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
        ]);

        $response->assertStatus(422);
    }

    public function test_login_returns_token_for_valid_credentials(): void
    {
        $this->makeTrainee([
            'email' => 'login@example.com',
            'password' => Hash::make('Password123!'),
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'login@example.com',
            'password' => 'Password123!',
            'device_name' => 'mobile',
        ]);

        $response->assertStatus(200);
        $data = $response->json();
        $token = $data['token'] ?? ($data['data']['token'] ?? ($data['plainTextToken'] ?? null));
        $this->assertNotEmpty($token);
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_login_rejects_invalid_credentials(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'noone@example.com',
            'password' => 'wrongpass',
        ]);

        $response->assertStatus(422);
    }

    public function test_inactive_user_cannot_login(): void
    {
        $this->makeTrainee([
            'email' => 'inactive@example.com',
            'password' => Hash::make('Password123!'),
            'is_active' => false,
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'inactive@example.com',
            'password' => 'Password123!',
        ]);

        $response->assertStatus(422);
    }

    public function test_me_requires_authentication(): void
    {
        $response = $this->getJson('/api/v1/auth/me');
        $response->assertStatus(401);
    }

    public function test_me_returns_user_when_authenticated(): void
    {
        $user = $this->makeTrainee(['email' => 'me@example.com']);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/auth/me');
        $response->assertStatus(200);
        $email = $response->json('email') ?? ($response->json('data.email') ?? ($response->json('user.email') ?? null));
        $this->assertEquals($user->email, $email);
    }

    public function test_forgot_password_sends_notification(): void
    {
        Notification::fake();
        $user = User::factory()->create(['email' => 'reset@example.com']);

        $response = $this->postJson('/api/v1/auth/forgot-password', ['email' => 'reset@example.com']);
        $response->assertStatus(200);

        Notification::assertSentTo($user, ResetPassword::class);
    }

    public function test_logout_revokes_current_token(): void
    {
        $user = $this->makeTrainee(['email' => 'logout@example.com']);

        $token = $user->createToken('mobile')->plainTextToken;
        $this->assertDatabaseCount('personal_access_tokens', 1);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)->postJson('/api/v1/auth/logout');
        $response->assertStatus(200);

        // Token must be removed from persistence (revocation proven at the data layer).
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_logout_all_revokes_every_token(): void
    {
        $user = $this->makeTrainee(['email' => 'logoutall@example.com']);
        $user->createToken('mobile');
        $user->createToken('tablet');

        $this->assertDatabaseCount('personal_access_tokens', 2);

        Sanctum::actingAs($user);
        $response = $this->postJson('/api/v1/auth/logout-all');
        $response->assertStatus(200);

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}
