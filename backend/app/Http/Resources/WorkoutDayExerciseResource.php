<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Gate;

class WorkoutDayExerciseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'exercise_id' => $this->exercise_id,
            'sort_order' => $this->sort_order,
            'target_sets' => $this->target_sets,
            'target_reps_min' => $this->target_reps_min,
            'target_reps_max' => $this->target_reps_max,
            'target_weight_kg' => $this->target_weight_kg,
            'rest_seconds' => $this->rest_seconds,
            'exercise' => $this->when(
                $this->relationLoaded('exercise')
                    && $this->exercise !== null
                    && Gate::allows('view', $this->exercise),
                fn () => new ExerciseResource($this->exercise),
            ),
        ];
    }
}
