<?php

namespace App\Http\Requests\Trainee;

use App\Enums\Enums\CardioActivityType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCardioSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isTrainee();
    }

    public function rules(): array
    {
        return [
            'activity_type' => ['required', Rule::enum(CardioActivityType::class)],
            'duration_seconds' => ['required', 'integer', 'between:1,86400'],
            'distance_km' => ['nullable', 'numeric', 'between:0,1000'],
            'average_heart_rate' => ['nullable', 'integer', 'between:30,250'],
            'performed_at' => ['required', 'date', 'before_or_equal:now'],

            'trainee_id' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }
}
