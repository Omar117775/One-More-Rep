<?php

namespace App\Http\Controllers\Api\V1\Coach;

use App\Http\Controllers\Controller;
use App\Http\Resources\WorkoutSessionResource;
use App\Models\User;
use App\Models\WorkoutSession;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class TraineeWorkoutController extends Controller
{
    public function index(Request $request, User $trainee): JsonResponse
    {
        Gate::authorize('access-trainee', $trainee);

        $filters = $request->validate([
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $sessions = WorkoutSession::query()
            ->where('trainee_id', $trainee->id)
            ->with(['sets.exercise', 'assignment.program'])
            ->orderByDesc('started_at')
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return WorkoutSessionResource::collection($sessions)->response();
    }

    public function show(User $trainee, WorkoutSession $session): JsonResponse
    {
        Gate::authorize('access-trainee', $trainee);
        abort_unless($session->trainee_id === $trainee->id, 404);

        $session->load([
            'sets.exercise',
            'assignment.program.days.exercises.exercise',
        ]);

        return (new WorkoutSessionResource($session))->response();
    }
}
