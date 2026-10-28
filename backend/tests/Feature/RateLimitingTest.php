<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class RateLimitingTest extends FeatureTestCase
{
    public function test_login_is_rate_limited_after_repeated_failures(): void
    {
        $user = User::factory()->create([
            'email' => 'ratelimit@example.com',
            'password' => Hash::make('Password123!'),
            'email_verified_at' => now(),
            'is_active' => true,
        ]);
        $user->roles()->attach(Role::where('name', 'trainee')->first()->id);

        $lastStatus = null;
        for ($i = 0; $i < 6; $i++) {
            $response = $this->postJson('/api/v1/auth/login', [
                'email' => 'ratelimit@example.com',
                'password' => 'wrong-password',
            ]);
            $lastStatus = $response->status();
        }

        $this->assertSame(429, $lastStatus, 'Expected login throttle to return 429 after repeated attempts.');
    }

    public function test_register_is_rate_limited_per_ip(): void
    {
        $lastStatus = null;
        for ($i = 0; $i < 6; $i++) {
            $response = $this->postJson('/api/v1/auth/register', [
                'name' => 'Spammer '.$i,
                'email' => "spam{$i}@example.com",
                'password' => 'Password123!',
                'password_confirmation' => 'Password123!',
            ]);
            $lastStatus = $response->status();
        }

        $this->assertSame(429, $lastStatus, 'Expected register throttle to return 429 after repeated attempts.');
    }

    public function test_health_endpoint_is_reachable(): void
    {
        $this->getJson('/api/v1/health')->assertStatus(200)->assertJson(['status' => 'ok']);
    }
}
