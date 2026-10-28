<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'email_verified_at' => $this->email_verified_at,
            'is_active' => $this->is_active,
            'locale' => $this->locale,
            'timezone' => $this->timezone,
            'last_login_at' => $this->last_login_at,
            'roles' => $this->whenLoaded('roles', fn () => $this->roles->pluck('name')),
            'coach_profile' => $this->whenLoaded('coachProfile', $this->coachProfile),
            'trainee_profile' => $this->whenLoaded('traineeProfile', $this->traineeProfile),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
