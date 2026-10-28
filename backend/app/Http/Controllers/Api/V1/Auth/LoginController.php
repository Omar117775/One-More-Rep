<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Resources\AuthTokenResource;
use App\Services\Auth\LoginService;
use App\Services\Auth\TokenService;
use Illuminate\Http\JsonResponse;

class LoginController extends Controller
{
    public function __construct(
        private LoginService $loginService,
        private TokenService $tokenService,
    ) {}

    public function store(LoginRequest $request): JsonResponse
    {
        $user = $this->loginService->attempt($request->input('email'), $request->input('password'));

        if (! $user) {
            return response()->json(['message' => 'These credentials do not match our records.'], 422);
        }

        $user->loadMissing(['roles', 'coachProfile', 'traineeProfile']);
        $token = $this->tokenService->issue($user, $request->input('device_name', 'mobile'));

        $resource = new AuthTokenResource((object) [
            'plainTextToken' => $token->plainTextToken,
            'accessToken' => $token->accessToken,
            'user' => $user,
        ]);

        return response()->json($resource->response()->getData(true), 200);
    }
}
