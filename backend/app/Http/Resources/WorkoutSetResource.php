<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Gate;

class WorkoutSetResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'exercise_id' => $this->exercise_id,
            'set_number' => $this->set_number,
            'weight_kg' => $this->weight_kg,
            'reps' => $this->reps,
            'is_completed' => $this->is_completed,
            'exercise' => $this->when(
                $this->relationLoaded('exercise')
                    && $this->exercise !== null
                    && Gate::allows('view', $this->exercise),
                fn () => new ExerciseResource($this->exercise),
            ),
        ];
    }
}
