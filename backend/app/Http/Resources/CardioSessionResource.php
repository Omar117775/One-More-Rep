<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CardioSessionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'trainee_id' => $this->trainee_id,
            'activity_type' => $this->activity_type?->value,
            'duration_seconds' => $this->duration_seconds,
            'distance_km' => $this->distance_km,
            'average_heart_rate' => $this->average_heart_rate,
            'performed_at' => $this->performed_at?->toIso8601String(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
