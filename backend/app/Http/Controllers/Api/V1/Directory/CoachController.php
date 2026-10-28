<?php

namespace App\Http\Controllers\Api\V1\Directory;

use App\Http\Controllers\Controller;
use App\Http\Resources\CoachSummaryResource;
use App\Models\User;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CoachController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $perPage = PaginationConfig::perPage($request->integer('per_page') ?: null);

        $coaches = User::query()
            ->select(['id', 'name', 'is_active'])
            ->where('is_active', true)
            ->whereNotNull('email_verified_at')
            ->whereHas('roles', fn ($query) => $query->where('name', 'coach'))
            ->with('coachProfile')
            ->orderBy('name')
            ->paginate($perPage);

        return CoachSummaryResource::collection($coaches)->response();
    }

    public function show(User $coach): JsonResponse
    {
        abort_unless($coach->is_active && $coach->isCoach() && $coach->email_verified_at !== null, 404);

        $coach->loadMissing('coachProfile');

        return (new CoachSummaryResource($coach))->response();
    }
}
