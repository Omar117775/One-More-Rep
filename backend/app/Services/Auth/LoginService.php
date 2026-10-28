<?php

namespace App\Services\Auth;

use App\Models\User;
use Illuminate\Support\Facades\Hash;

class LoginService
{
    public function attempt(string $email, string $password): ?User
    {
        $email = strtolower(trim($email));
        $user = User::where('email', $email)->first();

        if (! $user || ! Hash::check($password, $user->password)) {
            return null;
        }

        if (! $user->is_active) {
            return null;
        }

        $user->last_login_at = now();
        $user->save();

        return $user->fresh(['roles', 'coachProfile', 'traineeProfile']);
    }
}
