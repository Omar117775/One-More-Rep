<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function index(): JsonResponse
    {
        $this->authorize('viewAny', User::class);

        $users = User::query()
            ->with('roles')
            ->select(['id', 'name', 'email', 'email_verified_at', 'is_active', 'locale', 'timezone', 'last_login_at', 'created_at', 'updated_at'])
            ->orderBy('id')
            ->get();

        return response()->json(['data' => $users]);
    }
}
