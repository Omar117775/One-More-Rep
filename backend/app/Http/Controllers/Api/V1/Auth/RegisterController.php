<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\AuthTokenResource;
use App\Services\Auth\RegistrationService;
use App\Services\Auth\TokenService;
use Illuminate\Http\JsonResponse;

class RegisterController extends Controller
{
    public function __construct(
        private RegistrationService $registrationService,
        private TokenService $tokenService,
    ) {}

    public function store(RegisterRequest $request): JsonResponse
    {
        $user = $this->registrationService->register($request->validated());
        $user->loadMissing(['roles', 'traineeProfile', 'coachProfile']);
        $token = $this->tokenService->issue($user, $request->input('device_name', 'mobile'));

        $resource = new AuthTokenResource((object) [
            'plainTextToken' => $token->plainTextToken,
            'accessToken' => $token->accessToken,
            'user' => $user,
        ]);

        return response()->json($resource->response()->getData(true), 201);
    }
}
