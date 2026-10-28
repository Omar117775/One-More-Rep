<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CoachTraineeRelationshipResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'coach_id' => $this->coach_id,
            'trainee_id' => $this->trainee_id,
            'relationship_type' => $this->relationship_type?->value,
            'status' => $this->status?->value,
            'started_at' => $this->started_at,
            'responded_at' => $this->responded_at,
            'ended_at' => $this->ended_at,
            'coach' => $this->whenLoaded('coach', fn () => new RelationshipParticipantResource($this->coach)),
            'trainee' => $this->whenLoaded('trainee', fn () => new RelationshipParticipantResource($this->trainee)),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
