<?php

namespace App\Http\Controllers\Api\V1\Trainee;

use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Http\Controllers\Controller;
use App\Http\Resources\WorkoutAssignmentResource;
use App\Models\WorkoutAssignment;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class WorkoutAssignmentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'status' => ['sometimes', Rule::enum(WorkoutAssignmentStatus::class)],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $assignments = WorkoutAssignment::query()
            ->where('trainee_id', $request->user()->id)
            ->when(isset($filters['status']), fn ($query) => $query->where('status', $filters['status']))
            ->with('program.days.exercises.exercise')
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return WorkoutAssignmentResource::collection($assignments)->response();
    }

    public function show(Request $request, WorkoutAssignment $assignment): JsonResponse
    {
        $owned = WorkoutAssignment::query()
            ->where('trainee_id', $request->user()->id)
            ->with('program.days.exercises.exercise')
            ->findOrFail($assignment->id);

        return (new WorkoutAssignmentResource($owned))->response();
    }
}
