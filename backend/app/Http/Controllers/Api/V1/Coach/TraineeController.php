<?php

namespace App\Http\Controllers\Api\V1\Coach;

use App\Http\Controllers\Controller;
use App\Http\Resources\TraineeSummaryResource;
use App\Models\User;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class TraineeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $coach = $request->user();
        $perPage = PaginationConfig::perPage($request->integer('per_page') ?: null);

        // Tenant isolation: only trainees actively assigned to this coach.
        $trainees = User::query()
            ->select(['id', 'name', 'is_active'])
            ->whereHas('traineeRelationships', function ($query) use ($coach) {
                $query->where('coach_id', $coach->id)
                    ->where('status', 'active')
                    ->whereNull('ended_at');
            })
            ->whereHas('roles', fn ($query) => $query->where('name', 'trainee'))
            ->orderBy('id')
            ->paginate($perPage);

        return TraineeSummaryResource::collection($trainees)->response();
    }

    public function show(User $trainee): JsonResponse
    {
        Gate::authorize('access-trainee', $trainee);

        return (new TraineeSummaryResource($trainee))->response();
    }
}
