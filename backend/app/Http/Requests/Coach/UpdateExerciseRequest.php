<?php

namespace App\Http\Requests\Coach;

use App\Enums\Enums\ExerciseEquipment;
use App\Enums\Enums\ExerciseMuscleGroup;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class UpdateExerciseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isCoach();
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'min:2', 'max:120'],
            'muscle_group' => ['sometimes', Rule::enum(ExerciseMuscleGroup::class)],
            'equipment' => ['sometimes', 'nullable', Rule::enum(ExerciseEquipment::class)],
            'instructions' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'is_public' => ['sometimes', 'boolean'],

            'created_by' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            $editable = ['name', 'muscle_group', 'equipment', 'instructions', 'is_public'];

            if (array_intersect($editable, array_keys($this->all())) === []) {
                $validator->errors()->add('exercise', 'At least one editable field is required.');
            }
        });
    }
}
