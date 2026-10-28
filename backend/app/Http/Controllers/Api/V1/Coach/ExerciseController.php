<?php

namespace App\Http\Controllers\Api\V1\Coach;

use App\Http\Controllers\Controller;
use App\Http\Requests\Coach\StoreExerciseRequest;
use App\Http\Requests\Coach\UpdateExerciseRequest;
use App\Http\Resources\ExerciseResource;
use App\Models\Exercise;
use App\Services\Training\ExerciseService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExerciseController extends Controller
{
    public function __construct(private readonly ExerciseService $exercises) {}

    public function store(StoreExerciseRequest $request): JsonResponse
    {
        $exercise = $this->exercises->create($request->user(), $request->validated());

        return (new ExerciseResource($exercise))->response()->setStatusCode(201);
    }

    public function update(UpdateExerciseRequest $request, Exercise $exercise): JsonResponse
    {
        $owned = $this->findOwned($request, $exercise);
        $updated = $this->exercises->update($request->user(), $owned, $request->validated());

        return (new ExerciseResource($updated))->response();
    }

    public function destroy(Request $request, Exercise $exercise): JsonResponse
    {
        $owned = $this->findOwned($request, $exercise);
        $this->exercises->delete($request->user(), $owned);

        return response()->json(null, 204);
    }

    private function findOwned(Request $request, Exercise $exercise): Exercise
    {
        return Exercise::query()
            ->where('created_by', $request->user()->id)
            ->findOrFail($exercise->id);
    }
}
