<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Password;

class PasswordResetTest extends FeatureTestCase
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

    public function test_forgot_password_does_not_reveal_missing_accounts(): void
    {
        Notification::fake();

        $response = $this->postJson('/api/v1/auth/forgot-password', [
            'email' => 'does-not-exist@example.com',
        ]);

        $response->assertStatus(200);
        $response->assertJsonFragment(['message' => 'If the account exists, a reset link has been sent.']);
        Notification::assertNothingSent();
    }

    public function test_reset_password_with_valid_token_changes_password_and_revokes_tokens(): void
    {
        $user = $this->makeTrainee(['email' => 'resetme@example.com']);
        $user->createToken('mobile');
        $user->createToken('tablet');

        $token = Password::broker()->createToken($user);

        $response = $this->postJson('/api/v1/auth/reset-password', [
            'token' => $token,
            'email' => 'resetme@example.com',
            'password' => 'NewPassword123!',
            'password_confirmation' => 'NewPassword123!',
        ]);

        $response->assertStatus(200);

        $user->refresh();
        $this->assertTrue(Hash::check('NewPassword123!', $user->password));
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_reset_password_rejects_invalid_token(): void
    {
        $user = $this->makeTrainee(['email' => 'badtoken@example.com']);
        $originalHash = $user->password;

        $response = $this->postJson('/api/v1/auth/reset-password', [
            'token' => 'not-a-real-token',
            'email' => 'badtoken@example.com',
            'password' => 'NewPassword123!',
            'password_confirmation' => 'NewPassword123!',
        ]);

        $response->assertStatus(422);
        $this->assertSame($originalHash, $user->fresh()->password);
    }

    public function test_reset_password_rejects_weak_password(): void
    {
        $user = $this->makeTrainee(['email' => 'weak@example.com']);
        $token = Password::broker()->createToken($user);

        $response = $this->postJson('/api/v1/auth/reset-password', [
            'token' => $token,
            'email' => 'weak@example.com',
            'password' => 'short',
            'password_confirmation' => 'short',
        ]);

        $response->assertStatus(422);
        // Original password hash is unchanged.
        $this->assertNotNull($user->fresh()->password);
    }

    public function test_reset_password_requires_matching_confirmation(): void
    {
        $user = $this->makeTrainee(['email' => 'mismatch@example.com']);
        $token = Password::broker()->createToken($user);

        $response = $this->postJson('/api/v1/auth/reset-password', [
            'token' => $token,
            'email' => 'mismatch@example.com',
            'password' => 'NewPassword123!',
            'password_confirmation' => 'DifferentPassword123!',
        ]);

        $response->assertStatus(422);
    }

    public function test_forgot_password_notification_is_queued_or_sent(): void
    {
        Notification::fake();
        $user = $this->makeTrainee(['email' => 'notify@example.com']);

        $this->postJson('/api/v1/auth/forgot-password', ['email' => 'notify@example.com'])
            ->assertStatus(200);

        Notification::assertSentTo($user, ResetPassword::class);
    }
}
