<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Gate;

class WorkoutAssignmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'workout_program_id' => $this->workout_program_id,
            'trainee_id' => $this->trainee_id,
            'assigned_by' => $this->assigned_by,
            'starts_on' => $this->starts_on?->toDateString(),
            'ends_on' => $this->ends_on?->toDateString(),
            'status' => $this->status?->value,
            'program' => $this->when(
                $this->relationLoaded('program')
                    && $this->program !== null
                    && Gate::allows('view', $this->program),
                fn () => new WorkoutProgramResource($this->program),
            ),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
