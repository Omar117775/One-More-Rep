<?php

namespace App\Http\Requests\Trainee;

use App\Enums\Enums\CardioActivityType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class UpdateCardioSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isTrainee();
    }

    public function rules(): array
    {
        return [
            'activity_type' => ['sometimes', Rule::enum(CardioActivityType::class)],
            'duration_seconds' => ['sometimes', 'integer', 'between:1,86400'],
            'distance_km' => ['sometimes', 'nullable', 'numeric', 'between:0,1000'],
            'average_heart_rate' => ['sometimes', 'nullable', 'integer', 'between:30,250'],
            'performed_at' => ['sometimes', 'date', 'before_or_equal:now'],

            'trainee_id' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            $editable = ['activity_type', 'duration_seconds', 'distance_km', 'average_heart_rate', 'performed_at'];

            if (array_intersect($editable, array_keys($this->all())) === []) {
                $validator->errors()->add('cardio', 'At least one editable field is required.');
            }
        });
    }
}
