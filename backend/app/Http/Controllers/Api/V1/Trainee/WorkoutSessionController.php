<?php

namespace App\Http\Controllers\Api\V1\Trainee;

use App\Http\Controllers\Controller;
use App\Http\Requests\Trainee\StoreWorkoutSessionRequest;
use App\Http\Requests\Trainee\UpdateWorkoutSessionRequest;
use App\Http\Resources\WorkoutSessionResource;
use App\Models\WorkoutSession;
use App\Services\Training\WorkoutSessionService;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WorkoutSessionController extends Controller
{
    public function __construct(private readonly WorkoutSessionService $sessions) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'workout_assignment_id' => ['sometimes', 'integer'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $sessions = WorkoutSession::query()
            ->where('trainee_id', $request->user()->id)
            ->when(isset($filters['workout_assignment_id']), fn ($query) => $query->where('workout_assignment_id', $filters['workout_assignment_id']))
            ->with(['sets.exercise', 'assignment.program'])
            ->orderByDesc('started_at')
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return WorkoutSessionResource::collection($sessions)->response();
    }

    public function store(StoreWorkoutSessionRequest $request): JsonResponse
    {
        $session = $this->sessions->create($request->user(), $request->validated());

        return (new WorkoutSessionResource($session))->response()->setStatusCode(201);
    }

    public function show(Request $request, WorkoutSession $session): JsonResponse
    {
        $owned = $this->findOwned($request, $session)->load([
            'sets.exercise',
            'assignment.program.days.exercises.exercise',
        ]);

        return (new WorkoutSessionResource($owned))->response();
    }

    public function update(UpdateWorkoutSessionRequest $request, WorkoutSession $session): JsonResponse
    {
        $owned = $this->findOwned($request, $session);
        $updated = $this->sessions->update($request->user(), $owned, $request->validated());

        return (new WorkoutSessionResource($updated))->response();
    }

    public function destroy(Request $request, WorkoutSession $session): JsonResponse
    {
        $owned = $this->findOwned($request, $session);
        $this->sessions->delete($request->user(), $owned);

        return response()->json(null, 204);
    }

    private function findOwned(Request $request, WorkoutSession $session): WorkoutSession
    {
        return WorkoutSession::query()
            ->where('trainee_id', $request->user()->id)
            ->findOrFail($session->id);
    }
}
