<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AuthTokenResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'token' => $this->plainTextToken ?? null,
            'token_type' => 'Bearer',
            'expires_at' => $this->accessToken->expires_at ?? null,
            'user' => new UserResource($this->user ?? $request->user()),
        ];
    }
}
