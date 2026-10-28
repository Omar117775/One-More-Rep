<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkoutProgramDayResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'day_number' => $this->day_number,
            'name' => $this->name,
            'exercises' => WorkoutDayExerciseResource::collection($this->whenLoaded('exercises')),
        ];
    }
}
