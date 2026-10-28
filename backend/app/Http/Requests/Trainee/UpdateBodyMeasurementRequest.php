<?php

namespace App\Http\Requests\Trainee;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class UpdateBodyMeasurementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isTrainee();
    }

    public function rules(): array
    {
        return [
            'measured_on' => ['sometimes', 'date', 'before_or_equal:today'],
            'weight_kg' => ['sometimes', 'nullable', 'numeric', 'min:20', 'max:500'],
            'body_fat_percentage' => ['sometimes', 'nullable', 'numeric', 'min:0', 'max:100'],
            'waist_cm' => ['sometimes', 'nullable', 'numeric', 'min:20', 'max:300'],
            'chest_cm' => ['sometimes', 'nullable', 'numeric', 'min:20', 'max:300'],
            'arm_cm' => ['sometimes', 'nullable', 'numeric', 'min:5', 'max:150'],

            'trainee_id' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            $editable = ['measured_on', 'weight_kg', 'body_fat_percentage', 'waist_cm', 'chest_cm', 'arm_cm'];

            if (array_intersect($editable, array_keys($this->all())) === []) {
                $validator->errors()->add('measurements', 'At least one editable field is required.');
            }
        });
    }
}
