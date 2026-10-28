<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CoachSummaryResource extends JsonResource
{
    /**
     * Non-sensitive coach directory representation (never exposes email).
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'display_name' => $this->whenLoaded('coachProfile', fn () => $this->coachProfile?->display_name),
            'bio' => $this->whenLoaded('coachProfile', fn () => $this->coachProfile?->bio),
            'is_active' => $this->is_active,
        ];
    }
}
