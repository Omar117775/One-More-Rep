<?php

namespace App\Http\Requests\Trainee;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class StoreBodyMeasurementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isTrainee();
    }

    public function rules(): array
    {
        return [
            'measured_on' => ['required', 'date', 'before_or_equal:today'],
            'weight_kg' => ['nullable', 'numeric', 'min:20', 'max:500'],
            'body_fat_percentage' => ['nullable', 'numeric', 'min:0', 'max:100'],
            'waist_cm' => ['nullable', 'numeric', 'min:20', 'max:300'],
            'chest_cm' => ['nullable', 'numeric', 'min:20', 'max:300'],
            'arm_cm' => ['nullable', 'numeric', 'min:5', 'max:150'],

            // Progress records always belong to the authenticated trainee.
            'trainee_id' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            $fields = ['weight_kg', 'body_fat_percentage', 'waist_cm', 'chest_cm', 'arm_cm'];

            foreach ($fields as $field) {
                if ($this->filled($field)) {
                    return;
                }
            }

            $validator->errors()->add('measurements', 'At least one measurement value is required.');
        });
    }
}
