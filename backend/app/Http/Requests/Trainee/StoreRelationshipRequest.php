<?php

namespace App\Http\Requests\Trainee;

use Illuminate\Foundation\Http\FormRequest;

class StoreRelationshipRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isTrainee();
    }

    public function rules(): array
    {
        return [
            'coach_id' => ['required', 'integer', 'exists:users,id'],
            'relationship_type' => ['sometimes', 'string', 'in:primary,secondary'],

            // Ownership, lifecycle, and role fields are never client-controlled.
            'trainee_id' => ['prohibited'],
            'user_id' => ['prohibited'],
            'status' => ['prohibited'],
            'started_at' => ['prohibited'],
            'responded_at' => ['prohibited'],
            'ended_at' => ['prohibited'],
            'role' => ['prohibited'],
            'roles' => ['prohibited'],
        ];
    }
}
