<?php

namespace App\Services\Auth;

use App\Models\User;
use Illuminate\Support\Carbon;
use Laravel\Sanctum\NewAccessToken;
use Laravel\Sanctum\PersonalAccessToken;

class TokenService
{
    public function issue(User $user, string $deviceName = 'mobile'): NewAccessToken
    {
        $deviceName = trim($deviceName) === '' ? 'mobile' : trim($deviceName);
        $deviceName = mb_substr($deviceName, 0, 100);
        $expiresAt = null;
        $expirationMinutes = config('sanctum.expiration');

        if (is_numeric($expirationMinutes) && (int) $expirationMinutes > 0) {
            $expiresAt = Carbon::now()->addMinutes((int) $expirationMinutes);
        }

        return $user->createToken($deviceName, ['*'], $expiresAt);
    }

    public function revokeCurrent(User $user): void
    {
        $token = $user->currentAccessToken();
        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }
    }

    public function revokeAll(User $user): void
    {
        $user->tokens()->delete();
    }
}
