<?php

namespace App\Http\Requests\Coach;

use Illuminate\Foundation\Http\FormRequest;

class StoreWorkoutAssignmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isCoach();
    }

    public function rules(): array
    {
        return [
            'trainee_id' => ['required', 'integer', 'exists:users,id'],
            'starts_on' => ['required', 'date_format:Y-m-d'],
            'ends_on' => ['nullable', 'date_format:Y-m-d', 'after_or_equal:starts_on'],

            'workout_program_id' => ['prohibited'],
            'assigned_by' => ['prohibited'],
            'status' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }
}
