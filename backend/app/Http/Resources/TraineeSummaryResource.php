<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TraineeSummaryResource extends JsonResource
{
    /**
     * Minimal coach-facing trainee representation.
     * Email, roles, login metadata, and health profiles are excluded.
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'is_active' => $this->is_active,
        ];
    }
}
