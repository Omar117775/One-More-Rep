<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Gate;

class WorkoutSessionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'workout_assignment_id' => $this->workout_assignment_id,
            'trainee_id' => $this->trainee_id,
            'started_at' => $this->started_at?->toIso8601String(),
            'completed_at' => $this->completed_at?->toIso8601String(),
            'notes' => $this->notes,
            'sets' => WorkoutSetResource::collection($this->whenLoaded('sets')),
            'assignment' => $this->when(
                $this->relationLoaded('assignment')
                    && $this->assignment !== null
                    && Gate::allows('view', $this->assignment),
                fn () => new WorkoutAssignmentResource($this->assignment),
            ),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
