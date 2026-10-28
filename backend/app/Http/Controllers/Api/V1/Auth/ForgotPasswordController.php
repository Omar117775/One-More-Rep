<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;

class ForgotPasswordController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $request->validate(['email' => ['required', 'email']]);
        $email = strtolower(trim((string) $request->input('email')));

        // Always return generic response to prevent enumeration
        Password::sendResetLink(['email' => $email]);

        return response()->json(['message' => 'If the account exists, a reset link has been sent.']);
    }
}
