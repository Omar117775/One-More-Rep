<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Gate;

class WorkoutProgramResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'coach_id' => $this->coach_id,
            'name' => $this->name,
            'description' => $this->description,
            'is_active' => $this->is_active,
            'days' => $this->when(
                $this->relationLoaded('days') && Gate::allows('view', $this->resource),
                fn () => WorkoutProgramDayResource::collection($this->days),
            ),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
