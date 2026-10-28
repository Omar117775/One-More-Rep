<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Auth\Notifications\VerifyEmail;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\URL;
use Laravel\Sanctum\Sanctum;

class EmailVerificationTest extends FeatureTestCase
{
    private function makeUnverifiedTrainee(array $attrs = []): User
    {
        $user = User::factory()->create(array_merge([
            'email_verified_at' => null,
            'is_active' => true,
        ], $attrs));

        $user->roles()->attach(Role::where('name', 'trainee')->first()->id);

        return $user;
    }

    public function test_verification_notification_requires_auth(): void
    {
        $this->postJson('/api/v1/auth/email/verification-notification')->assertStatus(401);
    }

    public function test_verification_notification_is_sent_to_unverified_user(): void
    {
        Notification::fake();
        $user = $this->makeUnverifiedTrainee(['email' => 'unverified@example.com']);

        Sanctum::actingAs($user);
        $response = $this->postJson('/api/v1/auth/email/verification-notification');

        $response->assertStatus(200);
        Notification::assertSentTo($user, VerifyEmail::class);
    }

    public function test_verification_notification_not_sent_when_already_verified(): void
    {
        Notification::fake();
        $user = $this->makeUnverifiedTrainee();
        $user->forceFill(['email_verified_at' => now()])->save();

        Sanctum::actingAs($user);
        $response = $this->postJson('/api/v1/auth/email/verification-notification');

        $response->assertStatus(200);
        Notification::assertNothingSent();
    }

    public function test_signed_verification_link_verifies_email(): void
    {
        $user = $this->makeUnverifiedTrainee(['email' => 'verify@example.com']);

        $url = URL::temporarySignedRoute(
            'verification.verify',
            now()->addMinutes(60),
            ['id' => $user->id, 'hash' => sha1($user->email)]
        );

        Sanctum::actingAs($user);
        $response = $this->getJson($url);

        $response->assertStatus(200);
        $this->assertNotNull($user->fresh()->email_verified_at);
    }

    public function test_verification_link_with_invalid_signature_is_rejected(): void
    {
        $user = $this->makeUnverifiedTrainee(['email' => 'badsig@example.com']);

        Sanctum::actingAs($user);
        $response = $this->getJson(
            "/api/v1/auth/email/verify/{$user->id}/".sha1($user->email)
        );

        $response->assertStatus(403);
        $this->assertNull($user->fresh()->email_verified_at);
    }

    public function test_verification_link_with_wrong_hash_is_rejected(): void
    {
        $user = $this->makeUnverifiedTrainee(['email' => 'wronghash@example.com']);

        $url = URL::temporarySignedRoute(
            'verification.verify',
            now()->addMinutes(60),
            ['id' => $user->id, 'hash' => sha1('other@example.com')]
        );

        Sanctum::actingAs($user);
        $response = $this->getJson($url);

        $response->assertStatus(403);
        $this->assertNull($user->fresh()->email_verified_at);
    }
}
