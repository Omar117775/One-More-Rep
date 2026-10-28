<?php

namespace Tests\Concerns;

use App\Models\CoachProfile;
use App\Models\Role;
use App\Models\TraineeProfile;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\NewAccessToken;

trait CreatesUsers
{
    public function createUserWithRole(string $roleName, array $attributes = []): User
    {
        $user = User::factory()->create(array_merge([
            'email' => strtolower($attributes['email'] ?? fake()->unique()->safeEmail()),
            'password' => Hash::make('Password123'),
            'is_active' => true,
        ], $attributes));

        $role = Role::firstOrCreate(['name' => $roleName]);
        $user->roles()->syncWithoutDetaching([$role->id]);

        if ($roleName === 'trainee') {
            TraineeProfile::firstOrCreate(['user_id' => $user->id]);
        }

        if ($roleName === 'coach') {
            CoachProfile::firstOrCreate(['user_id' => $user->id], ['display_name' => $user->name, 'is_active' => true]);
        }

        return $user->fresh(['roles', 'coachProfile', 'traineeProfile']);
    }

    public function createSuperAdmin(array $attributes = []): User
    {
        return $this->createUserWithRole('super_admin', $attributes);
    }

    public function createCoach(array $attributes = []): User
    {
        return $this->createUserWithRole('coach', $attributes);
    }

    public function createTrainee(array $attributes = []): User
    {
        return $this->createUserWithRole('trainee', $attributes);
    }

    public function createBearerToken(User $user, string $deviceName = 'test-device'): NewAccessToken
    {
        return $user->createToken($deviceName);
    }

    public function withBearerToken(User $user, string $deviceName = 'test-device')
    {
        $token = $this->createBearerToken($user, $deviceName);

        return $this->withHeaders([
            'Authorization' => 'Bearer '.$token->plainTextToken,
        ]);
    }
}
