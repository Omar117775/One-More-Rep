<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Services\Auth\TokenService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LogoutAllController extends Controller
{
    public function __construct(private TokenService $tokenService) {}

    public function store(Request $request): JsonResponse
    {
        $this->tokenService->revokeAll($request->user());

        return response()->json(['message' => 'Logged out from all devices.'], 200);
    }
}
