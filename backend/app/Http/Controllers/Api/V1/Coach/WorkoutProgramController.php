<?php

namespace App\Http\Controllers\Api\V1\Coach;

use App\Http\Controllers\Controller;
use App\Http\Requests\Coach\StoreWorkoutAssignmentRequest;
use App\Http\Requests\Coach\StoreWorkoutProgramRequest;
use App\Http\Requests\Coach\UpdateWorkoutProgramRequest;
use App\Http\Resources\WorkoutAssignmentResource;
use App\Http\Resources\WorkoutProgramResource;
use App\Models\WorkoutProgram;
use App\Services\Training\WorkoutProgramService;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WorkoutProgramController extends Controller
{
    public function __construct(private readonly WorkoutProgramService $programs) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'is_active' => ['sometimes', 'boolean'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $programs = WorkoutProgram::query()
            ->where('coach_id', $request->user()->id)
            ->when(array_key_exists('is_active', $filters), fn ($query) => $query->where('is_active', (bool) $filters['is_active']))
            ->with('days.exercises.exercise')
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return WorkoutProgramResource::collection($programs)->response();
    }

    public function show(Request $request, WorkoutProgram $program): JsonResponse
    {
        $owned = $this->findOwned($request, $program)->load('days.exercises.exercise');

        return (new WorkoutProgramResource($owned))->response();
    }

    public function store(StoreWorkoutProgramRequest $request): JsonResponse
    {
        $program = $this->programs->create($request->user(), $request->validated());

        return (new WorkoutProgramResource($program))->response()->setStatusCode(201);
    }

    public function update(UpdateWorkoutProgramRequest $request, WorkoutProgram $program): JsonResponse
    {
        $owned = $this->findOwned($request, $program);
        $updated = $this->programs->update($request->user(), $owned, $request->validated());

        return (new WorkoutProgramResource($updated))->response();
    }

    public function destroy(Request $request, WorkoutProgram $program): JsonResponse
    {
        $owned = $this->findOwned($request, $program);
        $this->programs->delete($request->user(), $owned);

        return response()->json(null, 204);
    }

    public function assign(StoreWorkoutAssignmentRequest $request, WorkoutProgram $program): JsonResponse
    {
        $owned = $this->findOwned($request, $program);
        $assignment = $this->programs->assign($request->user(), $owned, $request->validated());

        return (new WorkoutAssignmentResource($assignment))->response()->setStatusCode(201);
    }

    private function findOwned(Request $request, WorkoutProgram $program): WorkoutProgram
    {
        return WorkoutProgram::query()
            ->where('coach_id', $request->user()->id)
            ->findOrFail($program->id);
    }
}
