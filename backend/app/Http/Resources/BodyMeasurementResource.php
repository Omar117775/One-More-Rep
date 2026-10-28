<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BodyMeasurementResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'trainee_id' => $this->trainee_id,
            'weight_kg' => $this->weight_kg,
            'body_fat_percentage' => $this->body_fat_percentage,
            'waist_cm' => $this->waist_cm,
            'chest_cm' => $this->chest_cm,
            'arm_cm' => $this->arm_cm,
            'measured_on' => $this->measured_on?->toDateString(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
