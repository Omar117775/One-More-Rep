<?php

namespace App\Http\Controllers\Api\V1\Directory;

use App\Enums\Enums\ExerciseEquipment;
use App\Enums\Enums\ExerciseMuscleGroup;
use App\Http\Controllers\Controller;
use App\Http\Resources\ExerciseResource;
use App\Models\Exercise;
use App\Services\Training\ExerciseService;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;

class ExerciseController extends Controller
{
    public function __construct(private readonly ExerciseService $exercises) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'search' => ['sometimes', 'nullable', 'string', 'max:80'],
            'muscle_group' => ['sometimes', Rule::enum(ExerciseMuscleGroup::class)],
            'equipment' => ['sometimes', Rule::enum(ExerciseEquipment::class)],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $query = $this->exercises->visibleTo($request->user())
            ->when(isset($filters['search']) && $filters['search'] !== '', function ($query) use ($filters) {
                $query->whereRaw('LOWER(name) LIKE ?', ['%'.mb_strtolower($filters['search']).'%']);
            })
            ->when(isset($filters['muscle_group']), fn ($query) => $query->where('muscle_group', $filters['muscle_group']))
            ->when(isset($filters['equipment']), fn ($query) => $query->where('equipment', $filters['equipment']))
            ->orderBy('name')
            ->orderBy('id');

        $exercises = $query->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return ExerciseResource::collection($exercises)->response();
    }

    public function show(Request $request, Exercise $exercise): JsonResponse
    {
        Gate::authorize('view', $exercise);

        return (new ExerciseResource($exercise))->response();
    }
}
