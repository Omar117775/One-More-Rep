<?php

namespace App\Services\Auth;

use App\Models\Role;
use App\Models\TraineeProfile;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class RegistrationService
{
    public function register(array $data): User
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => strtolower(trim($data['email'])),
                'password' => Hash::make($data['password']),
                'locale' => $data['locale'] ?? 'en',
                'timezone' => $data['timezone'] ?? 'UTC',
                'is_active' => true,
            ]);

            $role = Role::firstOrCreate(['name' => 'trainee']);
            $user->roles()->syncWithoutDetaching([$role->id]);

            TraineeProfile::firstOrCreate(['user_id' => $user->id]);

            return $user->fresh(['roles', 'traineeProfile', 'coachProfile']);
        });
    }
}
