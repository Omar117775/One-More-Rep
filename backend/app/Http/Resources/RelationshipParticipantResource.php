<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RelationshipParticipantResource extends JsonResource
{
    /**
     * Minimal participant representation. Email and health data are excluded.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'display_name' => $this->whenLoaded('coachProfile', fn () => $this->coachProfile?->display_name),
            'is_active' => $this->is_active,
        ];
    }
}
