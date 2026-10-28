<?php

namespace App\Http\Controllers\Api\V1\Coach;

use App\Enums\Enums\RelationshipStatus;
use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Http\Controllers\Controller;
use App\Http\Resources\WorkoutAssignmentResource;
use App\Models\WorkoutAssignment;
use App\Services\Training\WorkoutProgramService;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class WorkoutAssignmentController extends Controller
{
    public function __construct(private readonly WorkoutProgramService $programs) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'status' => ['sometimes', Rule::enum(WorkoutAssignmentStatus::class)],
            'trainee_id' => ['sometimes', 'integer'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $assignments = WorkoutAssignment::query()
            ->whereHas('program', fn ($query) => $query->where('coach_id', $request->user()->id))
            ->whereHas('trainee.traineeRelationships', fn ($query) => $query
                ->where('coach_id', $request->user()->id)
                ->where('status', RelationshipStatus::ACTIVE)
                ->whereNull('ended_at'))
            ->when(isset($filters['status']), fn ($query) => $query->where('status', $filters['status']))
            ->when(isset($filters['trainee_id']), fn ($query) => $query->where('trainee_id', $filters['trainee_id']))
            ->with('program.days.exercises.exercise')
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return WorkoutAssignmentResource::collection($assignments)->response();
    }

    public function end(Request $request, WorkoutAssignment $assignment): JsonResponse
    {
        $owned = WorkoutAssignment::query()
            ->whereHas('program', fn ($query) => $query->where('coach_id', $request->user()->id))
            ->whereHas('trainee.traineeRelationships', fn ($query) => $query
                ->where('coach_id', $request->user()->id)
                ->where('status', RelationshipStatus::ACTIVE)
                ->whereNull('ended_at'))
            ->findOrFail($assignment->id);

        $ended = $this->programs->end($request->user(), $owned);

        return (new WorkoutAssignmentResource($ended))->response();
    }
}
